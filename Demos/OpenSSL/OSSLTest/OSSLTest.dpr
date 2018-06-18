program OSSLTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  FastMM4, SysUtils, Windows;

const
  LibCryptoName = 'libeay32.dll';

var
  LibHandle: THandle;
  LibVersion: UInt32;

type
  PEVP_CIPHER_CTX = type Pointer;
  PEVP_CIPHER = type Pointer;

const
  _SSLEAY_VERSION = 0;

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

  TGetEVPCipher = function(): PEVP_CIPHER; cdecl;

var
  SSLeay: TSSLeay;
  SSLeay_version: TSSLeay_version;

  EVP_CIPHER_CTX_new: TEVP_CIPHER_CTX_new;
  EVP_CIPHER_CTX_init: TEVP_CIPHER_CTX_reset;
  EVP_CIPHER_CTX_free: TEVP_CIPHER_CTX_free;

  EVP_EncryptInit_ex: TEVP_CipherInit;
  EVP_EncryptUpdate: TEVP_CipherUpdate;
  EVP_EncryptFinal_ex: TEVP_CipherFinal;

  EVP_DecryptInit_ex: TEVP_CipherInit;
  EVP_DecryptUpdate: TEVP_CipherUpdate;
  EVP_DecryptFinal_ex: TEVP_CipherFinal;

  EVP_CIPHER_CTX_set_padding: TEVP_CIPHER_CTX_set_padding;

  EVP_aes_128_ecb: TGetEVPCipher;

procedure LoadFunction(var Address: Pointer; const Name: string);
begin
  Address:= GetProcAddress(LibHandle, PChar(Name));
  if (Address = nil) then
    raise Exception.Create('Error Loading Function ' + Name);
end;

procedure LoadLibCrypto(const Name: string = '');
var
  LName: string;

begin
  if (Name = '') then
    LName:= libCryptoName
  else
    LName:= Name;

  LibHandle:= LoadLibrary(PChar(LName));

  if (LibHandle = 0) then
    raise Exception.Create('Error Loading ' + LName);

  LoadFunction(@SSLeay, 'SSLeay');
//  LoadFunction(@SSLeay, 'OpenSSL_version_num');
  LoadFunction(@SSLeay_version, 'SSLeay_version');
//  LoadFunction(@SSLeay_version, 'OpenSSL_version');
  LoadFunction(@EVP_CIPHER_CTX_new, 'EVP_CIPHER_CTX_new');
  LoadFunction(@EVP_CIPHER_CTX_init, 'EVP_CIPHER_CTX_init');
//  LoadFunction(@EVP_CIPHER_CTX_init, 'EVP_CIPHER_CTX_reset');
  LoadFunction(@EVP_CIPHER_CTX_free, 'EVP_CIPHER_CTX_free');
  LoadFunction(@EVP_EncryptInit_ex, 'EVP_EncryptInit_ex');
  LoadFunction(@EVP_EncryptUpdate, 'EVP_EncryptUpdate');
  LoadFunction(@EVP_EncryptFinal_ex, 'EVP_EncryptFinal_ex');
  LoadFunction(@EVP_DecryptInit_ex, 'EVP_DecryptInit_ex');
  LoadFunction(@EVP_DecryptUpdate, 'EVP_DecryptUpdate');
  LoadFunction(@EVP_DecryptFinal_ex, 'EVP_DecryptFinal_ex');
  LoadFunction(@EVP_CIPHER_CTX_set_padding, 'EVP_CIPHER_CTX_set_padding');
  LoadFunction(@EVP_aes_128_ecb, 'EVP_aes_128_ecb');

  Writeln('Version: ', string(SSLeay_version(_SSLEAY_VERSION)));
  Writeln('Version number: ',  IntToHex(SSLeay(), 8));
  Writeln;
end;

var
  Key: array[0..15] of Byte;
  IV: array[0..15] of Byte; // IV is not used in ECB
  PlainText: array of Byte;
  Encrypted: array of Byte;
  Decrypted: array of Byte;
  WorkBuffer: array of Byte;

procedure Prepare;
var
  I: Integer;

begin
  for I:= 0 to 15 do
    Key[I]:= I + 1;
  SetLength(PlainText, 50);
  for I:= 0 to Length(PlainText) - 1 do
    PlainText[I]:= I;
  SetLength(Encrypted, 64);
  SetLength(Decrypted, 64);
  SetLength(WorkBuffer, 48);
end;

procedure TestEncryption;
var
  Ctx: PEVP_CIPHER_CTX;
  L1, L2, L3: Integer;

begin

// create encryption context
  Ctx:= EVP_CIPHER_CTX_new();

