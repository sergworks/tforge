{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # generic block cipher
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TStreamCipherInstance <--
        <-- TBlockCipherInstance
}

unit tfBlockCiphers;

{$I TFL.inc}
{$R-}

interface

uses
  tfTypes, tfUtils;

type
  PBlockCipherInstance = ^TBlockCipherInstance;
  TBlockCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
    FPos:      Integer;
{$HINTS ON}
    FCache: array[0..0] of Byte;

    function DecodePad(PadBlock: PByte; BlockSize: Cardinal;
                         Padding: UInt32; out PayLoad: Cardinal): TF_RESULT;
  public
//    class function GetIsBlockCipher(Inst: Pointer): Boolean;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function IncBlockNoCTR(Inst: PBlockCipherInstance; Count: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecBlockNoCTR(Inst: PBlockCipherInstance; Count: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SkipCTR(Inst: PBlockCipherInstance; Dist: Int64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKey(Inst: Pointer; Key: PByte; KeySize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKeyNonce(Inst: Pointer; Key: PByte; KeySize: Cardinal; Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptECB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptECB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptCBC(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptCBC(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyBlockCTR(Inst: PBlockCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function GetKeyBlockOFB(Inst: Pointer; Data: PByte): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetIV(Inst: Pointer; IV: Pointer; IVLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetNonce(Inst: PBlockCipherInstance; Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIV(Inst: PBlockCipherInstance; IV: Pointer; IVLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetNonce(Inst: PBlockCipherInstance; var Nonce: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIVPointer(Inst: PBlockCipherInstance): Pointer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function EncryptFinalECB(Inst: PBlockCipherInstance;
//                     OutData: PByte; var OutSize: Cardinal): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
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
                 InBuffer, OutBuffer: PByte; var DataSize: Cardinal;
                 OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  IVector: PByte;
  OutCount: Cardinal;     // number of bytes written to OutData
  LPadding: UInt32;
  LBlockSize: Integer;
  LDataSize: Cardinal;
  Cnt: Cardinal;

begin
  if not ValidEncryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @EncryptBlock:= TCipherHelper.GetEncryptBlockFunc(Inst);

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  IVector:= PByte(@Inst.FCache) + LBlockSize;
  LDataSize:= DataSize;
  OutCount:= 0;

// process incomplete cached block
  if Inst.FPos > 0 then begin
    Cnt:= LBlockSize - Inst.FPos;
    if Cnt > LDataSize then Cnt:= LDataSize;
    Move(InBuffer^, Inst.FCache[Inst.FPos], Cnt);
    Inc(InBuffer, Cnt);
    Dec(LDataSize, Cnt);
    Inc(Inst.FPos, Cnt);
    if Inst.FPos = LBlockSize then begin
      Inst.FPos:= 0;
      if OutBufSize < Cardinal(LBlockSize) then begin
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      XorBytes(@Inst.FCache, IVector, LBlockSize);
      EncryptBlock(Inst, @Inst.FCache);
      Move(Inst.FCache, IVector^, LBlockSize);
      Move(Inst.FCache, OutBuffer^, LBlockSize);
      FillChar(Inst.FCache, LBlockSize, 0);
      Inc(OutBuffer, LBlockSize);
      OutCount:= LBlockSize;
    end;
  end;

