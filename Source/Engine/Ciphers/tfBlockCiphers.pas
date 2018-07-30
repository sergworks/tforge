{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # generic block cipher
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TBlockCipherInstance
}

unit tfBlockCiphers;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  PBlockCipherInstance = ^TBlockCipherInstance;
  TBlockCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: UInt32;
    FPos:      Cardinal;
{$HINTS ON}
    FIVector: array[0..0] of Byte;

  public
    class function GetIsBlockCipher(Inst: Pointer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKey(Inst: Pointer; Key: PByte; KeySize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKeyNonce(Inst: Pointer; Key: PByte; KeySize: Cardinal; Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptECB(Inst: PBlockCipherInstance; Data: PByte; var DataSize: Cardinal;
                     OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptECB(Inst: PBlockCipherInstance; Data: PByte; var DataSize: Cardinal;
                     OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptCBC(Inst: PBlockCipherInstance; Data: PByte; var DataSize: Cardinal;
                     OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptCBC(Inst: PBlockCipherInstance; Data: PByte; var DataSize: Cardinal;
                     OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyBlockCTR(Inst: Pointer; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyBlockOFB(Inst: Pointer; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetIV(Inst: Pointer; IV: Pointer; IVLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetNonce(Inst: PBlockCipherInstance; Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIV(Inst: PBlockCipherInstance; IV: Pointer; IVLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetNonce(Inst: PBlockCipherInstance; var Nonce: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
 end;

implementation

uses
  tfCipherHelpers;

function ValidEncryptionKey(Inst: PBlockCipherInstance): Boolean; inline;
begin
  Result:= (Inst.FKeyFlags and TF_KEYFLAG_KEY <> 0) and
           ((Inst.FAlgID and TF_KEYDIR_ENABLED = 0) or
             (Inst.FAlgID and TF_KEYDIR_ENC <> 0));
end;

function ValidDecryptionKey(Inst: PBlockCipherInstance): Boolean; inline;
begin
  Result:= (Inst.FKeyFlags and TF_KEYFLAG_KEY <> 0) and
           ((Inst.FAlgID and TF_KEYDIR_ENABLED = 0) or
             (Inst.FAlgID and TF_KEYDIR_ENC = 0));
end;

procedure XorBytes(Target: Pointer; Value: Pointer; Count: Integer);
var
  LCount: Integer;

begin
  LCount:= Count shr 2;
  while LCount > 0 do begin
    PUInt32(Target)^:= PUInt32(Target)^ xor PUInt32(Value)^;
    Inc(PUInt32(Target));
    Inc(PUInt32(Value));
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

{ TBlockCipherInstance }

class function TBlockCipherInstance.EncryptCBC(Inst: PBlockCipherInstance;
                 Data: PByte; var DataSize: Cardinal;
                 OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  RequiredSize: Cardinal;
  LDataSize: Cardinal;
  LPadding: UInt32;
  LBlockSize: Cardinal;
  Cnt: Cardinal;

begin
  if not ValidEncryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @EncryptBlock:= TCipherHelper.GetEncryptBlockFunc(Inst);
  LDataSize:= DataSize;
  LPadding:= Inst.FAlgID and TF_PADDING_MASK;

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

// check arguments
  if Last then begin
    case LPadding of
      TF_PADDING_NONE: begin
        if LDataSize and (LBlockSize - 1) <> 0 then begin
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
    if LDataSize and (LBlockSize - 1) <> 0 then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    RequiredSize:= LDataSize;
  end;
  DataSize:= RequiredSize;
  if OutSize < RequiredSize then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// encrypt
  while LDataSize >= LBlockSize do begin
    Move(Data^, OutData^, LBlockSize);
    XorBytes(OutData, @Inst.FIVector, LBlockSize);
    EncryptBlock(Inst, OutData);
    Move(OutData^, Inst.FIVector, LBlockSize);
    Inc(Data, LBlockSize);
    Inc(OutData, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;

  if Last then begin
    Cnt:= LBlockSize - LDataSize;    // 0 < Cnt <= BLOCK_SIZE
    case LPadding of
                                            // XX 00 00 00 00
      TF_PADDING_ZERO: if LDataSize > 0 then begin
        Move(Data^, OutData^, LBlockSize);
        Inc(OutData, LDataSize);
        FillChar(OutData^, Cnt, 0);
        Dec(OutData, LDataSize);
        XorBytes(OutData, @Inst.FIVector, LBlockSize);
        EncryptBlock(Inst, OutData);
      end;
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        Move(Data^, OutData^, LBlockSize);
        Inc(OutData, LDataSize);
        FillChar(OutData^, Cnt - 1, 0);
        Inc(OutData, Cnt - 1);
        OutData^:= Byte(Cnt);
        Dec(OutData, LBlockSize - 1);
        XorBytes(OutData, @Inst.FIVector, LBlockSize);
        EncryptBlock(Inst, OutData);
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126: begin
        Move(Data^, OutData^, LBlockSize);
        Inc(OutData, LDataSize);
        FillChar(OutData^, Cnt, Byte(Cnt));
        Dec(OutData, LDataSize);
        XorBytes(OutData, @Inst.FIVector, LBlockSize);
        EncryptBlock(Inst, OutData);
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        Move(Data^, OutData^, LBlockSize);
        Inc(OutData, LDataSize);
        Data^:= $80;
        Inc(OutData);
        FillChar(OutData^, Cnt - 1, 0);
        Dec(OutData, LDataSize + 1);
        XorBytes(OutData, @Inst.FIVector, LBlockSize);
        EncryptBlock(Inst, OutData);
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.EncryptECB(Inst: PBlockCipherInstance;
                 Data: PByte; var DataSize: Cardinal;
                 OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  RequiredSize: Cardinal;
  LDataSize: Cardinal;
  LPadding: UInt32;
  LBlockSize: Cardinal;
  Cnt: Cardinal;

begin
  if not ValidEncryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @EncryptBlock:= TCipherHelper.GetEncryptBlockFunc(Inst);
  LDataSize:= DataSize;
  LPadding:= Inst.FAlgID and TF_PADDING_MASK;

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

// check arguments
  if Last then begin
    case LPadding of
      TF_PADDING_NONE: begin
        if LDataSize and (LBlockSize - 1) <> 0 then begin
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
    if LDataSize and (LBlockSize - 1) <> 0 then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    RequiredSize:= LDataSize;
  end;
  DataSize:= RequiredSize;
  if (Data = nil) or (OutSize < RequiredSize) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// encrypt
  while LDataSize >= LBlockSize do begin
    Move(Data^, OutData^, LBlockSize);
    EncryptBlock(Inst, OutData);
    Inc(Data, LBlockSize);
    Inc(OutData, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;
  if Last then begin
    Cnt:= LBlockSize - LDataSize;    // 0 < Cnt <= LBlockSize
    case LPadding of
                                            // XX 00 00 00 00
      TF_PADDING_ZERO: if LDataSize > 0 then begin
        Move(Data^, OutData^, LDataSize);
        Inc(OutData, LDataSize);
        FillChar(OutData^, Cnt, 0);
        Dec(OutData, LDataSize);
        EncryptBlock(Inst, OutData);
      end;
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        Move(Data^, OutData^, LDataSize);
        Inc(OutData, LDataSize);
        FillChar(OutData^, Cnt - 1, 0);
        Inc(OutData, Cnt - 1);
        OutData^:= Byte(Cnt);
        Dec(OutData, LBlockSize - 1);
        EncryptBlock(Inst, OutData);
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126: begin
        Move(Data^, OutData^, LDataSize);
        Inc(OutData, LDataSize);
        FillChar(OutData^, Cnt, Byte(Cnt));
        Dec(OutData, LDataSize);
        EncryptBlock(Inst, OutData);
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        Move(Data^, OutData^, LDataSize);
        Inc(OutData, LDataSize);
        OutData^:= $80;
        Inc(OutData);
        FillChar(OutData^, Cnt - 1, 0);
        Dec(OutData, LDataSize + 1);
        EncryptBlock(Inst, OutData);
      end;
    end;
  end;
  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.ExpandKey(Inst: Pointer;
                 Key: PByte; KeySize: Cardinal): TF_RESULT;
begin
  Result:= TCipherHelper.ExpandKeyIV(Inst, Key, KeySize, nil, 0);
end;

class function TBlockCipherInstance.ExpandKeyNonce(Inst: Pointer;
                 Key: PByte; KeySize: Cardinal; Nonce: TNonce): TF_RESULT;
begin
  Result:= TCipherHelper.ExpandKeyIV(Inst, Key, KeySize, nil, 0);
  if Result = TF_S_OK then
    Result:= SetNonce(Inst, Nonce);
end;

class function TBlockCipherInstance.DecryptCBC(Inst: PBlockCipherInstance;
                 Data: PByte; var DataSize: Cardinal;
                 OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
var
  DecryptBlock: TCipherHelper.TBlockFunc;
  Temp: TCipherHelper.TBlock;
  LDataSize: Cardinal;
  LPadding: UInt32;
  LBlockSize: Cardinal;
  Cnt, SaveCnt: Cardinal;

begin
  if not ValidDecryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @DecryptBlock:= TCipherHelper.GetDecryptBlockFunc(Inst);

  LPadding:= Inst.FAlgID and TF_PADDING_MASK;
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  LDataSize:= DataSize;
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
    Move(Data^, OutData^, LBlockSize);
    Move(Data^, Temp, LBlockSize);
    DecryptBlock(Inst, OutData);
    XorBytes(OutData, @Inst.FIVector, LBlockSize);
    Move(Temp, Inst.FIVector, LBlockSize);
    Inc(Data, LBlockSize);
    Inc(OutData, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;
  if Last then begin
    case LPadding of
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        Dec(OutData);
        Cnt:= OutData^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(OutData);
            if OutData^ <> 0 then begin
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
        Dec(OutData);
        Cnt:= OutData^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(OutData);
            if OutData^ <> Cnt then begin
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
        Cnt:= (OutData - 1)^;
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
          Dec(OutData);
          Dec(Cnt);
        until (OutData^ <> 0) or (Cnt = 0);
        if (OutData^ = $80) then
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

class function TBlockCipherInstance.DecryptECB(Inst: PBlockCipherInstance;
                 Data: PByte; var DataSize: Cardinal;
                 OutData: PByte; OutSize: Cardinal; Last: Boolean): TF_RESULT;
var
  DecryptBlock: TCipherHelper.TBlockFunc;
  LDataSize: Cardinal;
  LPadding: UInt32;
  LBlockSize: Cardinal;
  Cnt, SaveCnt: Cardinal;

begin
  if not ValidDecryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @DecryptBlock:= TCipherHelper.GetDecryptBlockFunc(Inst);

  LPadding:= Inst.FAlgID and TF_PADDING_MASK;
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  LDataSize:= DataSize;
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
    Move(Data^, OutData^, LBlockSize);
    DecryptBlock(Inst, OutData);
    Inc(Data, LBlockSize);
    Inc(OutData, LBlockSize);
    Dec(LDataSize, LBlockSize);
  end;
                                          // if LPadding = TF_PADDING_NONE
                                          // or LPadding:= TF_PADDING_ZERO
                                          //   we are done, else decode padding block
  if Last then begin
    case LPadding of
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        Dec(OutData);
        Cnt:= OutData^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(OutData);
            if OutData^ <> 0 then begin
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
        Dec(OutData);
        Cnt:= OutData^;
        if (Cnt > 0) and (Cnt <= LBlockSize) then begin
          SaveCnt:= Cnt - 1;
          while SaveCnt > 0 do begin
            Dec(OutData);
            if OutData^ <> Cnt then begin
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
        Cnt:= (OutData - 1)^;
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
          Dec(OutData);
          Dec(Cnt);
        until (OutData^ <> 0) or (Cnt = 0);
        if (OutData^ = $80) then
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

class function TBlockCipherInstance.GetIsBlockCipher(Inst: Pointer): Boolean;
begin
  Result:= True;
end;

class function TBlockCipherInstance.GetIV(Inst: PBlockCipherInstance;
  IV: Pointer; IVLen: Cardinal): TF_RESULT;
var
  LBlockSize: Cardinal;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  if (IVLen = LBlockSize) then begin
    Move(Inst.FIVector, IV^, IVLen);
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;

end;

// for block ciphers in stream modes;
//   block modes should use TCipherInstance.GetKeyBlockStub
class function TBlockCipherInstance.GetKeyBlockCTR(Inst: Pointer; Data: PByte): TF_RESULT;
var
  LBlockSize, Cnt: Cardinal;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  Move(FIVector, Data^, LBlockSize);          // copy IV to Data block
  TCipherHelper.EncryptBlock(Inst, Data);     // encrypt Data block
  Cnt:= LBlockSize - 1;                       // increment IV
  Inc(FIVector[Cnt]);
  if FIVector[Cnt] = 0 then begin
    repeat
      Dec(Cnt);
      Inc(FIVector[Cnt]);
    until (FIVector[Cnt] <> 0) or (Cnt = 0);
  end;
end;

class function TBlockCipherInstance.GetNonce(Inst: PBlockCipherInstance;
  var Nonce: UInt64): TF_RESULT;
var
  LBlockSize: Cardinal;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  if (LBlockSize < 16) then
    Nonce:= 0
  else
    Move(Inst.FIVector, Nonce, SizeOf(Nonce));

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.SetIV(Inst: Pointer;
  IV: Pointer; IVLen: Cardinal): TF_RESULT;
var
  LBlockSize: Cardinal;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  if (IV = nil) then begin
    if (IVLen = 0) or (IVLen = LBlockSize) then begin
      FillChar(PBlockCipherInstance(Inst).FIVector, LBlockSize, 0);
      Result:= TF_S_OK;
    end
    else begin
      Result:= TF_E_INVALIDARG;
    end;
    Exit;
  end;

  if (IVLen = LBlockSize) then begin
    Move(IV^, PBlockCipherInstance(Inst).FIVector, IVLen);
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;

end;

class function TBlockCipherInstance.SetNonce(Inst: PBlockCipherInstance;
  Nonce: TNonce): TF_RESULT;
var
  LBlockSize: Cardinal;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

// IV consists of 2 parts: Nonce and BlockNo;
//   if BlockSize >= 16 (128 bits),
//     then both Nonce and BlockNo are of 8 bytes (64 bits);
//     nonce is the leftmost 8 bytes, blockno is the rightmost 6 bytes.
//   if BlockSize < 16 (128 bits),
//     then whole IV is BlockNo, and the only valid nonce value is zero.
//   if BlockSize > 16 (128 bits),
//     then (BlockSize - 16) bytes of IV between Nonce and BlockNo are zeroed.
//   BlockNo bytes of IV are zeroed.

  FillChar(Inst.FIVector, LBlockSize, 0);

  if (LBlockSize < 16) then begin
    if (Nonce <> 0) then
      Result:= TF_E_INVALIDARG
    else
      Result:= TF_S_OK;
    Exit;
  end;

  Move(Nonce, Inst.FIVector, SizeOf(Nonce));
  Result:= TF_S_OK;
end;

end.
