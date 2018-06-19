{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
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

    FValidKey: Boolean;
    FFlags:    UInt32;
    FCtx:      PEVP_CIPHER_CTX;
//    FInit:     TEVP_CipherInit;
    FUpdate:   TEVP_CipherUpdate;
    FFinal:    TEVP_CipherFinal;
{$HINTS ON}
  public
    function InitCtx: TF_RESULT;
    function FreeCtx: TF_RESULT;

    class function Release(Inst: Pointer): Integer; stdcall; static;
    class function Duplicate(Inst: PEvpCipherInstance; var NewInst: PEvpCipherInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure DestroyKey(Inst: PEvpCipherInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKey(Inst: PEvpCipherInstance; Key: PByte; KeySize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function UpdateBlock(Inst: PEvpCipherInstance; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function GetRand(Inst: Pointer; Data: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RandBlock(Inst: Pointer; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RandCrypt(Inst: Pointer; Data: PByte; DataSize: Cardinal;
      Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function SetKeyParam(Inst: PEvpCipherInstance; Param: UInt32; Data: Pointer;
      DataLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyParam(Inst: PEvpCipherInstance; Param: UInt32; Data: Pointer;
      var DataLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function Encrypt(Inst: PEvpCipherInstance; Data: PByte; var DataSize: Cardinal;
      BufSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Decrypt(Inst: PEvpCipherInstance; OutData, Data: PByte; var DataSize: Cardinal;
      Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKeyNonce(Inst: PEvpCipherInstance; Key: PByte; KeySize: Cardinal;
          Nonce: UInt64): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
end;

implementation

uses
  tfRecords;

{ TEvpCipher }

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
  Inst.FValidKey:= False;
  Inst.FFlags:= 0;
end;

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

class procedure TEvpCipherInstance.DestroyKey(Inst: PEvpCipherInstance);
begin
  BurnKey(Inst);
end;

class function TEvpCipherInstance.Duplicate(Inst: PEvpCipherInstance;
  var NewInst: PEvpCipherInstance): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TEvpCipherInstance.Encrypt(Inst: PEvpCipherInstance; Data: PByte;
  var DataSize: Cardinal; BufSize: Cardinal; Last: Boolean): TF_RESULT;
var
  LBufSize: Integer;
  SaveSize: Integer;
  RC: Integer;

begin
  if not Assigned(Inst.FUpdate) or not Assigned(Inst.FFinal) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
  LBufSize:= BufSize;
  RC:= Inst.FUpdate(Inst.FCtx, Data, LBufSize, Data, DataSize);
  if RC <> 1 then begin
    Result:= TF_E_OSSL;
    Exit;
  end;
  SaveSize:= LBufSize;
  if Last then begin
    Inc(Data, LBufSize);
    LBufSize:= Integer(BufSize) - LBufSize;
    RC:= Inst.FFinal(Inst.FCtx, Data, LBufSize);
    if RC <> 1 then begin
      Result:= TF_E_OSSL;
      Exit;
    end;
    Inc(SaveSize, LBufSize);
  end;
  DataSize:= Cardinal(SaveSize);
  Result:= TF_S_OK;
end;

class function TEvpCipherInstance.ExpandKey(Inst: PEvpCipherInstance;
  Key: PByte; KeySize: Cardinal): TF_RESULT;
begin
  Result:= ICipher(Inst).ExpandKeyIV(Key, KeySize, nil, 0);
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

class function TEvpCipherInstance.Decrypt(Inst: PEvpCipherInstance; OutData, Data: PByte;
  var DataSize: Cardinal; Last: Boolean): TF_RESULT;
var
  LBufSize: Integer;
  SaveSize: Integer;
  RC: Integer;

begin
  if not Assigned(Inst.FUpdate) or not Assigned(Inst.FFinal) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
//  LBufSize:= DataSize;
  RC:= Inst.FUpdate(Inst.FCtx, OutData, LBufSize, Data, DataSize);
  if RC <> 1 then begin
    Result:= TF_E_OSSL;
    Exit;
  end;
  SaveSize:= LBufSize;
  if Last then begin
    Inc(OutData, LBufSize);
//    LBufSize:= Integer(DataSize) - LBufSize;
    RC:= Inst.FFinal(Inst.FCtx, OutData, LBufSize);
    if RC <> 1 then begin
      Result:= TF_E_OSSL;
      Exit;
    end;
    Inc(SaveSize, LBufSize);
  end;
  DataSize:= Cardinal(SaveSize);
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

end.