// initialize encryption context with AES cipher, 128 bit key
  if EVP_EncryptInit_ex(Ctx, EVP_aes_128_ecb(), nil, @Key[0], @IV[0]) <> 1 then
    raise Exception.Create('EVP_EncryptInit_ex Error');

// encrypt first 32 bytes of plaintext
  Move(Plaintext[0], WorkBuffer[0], 32);
  if EVP_EncryptUpdate(Ctx, @WorkBuffer[0], L1, @WorkBuffer[0], 32) <> 1 then
    raise Exception.Create('EVP_EncryptUpdate Error');

  Writeln('Encrypted after 1st Update: ', L1);
  Move(WorkBuffer[0], Encrypted[0], L1);

// encrypt last 18 bytes of plaintext
  Move(Plaintext[32], WorkBuffer[0], 18);
  if EVP_EncryptUpdate(Ctx, @WorkBuffer[0], L2, @WorkBuffer[0], 18) <> 1 then
    raise Exception.Create('EVP_EncryptUpdate Error');

  Writeln('Encrypted after 2nd Update: ', L2);
  Move(WorkBuffer[0], Encrypted[L1], L2);

  if EVP_EncryptFinal_ex(Ctx, @WorkBuffer[L2], L3) <> 1 then
    raise Exception.Create('EVP_EncryptFinal_ex Error');

  Writeln('Encrypted after Final: ', L3);
  Move(WorkBuffer[L2], Encrypted[L1 + L2], L3);

  Writeln('Encrypted Size: ', L1 + L2 + L3);

// release encryption context
  EVP_CIPHER_CTX_free(Ctx);
end;

procedure TestDecryption;
var
  Ctx: PEVP_CIPHER_CTX;
  L1, L2, L3: Integer;

begin

// create decryption context
  Ctx:= EVP_CIPHER_CTX_new();

// initialize decryption context with AES cipher, 128 bit key
  if EVP_DecryptInit_ex(Ctx, EVP_aes_128_ecb(), nil, @Key[0], @IV[0]) <> 1 then
    raise Exception.Create('EVP_DecryptInit_ex Error');

// decrypt first 32 bytes of ciphertext
  Move(Encrypted[0], WorkBuffer[0], 32);
  if EVP_DecryptUpdate(Ctx, @WorkBuffer[0], L1, @WorkBuffer[0], 32) <> 1 then
    raise Exception.Create('EVP_DecryptUpdate Error');

  Writeln('Decrypted after 1st Update: ', L1);
  Move(WorkBuffer[0], Decrypted[0], L1);

// decrypt last 32 bytes of ciphertext
  Move(Encrypted[32], WorkBuffer[16], 32);
  if EVP_DecryptUpdate(Ctx, @WorkBuffer[0], L2, @WorkBuffer[16], 32) <> 1 then
    raise Exception.Create('EVP_DecryptUpdate Error');

  Writeln('Decrypted after 2nd Update: ', L2);
  Move(WorkBuffer[0], Decrypted[L1], L2);

  if EVP_DecryptFinal_ex(Ctx, @WorkBuffer[L2], L3) <> 1 then
    raise Exception.Create('EVP_DecryptFinal_ex Error');

  Writeln('Decrypted after Final: ', L3);
  Move(WorkBuffer[L2], Decrypted[L1 + L2], L3);

  Writeln('Decrypted Size: ', L1 + L2 + L3);

// release encryption context
  EVP_CIPHER_CTX_free(Ctx);
end;

procedure PrintResults;
var
  I: Integer;

begin
  Writeln('Key: ');
  for I:= 0 to 15 do
    Write(IntToHex(Key[I], 2), ' ');
  Writeln;
  Writeln('PlainText: ');
  for I:= 0 to Length(PlainText) - 1 do
    Write(IntToHex(PlainText[I], 2), ' ');
  Writeln;
  Writeln('Encrypted: ');
  for I:= 0 to Length(Encrypted) - 1 do
    Write(IntToHex(Encrypted[I], 2), ' ');
  Writeln;
  Writeln('Decrypted: ');
  for I:= 0 to 50 - 1 do
    Write(IntToHex(Decrypted[I], 2), ' ');
  Writeln;
end;

begin
  try
//    LoadLibCrypto('C:\Software\OSSL1117_32\libcrypto-1_1.dll');
//    LoadLibCrypto('C:\Software\OSSL110h\libcrypto-1_1.dll');
    LoadLibCrypto();
    Prepare;
    TestEncryption;
    TestDecryption;
    PrintResults;
    SetLength(PlainText, 0);
    SetLength(Encrypted, 0);
    SetLength(Decrypted, 0);
    SetLength(WorkBuffer, 0);
    FreeLibrary(LibHandle);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
