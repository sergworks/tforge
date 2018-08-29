{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # generic block cipher
}

unit tfBlockCiphers;

{$I TFL.inc}
{$R-}

interface

uses
  tfTypes, tfUtils, tfCipherInstances;

type
  PBlockCipherInstance = ^TBlockCipherInstance;
  TBlockCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
{$HINTS ON}
//
// the semantics of FPos field depends on the mode of operation;
// for block modes (ECB, CBC) FPos is number of cached
//   plaintext(encryption)/ciphertext(decryption) bytes, 0..BlockSize-1
// for stream modes (CFB, OFB, CTR) the cache is either empty
//   or contains keystream block;
//   FPos = 0..BlockSize is number of used keystream bytes;
//   FPos = BlockSize is the same as cache is empty.
//  CFB and OFB modes use IV field instead of FCache for keystream caching
//
    FPos:      Integer;
    FCache: array[0..0] of Byte;

    function DecodePad(PadBlock: PByte; BlockSize: Cardinal;
                         Padding: UInt32; out PayLoad: Cardinal): TF_RESULT;
  public
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
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptCBC(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptCTR(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyStreamCTR(Inst: PBlockCipherInstance; Data: PByte;
                     DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptCFB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptOFB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptUpdateECB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptUpdateECB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptECB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptCBC(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptCFB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptUpdateCBC(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptUpdateCBC(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptUpdateCFB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptUpdateCFB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptUpdateOFB(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptUpdateCTR(Inst: PBlockCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyBlockCTR(Inst: PBlockCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
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
  end;

implementation

uses
  tfHelpers, tfCipherHelpers;

(*
function ValidKey(Inst: PBlockCipherInstance): Boolean; inline;
begin
  Result:= (Inst.FKeyFlags and TF_KEYFLAG_KEY <> 0);
end;

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
*)

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
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  IVector: PByte;
  LBlockSize: Integer;

begin
  if not TCipherInstance.ValidEncryptionKey(Inst) then begin
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

  if (Inst.FAlgID and TF_PADDING_MASK <> TF_PADDING_NONE) or (Inst.FPos <> 0) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  if DataSize mod Cardinal(LBlockSize) <> 0 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// encrypt  complete blocks
  while DataSize > 0 do begin
    Move(InBuffer^, OutBuffer^, LBlockSize);
    XorBytes(OutBuffer, IVector, LBlockSize);
    EncryptBlock(Inst, OutBuffer);
    Move(OutBuffer^, IVector^, LBlockSize);

    Inc(InBuffer, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Dec(DataSize, LBlockSize);
  end;

// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.EncryptCFB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  IVector, IV: PByte;
  LBlockSize: Integer;
  Cnt: Integer;

begin
  if not TCipherInstance.ValidEncryptionKey(Inst) then begin
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

  while DataSize > 0 do begin
    if Inst.FPos = LBlockSize then begin
      EncryptBlock(Inst, IVector);
      Inst.FPos:= 0;
    end;
    Cnt:= LBlockSize - Inst.FPos;

{$IFDEF DEBUG}
    if (Cnt < 0) then begin
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
{$ENDIF}

    if Cardinal(Cnt) > DataSize then
      Cnt:= DataSize;
    IV:= @IVector[Inst.FPos];
    Inc(Inst.FPos, Cnt);
    Dec(DataSize, Cnt);
    while Cnt > 0 do begin
      IV^:= IV^ xor InBuffer^;
      OutBuffer^:= IV^;
      Inc(OutBuffer);
      Inc(InBuffer);
      Inc(IV);
      Dec(Cnt);
    end;
  end;
{
  if Last then begin
    FillChar(IVector, LBlockSize, 0);
    Inst.FPos:= LBlockSize;
  end;
}

// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.EncryptCTR(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  IVector, PCache: PByte;
  LBlockSize: Integer;
  Cnt: Integer;

begin
  if not TCipherInstance.ValidKey(Inst) then begin
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

  while DataSize > 0 do begin
    if Inst.FPos = LBlockSize then begin
      Move(IVector^, Inst.FCache, LBlockSize);
      TBigEndian.Incr(IVector, IVector + LBlockSize);
      EncryptBlock(Inst, @Inst.FCache);
      Inst.FPos:= 0;
    end;
    Cnt:= LBlockSize - Inst.FPos;

{$IFDEF DEBUG}
    if (Cnt < 0) then begin
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
{$ENDIF}

    if Cardinal(Cnt) > DataSize then
      Cnt:= DataSize;
    PCache:= @Inst.FCache[Inst.FPos];
    Inc(Inst.FPos, Cnt);
    Dec(DataSize, Cnt);
    while Cnt > 0 do begin
      OutBuffer^:= InBuffer^ xor PCache^;
      Inc(OutBuffer);
      Inc(InBuffer);
      Inc(PCache);
      Dec(Cnt);
    end;
  end;

// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.GetKeyStreamCTR(Inst: PBlockCipherInstance;
                 Data: PByte; DataSize: Cardinal): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  IVector, PCache: PByte;
  LBlockSize: Integer;
  Cnt: Integer;

begin
  if not TCipherInstance.ValidKey(Inst) then begin
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

  while DataSize > 0 do begin
    if Inst.FPos = LBlockSize then begin
      Move(IVector^, Inst.FCache, LBlockSize);
      TBigEndian.Incr(IVector, IVector + LBlockSize);
      EncryptBlock(Inst, @Inst.FCache);
      Inst.FPos:= 0;
    end;
    Cnt:= LBlockSize - Inst.FPos;

{$IFDEF DEBUG}
    if (Cnt < 0) then begin
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
{$ENDIF}

    if Cardinal(Cnt) > DataSize then
      Cnt:= DataSize;
    PCache:= @Inst.FCache[Inst.FPos];
    Inc(Inst.FPos, Cnt);
    Dec(DataSize, Cnt);
    if Cnt = LBlockSize then begin
      Move(Data^, PCache^, LBlockSize);
      Inc(Data, LBlockSize);
    end
    else while Cnt > 0 do begin
      Data^:= PCache^;
      Inc(Data);
      Inc(PCache);
      Dec(Cnt);
    end;
  end;
  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.EncryptECB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  LBlockSize: Integer;

begin
  if not TCipherInstance.ValidEncryptionKey(Inst) then begin
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

  if (Inst.FAlgID and TF_PADDING_MASK <> TF_PADDING_NONE) or (Inst.FPos <> 0) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  if DataSize mod Cardinal(LBlockSize) <> 0 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// encrypt  complete blocks
  while DataSize > 0 do begin
    Move(InBuffer^, OutBuffer^, LBlockSize);
    EncryptBlock(Inst, OutBuffer);
    Inc(InBuffer, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Dec(DataSize, LBlockSize);
  end;

// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.EncryptOFB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  IVector, IV: PByte;
  LBlockSize: Integer;
  Cnt: Integer;

begin
  if not TCipherInstance.ValidKey(Inst) then begin
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

  while DataSize > 0 do begin
    if Inst.FPos = LBlockSize then begin
      EncryptBlock(Inst, IVector);
      Inst.FPos:= 0;
    end;
    Cnt:= LBlockSize - Inst.FPos;

{$IFDEF DEBUG}
    if (Cnt < 0) then begin
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
{$ENDIF}

    if Cardinal(Cnt) > DataSize then
      Cnt:= DataSize;
    IV:= @IVector[Inst.FPos];
    Inc(Inst.FPos, Cnt);
    Dec(DataSize, Cnt);
    while Cnt > 0 do begin
      OutBuffer^:= InBuffer^ xor IV^;
      Inc(OutBuffer);
      Inc(InBuffer);
      Inc(IV);
      Dec(Cnt);
    end;
  end;
{
  if Last then begin
    FillChar(IVector, LBlockSize, 0);
    Inst.FPos:= LBlockSize;
  end;
}

// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.EncryptUpdateCBC(Inst: PBlockCipherInstance;
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
  if not TCipherInstance.ValidEncryptionKey(Inst) then begin
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
      TF_PADDING_PKCS: begin
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
      TF_PADDING_ISO: begin
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
//    FillChar(Inst.FCache, LBlockSize, 0);
//    Inst.FPos:= 0;

// Burn clears FKeyFlags field and invalidates Key
    TForgeHelper.Burn(Inst);
  end;

  DataSize:= OutCount;
end;

class function TBlockCipherInstance.EncryptUpdateCFB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; var DataSize: Cardinal; OutBufSize: Cardinal;
  Last: Boolean): TF_RESULT;
begin
  if OutBufSize < DataSize then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end
  else
    Result:= EncryptCFB(Inst, InBuffer, OutBuffer, DataSize, Last);
end;

class function TBlockCipherInstance.EncryptUpdateCTR(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; var DataSize: Cardinal; OutBufSize: Cardinal;
  Last: Boolean): TF_RESULT;
begin
  if OutBufSize < DataSize then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end
  else
    Result:= EncryptCTR(Inst, InBuffer, OutBuffer, DataSize, Last);
end;

class function TBlockCipherInstance.EncryptUpdateECB(Inst: PBlockCipherInstance;
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
  if not TCipherInstance.ValidEncryptionKey(Inst) then begin
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
      TF_PADDING_PKCS: begin
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
      TF_PADDING_ISO: begin
        if OutCount + Cardinal(LBlockSize) > OutBufSize then begin
          Result:= TF_E_INVALIDARG;
        end
        else begin
          Inst.FCache[Inst.FPos]:= $80;
          FillChar(Inst.FCache[Inst.FPos + 1], Cnt - 1, 0);
          EncryptBlock(Inst, @Inst.FCache);
          Move(Inst.FCache, OutBuffer^, LBlockSize);
          Inc(OutCount, LBlockSize);
        end;
      end;
    end;
//    FillChar(Inst.FCache, LBlockSize, 0);
//    Inst.FPos:= 0;

// Burn clears FKeyFlags field and invalidates Key
    TForgeHelper.Burn(Inst);
  end;

  DataSize:= OutCount;
end;

class function TBlockCipherInstance.EncryptUpdateOFB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; var DataSize: Cardinal; OutBufSize: Cardinal;
  Last: Boolean): TF_RESULT;
begin
  if OutBufSize < DataSize then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end
  else
    Result:= EncryptOFB(Inst, InBuffer, OutBuffer, DataSize, Last);
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
                                      // XX ?? ?? ?? 04
    TF_PADDING_ANSI: begin
      Cnt:= PadBlock[BlockSize - 1];
      if (Cnt <= 0) or (Cnt > BlockSize) then
        Result:= TF_E_INVALIDPAD;
      Cnt:= PadBlock[BlockSize - 1];
{
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
}
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
                                      // XX 80 00 00 00
    TF_PADDING_ISO: begin
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
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  DecryptBlock: TCipherHelper.TBlockFunc;
  IVector: PByte;
  LBlockSize: Integer;

begin
  if not TCipherInstance.ValidDecryptionKey(Inst) then begin
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

  if (Inst.FAlgID and TF_PADDING_MASK <> TF_PADDING_NONE) or (Inst.FPos <> 0) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  if DataSize mod Cardinal(LBlockSize) <> 0 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  IVector:= PByte(@Inst.FCache) + LBlockSize;

// decrypt complete blocks
  while DataSize > 0 do begin
    Move(InBuffer^, OutBuffer^, LBlockSize);
// since InBuffer and OutBuffer can be identical
//   we store InBuffer block in intermediate buffer
    Move(InBuffer^, Inst.FCache, LBlockSize);
    DecryptBlock(Inst, OutBuffer);
    XorBytes(OutBuffer, IVector, LBlockSize);
    Move(Inst.FCache, IVector^, LBlockSize);

    Inc(InBuffer, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Dec(DataSize, LBlockSize);
  end;

// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.DecryptCFB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  EncryptBlock: TCipherHelper.TBlockFunc;
  IVector, IV: PByte;
  LBlockSize: Integer;
  Cnt: Integer;
  Tmp: Byte;

begin
  if not TCipherInstance.ValidDecryptionKey(Inst) then begin
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

  while DataSize > 0 do begin
    if Inst.FPos = LBlockSize then begin
      EncryptBlock(Inst, IVector);
      Inst.FPos:= 0;
    end;
    Cnt:= LBlockSize - Inst.FPos;

{$IFDEF DEBUG}
    if (Cnt < 0) then begin
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
{$ENDIF}

    if Cardinal(Cnt) > DataSize then
      Cnt:= DataSize;
    IV:= @IVector[Inst.FPos];
    Inc(Inst.FPos, Cnt);
    Dec(DataSize, Cnt);
    while Cnt > 0 do begin
      Tmp:= InBuffer^;
      OutBuffer^:= IV^ xor Tmp;
      Inc(OutBuffer);
      Inc(InBuffer);
      Inc(IV);
      IV^:= Tmp;
      Dec(Cnt);
    end;
//    Tmp:= 0;
  end;
{
  if Last then begin
    FillChar(IVector, LBlockSize, 0);
    Inst.FPos:= LBlockSize;
  end;
}
// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.DecryptECB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  DecryptBlock: TCipherHelper.TBlockFunc;
  LBlockSize: Integer;

begin
  if not TCipherInstance.ValidDecryptionKey(Inst) then begin
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

  if (Inst.FAlgID and TF_PADDING_MASK <> TF_PADDING_NONE) or (Inst.FPos <> 0) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  if DataSize mod Cardinal(LBlockSize) <> 0 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// decrypt complete blocks
  while DataSize > 0 do begin
    Move(InBuffer^, OutBuffer^, LBlockSize);
    DecryptBlock(Inst, OutBuffer);
    Inc(InBuffer, LBlockSize);
    Inc(OutBuffer, LBlockSize);
    Dec(DataSize, LBlockSize);
  end;

// Burn clears FKeyFlags field and invalidates Key
  if Last then
    TForgeHelper.Burn(Inst);

  Result:= TF_S_OK;
end;

class function TBlockCipherInstance.DecryptUpdateCBC(Inst: PBlockCipherInstance;
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
  if not TCipherInstance.ValidDecryptionKey(Inst) then begin
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
        Inc(OutCount, Cnt);
//        FillChar(Inst.FCache, LBlockSize, 0);
//        Inst.FPos:= 0;
      end;
    end; { outer case }

// Burn clears FKeyFlags field and invalidates Key
    TForgeHelper.Burn(Inst);
  end;
  DataSize:= OutCount;

end;

class function TBlockCipherInstance.DecryptUpdateCFB(Inst: PBlockCipherInstance;
  InBuffer, OutBuffer: PByte; var DataSize: Cardinal; OutBufSize: Cardinal;
  Last: Boolean): TF_RESULT;
begin
  if OutBufSize < DataSize then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end
  else
    Result:= DecryptCFB(Inst, InBuffer, OutBuffer, DataSize, Last);
end;

class function TBlockCipherInstance.DecryptUpdateECB(Inst: PBlockCipherInstance;
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
  if not TCipherInstance.ValidDecryptionKey(Inst) then begin
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
        Inc(OutCount, Cnt);
//        FillChar(Inst.FCache, LBlockSize, 0);
//        Inst.FPos:= 0;
      end;
    end; { outer case }

// Burn clears FKeyFlags field and invalidates Key
    TForgeHelper.Burn(Inst);

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
  LMode: TAlgID;

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

  LMode:= PBlockCipherInstance(Inst).FAlgID and TF_KEYMODE_MASK;
  case LMode of
    TF_KEYMODE_ECB,
    TF_KEYMODE_CBC: PBlockCipherInstance(Inst).FPos:= 0;
  else
    PBlockCipherInstance(Inst).FPos:= LBlockSize;
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
