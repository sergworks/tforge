{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2018         * }
{ *********************************************************** }

unit tfEvpCiphers;

interface

{$I TFL.INC}

uses
  tfTypes, tfOpenSSL;

type
  PEvpCipherInstance = ^TEvpCipherInstance;
  TEvpCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;

    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
    FCtx:      PEVP_CIPHER_CTX;
//    FInit:     TEVP_CipherInit;
    FUpdate:   TEVP_CipherUpdate;
    FFinal:    TEVP_CipherFinal;
{$HINTS ON}
  public
    function InitCtx: TF_RESULT;
    function FreeCtx: TF_RESULT;

//    class function Release(Inst: Pointer): Integer; stdcall; static;
    class procedure Burn(Inst: PEvpCipherInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Clone(Inst: PEvpCipherInstance; var NewInst: PEvpCipherInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKey(Inst: PEvpCipherInstance; Key: PByte; KeySize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

//    class function UpdateBlock(Inst: PEvpCipherInstance; Data: PByte): TF_RESULT;
//          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

//    class function GetRand(Inst: Pointer; Data: PByte; DataSize: Cardinal): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function RandBlock(Inst: Pointer; Data: PByte): TF_RESULT;
//          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function RandCrypt(Inst: Pointer; Data: PByte; DataSize: Cardinal;
//      Last: Boolean): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

//    class function SetKeyParam(Inst: PEvpCipherInstance; Param: UInt32; Data: Pointer;
//      DataLen: Cardinal): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function GetKeyParam(Inst: PEvpCipherInstance; Param: UInt32; Data: Pointer;
//      var DataLen: Cardinal): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function Encrypt(Inst: PEvpCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Decrypt(Inst: PEvpCipherInstance; InBuffer, OutBuffer: PByte;
                     var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKeyNonce(Inst: PEvpCipherInstance; Key: PByte; KeySize: Cardinal;
                     Nonce: UInt64): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
end;

implementation

uses
  tfRecords, tfHelpers, tfCipherHelpers;

{ TEvpCipher }

(*
procedure BurnKey(Inst: PEvpCipherInstance); inline;
//var
//  BurnSize: Integer;

begin
  if Inst.FCtx <> nil then begin
// release encryption context
    if @EVP_CIPHER_CTX_free <> nil then
      EVP_CIPHER_CTX_free(Inst.FCtx);
    Inst.FCtx:= nil;
  end;
  Inst.FKeyFlags:= 0;
end;
*)
(*
class function TEvpCipherInstance.RandBlock(Inst: Pointer;
  Data: PByte): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TEvpCipherInstance.RandCrypt(Inst: Pointer; Data: PByte;
  DataSize: Cardinal; Last: Boolean): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;
*)
(*
class function TEvpCipherInstance.Release(Inst: Pointer): Integer;
begin
  if PEvpCipherInstance(Inst).FRefCount > 0 then begin
    Result:= tfDecrement(PEvpCipherInstance(Inst).FRefCount);
    if Result = 0 then begin
      BurnKey(Inst);
      FreeMem(Inst);
    end;
  end
  else
    Result:= PEvpCipherInstance(Inst).FRefCount;
end;
*)

class procedure TEvpCipherInstance.Burn(Inst: PEvpCipherInstance);
begin
  if Inst.FCtx <> nil then begin
// release encryption context
    if @EVP_CIPHER_CTX_free <> nil then
      EVP_CIPHER_CTX_free(Inst.FCtx);
    Inst.FCtx:= nil;
  end;
  Inst.FKeyFlags:= 0;
  @Inst.FUpdate:= nil;
  @Inst.FFinal:= nil;
end;

class function TEvpCipherInstance.Clone(Inst: PEvpCipherInstance;
  var NewInst: PEvpCipherInstance): TF_RESULT;
var
  Tmp: PEvpCipherInstance;

begin
  try
    GetMem(Tmp, SizeOf(TEvpCipherInstance));
    Move(Inst^, Tmp^, SizeOf(TEvpCipherInstance));
    Tmp.FRefCount:= 1;

    TForgeHelper.Free(NewInst);
    NewInst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TEvpCipherInstance.Encrypt(Inst: PEvpCipherInstance;
                 InBuffer, OutBuffer: PByte;
                 var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
var
  Size: Integer;
  TotalSize: Integer;
  RC: Integer;

begin
  if not Assigned(Inst.FUpdate) or not Assigned(Inst.FFinal) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
  RC:= Inst.FUpdate(Inst.FCtx, OutBuffer, Size, InBuffer, DataSize);
  if RC <> 1 then begin
    Result:= TF_E_OSSL;
    Exit;
  end;
// Size contains number of bytes written to OutBuffer by FUpdate
  TotalSize:= Size;
  if Last then begin
    Inc(OutBuffer, Size);
    RC:= Inst.FFinal(Inst.FCtx, OutBuffer, Size);
    if RC <> 1 then begin
      Result:= TF_E_OSSL;
      Exit;
    end;
// Size contains number of bytes written to OutBuffer by FFinal
    Inc(TotalSize, Size);
  end;
  DataSize:= Cardinal(TotalSize);
  if Cardinal(TotalSize) > OutBufSize then
    Result:= TF_E_INVALIDARG
  else
    Result:= TF_S_OK;
end;

class function TEvpCipherInstance.ExpandKey(Inst: PEvpCipherInstance;
                 Key: PByte; KeySize: Cardinal): TF_RESULT;
var
  LBlockSize: Integer;
  Block: TCipherHelper.TBlock;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);

{$IFDEF DEBUG}
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
//    OutSize:= 0;
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
{$ENDIF}

  FillChar(Block, LBlockSize, 0);
  Result:= TCipherHelper.ExpandKeyIV(Inst, Key, KeySize, @Block, LBlockSize);
end;

class function TEvpCipherInstance.ExpandKeyNonce(Inst: PEvpCipherInstance;
  Key: PByte; KeySize: Cardinal; Nonce: UInt64): TF_RESULT;
var
  Buf: array[0..TF_MAX_CIPHER_BLOCK_SIZE-1] of Byte;
  BlockSize: Integer;

begin
  FillChar(Buf, SizeOf(Buf), 0);
  Move(Nonce, Buf, SizeOf(Nonce));
  BlockSize:= ICipher(Inst).GetBlockSize;
  Result:= ICipher(Inst).ExpandKeyIV(Key, KeySize, @Buf, BlockSize);
end;

class function TEvpCipherInstance.Decrypt(Inst: PEvpCipherInstance;
                 InBuffer, OutBuffer: PByte;
                 var DataSize: Cardinal; OutBufSize: Cardinal; Last: Boolean): TF_RESULT;
var
  Size: Integer;
  TotalSize: Integer;
  RC: Integer;

begin
  if not Assigned(Inst.FUpdate) or not Assigned(Inst.FFinal) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
//  LBufSize:= DataSize;
  RC:= Inst.FUpdate(Inst.FCtx, OutBuffer, Size, InBuffer, DataSize);
  if RC <> 1 then begin
    Result:= TF_E_OSSL;
    Exit;
  end;
  TotalSize:= Size;
  if Last then begin
    Inc(OutBuffer, Size);
    RC:= Inst.FFinal(Inst.FCtx, OutBuffer, Size);
    if RC <> 1 then begin
      Result:= TF_E_OSSL;
      Exit;
    end;
    Inc(TotalSize, Size);
  end;
  DataSize:= Cardinal(TotalSize);
  if Cardinal(TotalSize) > OutBufSize then
    Result:= TF_E_INVALIDARG
  else
    Result:= TF_S_OK;
end;

function TEvpCipherInstance.FreeCtx: TF_RESULT;
begin
  if FCtx = nil then begin
    Result:= TF_S_FALSE;
    Exit;
  end;
  if @EVP_CIPHER_CTX_free = nil then begin
    Result:= TF_E_LOADERROR;
    Exit;
  end;
  EVP_CIPHER_CTX_free(FCtx);
  FCtx:= nil;
  Result:= TF_S_OK;
end;

function TEvpCipherInstance.InitCtx: TF_RESULT;
begin
  if @EVP_CIPHER_CTX_new = nil then begin
    Result:= TF_E_LOADERROR;
    Exit;
  end;
// Assert FCtx = nil
  FCtx:= EVP_CIPHER_CTX_new();
  if FCtx = nil then
    Result:= TF_E_UNEXPECTED
  else
    Result:= TF_S_OK;
end;
(*
class function TEvpCipherInstance.SetKeyParam(Inst: PEvpCipherInstance; Param: UInt32;
               Data: Pointer; DataLen: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TEvpCipherInstance.UpdateBlock(Inst: PEvpCipherInstance;
  Data: PByte): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TEvpCipherInstance.GetKeyParam(Inst: PEvpCipherInstance;
  Param: UInt32; Data: Pointer; var DataLen: Cardinal): TF_RESULT;
begin
// todo: later
  Result:= TF_E_NOTIMPL;
end;

class function TEvpCipherInstance.GetRand(Inst: Pointer; Data: PByte;
  DataSize: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;
*)

end.
