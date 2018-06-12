{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfOpenSSL;

interface

type
  PEVP_CIPHER_CTX = type Pointer;
  PEVP_CIPHER = type Pointer;

const
  _SSLEAY_VERSION = 0;
  _SSLEAY_CFLAGS = 2;
  _SSLEAY_BUILT_ON = 3;
  _SSLEAY_PLATFORM = 4;
  _SSLEAY_DIR = 5;

type
// OpenSSL version API
  TSSLeay = function: Cardinal; cdecl;
  TSSLeay_version = function(AType: Integer): PAnsiChar; cdecl;

// OpenSSL EVP API
  TEVP_CIPHER_CTX_new = function(): PEVP_CIPHER_CTX; cdecl;
  TEVP_CIPHER_CTX_reset = function(CTX: PEVP_CIPHER_CTX): Integer; cdecl;
  TEVP_CIPHER_CTX_free = procedure(CTX: PEVP_CIPHER_CTX); cdecl;

  TEVP_CipherInit = function(CTX: PEVP_CIPHER_CTX; EVP_CIPHER: PEVP_CIPHER;
         Impl: Pointer; Key, IV: PByte): Integer; cdecl;
  TEVP_CipherUpdate = function(CTX: PEVP_CIPHER_CTX; OutBuf: PByte;
         var OutBufLen: Integer; InBuf: PByte; InBufLen: Integer): Integer; cdecl;
  TEVP_CipherFinal = function(CTX: PEVP_CIPHER_CTX; OutBuf: PByte;
         var OutBufLen: Integer): Integer; cdecl;

  TEVP_CIPHER_CTX_set_padding = function(CTX: PEVP_CIPHER_CTX;
         Padding: Integer): Integer; cdecl;

(*
  TEVP_DecryptInit_ex = function(CTX: PEVP_CIPHER_CTX; EVP_CIPHER: PEVP_CIPHER;
         Impl: Pointer; Key, IV: PByte): Integer; cdecl;
  TEVP_DecryptUpdate = function(CTX: PEVP_CIPHER_CTX; OutBuf: PByte;
         var OutBufLen: Integer; InBuf: PByte; InBufLen: Integer): Integer; cdecl;
  TEVP_DecryptFinal_ex = function(CTX: PEVP_CIPHER_CTX; OutBuf: PByte;
         var OutBufLen: Integer): Integer; cdecl;
*)

  TGetEVPCipher = function(): PEVP_CIPHER; cdecl;

var
  SSLeay: TSSLeay;
  SSLeay_version: TSSLeay_version;

  EVP_CIPHER_CTX_new: TEVP_CIPHER_CTX_new;
  EVP_CIPHER_CTX_init: TEVP_CIPHER_CTX_reset;
  EVP_CIPHER_CTX_cleanup: TEVP_CIPHER_CTX_reset;
  EVP_CIPHER_CTX_free: TEVP_CIPHER_CTX_free;

  EVP_EncryptInit_ex: TEVP_CipherInit;
  EVP_EncryptUpdate: TEVP_CipherUpdate;
  EVP_EncryptFinal_ex: TEVP_CipherFinal;

  EVP_DecryptInit_ex: TEVP_CipherInit;
  EVP_DecryptUpdate: TEVP_CipherUpdate;
  EVP_DecryptFinal_ex: TEVP_CipherFinal;

  EVP_CIPHER_CTX_set_padding: TEVP_CIPHER_CTX_set_padding;

  EVP_aes_128_cbc: TGetEVPCipher;
  EVP_aes_128_ecb: TGetEVPCipher;
  EVP_aes_128_ctr: TGetEVPCipher;

  EVP_aes_192_cbc: TGetEVPCipher;
  EVP_aes_192_ecb: TGetEVPCipher;
  EVP_aes_192_ctr: TGetEVPCipher;

  EVP_aes_256_cbc: TGetEVPCipher;
  EVP_aes_256_ecb: TGetEVPCipher;
  EVP_aes_256_ctr: TGetEVPCipher;

  EVP_des_cbc: TGetEVPCipher;

implementation

end.
