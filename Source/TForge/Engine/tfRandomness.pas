{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2016         * }
{ *********************************************************** }

unit tfRandomness;

interface

{$I TFL.inc}

uses tfTypes, Windows;

// Advapi32.dll, WinCrypt.h

const
  PROV_RSA_FULL = 1;
  CRYPT_VERIFYCONTEXT = DWORD($F0000000);

type
  HCRYPTPROV = ULONG_PTR;
// HCRYPTPROV = Pointer;

function CryptAcquireContext(var phProv: HCRYPTPROV; pszContainer: LPCTSTR;
  pszProvider: LPCTSTR; dwProvType: DWORD; dwFlags: DWORD): BOOL; stdcall;
function CryptReleaseContext(hProv: HCRYPTPROV; dwFlags: DWORD): BOOL; stdcall;
function CryptGenRandom(hProv: HCRYPTPROV; dwLen: DWORD; pbBuffer: LPBYTE): BOOL; stdcall;

function GenRandom(var Buf; BufSize: LongWord): TF_RESULT;

implementation

function CryptAcquireContext; external advapi32 name 'CryptAcquireContext';
function CryptReleaseContext; external advapi32 name 'CryptReleaseContext';
function CryptGenRandom; external advapi32 name 'CryptGenRandom';

function GenRandom(var Buf; BufSize: LongWord): TF_RESULT;
var
  Provider: HCRYPTPROV;


begin
  if BufSize > 256 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

	if not CryptAcquireContext(Provider, nil, nil,
      PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then begin
    Result:= TF_E_FAIL;
    Exit;
  end;

	if not CryptGenRandom(Provider, BufSize, @Buf) then begin
		CryptReleaseContext(Provider, 0);
    Result:= TF_E_FAIL;
    Exit;
  end;

	CryptReleaseContext(Provider, 0);
  Result:= TF_S_OK;
end;

end.