// process full blocks
  while LDataSize >= Cardinal(LBlockSize) do begin
    if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    Move(InBuffer^, OutBuffer^, LBlockSize);
    XorBytes(OutBuffer, IVector, LBlockSize);
    EncryptBlock(Inst, OutBuffer);
    Move(OutBuffer^, IVector^, LBlockSize);
    Inc(InBuffer, LBlockSize);
    Dec(LDataSize, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Inc(OutCount, LBlockSize);
  end;

// process last incomplete block
  if LDataSize > 0 then begin
    Move(InBuffer^, Inst.FCache, LDataSize);
    Inst.FPos:= LDataSize;
  end;

  Result:= TF_S_OK;

  if Last then begin
    LPadding:= Inst.FAlgID and TF_PADDING_MASK;
    if LPadding = TF_PADDING_DEFAULT
      then LPadding:= TF_PADDING_PKCS;

    Cnt:= Cardinal(LBlockSize) - LDataSize;      // 0 < Cnt <= LBlockSize
    case LPadding of

      TF_PADDING_NONE: begin
        if Inst.FPos > 0 then begin
          Result:= TF_E_INVALIDPAD;
        end;
      end;
                                            // XX 00 00 00 00
      TF_PADDING_ZERO: if Inst.FPos > 0 then begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          FillChar(Inst.FCache[Inst.FPos], Cnt, 0);
          XorBytes(@Inst.FCache, IVector, LBlockSize);
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, IVector^, LBlockSize);
          Move(Inst.FCache, OutBuffer^, LBlockSize);
          Inc(OutCount, LBlockSize);
        end;
      end;
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          FillChar(Inst.FCache[Inst.FPos], Cnt - 1, 0);
          Inst.FCache[LBlockSize - 1]:= Byte(Cnt);
          XorBytes(@Inst.FCache, IVector, LBlockSize);
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, IVector^, LBlockSize);
          Move(Inst.FCache, OutBuffer^, LBlockSize);
          Inc(OutCount, LBlockSize);
        end;
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126: begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          FillChar(Inst.FCache[Inst.FPos], Cnt, Byte(Cnt));
          XorBytes(@Inst.FCache, IVector, LBlockSize);
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, IVector^, LBlockSize);
          Move(Inst.FCache, OutBuffer^, LBlockSize);

          Inc(OutCount, LBlockSize);
        end;
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          Inst.FCache[Inst.FPos]:= $80;
          FillChar(Inst.FCache[Inst.FPos + 1], Cnt - 1, 0);
          XorBytes(@Inst.FCache, IVector, LBlockSize);
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, IVector^, LBlockSize);
          Move(Inst.FCache, OutBuffer^, LBlockSize);

          Inc(OutCount, LBlockSize);
        end;
      end;
    end;
    FillChar(Inst.FCache, LBlockSize, 0);
    Inst.FPos:= 0;
  end;

  DataSize:= OutCount;
end;

class function TBlockCipherInstance.EncryptECB(Inst: PBlockCipherInstance;
                 InBuffer, OutBuffer: PByte;
                 var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  OutCount: Cardinal;     // number of bytes written to OutBuffer
  LPadding: UInt32;
  LBlockSize: Integer;
  LDataSize: Cardinal;
  Cnt: Cardinal;

begin
  if not ValidEncryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @EncryptBlock:= TCipherHelper.GetEncryptBlockFunc(Inst);

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  LDataSize:= DataSize;
  OutCount:= 0;

// process incomplete cached block
  if Inst.FPos > 0 then begin
    Cnt:= LBlockSize - Inst.FPos;
    if Cnt > LDataSize then Cnt:= LDataSize;
    Move(InBuffer^, Inst.FCache[Inst.FPos], Cnt);
    Inc(InBuffer, Cnt);
    Dec(LDataSize, Cnt);
    Inc(Inst.FPos, Cnt);
    if Inst.FPos = LBlockSize then begin
      Inst.FPos:= 0;
      if OutBufSize < Cardinal(LBlockSize) then begin
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      EncryptBlock(Inst, @Inst.FCache);
      Move(Inst.FCache, OutBuffer^, LBlockSize);
      FillChar(Inst.FCache, LBlockSize, 0);
      Inc(OutBuffer, LBlockSize);
      OutCount:= LBlockSize;
    end;
  end;

// process full blocks
  while LDataSize >= Cardinal(LBlockSize) do begin
    if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    Move(InBuffer^, OutBuffer^, LBlockSize);
    EncryptBlock(Inst, OutBuffer);
    Inc(InBuffer, LBlockSize);
    Dec(LDataSize, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Inc(OutCount, LBlockSize);
  end;

// process last incomplete block
  if LDataSize > 0 then begin
    Move(InBuffer^, Inst.FCache, LDataSize);
    Inst.FPos:= LDataSize;
  end;

  Result:= TF_S_OK;

  if Last then begin
    LPadding:= Inst.FAlgID and TF_PADDING_MASK;
    if LPadding = TF_PADDING_DEFAULT
      then LPadding:= TF_PADDING_PKCS;

    Cnt:= Cardinal(LBlockSize) - LDataSize;      // 0 < Cnt <= LBlockSize
    case LPadding of

      TF_PADDING_NONE: begin
        if Inst.FPos > 0 then begin
          Result:= TF_E_INVALIDPAD;
        end;
      end;
                                            // XX 00 00 00 00
      TF_PADDING_ZERO: if Inst.FPos > 0 then begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          FillChar(Inst.FCache[Inst.FPos], Cnt, 0);
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, OutBuffer^, LBlockSize);
          Inc(OutCount, LBlockSize);
        end;
      end;
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          FillChar(Inst.FCache[Inst.FPos], Cnt - 1, 0);
          Inst.FCache[LBlockSize - 1]:= Byte(Cnt);
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, OutBuffer^, LBlockSize);
          Inc(OutCount, LBlockSize);
        end;
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS,
      TF_PADDING_ISO10126: begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          FillChar(Inst.FCache[Inst.FPos], Cnt, Byte(Cnt));
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, OutBuffer^, LBlockSize);
          Inc(OutCount, LBlockSize);
        end;
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          Inst.FCache[Inst.FPos]:= $80;
          FillChar(Inst.FCache[Inst.FPos + 1], Cnt - 1, 0);
          EncryptBlock(Inst, OutBuffer);
          Move(Inst.FCache, OutBuffer^, LBlockSize);
          Inc(OutCount, LBlockSize);
        end;
      end;
    end;
    FillChar(Inst.FCache, LBlockSize, 0);
    Inst.FPos:= 0;
  end;

  DataSize:= OutCount;
