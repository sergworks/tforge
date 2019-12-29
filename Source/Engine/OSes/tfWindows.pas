{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfWindows;

{$I TFL.inc}

interface

uses tfTypes, tfOpenSSL, Windows, SysUtils;

// Advapi32.dll, WinCrypt.h

const
  PROV_RSA_FULL = 1;
  CRYPT_VERIFYCONTEXT = DWORD($F0000000);

type
  HCRYPTPROV = ULONG_PTR;

function CryptAcquireContext(var phProv: HCRYPTPROV; pszContainer: LPCTSTR;
  pszProvider: LPCTSTR; dwProvType: DWORD; dwFlags: DWORD): BOOL; stdcall;
function CryptReleaseContext(hProv: HCRYPTPROV; dwFlags: DWORD): BOOL; stdcall;
function CryptGenRandom(hProv: HCRYPTPROV; dwLen: DWORD; pbBuffer: LPBYTE): BOOL; stdcall;

type
  TtfLock = record
    FMutex: THandle;
    function Acquire: TF_RESULT;
    function Resease: TF_RESULT;
  end;

// nobody knows is Windows CryptoAPI threadsafe or not;
//   TForge uses CryptLock to be on the safe side.
var
  CryptLock: TtfLock;

function GenRandom(var Buf; BufSize: Cardinal): TF_RESULT;

// OpenSSL
function TryLoadLibCrypto(const LibName: string = ''): TF_RESULT;

implementation

type
  PCipherItem = ^TCipherItem;
  TCipherItem = record
    Name: PChar;
    AlgID: UInt32;
    Modes: UInt32;
  end;

type
  TCipherList = array of TCipherItem;

function CryptAcquireContext; external advapi32
  name {$IFDEF UNICODE}'CryptAcquireContextW'{$ELSE}'CryptAcquireContextA'{$ENDIF};
function CryptReleaseContext; external advapi32 name 'CryptReleaseContext';
function CryptGenRandom; external advapi32 name 'CryptGenRandom';

{$ifdef fpc}
function InterlockedCompareExchangePointer(var Target: Pointer; NewValue: Pointer; Comperand: Pointer): Pointer;
begin
{$ifdef cpu64}
  Result:= Pointer(InterlockedCompareExchange64(int64(Target), int64(NewValue), int64(Comperand)));
{$else cpu64}
  Result:= Pointer(InterlockedCompareExchange(LongInt(Target), LongInt(NewValue), LongInt(Comperand)));
{$endif cpu64}
end;
{$endif fpc}


function GenRandom(var Buf; BufSize: Cardinal): TF_RESULT;
var
  Provider: HCRYPTPROV;

begin
// TForge uses GenRandom only to get a random seed value,
//   so large BufSize values aren't needed
  if BufSize > 256 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  Result:= CryptLock.Acquire;
  if Result = TF_S_OK then begin
    if CryptAcquireContext(Provider, nil, nil,
        PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then begin

      if not CryptGenRandom(Provider, BufSize, @Buf) then begin
        Result:= TF_E_FAIL;
      end;
      CryptReleaseContext(Provider, 0);
    end
    else begin
      Result:= TF_E_FAIL;
    end;
    CryptLock.Resease;
  end;
end;

{ TtfLock }

{ Initially FMutex field contains zero; TtfLock does not provide constructor
    or method to initialize the field because
    TtfLock instances are designed to be declared as a global variables.
    ===================================================================

  On the first lock attempt, FMutex field is initialized by a non-zero value.
  On collision, each thread attempts to create a mutex and compare-and-swap it
   into place as the FMutex field. On failure to swap in the FMutex field,
   the mutex is closed.
}

function TtfLock.Acquire: TF_RESULT;
var
  Tmp: THandle;

begin
  if FMutex = 0 then begin
    Tmp:= CreateMutex(nil, False, nil);
    if InterlockedCompareExchangePointer(Pointer(FMutex), Pointer(Tmp), nil) <> nil
      then CloseHandle(Tmp);
  end;
  if WaitForSingleObject(FMutex, INFINITE) = WAIT_OBJECT_0
    then Result:= TF_S_OK
    else Result:= TF_E_UNEXPECTED;
end;

function TtfLock.Resease: TF_RESULT;
begin
  ReleaseMutex(FMutex);
  Result:= TF_S_OK;
end;

// OpenSSL staff

const
  libCryptoName1 = 'libeay32.dll';
  libCryptoName2 = 'libcrypto-1_1.dll';

var
  LibCryptoLoaded: Boolean = False;

function TryLoadLibCrypto(const LibName: string): TF_RESULT;
var
  LibHandle: THandle;
//  Version: LongWord;

function LoadFunction(var Address: Pointer; const Name: string): Boolean;
begin
  Address:= GetProcAddress(LibHandle, PChar(Name));
  Result:= Address <> nil;
end;

// !! ver 1.1.0 replaced 'EVP_CIPHER_CTX_init' by 'EVP_CIPHER_CTX_reset'
//    from man pages:
//  # EVP_CIPHER_CTX was made opaque in OpenSSL 1.1.0. As a result,
//  # EVP_CIPHER_CTX_reset() appeared and EVP_CIPHER_CTX_cleanup() disappeared.
//  # EVP_CIPHER_CTX_init() remains as an alias for EVP_CIPHER_CTX_reset().
//    from evp.h:
//  #  define EVP_CIPHER_CTX_init(c)      EVP_CIPHER_CTX_reset(c)
//  #  define EVP_CIPHER_CTX_cleanup(c)   EVP_CIPHER_CTX_reset(c)
//
//  I am using 'EVP_CIPHER_CTX_init' and 'EVP_CIPHER_CTX_cleanup'
//    for compliance with version 1.0.2
//
function LoadBrokenABI: Boolean;
begin
  if LoadFunction(@OpenSSL_version_num, 'SSLeay') then begin
    Result:= LoadFunction(@OpenSSL_version, 'SSLeay_version')
      and LoadFunction(@EVP_CIPHER_CTX_init, 'EVP_CIPHER_CTX_init')
      and LoadFunction(@EVP_CIPHER_CTX_cleanup, 'EVP_CIPHER_CTX_cleanup');
  end
  else begin
    Result:= LoadFunction(@OpenSSL_version_num, 'OpenSSL_version_num')
      and LoadFunction(@OpenSSL_version, 'OpenSSL_version')
      and LoadFunction(@EVP_CIPHER_CTX_init, 'EVP_CIPHER_CTX_reset');
      @EVP_CIPHER_CTX_cleanup:= @EVP_CIPHER_CTX_init;
  end;
end;

begin
  if LibCryptoLoaded then begin
    Result:= TF_S_FALSE;
    Exit;
  end;

  if (LibName = '') then begin
    LibHandle:= LoadLibrary(PChar(libCryptoName1));
    if LibHandle = 0 then
      LibHandle:= LoadLibrary(PChar(libCryptoName2));
  end
  else begin
    LibHandle:= LoadLibrary(PChar(LibName));
  end;

  if (LibHandle = 0) then begin
    Result:= TF_E_LOADERROR;
    Exit;
  end;

  if LoadBrokenABI
    and LoadFunction(@EVP_CIPHER_CTX_new, 'EVP_CIPHER_CTX_new')
    and LoadFunction(@EVP_CIPHER_CTX_free, 'EVP_CIPHER_CTX_free')

    and LoadFunction(@EVP_EncryptInit_ex, 'EVP_EncryptInit_ex')
    and LoadFunction(@EVP_EncryptUpdate, 'EVP_EncryptUpdate')
    and LoadFunction(@EVP_EncryptFinal_ex, 'EVP_EncryptFinal_ex')

    and LoadFunction(@EVP_DecryptInit_ex, 'EVP_DecryptInit_ex')
    and LoadFunction(@EVP_DecryptUpdate, 'EVP_DecryptUpdate')
    and LoadFunction(@EVP_DecryptFinal_ex, 'EVP_DecryptFinal_ex')

    and LoadFunction(@EVP_CIPHER_CTX_set_padding, 'EVP_CIPHER_CTX_set_padding')

    and LoadFunction(@EVP_aes_128_ecb, 'EVP_aes_128_ecb')
    and LoadFunction(@EVP_aes_128_cbc, 'EVP_aes_128_cbc')
    and LoadFunction(@EVP_aes_128_cfb, 'EVP_aes_128_cfb128')
    and LoadFunction(@EVP_aes_128_ofb, 'EVP_aes_128_ofb')
    and LoadFunction(@EVP_aes_128_ctr, 'EVP_aes_128_ctr')
    and LoadFunction(@EVP_aes_128_gcm, 'EVP_aes_128_gcm')

    and LoadFunction(@EVP_aes_192_ecb, 'EVP_aes_192_ecb')
    and LoadFunction(@EVP_aes_192_cbc, 'EVP_aes_192_cbc')
    and LoadFunction(@EVP_aes_192_cfb, 'EVP_aes_192_cfb128')
    and LoadFunction(@EVP_aes_192_ofb, 'EVP_aes_192_ofb')
    and LoadFunction(@EVP_aes_192_ctr, 'EVP_aes_192_ctr')
    and LoadFunction(@EVP_aes_192_gcm, 'EVP_aes_192_gcm')

    and LoadFunction(@EVP_aes_256_ecb, 'EVP_aes_256_ecb')
    and LoadFunction(@EVP_aes_256_cbc, 'EVP_aes_256_cbc')
    and LoadFunction(@EVP_aes_256_cfb, 'EVP_aes_256_cfb128')
    and LoadFunction(@EVP_aes_256_ofb, 'EVP_aes_256_ofb')
    and LoadFunction(@EVP_aes_256_ctr, 'EVP_aes_256_ctr')
    and LoadFunction(@EVP_aes_256_gcm, 'EVP_aes_256_gcm')

    and LoadFunction(@EVP_des_ecb, 'EVP_des_ecb')
    and LoadFunction(@EVP_des_cbc, 'EVP_des_cbc')

  then begin
    LibCryptoLoaded:= True;
    Result:= TF_S_OK;
    Exit;
  end;
{
       3277  621 00070BC0 EVP_des_cfb1
        300  622 00070B90 EVP_des_cfb64
       3267  623 00070BD0 EVP_des_cfb8
        301  624 00070BB0 EVP_des_ecb
        302  625 00071540 EVP_des_ede
        303  626 000716A0 EVP_des_ede3
        304  627 00071550 EVP_des_ede3_cbc
       3280  628 00071580 EVP_des_ede3_cfb1
        305  629 00071560 EVP_des_ede3_cfb64
       3258  62A 00071590 EVP_des_ede3_cfb8
       3236  62B 000716A0 EVP_des_ede3_ecb
        306  62C 00071570 EVP_des_ede3_ofb
       4737  62D 00071970 EVP_des_ede3_wrap
        307  62E 00071510 EVP_des_ede_cbc
        308  62F 00071520 EVP_des_ede_cfb64
       3231  630 00071540 EVP_des_ede_ecb
        309  631 00071530 EVP_des_ede_ofb
        310  632 00070BA0 EVP_des_ofb
        311  633 00073F20 EVP_desx_cbc
}
  FreeLibrary(LibHandle);
  Result:= TF_E_LOADERROR;
end;

end.
