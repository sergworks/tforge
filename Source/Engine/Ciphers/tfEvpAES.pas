{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2018         * }
{ *********************************************************** }

unit tfEvpAES;

interface

{$I TFL.inc}

uses
  tfTypes, tfOpenSSL;

type
  PEvpAESInstance = ^TEvpAESInstance;
  TEvpAESInstance = record
  private
{$HINTS OFF}
                                // from tfRecord
    FVTable:   Pointer;
    FRefCount: Integer;
                                // from tfEvpCipherInstance
    FValidKey: Boolean;
    FFlags:    UInt32;
    FCtx:      PEVP_CIPHER_CTX;
    FInit:     TEVP_CipherInit;
    FUpdate:   TEVP_CipherUpdate;
    FFinal:    TEVP_CipherFinal;
{$HINTS ON}
  public
    class function GetBlockSize(Inst: PEvpAESInstance): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIsBlockCipher(Inst: Pointer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKeyIV(Inst: PEvpAESInstance; Key: PByte; KeySize: Cardinal;
          IV: PByte; IVSize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetEvpAESInstance(var Inst: PEvpAESInstance; Flags: UInt32): TF_RESULT;

implementation

uses tfRecords, tfEvpCiphers;

const
  AES_BLOCK_SIZE = 16;  // 16 bytes = 128 bits

const
  EvpAESCipherVTable: array[0..18] of Pointer = (
   @TForgeInstance.QueryIntf,
   @TForgeInstance.Addref,
   @TEvpCipherInstance.Release,

   @TEvpCipherInstance.DestroyKey,
   @TEvpCipherInstance.Duplicate,
   @TEvpCipherInstance.ExpandKey,
   @TEvpCipherInstance.SetKeyParam,
   @TEvpCipherInstance.GetKeyParam,
   @TEvpAESInstance.GetBlockSize,
   @TEvpCipherInstance.Encrypt,
   @TEvpCipherInstance.Decrypt,
   @TEvpCipherInstance.UpdateBlock,
   @TEvpCipherInstance.UpdateBlock,
   @TEvpCipherInstance.GetRand,
   @TEvpCipherInstance.RandBlock,
   @TEvpCipherInstance.RandCrypt,
   @TEvpAESInstance.GetIsBlockCipher,
   @TEvpAESInstance.ExpandKeyIV,
   @TEvpCipherInstance.ExpandKeyNonce
   );

function GetEvpAESInstance(var Inst: PEvpAESInstance; Flags: UInt32): TF_RESULT;
var
  Padding: Cardinal;
  KeyMode: Cardinal;
  KeyDir: Cardinal;
  Tmp: PEvpAESInstance;

begin
  KeyDir:= Flags and TF_KEYDIR_MASK;
  if (KeyDir <> TF_KEYDIR_ENCRYPT) and (KeyDir <> TF_KEYDIR_DECRYPT) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  Padding:= Flags and TF_PADDING_MASK;
  if Padding = TF_PADDING_DEFAULT then
    Padding:= TF_PADDING_PKCS;
  if (Padding <> TF_PADDING_NONE) and (Padding <> TF_PADDING_PKCS) then  begin
    Result:= TF_E_NOTIMPL;
    Exit;
  end;

  KeyMode:= Flags and TF_KEYMODE_MASK;
  if (KeyMode <> TF_KEYMODE_ECB) and (KeyMode <> TF_KEYMODE_CBC)
    and (KeyMode <> TF_KEYMODE_CTR) then begin
      Result:= TF_E_NOTIMPL;
      Exit;
    end;

  try
    Tmp:= AllocMem(SizeOf(TEvpAESInstance));
    Tmp^.FVTable:= @EvpAESCipherVTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FFlags:= Flags;
{
    Result:= PBaseBlockCipher(Tmp).SetFlags(Flags);
    if Result <> TF_S_OK then begin
      FreeMem(Tmp);
      Exit;
    end;
}
    if Inst <> nil then TEvpCipherInstance.Release(Inst);
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
  case KeySize of
    16: PCipher:= EVP_aes_128_cbc();
    24: PCipher:= EVP_aes_192_cbc();
    32: PCipher:= EVP_aes_256_cbc();
  else
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  if PCipher = nil then begin
    Result:= TF_E_OSSL;
    Exit;
  end;

  Inst.FCtx:= EVP_CIPHER_CTX_new();
  if Inst.FCtx = nil then begin
    Result:= TF_E_OSSL;
    Exit;
  end;

  KeyDir:= Inst.FFlags and TF_KEYDIR_MASK;
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
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  if RC <> 1 then begin
    EVP_CIPHER_CTX_free(Inst.FCtx);
    Inst.FCtx:= nil;
    Result:= TF_E_OSSL;
    Exit;
  end;

  Result:= TF_S_OK;
end;

class function TEvpAESInstance.GetBlockSize(Inst: PEvpAESInstance): Integer;
begin
  Result:= AES_BLOCK_SIZE;
end;

class function TEvpAESInstance.GetIsBlockCipher(Inst: Pointer): Boolean;
begin
  Result:= True;
end;

end.