end;

// I assume here that derived class implements ExpandKeyIV
//   and inherits ExpandKey and ExpandKeyNonce implementations
//   from TBlockCipherInstance
class function TBlockCipherInstance.ExpandKey(Inst: Pointer;
                 Key: PByte; KeySize: Cardinal): TF_RESULT;
begin
  Result:= TCipherHelper.ExpandKeyIV(Inst, Key, KeySize, nil, 0);
end;

class function TBlockCipherInstance.ExpandKeyNonce(Inst: Pointer;
                 Key: PByte; KeySize: Cardinal; Nonce: TNonce): TF_RESULT;
begin
//  Result:= TCipherHelper.ExpandKeyIV(Inst, Key, KeySize, nil, 0);
  Result:= TCipherHelper.ExpandKey(Inst, Key, KeySize);
  if Result = TF_S_OK then
    Result:= SetNonce(Inst, Nonce);
end;

function TBlockCipherInstance.DecodePad(PadBlock: PByte; BlockSize: Cardinal;
           Padding: UInt32; out PayLoad: Cardinal): TF_RESULT;
var
  Cnt, Cnt2: Cardinal;

begin
  Result:= TF_S_OK;

  case Padding of
                                      // XX 00 00 00 04
    TF_PADDING_ANSI: begin
      Cnt:= PadBlock[BlockSize - 1];
      if (Cnt > 0) and (Cnt <= BlockSize) then begin
        Cnt2:= Cnt;
        while Cnt2 > 1 do begin    // Cnt - 1 zero bytes
          if PadBlock[BlockSize - Cnt2] <> 0 then begin
            Result:= TF_E_INVALIDPAD;
            Break;
          end;
          Dec(Cnt2);
        end;
      end
      else
        Result:= TF_E_INVALIDPAD;
    end;
                                      // XX 04 04 04 04
    TF_PADDING_PKCS: begin
      Cnt:= PadBlock[BlockSize - 1];
      if (Cnt > 0) and (Cnt <= BlockSize) then begin
        Cnt2:= Cnt;
        while Cnt2 > 1 do begin // Cnt - 1 bytes
          if PadBlock[BlockSize - Cnt2] <> Byte(Cnt) then begin
            Result:= TF_E_INVALIDPAD;
            Break;
          end;
          Dec(Cnt2);
        end;
      end
      else
        Result:= TF_E_INVALIDPAD;
    end;
                                      // XX ?? ?? ?? 04
    TF_PADDING_ISO10126: begin
      Cnt:= PadBlock[BlockSize - 1];
      if (Cnt <= 0) or (Cnt > BlockSize) then
        Result:= TF_E_INVALIDPAD;
    end;
                                      // XX 80 00 00 00
    TF_PADDING_ISOIEC: begin
      Cnt:= BlockSize;
      repeat
        Dec(Cnt);
      until (PadBlock[Cnt] <> 0) or (Cnt = 0);
      if (PadBlock[Cnt] = $80) then
        Cnt:= BlockSize - Cnt
      else
        Result:= TF_E_INVALIDPAD;
    end;
  else
    Cnt:= 0; // not used, just to remove compiler warning
             //   W1036 Variable 'Cnt' might not have been initialized
    Result:= TF_E_UNEXPECTED;
  end;
  if Result = TF_S_OK then
    PayLoad:= BlockSize - Cnt
  else
    PayLoad:= 0;
end;

