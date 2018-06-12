{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2018         * }
{ *********************************************************** }

unit tfEngines;

interface

{$I TFL.inc}

uses
  SysUtils, tfTypes, tfWindows, tfExceptions;

//type
//  EOSSLError = class(Exception);

procedure LoadOpenSSL(const FolderName: string = '');
// procedure OSSLResCheck(Res: Integer);

implementation

procedure LoadOpenSSL(const FolderName: string);
var
  Code: TF_RESULT;

begin
  Code:= LoadLibCrypto(FolderName);
  if Code < 0 then
    ForgeError(Code, 'OpenSSL Load Error');
end;
{  not used
procedure OSSLResCheck(Res: Integer);
begin
  if Res <> 1 then
    raise EOSSLError.Create('OpenSSL Error');
end;
}
end.
