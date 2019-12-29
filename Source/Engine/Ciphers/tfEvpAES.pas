{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2018         * }
{ *********************************************************** }

unit tfEvpAES;

interface

{$I TFL.inc}

uses
  tfTypes, tfOpenSSL, tfCipherInstances;

type
  PEvpAESInstance = ^TEvpAESInstance;
  TEvpAESInstance = record
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
(*
    class function GetBlockSize(Inst: PEvpAESInstance): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIsBlockCipher(Inst: Pointer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
    class function ExpandKeyIV(Inst: PEvpAESInstance; Key: PByte; KeySize: Cardinal;
          IV: PByte; IVSize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetEvpAESInstance(var Inst: PEvpAESInstance; AlgID: TAlgID): TF_RESULT;

implementation

uses tfRecords, tfHelpers, tfEvpCiphers;

const
  AES_BLOCK_SIZE = 16;  // 16 bytes = 128 bits

const
  EvpAESCipherVTable: array[0..25] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TEvpCipherInstance.Burn,
    @TEvpCipherInstance.Clone,
    @TEvpCipherInstance.ExpandKey,
    @TEvpAESInstance.ExpandKeyIV,
    @TEvpCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TEvpCipherInstance.EncryptUpdate,
    @TEvpCipherInstance.DecryptUpdate,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.EncryptStub,
    @TCipherInstance.EncryptStub,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.SetNonceStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.GetNonceStub,
    @TCipherInstance.GetIVPointerStub
   );

function GetEvpAESInstance(var Inst: PEvpAESInstance; AlgID: TAlgID): TF_RESULT;
var
  Padding: Cardinal;
  KeyMode: Cardinal;
  KeyDir: Cardinal;
  Tmp: PEvpAESInstance;

begin
  KeyDir:= AlgID and TF_KEYDIR_MASK;
  if (KeyDir <> TF_KEYDIR_ENCRYPT) and (KeyDir <> TF_KEYDIR_DECRYPT) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  Padding:= AlgID and TF_PADDING_MASK;
  if Padding = TF_PADDING_DEFAULT then
    Padding:= TF_PADDING_PKCS;
  if (Padding <> TF_PADDING_NONE) and (Padding <> TF_PADDING_PKCS) then  begin
    Result:= TF_E_NOTIMPL;
    Exit;
  end;

  KeyMode:= AlgID and TF_KEYMODE_MASK;
  case KeyMode of
    TF_KEYMODE_ECB, TF_KEYMODE_CBC, TF_KEYMODE_CFB,
    TF_KEYMODE_OFB, TF_KEYMODE_CTR, TF_KEYMODE_GCM: ;
  else
    Result:= TF_E_NOTIMPL;
    Exit;
  end;

  try
    Tmp:= AllocMem(SizeOf(TEvpAESInstance));
    Tmp^.FVTable:= @EvpAESCipherVTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FAlgID:= AlgID;

    TForgeHelper.Free(Inst);
    Inst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

{ TEvpAESInstance }

class function TEvpAESInstance.ExpandKeyIV(Inst: PEvpAESInstance; Key: PByte;
  KeySize: Cardinal; IV: PByte; IVSize: Cardinal): TF_RESULT;
var
  RC: Integer;
  KeyDir: Cardinal;
  KeyMode: Cardinal;
  Padding: Cardinal;
  PCipher: PEVP_CIPHER;

begin
  if Inst.FCtx <> nil then begin
    EVP_CIPHER_CTX_free(Inst.FCtx);
    Inst.FCtx:= nil;
  end;

  if (IV <> nil) and (IVSize <> AES_BLOCK_SIZE) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

{  if (KeySize <> 16) and (KeySize <> 24) and (KeySize <> 32) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
}
  KeyMode:= Inst.FAlgID and TF_KEYMODE_MASK;
  PCipher:= nil;
  case KeyMode of
    TF_KEYMODE_ECB:
      case KeySize of
        16: PCipher:= EVP_aes_128_ecb();
        24: PCipher:= EVP_aes_192_ecb();
        32: PCipher:= EVP_aes_256_ecb();
      end;
    TF_KEYMODE_CBC:
      case KeySize of
        16: PCipher:= EVP_aes_128_cbc();
        24: PCipher:= EVP_aes_192_cbc();
        32: PCipher:= EVP_aes_256_cbc();
      end;
    TF_KEYMODE_CFB:
      case KeySize of
        16: PCipher:= EVP_aes_128_cfb();
        24: PCipher:= EVP_aes_192_cfb();
        32: PCipher:= EVP_aes_256_cfb();
      end;
    TF_KEYMODE_OFB:
      case KeySize of
        16: PCipher:= EVP_aes_128_ofb();
        24: PCipher:= EVP_aes_192_ofb();
        32: PCipher:= EVP_aes_256_ofb();
      end;
    TF_KEYMODE_CTR:
      case KeySize of
        16: PCipher:= EVP_aes_128_ctr();
        24: PCipher:= EVP_aes_192_ctr();
        32: PCipher:= EVP_aes_256_ctr();
      end;
    TF_KEYMODE_GCM:
      case KeySize of
        16: PCipher:= EVP_aes_128_gcm();
        24: PCipher:= EVP_aes_192_gcm();
        32: PCipher:= EVP_aes_256_gcm();
      end;
  end;

  if PCipher = nil then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  Inst.FCtx:= EVP_CIPHER_CTX_new();
  if Inst.FCtx = nil then begin
    Result:= TF_E_OSSL;
    Exit;
  end;

  KeyDir:= Inst.FAlgID and TF_KEYDIR_MASK;
  if KeyDir = TF_KEYDIR_ENCRYPT then begin
    RC:= EVP_EncryptInit_ex(Inst.FCtx, PCipher, nil, Key, IV);
    if RC = 1 then begin
      @Inst.FUpdate:= @EVP_EncryptUpdate;
      @Inst.FFinal:= @EVP_EncryptFinal_ex;
    end;
  end
  else if KeyDir = TF_KEYDIR_DECRYPT then begin
    RC:= EVP_DecryptInit_ex(Inst.FCtx, PCipher, nil, Key, IV);
    if RC = 1 then begin
      @Inst.FUpdate:= @EVP_DecryptUpdate;
      @Inst.FFinal:= @EVP_DecryptFinal_ex;
    end;
  end
  else begin
    EVP_CIPHER_CTX_free(Inst.FCtx);
    Inst.FCtx:= nil;
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  if RC <> 1 then begin
    EVP_CIPHER_CTX_free(Inst.FCtx);
    Inst.FCtx:= nil;
    Result:= TF_E_OSSL;
    Exit;
  end;

  Padding:= Inst.FAlgID and TF_PADDING_MASK;
  case Padding of
    TF_PADDING_DEFAULT: ;
    TF_PADDING_NONE: EVP_CIPHER_CTX_set_padding(Inst.FCtx, 0);
    TF_PADDING_PKCS: EVP_CIPHER_CTX_set_padding(Inst.FCtx, 1);
  else
    EVP_CIPHER_CTX_free(Inst.FCtx);
    Inst.FCtx:= nil;
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  Result:= TF_S_OK;
end;

{
class function TEvpAESInstance.GetBlockSize(Inst: PEvpAESInstance): Integer;
begin
  Result:= AES_BLOCK_SIZE;
end;

class function TEvpAESInstance.GetIsBlockCipher(Inst: Pointer): Boolean;
begin
  Result:= True;
end;
}
end.
