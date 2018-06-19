{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2018         * }
{ *********************************************************** }

unit tfEngines;

interface

{$I TFL.inc}

uses
  SysUtils, tfTypes, tfOpenSSL, tfWindows, tfExceptions;

//type
//  EOSSLError = class(Exception);

procedure LoadLibCrypto(const FolderName: string = '');
function OpenSSLVersion: string;
// procedure OSSLResCheck(Res: Integer);

implementation

procedure LoadLibCrypto(const FolderName: string);
var
  Code: TF_RESULT;

begin
  Code:= TryLoadLibCrypto(FolderName);
  if Code < 0 then
    ForgeError(TF_E_LOADERROR, 'OpenSSL Load Error');
end;

function OpenSSLVersion: string;
begin
  if Assigned(OpenSSL_version) then begin
    Result:= string(OpenSSL_version(_SSLEAY_VERSION));
  end
  else
    ForgeError(TF_E_LOADERROR, 'OpenSSL Load Error');
end;

{  not used
procedure OSSLResCheck(Res: Integer);
begin
  if Res <> 1 then
    raise EOSSLError.Create('OpenSSL Error');
end;
}
end.

