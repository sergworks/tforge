{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfEVPCiphers;

interface

uses
  tfTypes, tfOpenSSL;

type
  PEVPCipherInstance = ^TEVPCipherInstance;
  TEVPCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;

    FValidKey: Boolean;
{$HINTS ON}
    FFlags:    UInt32;
    FCtx:      PEVP_CIPHER_CTX;
    FInit:     TEVP_CipherInit;
    FUpdate:   TEVP_CipherUpdate;
    FFinal:    TEVP_CipherFinal;
  public
    function InitCtx: TF_RESULT;
    function FreeCtx: TF_RESULT;

    class function SetKeyParam(Inst: PEVPCipherInstance; Param: UInt32; Data: Pointer;
      DataLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyParam(Inst: PEVPCipherInstance; Param: UInt32; Data: Pointer;
      var DataLen: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

  end;

implementation

{ TEVPCipher }

function TEVPCipherInstance.FreeCtx: TF_RESULT;
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

function TEVPCipherInstance.InitCtx: TF_RESULT;
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

class function TEVPCipherInstance.SetKeyParam(Inst: PEVPCipherInstance; Param: UInt32;
               Data: Pointer; DataLen: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TEVPCipherInstance.GetKeyParam(Inst: PEVPCipherInstance;
  Param: UInt32; Data: Pointer; var DataLen: Cardinal): TF_RESULT;
begin
// todo: later
  Result:= TF_E_NOTIMPL;
end;

end.
