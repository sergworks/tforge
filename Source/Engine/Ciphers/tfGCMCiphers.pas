{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # GCM mode of operation for 128-bit block ciphers
}

unit tfGCMCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfGHash, tfCipherInstances, SysUtils;

type
  PGCMCipherInstance = ^TGCMCipherInstance;
  TGCMCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
{$HINTS ON}
    FPos:      Integer;
    FCache:    array[0..15] of Byte;
    FCounter:  array[0..15] of Byte;
    FH:        array[0..15] of Byte;
    FAuthSize: UInt64;
    FDataSize: UInt64;
    FGHash:    TGHash;
  public
    class function SetIV(Inst: PGcmCipherInstance; IV: Pointer; IVLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetNonce(Inst: PGcmCipherInstance; Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function AddAuthData(Inst: PGCMCipherInstance; Data: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Encrypt(Inst: PGCMCipherInstance; InData, OutData: PByte;
                     DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Decrypt(Inst: PGCMCipherInstance; InData, OutData: PByte;
                     DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ComputeTag(Inst: PGCMCipherInstance; Tag: PByte;
                     TagSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function CheckTag(Inst: PGCMCipherInstance; Tag: PByte;
                     TagSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;


implementation

uses
  tfCipherHelpers, tfUtils;


function Swap64(Value: UInt64): UInt64;
begin
  Result:= (Value and $00000000000000FF) shl 56
        or (Value and $000000000000FF00) shl 40
        or (Value and $0000000000FF0000) shl 24
        or (Value and $00000000FF000000) shl 8
        or (Value and $000000FF00000000) shr 8
        or (Value and $0000FF0000000000) shr 24
        or (Value and $00FF000000000000) shr 40
        or (Value and $FF00000000000000) shr 56;
end;

{ TGCMCipherInstance }

// max supported IV size is 2^29-1
class function TGCMCipherInstance.AddAuthData(Inst: PGCMCipherInstance;
                 Data: PByte; DataSize: Cardinal): TF_RESULT;
begin
  if Inst.FKeyFlags and TF_KEYFLAG_STARTED = 0 then begin
    Inst.FGHash.Update(Data, DataSize);
    Inst.FAuthSize:= Inst.FAuthSize + DataSize;
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_UNEXPECTED;
end;

class function TGCMCipherInstance.CheckTag(Inst: PGCMCipherInstance; Tag: PByte;
  TagSize: Cardinal): TF_RESULT;
begin
  Result:= TF_E_INVALIDARG;
  if TagSize <= 16 then begin
    ComputeTag(Inst, @Inst.FCounter, 16);
    if CompareMem(@Inst.FCounter, Tag, TagSize) then
      Result:= TF_S_OK;
  end;
end;

class function TGCMCipherInstance.ComputeTag(Inst: PGCMCipherInstance;
  Tag: PByte; TagSize: Cardinal): TF_RESULT;
var
  Sizes: array[0..1] of UInt64;
  I: Integer;

begin
  if TagSize <= 16 then begin
    Inst.FGHash.Pad();
    Sizes[0]:= Swap64(Inst.FAuthSize * 8);
    Sizes[1]:= Swap64(Inst.FDataSize * 8);
    Inst.FGHash.Update(@Sizes, SizeOf(Sizes));
    FillChar(Sizes, SizeOf(Sizes), 0);
    Inst.FGHash.Done(@Inst.FCache, 16);

    for I:= 0 to 15 do
      Inst.FCache[I]:= Inst.FCache[I] xor Inst.FH[I];

    Move(Inst.FCache, Tag^, TagSize);
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;
end;

class function TGCMCipherInstance.Decrypt(Inst: PGCMCipherInstance; InData,
  OutData: PByte; DataSize: Cardinal): TF_RESULT;
var
  PCache: PByte;
  Size: Cardinal;

begin
// todo: Check TF_KEYFLAG_KEY and TF_KEYFLAG_IV

  if Inst.FKeyFlags and TF_KEYFLAG_STARTED = 0 then begin
// finalize auth data processing
    Inst.FGHash.Pad();
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_STARTED;
  end;

// InData and OutData can be identical;
//   hash the ciphertext before we lost it
  Inst.FGHash.Update(InData, DataSize);
  Inc(Inst.FDataSize, DataSize);

// decrypt the ciphertext (using EncryptBlock because CTR mode)
  while DataSize > 0 do begin
    if Inst.FPos = 16 then begin
      TBigEndian.Incr(@Inst.FCounter[12], PByte(@Inst.FCounter) + 16);
      Move(Inst.FCounter, Inst.FCache, 16);
      TCipherHelper.EncryptBlock(Inst, @Inst.FCache);
      Inst.FPos:= 0;
    end;
    Size:= 16 - Inst.FPos;
    if Size > DataSize then
      Size:= DataSize;
    PCache:= @Inst.FCache[Inst.FPos];
    Inc(Inst.FPos, Size);
    Dec(DataSize, Size);
    while Size > 0 do begin
      OutData^:= InData^ xor PCache^;
      Inc(OutData);
      Inc(InData);
      Inc(PCache);
      Dec(Size);
    end;
  end;
{
  if Last then begin
    FillChar(Inst.FCache, SizeOf(Inst.FCache), 0);
    Inst.FPos:= 16;
  end;
}
  Result:= TF_S_OK;
end;

class function TGCMCipherInstance.Encrypt(Inst: PGCMCipherInstance;
                 InData, OutData: PByte; DataSize: Cardinal): TF_RESULT;
var
  POutData, PCache: PByte;
  LDataSize: Cardinal;
  Size: Cardinal;

begin
// todo: Check TF_KEYFLAG_KEY and TF_KEYFLAG_IV

  if Inst.FKeyFlags and TF_KEYFLAG_STARTED = 0 then begin
// finalize auth data processing
    Inst.FGHash.Pad();
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_STARTED;
  end;

  POutData:= OutData;
  LDataSize:= DataSize;
  while LDataSize > 0 do begin
    if Inst.FPos = 16 then begin
      TBigEndian.Incr(@Inst.FCounter[12], PByte(@Inst.FCounter) + 16);
      Move(Inst.FCounter, Inst.FCache, 16);
      TCipherHelper.EncryptBlock(Inst, @Inst.FCache);
      Inst.FPos:= 0;
    end;
    Size:= 16 - Inst.FPos;
    if Size > LDataSize then
      Size:= LDataSize;
    PCache:= @Inst.FCache[Inst.FPos];
    Inc(Inst.FPos, Size);
    Dec(LDataSize, Size);
//    if Inst.FPos = 16 then
//      Inst.FPos:= 0;
    while Size > 0 do begin
      POutData^:= InData^ xor PCache^;
      Inc(POutData);
      Inc(InData);
      Inc(PCache);
      Dec(Size);
    end;
  end;
  Inst.FGHash.Update(OutData, DataSize);
  Inst.FDataSize:= Inst.FDataSize + DataSize;
{
  if Last then begin
    FillChar(Inst.FCache, SizeOf(Inst.FCache), 0);
    Inst.FPos:= 16;
  end;
}
  Result:= TF_S_OK;
end;


class function TGCMCipherInstance.SetIV(Inst: PGcmCipherInstance;
                 IV: Pointer; IVLen: Cardinal): TF_RESULT;
var
  Sizes: array[0..1] of UInt64;

begin
  if (IVLen = 12) then begin
    Move(IV^, Inst.FCounter, 12);
    Inst.FCounter[12]:= 0;
    Inst.FCounter[13]:= 0;
    Inst.FCounter[14]:= 0;
    Inst.FCounter[15]:= 1;
  end
  else begin
    FillChar(Inst.FH, SizeOf(Inst.FH), 0);
    TCipherHelper.EncryptBlock(Inst, @Inst.FH);
    Inst.FGHash.Init(@Inst.FH);
    Inst.FGHash.Update(IV, IVLen);
    Inst.FGHash.Pad;
    Sizes[0]:= 0;                            // auth data bit length
    Sizes[1]:= Swap64(UInt64(IVLen * 8));    // IV bit length
    Inst.FGHash.Update(@Sizes, SizeOf(Sizes));
    FillChar(Sizes, SizeOf(Sizes), 0);
    Inst.FGHash.Done(@Inst.FCounter, SizeOf(Inst.FCounter));
  end;

  Inst.FAuthSize:= 0;
  Inst.FDataSize:= 0;

// force counter increment at first encrypt or decrypt invocation
  Inst.FPos:= 16;

// prepare GHash for hashing auth data
  FillChar(Inst.FH, SizeOf(Inst.FH), 0);
  TCipherHelper.EncryptBlock(Inst, @Inst.FH);
  Inst.FGHash.Init(@Inst.FH);

// save encrypted initial counter for final tag computation
  Move(Inst.FCounter, Inst.FH, SizeOf(Inst.FH));
  TCipherHelper.EncryptBlock(Inst, @Inst.FH);

// not needed - allow auth data processing
//  Inst.FKeyFlags:= Inst.FKeyFlags and not TF_KEYFLAG_STARTED;
  Inst.FKeyFlags:= Inst.FKeyFlags and TF_KEYFLAG_IV;
  Result:= TF_S_OK;
end;

class function TGCMCipherInstance.SetNonce(Inst: PGcmCipherInstance; Nonce: TNonce): TF_RESULT;
type
  UInt64Rec = record
    Lo, Hi: UInt32;
  end;

var
  IV: array[0..2] of UInt32;

begin
  IV[0]:= 0;
  IV[1]:= UInt64Rec(Nonce).Lo;
  IV[2]:= UInt64Rec(Nonce).Hi;
  Result:= SetIV(Inst, @IV, SizeOf(IV));
end;

(*
procedure TGCMCipherInstance.SetIV(IV: PByte; IVSize: Cardinal);
var
  Sizes: array[0..1] of UInt64;

begin
  if (IVSize = 12) then begin
    Move(IV^, FCounter, 12);
    FCounter[12]:= 0;
    FCounter[13]:= 0;
    FCounter[14]:= 0;
    FCounter[15]:= 1;
  end
  else begin
    FillChar(FH, SizeOf(FH), 0);
    TCipherHelper.EncryptBlock(@Self, @FH);
    FGHash.Init(@FH);
    FGHash.Update(IV, IVSize);
    FGHash.Pad;
    Sizes[0]:= 0;                            // auth data bit length
    Sizes[1]:= Swap64(UInt64(IVSize * 8));   // IV bit length
    FGHash.Update(@Sizes, SizeOf(Sizes));
    FillChar(Sizes, SizeOf(Sizes), 0);
    FGHash.Done(@FCounter, SizeOf(FCounter));
  end;

  FAuthSize:= 0;
  FDataSize:= 0;

// force counter increment at first encrypt or decrypt invocation
  FPos:= 16;

// prepare GHash for hashing auth data
  FillChar(FH, SizeOf(FH), 0);
  TCipherHelper.EncryptBlock(@Self, @FH);
  FGHash.Init(@FH);

// save encrypted initial counter for final tag computation
  Move(FCounter, FH, SizeOf(FH));
  TCipherHelper.EncryptBlock(@Self, @FH);

// allow auth data processing
  FKeyFlags:= FKeyFlags and not TF_KEYFLAG_STARTED;
//  FKeyFlags:= FKeyFlags and not TF_KEYFLAG_EXT;
end;
*)

end.
