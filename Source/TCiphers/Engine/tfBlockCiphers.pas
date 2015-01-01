{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfBlockCiphers;

interface

{$I TFL.inc}

uses
  tfTypes;

type
  PBlockCipher = ^TBlockCipher;
  TBlockCipher = record
  private type
    TBlock = array[0..255] of Byte;   // up to 256 * 8 = 2048 bit blocks
  private
    FVTable: Pointer;
    FRefCount: Integer;

    FValidKey: LongBool;

    FDir:     LongWord;
    FMode:    LongWord;
    FPadding: LongWord;

    FIVector: TBlock;     // var len


    function SetIV(Data: Pointer; DataLen: LongWord): TF_RESULT;
    function SetDir(Data: LongWord): TF_RESULT;
    function SetMode(Data: LongWord): TF_RESULT;
    function SetPadding(Data: LongWord): TF_RESULT;
    function SetFlags(Data: LongWord): TF_RESULT;

    function EncryptECB(Data: PByte; var DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): TF_RESULT;
    function EncryptCBC(Data: PByte; var DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): TF_RESULT;
    function EncryptCTR(Data: PByte; var DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): TF_RESULT;
    function DecryptECB(Data: PByte; var DataSize: LongWord;
             Last: Boolean): TF_RESULT;
    function DecryptCBC(Data: PByte; var DataSize: LongWord;
             Last: Boolean): TF_RESULT;
    function DecryptCTR(Data: PByte; var DataSize: LongWord;
             Last: Boolean): TF_RESULT;
  public
    class function SetKeyParam(Inst: Pointer; Param: LongWord; Data: Pointer;
      DataLen: LongWord): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Encrypt(Inst: Pointer; Data: PByte; var DataSize: LongWord;
      BufSize: LongWord; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Decrypt(Inst: Pointer; Data: PByte; var DataSize: LongWord;
      Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

type
  TVTable = array[0..11] of Pointer;
  PVTable = ^TVTable;
  PPVTable = ^PVTable;

  TBlockProc = procedure(Inst: PBlockCipher; Data: PByte);
                 {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

  TGetBlockSizeFunc = function(Inst: PBlockCipher): LongInt;
                 {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}


function GetEncryptProc(Inst: PBlockCipher): Pointer; inline;
begin
  Result:= PPVTable(Inst)^^[10];     // 10 is 'EncryptBlock' index
end;

function GetDecryptProc(Inst: PBlockCipher): Pointer; inline;
begin
  Result:= PPVTable(Inst)^^[11];    // 11 is 'DecryptBlock' index
end;

function GetBlockSize(Inst: PBlockCipher): LongInt; inline;
begin
  Result:= TGetBlockSizeFunc(PPVTable(Inst)^^[7])(Inst);
end;

procedure XorBytes(Target: Pointer; Value: Pointer; Count: Integer); inline;
var
  LCount: Integer;

begin
  LCount:= Count shr 2;
  while LCount > 0 do begin
    PLongWord(Target)^:= PLongWord(Target)^ xor PLongWord(Value)^;
    Inc(PLongWord(Target));
    Inc(PLongWord(Value));
    Dec(LCount);
  end;
  LCount:= Count and 3;
  while LCount > 0 do begin
    PByte(Target)^:= PByte(Target)^ xor PByte(Value)^;
    Inc(PByte(Target));
    Inc(PByte(Value));
    Dec(LCount);
  end;
end;

class function TBlockCipher.Encrypt(Inst: Pointer; Data: PByte;
  var DataSize: LongWord; BufSize: LongWord; Last: Boolean): TF_RESULT;
begin
  if (PBlockCipher(Inst).FDir = TF_KEYDIR_ENCRYPT) and
      PBlockCipher(Inst).FValidKey then begin
    case PBlockCipher(Inst).FMode of
      TF_KEYMODE_ECB: Result:= PBlockCipher(Inst).EncryptECB(Data, DataSize, BufSize, Last);
      TF_KEYMODE_CBC: Result:= PBlockCipher(Inst).EncryptCBC(Data, DataSize, BufSize, Last);
      TF_KEYMODE_CTR: Result:= PBlockCipher(Inst).EncryptCTR(Data, DataSize, BufSize, Last);
    else
      Result:= TF_E_UNEXPECTED;
    end;
  end
  else
    Result:= TF_E_UNEXPECTED;
end;

class function TBlockCipher.Decrypt(Inst: Pointer; Data: PByte;
  var DataSize: LongWord; Last: Boolean): TF_RESULT;
begin
  if (PBlockCipher(Inst).FDir = TF_KEYDIR_DECRYPT) and
      PBlockCipher(Inst).FValidKey then begin
    case PBlockCipher(Inst).FMode of
      TF_KEYMODE_ECB: Result:= PBlockCipher(Inst).DecryptECB(Data, DataSize, Last);
      TF_KEYMODE_CBC: Result:= PBlockCipher(Inst).DecryptCBC(Data, DataSize, Last);
      TF_KEYMODE_CTR: Result:= PBlockCipher(Inst).DecryptCTR(Data, DataSize, Last);
    else
      Result:= TF_E_UNEXPECTED;
    end;
  end
  else
    Result:= TF_E_UNEXPECTED;
end;

function TBlockCipher.EncryptECB(Data: PByte; var DataSize: LongWord;
                      BufSize: LongWord; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TBlockProc;
  RequiredSize: LongWord;
  LDataSize: LongWord;
  LPadding: LongWord;
  LBlockSize: LongWord;
  Cnt: LongWord;

begin
  @EncryptBlock:= GetEncryptProc(@Self);
  LDataSize:= DataSize;
  LPadding:= FPadding;
  LBlockSize:= GetBlockSize(@Self);
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

// check arguments
  if Last then begin
    case LPadding of
      TF_PADDING_NONE: begin
        if LDataSize and not (LBlockSize - 1) <> 0 then begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
        RequiredSize:= LDataSize;
      end;
      TF_PADDING_ZERO: RequiredSize:= (LDataSize + LBlockSize - 1) and not (LBlockSize - 1);
      TF_PADDING_ANSI,
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126,
      TF_PADDING_ISOIEC: RequiredSize:= (LDataSize + LBlockSize) and not (LBlockSize - 1);
    else
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
  end
  else begin
    if LDataSize and not (LBlockSize - 1) <> 0 then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    RequiredSize:= LDataSize;
  end;
  DataSize:= RequiredSize;
  if (Data = nil) or (BufSize < RequiredSize) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// encrypt
  while LDataSize >= LBlockSize do begin
    EncryptBlock(@Self, Data);
    Inc(Data, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;
  if Last then begin
    Cnt:= LBlockSize - LDataSize;    // 0 < Cnt <= LBlockSize
    Inc(Data, LDataSize);
    case LPadding of
                                            // XX 00 00 00 00
      TF_PADDING_ZERO: if LDataSize > 0 then begin
        FillChar(Data^, Cnt, 0);
        Dec(Data, LDataSize);
        EncryptBlock(@Self, Data);
      end;
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        FillChar(Data^, Cnt - 1, 0);
        Inc(Data, Cnt - 1);
        Data^:= Byte(Cnt);
        Dec(Data, LBlockSize - 1);
        EncryptBlock(@Self, Data);
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126: begin
        FillChar(Data^, Cnt, Byte(Cnt));
        Dec(Data, LDataSize);
        EncryptBlock(@Self, Data);
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        Data^:= $80;
        Inc(Data);
        FillChar(Data^, Cnt - 1, 0);
        Dec(Data, LDataSize + 1);
        EncryptBlock(@Self, Data);
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

function TBlockCipher.SetIV(Data: Pointer; DataLen: LongWord): TF_RESULT;
begin
  if (Data = nil) then begin
    FillChar(FIVector, GetBlockSize(@Self), 0);
    Result:= TF_S_OK;
  end
  else if (DataLen = LongWord(GetBlockSize(@Self))) then begin
    Move(Data^, FIVector, DataLen);
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;
end;

function TBlockCipher.SetDir(Data: LongWord): TF_RESULT;
begin
  if (Data = TF_KEYDIR_ENCRYPT) or (Data = TF_KEYDIR_DECRYPT) then begin
    FDir:= Data;
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;
end;

function TBlockCipher.SetMode(Data: LongWord): TF_RESULT;
begin
  if (Data >= TF_KEYMODE_MIN) and (Data <= TF_KEYMODE_MAX) then begin
    FMode:= Data;
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;
end;

function TBlockCipher.SetPadding(Data: LongWord): TF_RESULT;
begin
  if (Data >= TF_PADDING_MIN) and (Data <= TF_PADDING_MAX) then begin
    FPadding:= Data;
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;
end;

function TBlockCipher.SetFlags(Data: LongWord): TF_RESULT;
begin
  Result:= TF_S_FALSE;

  if Data and TF_KEYDIR_BASE <> 0 then
    Result:= SetDir(Data and TF_KEYDIR_MASK);

  if (Result >= 0) and (Data and TF_KEYMODE_BASE <> 0) then
    Result:= SetMode(Data and TF_KEYMODE_MASK);

  if (Result >= 0) and (Data and TF_PADDING_BASE <> 0) then
    Result:= SetPadding(Data and TF_PADDING_MASK);
end;

class function TBlockCipher.SetKeyParam(Inst: Pointer; Param: LongWord;
               Data: Pointer; DataLen: LongWord): TF_RESULT;
var
  LData: LongWord;

begin
  if Param = TF_KP_IV then begin
    Result:= PBlockCipher(Inst).SetIV(Data, DataLen);
  end
  else begin
    if DataLen = SizeOf(LongWord) then begin
      LData:= PLongWord(Data)^;
      case Param of
        TF_KP_DIR: Result:= PBlockCipher(Inst).SetDir(LData);
        TF_KP_MODE: Result:= PBlockCipher(Inst).SetMode(LData);
        TF_KP_PADDING: Result:= PBlockCipher(Inst).SetPadding(LData);
        TF_KP_FLAGS: Result:= PBlockCipher(Inst).SetFlags(LData);
      else
        Result:= TF_E_INVALIDARG;
      end;
    end
    else
      Result:= TF_E_INVALIDARG;

// setting flags invalidates key
    PBlockCipher(Inst).FValidKey:= False;
  end;
end;

function TBlockCipher.EncryptCBC(Data: PByte; var DataSize: LongWord;
                      BufSize: LongWord; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TBlockProc;
  RequiredSize: LongWord;
  LDataSize: LongWord;
  LPadding: LongWord;
  LBlockSize: LongWord;
  Cnt: LongWord;

begin
  @EncryptBlock:= GetEncryptProc(@Self);
  LDataSize:= DataSize;
  LPadding:= FPadding;
  LBlockSize:= GetBlockSize(@Self);
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

// check arguments
  if Last then begin
    case LPadding of
      TF_PADDING_NONE: begin
        if LDataSize and not (LBlockSize - 1) <> 0 then begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
        RequiredSize:= LDataSize;
      end;
      TF_PADDING_ZERO: RequiredSize:= (LDataSize + LBlockSize - 1) and not (LBlockSize - 1);
      TF_PADDING_ANSI,
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126,
      TF_PADDING_ISOIEC: RequiredSize:= (LDataSize + LBlockSize) and not (LBlockSize - 1);
    else
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
  end
  else begin
    if LDataSize and not (LBlockSize - 1) <> 0 then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    RequiredSize:= LDataSize;
  end;
  DataSize:= RequiredSize;
  if BufSize < RequiredSize then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// encrypt
  while LDataSize >= LBlockSize do begin
    XorBytes(Data, @FIVector, LBlockSize);
    EncryptBlock(@Self, Data);
    Move(Data^, FIVector, LBlockSize);
    Inc(Data, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;
  if Last then begin
    Cnt:= LBlockSize - LDataSize;    // 0 < Cnt <= BLOCK_SIZE
    Inc(Data, LDataSize);
    case LPadding of
                                            // XX 00 00 00 00
      TF_PADDING_ZERO: if LDataSize > 0 then begin
        FillChar(Data^, Cnt, 0);
        Dec(Data, LDataSize);
        XorBytes(Data, @FIVector, LBlockSize);
        EncryptBlock(@Self, Data);
      end;
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        FillChar(Data^, Cnt - 1, 0);
        Inc(Data, Cnt - 1);
        Data^:= Byte(Cnt);
        Dec(Data, LBlockSize - 1);
        XorBytes(Data, @FIVector, LBlockSize);
        EncryptBlock(@Self, Data);
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126: begin
        FillChar(Data^, Cnt, Byte(Cnt));
        Dec(Data, LDataSize);
        XorBytes(Data, @FIVector, LBlockSize);
        EncryptBlock(@Self, Data);
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        Data^:= $80;
        Inc(Data);
        FillChar(Data^, Cnt - 1, 0);
        Dec(Data, LDataSize + 1);
        XorBytes(Data, @FIVector, LBlockSize);
        EncryptBlock(@Self, Data);
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

function TBlockCipher.EncryptCTR(Data: PByte; var DataSize: LongWord;
  BufSize: LongWord; Last: Boolean): TF_RESULT;

var
  EncryptBlock: TBlockProc;
  Temp: TBlock;
  RequiredSize: LongWord;
  LDataSize: LongWord;
  LPadding: LongWord;
  LBlockSize: LongWord;
  Cnt: LongWord;

begin
  @EncryptBlock:= GetEncryptProc(@Self);
  LDataSize:= DataSize;
  LPadding:= FPadding;
  LBlockSize:= GetBlockSize(@Self);
  if LBlockSize > SizeOf(TBlock) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_NONE;

// check arguments
  if Last then begin
    case LPadding of
      TF_PADDING_NONE: RequiredSize:= LDataSize;
      TF_PADDING_ZERO: RequiredSize:= (LDataSize + LBlockSize - 1) and not (LBlockSize - 1);
      TF_PADDING_ANSI,
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126,
      TF_PADDING_ISOIEC: RequiredSize:= (LDataSize + LBlockSize) and not (LBlockSize - 1);
    else
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
  end
  else begin
    if LDataSize and not (LBlockSize - 1) <> 0 then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    RequiredSize:= LDataSize;
  end;
  DataSize:= RequiredSize;
  if BufSize < RequiredSize then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// encrypt
  while LDataSize >= LBlockSize do begin        // process full blocks
    Move(FIVector, Temp, LBlockSize);           // copy IV to temp block
                                                // encrypt temp block
    EncryptBlock(@Self, @Temp);
    XorBytes(Data, @Temp, LBlockSize);          // xor ciphertext with encrypted block
                                                // increment IV
    Cnt:= LBlockSize - 1;
    Inc(FIVector[Cnt]);
    if FIVector[Cnt] = 0 then begin
      repeat
        Dec(Cnt);
        Inc(FIVector[Cnt]);
      until (FIVector[Cnt] <> 0) or (Cnt = 0);
    end;
    Inc(Data, LBlockSize);                      // go to next block
    Dec(LDataSize, LBlockSize);
  end;
  if Last then begin
    if LPadding = TF_PADDING_NONE then begin
      if LDataSize > 0 then begin
        Move(FIVector, Temp, LBlockSize);       // copy IV to temp block
                                                // encrypt temp block
        EncryptBlock(@Self, @Temp);
        XorBytes(Data, @Temp, LDataSize);
        Cnt:= LBlockSize - 1;
        Inc(FIVector[Cnt]);
        if FIVector[Cnt] = 0 then begin
          repeat
            Dec(Cnt);
            Inc(FIVector[Cnt]);
          until (FIVector[Cnt] <> 0) or (Cnt = 0);
        end;
      end;
    end
    else begin
      Cnt:= LBlockSize - LDataSize;           // 0 < Cnt <= BLOCK_SIZE
      Inc(Data, LDataSize);
      case LPadding of
                                              // XX 00 00 00 00
        TF_PADDING_ZERO: if LDataSize > 0 then begin
          FillChar(Data^, Cnt, 0);
          Dec(Data, LDataSize);
          XorBytes(Data, @FIVector, LBlockSize);
          EncryptBlock(@Self, Data);
        end;
                                              // XX 00 00 00 04
        TF_PADDING_ANSI: begin
          FillChar(Data^, Cnt - 1, 0);
          Inc(Data, Cnt - 1);
          Data^:= Byte(Cnt);
          Dec(Data, LBlockSize - 1);
          XorBytes(Data, @FIVector, LBlockSize);
          EncryptBlock(@Self, Data);
        end;
                                              // XX 04 04 04 04
        TF_PADDING_PKCS,
        TF_PADDING_ISO10126 : begin
          FillChar(Data^, Cnt, Byte(Cnt));
          Dec(Data, LDataSize);
          XorBytes(Data, @FIVector, LBlockSize);
          EncryptBlock(@Self, Data);
        end;
                                              // XX 80 00 00 00
        TF_PADDING_ISOIEC: begin
          Data^:= $80;
          Inc(Data);
          FillChar(Data^, Cnt - 1, 0);
          Dec(Data, LDataSize + 1);
          XorBytes(Data, @FIVector, LBlockSize);
          EncryptBlock(@Self, Data);
        end;
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

function TBlockCipher.DecryptECB(Data: PByte; var DataSize: LongWord;
                                 Last: Boolean): TF_RESULT;
var
  DecryptBlock: TBlockProc;
  LDataSize: LongWord;
  LPadding: LongWord;
  LBlockSize: LongWord;
  Cnt, SaveCnt: LongWord;

begin
  @DecryptBlock:= GetDecryptProc(@Self);
  LDataSize:= DataSize;
  LPadding:= FPadding;
  LBlockSize:= GetBlockSize(@Self);
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

  if LDataSize and (LBlockSize - 1) <> 0 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  if Last and (LDataSize = 0) then begin
    case LPadding of
      TF_PADDING_ANSI,
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126,
      TF_PADDING_ISOIEC: begin
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
    end;
  end;
  while LDataSize >= LBlockSize do begin
    DecryptBlock(@Self, Data);
    Inc(Data, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;
  if Last then begin
    case LPadding of
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        Dec(Data);
        Cnt:= Data^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(Data);
            if Data^ <> 0 then begin
              Result:= TF_E_INVALIDARG;
              Exit;
            end;
            Dec(SaveCnt);
          end;
          DataSize:= DataSize - Cnt;
        end
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS: begin
        Dec(Data);
        Cnt:= Data^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(Data);
            if Data^ <> Cnt then begin
              Result:= TF_E_INVALIDARG;
              Exit;
            end;
            Dec(SaveCnt);
          end;
          DataSize:= DataSize - Cnt;
        end
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
                                            // XX ?? ?? ?? 04
      TF_PADDING_ISO10126: begin
        Cnt:= (Data - 1)^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          DataSize:= DataSize - Cnt;
        end
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        Cnt:= LBlockSize;
        repeat
          Dec(Data);
          Dec(Cnt);
        until (Data^ <> 0) or (Cnt = 0);
        if (Data^ = $80) then
          DataSize:= DataSize - LBlockSize + Cnt
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

function TBlockCipher.DecryptCBC(Data: PByte; var DataSize: LongWord;
                    Last: Boolean): TF_RESULT;
var
  DecryptBlock: TBlockProc;
  Temp: TBlock;
  LDataSize: LongWord;
  LPadding: LongWord;
  LBlockSize: LongWord;
  Cnt, SaveCnt: LongWord;

begin
  @DecryptBlock:= GetDecryptProc(@Self);

  LPadding:= FPadding;
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

  LBlockSize:= GetBlockSize(@Self);
  if LBlockSize > SizeOf(TBlock) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  LDataSize:= DataSize;
  if LDataSize and (LBlockSize - 1) <> 0 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  if Last and (DataSize = 0) then begin
    case LPadding of
      TF_PADDING_ANSI,
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126,
      TF_PADDING_ISOIEC: begin
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
    end;
  end;
  while LDataSize >= LBlockSize do begin
    Move(Data^, Temp, LBlockSize);
    DecryptBlock(@Self, Data);
    XorBytes(Data, @FIVector, LBlockSize);
    Move(Temp, FIVector, LBlockSize);
    Inc(Data, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;
  if Last then begin
    case LPadding of
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        Dec(Data);
        Cnt:= Data^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(Data);
            if Data^ <> 0 then begin
              Result:= TF_E_INVALIDARG;
              Exit;
            end;
            Dec(SaveCnt);
          end;
          DataSize:= DataSize - Cnt;
        end
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
                                              // XX 04 04 04 04
      TF_PADDING_PKCS: begin
        Dec(Data);
        Cnt:= Data^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(Data);
            if Data^ <> Cnt then begin
              Result:= TF_E_INVALIDARG;
              Exit;
            end;
            Dec(SaveCnt);
          end;
          DataSize:= DataSize - Cnt;
        end
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
                                              // XX ?? ?? ?? 04
      TF_PADDING_ISO10126: begin
        Cnt:= (Data - 1)^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          DataSize:= DataSize - Cnt;
        end
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
                                              // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        Cnt:= LBlockSize;
        repeat
          Dec(Data);
          Dec(Cnt);
        until (Data^ <> 0) or (Cnt = 0);
        if (Data^ = $80) then
          DataSize:= DataSize - LBlockSize + Cnt
        else begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

function TBlockCipher.DecryptCTR(Data: PByte; var DataSize: LongWord;
                               Last: Boolean): TF_RESULT;
var
  EncryptBlock: TBlockProc;
  Temp: TBlock;
  LDataSize: LongWord;
  LPadding: LongWord;
  LBlockSize: LongWord;
  Cnt, SaveCnt: LongWord;

begin
  @EncryptBlock:= GetEncryptProc(@Self);  // !! CTR mode uses EncryptBlock for decryption
  LDataSize:= DataSize;
  LPadding:= FPadding;
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_NONE;

  LBlockSize:= GetBlockSize(@Self);
  if LBlockSize > SizeOf(TBlock) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  if (LDataSize and (LBlockSize - 1) <> 0) then begin
// the last block with TF_PADDING_NONE can be incomplete
    if not Last or (LPadding <> TF_PADDING_NONE) then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
  end;

// encrypt
  while LDataSize >= LBlockSize do begin        // process full blocks
    Move(FIVector, Temp, LBlockSize);           // copy IV to temp block
                                                // encrypt temp block
    EncryptBlock(@Self, @Temp);
    XorBytes(Data, @Temp, LBlockSize);          // xor ciphertext with encrypted block
                                                // increment IV
    Cnt:= LBlockSize - 1;
    Inc(FIVector[Cnt]);
    if FIVector[Cnt] = 0 then begin
      repeat
        Dec(Cnt);
        Inc(FIVector[Cnt]);
      until (FIVector[Cnt] <> 0) or (Cnt = 0);
    end;
    Inc(Data, LBlockSize);                      // go to next block
    Dec(LDataSize, LBlockSize);
  end;

  if Last then begin
    if LDataSize > 0 then begin
      Move(FIVector, Temp, LBlockSize);       // copy IV to temp block
                                              // encrypt temp block
      EncryptBlock(@Self, @Temp);
      Cnt:= LBlockSize - 1;
      Inc(FIVector[Cnt]);
      if FIVector[Cnt] = 0 then begin
        repeat
          Dec(Cnt);
          Inc(FIVector[Cnt]);
        until (FIVector[Cnt] <> 0) or (Cnt = 0);
      end;
      if LPadding = TF_PADDING_NONE then begin
        XorBytes(Data, @Temp, LDataSize);
        Result:= TF_S_OK;
      end
      else
        Result:= TF_E_INVALIDARG;
      Exit;
    end
    else begin    { LDataSize = 0 }
      case LPadding of
                                              // XX 00 00 00 04
        TF_PADDING_ANSI: begin
          Dec(Data);
          Cnt:= Data^;
          if (Cnt > 0) and (Cnt <= LBlockSize) then begin
            SaveCnt:= Cnt - 1;
            while SaveCnt > 0 do begin
              Dec(Data);
              if Data^ <> 0 then begin
                Result:= TF_E_INVALIDARG;
                Exit;
              end;
              Dec(SaveCnt);
            end;
            DataSize:= DataSize - Cnt;
          end
          else begin
            Result:= TF_E_INVALIDARG;
            Exit;
          end;
        end;
                                              // XX 04 04 04 04
        TF_PADDING_PKCS: begin
          Dec(Data);
          Cnt:= Data^;
          if (Cnt > 0) and (Cnt <= LBlockSize) then begin
            SaveCnt:= Cnt - 1;
            while SaveCnt > 0 do begin
              Dec(Data);
              if Data^ <> Cnt then begin
                Result:= TF_E_INVALIDARG;
                Exit;
              end;
              Dec(SaveCnt);
            end;
            DataSize:= DataSize - Cnt;
          end
          else begin
            Result:= TF_E_INVALIDARG;
            Exit;
          end;
        end;
                                              // XX ?? ?? ?? 04
        TF_PADDING_ISO10126: begin
          Cnt:= (Data - 1)^;
          if (Cnt > 0) and (Cnt <= LBlockSize) then begin
            DataSize:= DataSize - Cnt;
          end
          else begin
            Result:= TF_E_INVALIDARG;
            Exit;
          end;
        end;

                                              // XX 80 00 00 00
        TF_PADDING_ISOIEC: begin
          Cnt:= LBlockSize;
          repeat
            Dec(Data);
            Dec(Cnt);
          until (Data^ <> 0) or (Cnt = 0);
          if (Data^ = $80) then
            DataSize:= DataSize - LBlockSize + Cnt
          else begin
            Result:= TF_E_INVALIDARG;
            Exit;
          end;
        end;
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

end.