class function TBlockCipherInstance.DecryptCBC(Inst: PBlockCipherInstance;
                 InBuffer, OutBuffer: PByte;
                 var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
var
  DecryptBlock: TCipherHelper.TBlockFunc;
  IVector: PByte;
  OutCount: Cardinal;     // number of bytes written to OutData
  LPadding: UInt32;
  LBlockSize: Integer;
  LDataSize: Cardinal;
  Cnt: Cardinal;
  NoPadBlock: Boolean;

begin
  if not ValidDecryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @DecryptBlock:= TCipherHelper.GetDecryptBlockFunc(Inst);

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  IVector:= PByte(@Inst.FCache) + LBlockSize;
  LDataSize:= DataSize;
  OutCount:= 0;

  LPadding:= Inst.FAlgID and TF_PADDING_MASK;
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

  NoPadBlock:= (LPadding = TF_PADDING_NONE) or (LPadding = TF_PADDING_ZERO);

// process cached block
  if LDataSize > 0 then begin
    Cnt:= LBlockSize - Inst.FPos;   // it is possible that Cnt = 0
    if Cnt > LDataSize then Cnt:= LDataSize;
    Move(InBuffer^, Inst.FCache[Inst.FPos], Cnt);
    Inc(InBuffer, Cnt);
    Dec(LDataSize, Cnt);
    Inc(Inst.FPos, Cnt);
    if (Inst.FPos = LBlockSize) and ((LDataSize > 0) or NoPadBlock) then begin
      Inst.FPos:= 0;
      if OutBufSize < Cardinal(LBlockSize) then begin
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      Move(Inst.FCache, OutBuffer^, LBlockSize);
      DecryptBlock(Inst, OutBuffer);
      XorBytes(OutBuffer, IVector, LBlockSize);
      Move(Inst.FCache, IVector^, LBlockSize);
//      FillChar(Inst.FCache, LBlockSize, 0);
      Inc(OutBuffer, LBlockSize);
      OutCount:= LBlockSize;
    end;
  end;

// process full blocks
  while (LDataSize > Cardinal(LBlockSize)) or ((LDataSize = Cardinal(LBlockSize)) and NoPadBlock) do begin
    if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    Move(InBuffer^, OutBuffer^, LBlockSize);
// since InBuffer and OutBuffer can be identical
//   we store InBuffer block in intermediate buffer
    Move(InBuffer^, Inst.FCache, LBlockSize);
    DecryptBlock(Inst, OutBuffer);
    XorBytes(OutBuffer, IVector, LBlockSize);
    Move(Inst.FCache, IVector^, LBlockSize);
    Inc(InBuffer, LBlockSize);
    Dec(LDataSize, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Inc(OutCount, LBlockSize);
  end;

// process last block
  if LDataSize > 0 then begin
    Move(InBuffer^, Inst.FCache, LDataSize);
    Inst.FPos:= LDataSize;
  end;

  Result:= TF_S_OK;
                                          // if LPadding = TF_PADDING_NONE
                                          // or LPadding:= TF_PADDING_ZERO
                                          //   we are done, else decode padding block
  if Last then begin

    case LPadding of
      TF_PADDING_NONE, TF_PADDING_ZERO: if Inst.FPos > 0 then
        Result:= TF_E_INVALIDARG;
    else
      if (Inst.FPos <> LBlockSize) or (OutCount + Cardinal(LBlockSize) > OutBufSize) then begin
        Result:= TF_E_INVALIDARG;
      end
      else begin
        Move(Inst.FCache, OutBuffer^, LBlockSize);
        DecryptBlock(Inst, OutBuffer);
        XorBytes(OutBuffer, IVector, LBlockSize);
        Move(Inst.FCache, IVector^, LBlockSize);
        Result:= Inst.DecodePad(OutBuffer, LBlockSize, LPadding, Cnt);
(*
        case LPadding of
                                            // XX 00 00 00 04
          TF_PADDING_ANSI: begin
            Cnt:= OutData[LBlockSize - 1];
            if (Cnt > 0) and (Cnt <= LBlockSize) then begin
              SaveCnt:= Cnt;
              while SaveCnt > 1 do begin    // Cnt - 1 zero bytes
                if OutData[LBlockSize - SaveCnt] <> 0 then begin
                  Result:= TF_E_INVALIDPAD;
                  Break;
                end;
                Dec(SaveCnt);
              end;
            end
            else
              Result:= TF_E_INVALIDPAD;
          end;
                                            // XX 04 04 04 04
          TF_PADDING_PKCS: begin
            Cnt:= OutData[LBlockSize - 1];
            if (Cnt > 0) and (Cnt <= LBlockSize) then begin
              SaveCnt:= Cnt;
              while SaveCnt > 1 do begin // Cnt - 1 bytes
                if OutData[LBlockSize - SaveCnt] <> Byte(Cnt) then begin
                  Result:= TF_E_INVALIDPAD;
                  Break;
                end;
                Dec(SaveCnt);
              end;
            end
            else
              Result:= TF_E_INVALIDPAD;
          end;
                                            // XX ?? ?? ?? 04
          TF_PADDING_ISO10126: begin
            Cnt:= OutData[LBlockSize - 1];
            if (Cnt = 0) or (Cnt > LBlockSize) then
              Result:= TF_E_INVALIDPAD;
          end;
                                            // XX 80 00 00 00
          TF_PADDING_ISOIEC: begin
            Cnt:= LBlockSize;
            repeat
              Dec(Cnt);
            until (OutData[Cnt] <> 0) or (Cnt = 0);
            if (OutData[Cnt] = $80) then
              Cnt:= LBlockSize - Cnt
            else
              Result:= TF_E_INVALIDPAD;
          end;
        else
          Result:= TF_E_UNEXPECTED;
        end; { inner case }
        if Result = TF_S_OK then
          Inc(OutCount, LBlockSize - Cnt);
*)
        Inc(OutCount, Cnt);
        FillChar(Inst.FCache, LBlockSize, 0);
        Inst.FPos:= 0;
      end;
    end; { outer case }
  end;
  DataSize:= OutCount;

end;

class function TBlockCipherInstance.DecryptECB(Inst: PBlockCipherInstance;
                 InBuffer, OutBuffer: PByte;
                 var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
var
  DecryptBlock: TCipherHelper.TBlockFunc;
  OutCount: Cardinal;     // number of bytes written to OutData
  LPadding: UInt32;
  LBlockSize: Integer;
  LDataSize: Cardinal;
//  Cnt, SaveCnt: Cardinal;
  Cnt: Cardinal;
  NoPadBlock: Boolean;

begin
  if not ValidDecryptionKey(Inst) then begin
    Result:= TF_E_INVALIDKEY;
    Exit;
  end;

  @DecryptBlock:= TCipherHelper.GetDecryptBlockFunc(Inst);

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  LDataSize:= DataSize;
  OutCount:= 0;

  LPadding:= Inst.FAlgID and TF_PADDING_MASK;
  if LPadding = TF_PADDING_DEFAULT
    then LPadding:= TF_PADDING_PKCS;

  NoPadBlock:= (LPadding = TF_PADDING_NONE) or (LPadding = TF_PADDING_ZERO);

// process cached block
  if LDataSize > 0 then begin
    Cnt:= LBlockSize - Inst.FPos;   // it is possible that Cnt = 0
    if Cnt > LDataSize then Cnt:= LDataSize;
    Move(InBuffer^, Inst.FCache[Inst.FPos], Cnt);
    Inc(InBuffer, Cnt);
    Dec(LDataSize, Cnt);
    Inc(Inst.FPos, Cnt);
    if (Inst.FPos = LBlockSize) and ((LDataSize > 0) or NoPadBlock) then begin
      Inst.FPos:= 0;
      if OutBufSize < Cardinal(LBlockSize) then begin
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      DecryptBlock(Inst, @Inst.FCache);
      Move(Inst.FCache, OutBuffer^, LBlockSize);
      FillChar(Inst.FCache, LBlockSize, 0);
      Inc(OutBuffer, LBlockSize);
      OutCount:= LBlockSize;
    end;
  end;

// process full blocks
  while (LDataSize > Cardinal(LBlockSize)) or ((LDataSize = Cardinal(LBlockSize)) and NoPadBlock) do begin
    if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
    Move(InBuffer^, OutBuffer^, LBlockSize);
    DecryptBlock(Inst, OutBuffer);
    Inc(InBuffer, LBlockSize);
    Dec(LDataSize, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Inc(OutCount, LBlockSize);
  end;

// process last block
  if LDataSize > 0 then begin
    Move(InBuffer^, Inst.FCache, LDataSize);
    Inst.FPos:= LDataSize;
  end;

  Result:= TF_S_OK;
                                          // if LPadding = TF_PADDING_NONE
                                          // or LPadding:= TF_PADDING_ZERO
                                          //   we are done, else decode padding block
  if Last then begin

    case LPadding of
      TF_PADDING_NONE, TF_PADDING_ZERO: if Inst.FPos > 0 then
        Result:= TF_E_INVALIDARG;
    else
      if (Inst.FPos <> LBlockSize) or (OutCount + Cardinal(LBlockSize) > OutBufSize) then begin
        Result:= TF_E_INVALIDARG;
      end
      else begin
        Move(Inst.FCache, OutBuffer^, LBlockSize);
        DecryptBlock(Inst, OutBuffer);
        Result:= Inst.DecodePad(OutBuffer, LBlockSize, LPadding, Cnt);
(*
        case LPadding of
                                            // XX 00 00 00 04
          TF_PADDING_ANSI: begin
            Cnt:= OutData[LBlockSize - 1];
            if (Cnt > 0) and (Cnt <= LBlockSize) then begin
              SaveCnt:= Cnt;
              while SaveCnt > 1 do begin    // Cnt - 1 zero bytes
                if OutData[LBlockSize - SaveCnt] <> 0 then begin
                  Result:= TF_E_INVALIDPAD;
                  Break;
                end;
                Dec(SaveCnt);
              end;
            end
            else
              Result:= TF_E_INVALIDPAD;
          end;
                                            // XX 04 04 04 04
          TF_PADDING_PKCS: begin
            Cnt:= OutData[LBlockSize - 1];
            if (Cnt > 0) and (Cnt <= LBlockSize) then begin
              SaveCnt:= Cnt;
              while SaveCnt > 1 do begin // Cnt - 1 bytes
                if OutData[LBlockSize - SaveCnt] <> Byte(Cnt) then begin
                  Result:= TF_E_INVALIDPAD;
                  Break;
                end;
                Dec(SaveCnt);
              end;
            end
            else
              Result:= TF_E_INVALIDPAD;
          end;
                                            // XX ?? ?? ?? 04
          TF_PADDING_ISO10126: begin
            Cnt:= OutData[LBlockSize - 1];
            if (Cnt = 0) or (Cnt > LBlockSize) then
              Result:= TF_E_INVALIDPAD;
          end;
                                            // XX 80 00 00 00
          TF_PADDING_ISOIEC: begin
            Cnt:= LBlockSize;
            repeat
              Dec(Cnt);
            until (OutData[Cnt] <> 0) or (Cnt = 0);
            if (OutData[Cnt] = $80) then
              Cnt:= LBlockSize - Cnt
            else
              Result:= TF_E_INVALIDPAD;
          end;
        else
          Result:= TF_E_UNEXPECTED;
        end; { inner case }
        if Result = TF_S_OK then
          Inc(OutCount, LBlockSize - Cnt);
*)
        Inc(OutCount, Cnt);
        FillChar(Inst.FCache, LBlockSize, 0);
        Inst.FPos:= 0;
      end;
    end; { outer case }



(*
    case LPadding of
      TF_PADDING_NONE,
      TF_PADDING_ZERO: if Inst.FPos > 0 then begin
        Result:= TF_E_INVALIDARG;
      end;
                                            // XX 00 00 00 04
      TF_PADDING_ANSI: begin
        if (Inst.FPos <> LBlockSize) or (OutCount + LBlockSize > OutSize) then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          DecryptBlock(Inst, @Inst.FCache);
          Cnt:= Inst.FCache[LBlockSize - 1];
          if (Cnt > 0) and (Cnt <= LBlockSize) then begin
            SaveCnt:= Cnt;
            while SaveCnt > 1 do begin // Cnt - 1 zero bytes
              if Inst.FCache[LBlockSize - SaveCnt] <> 0 then begin
                Result:= TF_E_INVALIDPAD;
                Break;
              end;
              Dec(SaveCnt);
            end;
            if Result = TF_S_OK then begin
              Inc(OutCount, LBlockSize - Cnt);
              Move(Inst.FCache, OutData^, LBlockSize - Cnt);
            end;
          end
          else begin
            Result:= TF_E_INVALIDARG;
          end;
        end;
      end;
                                            // XX 04 04 04 04
      TF_PADDING_PKCS: begin
        if (Inst.FPos <> LBlockSize) or (OutCount + LBlockSize > OutSize) then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          DecryptBlock(Inst, @Inst.FCache);
          Cnt:= Inst.FCache[LBlockSize - 1];
          if (Cnt > 0) and (Cnt <= LBlockSize) then begin
            SaveCnt:= Cnt;
            while SaveCnt > 1 do begin // Cnt - 1 bytes
              if Inst.FCache[LBlockSize - SaveCnt] <> Byte(Cnt) then begin
                Result:= TF_E_INVALIDPAD;
                Break;
              end;
              Dec(SaveCnt);
            end;
            if Result = TF_S_OK then begin
              Inc(OutCount, LBlockSize - Cnt);
              Move(Inst.FCache, OutData^, LBlockSize - Cnt);
            end;
          end
          else begin
            Result:= TF_E_INVALIDPAD;
          end;
        end;
      end;
                                            // XX ?? ?? ?? 04
      TF_PADDING_ISO10126: begin
        if (Inst.FPos <> LBlockSize) or (OutCount + LBlockSize > OutSize) then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          DecryptBlock(Inst, @Inst.FCache);
          Cnt:= Inst.FCache[LBlockSize - 1];
          if (Cnt > 0) and (Cnt <= LBlockSize) then begin
            Inc(OutCount, LBlockSize - Cnt);
            Move(Inst.FCache, OutData^, LBlockSize - Cnt);
          end
          else begin
            Result:= TF_E_INVALIDPAD;
          end;
        end;
      end;
                                            // XX 80 00 00 00
      TF_PADDING_ISOIEC: begin
        if (Inst.FPos <> LBlockSize) or (OutCount + LBlockSize > OutSize) then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          DecryptBlock(Inst, @Inst.FCache);
          Cnt:= LBlockSize;
          repeat
            Dec(Cnt);
          until (Inst.FCache[Cnt] <> 0) or (Cnt = 0);
          if (Inst.FCache[Cnt] = $80) then begin
            Inc(OutCount, LBlockSize - Cnt);
            Move(Inst.FCache, OutData^, LBlockSize - Cnt);
          end
          else begin
            Result:= TF_E_INVALIDPAD;
          end;
        end;
      end;
    else
      Result:= TF_E_INVALIDPAD;
    end;
    FillChar(Inst.FCache, LBlockSize, 0);
    Inst.FPos:= 0;
*)
  end;

  DataSize:= OutCount;
end;
{
class function TBlockCipherInstance.GetIsBlockCipher(Inst: Pointer): Boolean;
begin
  Result:= True;
end;
}
class function TBlockCipherInstance.GetIV(Inst: PBlockCipherInstance;
  IV: Pointer; IVLen: Cardinal): TF_RESULT;
var
  LBlockSize: Cardinal;
  IVector: PByte;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  IVector:= PByte(@Inst.FCache) + LBlockSize;

  if (IVLen = LBlockSize) then begin
    Move(IVector^, IV^, IVLen);
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;

end;

class function TBlockCipherInstance.GetIVPointer(Inst: PBlockCipherInstance): Pointer;
var
  LBlockSize: Cardinal;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= nil;
    Exit;
  end;
{$ENDIF}

  Result:= PByte(@Inst.FCache) + LBlockSize;
end;

class function TBlockCipherInstance.GetKeyBlockCTR(
                 Inst: PBlockCipherInstance; Data: PByte): TF_RESULT;
var
  LBlockSize{, Cnt}: Cardinal;
  IVector: PByte;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  IVector:= PByte(@Inst.FCache) + LBlockSize;

  Move(IVector^, Data^, LBlockSize);            // copy IV to Data block
  TCipherHelper.EncryptBlock(Inst, Data);       // encrypt Data block
  TBigEndian.Incr(IVector, LBlockSize);         // increment IV
(*
  Cnt:= LBlockSize - 1;                         // increment IV
  Inc(IVector[Cnt]);
  if IVector[Cnt] = 0 then begin
    repeat
      Dec(Cnt);
      Inc(IVector[Cnt]);
    until (IVector[Cnt] <> 0) or (Cnt = 0);
  end;
*)
  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.GetNonce(Inst: PBlockCipherInstance;
  var Nonce: UInt64): TF_RESULT;
var
  LBlockSize: Cardinal;
  IVector: PByte;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  IVector:= PByte(@Inst.FCache) + LBlockSize;

  if (LBlockSize < 16) then
    Nonce:= 0
  else
    Move(IVector^, Nonce, SizeOf(Nonce));

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.IncBlockNoCTR(Inst: PBlockCipherInstance;
  Count: UInt64): TF_RESULT;
var
  LBlockSize: Cardinal;
  LCount: UInt64;
  PIV: PByte;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  PIV:= PByte(@PBlockCipherInstance(Inst).FCache) + LBlockSize;

// convert Count to big-endian
  TBigEndian.ReverseCopy(@Count, PByte(@Count) + SizeOf(UInt64), @LCount);

  TBigEndian.Add(PIV, LBlockSize, @LCount, SizeOf(UInt64));

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.DecBlockNoCTR(Inst: PBlockCipherInstance;
  Count: UInt64): TF_RESULT;
var
  LBlockSize: Cardinal;
  LCount: UInt64;
  PIV: PByte;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  PIV:= PByte(@PBlockCipherInstance(Inst).FCache) + LBlockSize;

// convert Count to big-endian
  TBigEndian.ReverseCopy(@Count, PByte(@Count) + SizeOf(UInt64), @LCount);

  TBigEndian.Sub(PIV, LBlockSize, @LCount, SizeOf(UInt64));

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.SkipCTR(Inst: PBlockCipherInstance;
                 Dist: Int64): TF_RESULT;
var
  LBlockSize: UInt64;
  Count, LCount: UInt64;
  Cnt: Cardinal;
  PIV: PByte;

begin
  if Dist = 0 then begin
    Result:= TF_S_OK;
    Exit;
  end;

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  PIV:= PByte(@PBlockCipherInstance(Inst).FCache) + LBlockSize;

  if Dist > 0 then begin
    Count:= UInt64(Dist) div LBlockSize;
    Cnt:= UInt64(Dist) mod LBlockSize;
    Inc(Inst.FPos, Cnt);
    if Inst.FPos >= LBlockSize then begin
      Inc(Count);
      Dec(Inst.FPos, LBlockSize);
    end;

    TBigEndian.ReverseCopy(@Count, PByte(@Count) + SizeOf(UInt64), @LCount);
    TBigEndian.Add(PIV, LBlockSize, @LCount, SizeOf(UInt64));
  end
  else begin
    Count:= UInt64(-Dist) div LBlockSize;
    Cnt:= UInt64(-Dist) mod LBlockSize;
    Dec(Inst.FPos, Cnt);
    if Inst.FPos < 0 then begin
      Inc(Count);
      Inc(Inst.FPos, LBlockSize);
    end;

    TBigEndian.ReverseCopy(@Count, PByte(@Count) + SizeOf(UInt64), @LCount);
    TBigEndian.Sub(PIV, LBlockSize, @LCount, SizeOf(UInt64));
  end;
  if Inst.FPos > 0 then
    Result:= GetKeyBlockCTR(Inst, @Inst.FCache)
  else
    Result:= TF_S_OK;
end;

class function TBlockCipherInstance.SetIV(Inst: Pointer;
  IV: Pointer; IVLen: Cardinal): TF_RESULT;
var
  LBlockSize: Cardinal;
  PIV: PByte;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  PIV:= PByte(@PBlockCipherInstance(Inst).FCache) + LBlockSize;

  if (IV = nil) then begin
    if (IVLen = 0) or (IVLen = LBlockSize) then begin
      FillChar(PIV^, LBlockSize, 0);
      Result:= TF_S_OK;
    end
    else begin
      Result:= TF_E_INVALIDARG;
    end;
    Exit;
  end;

  if (IVLen = LBlockSize) then begin
    Move(IV^, PIV^, IVLen);
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;

end;

class function TBlockCipherInstance.SetNonce(Inst: PBlockCipherInstance;
  Nonce: TNonce): TF_RESULT;
var
  LBlockSize: Cardinal;
  IVector: PByte;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  IVector:= PByte(@Inst.FCache) + LBlockSize;

// IV consists of 2 parts: Nonce and BlockNo;
//   if BlockSize >= 16 (128 bits),
//     then both Nonce and BlockNo are of 8 bytes (64 bits);
//     nonce is the leftmost 8 bytes, blockno is the rightmost 6 bytes.
//   if BlockSize < 16 (128 bits),
//     then whole IV is BlockNo, and the only valid nonce value is zero.
//   if BlockSize > 16 (128 bits),
//     then (BlockSize - 16) bytes of IV between Nonce and BlockNo are zeroed.
//   BlockNo bytes of IV are zeroed.

  FillChar(IVector^, LBlockSize, 0);

  if (LBlockSize < 16) then begin
    if (Nonce <> 0) then
      Result:= TF_E_INVALIDARG
    else
      Result:= TF_S_OK;
    Exit;
  end;

  Move(Nonce, IVector^, SizeOf(Nonce));
  Result:= TF_S_OK;
end;

end.
