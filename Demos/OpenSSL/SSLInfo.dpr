program SSLInfo;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfTypes, tfWindows;

procedure PrintInfo;
begin
//  if LoadSSLCrypto < 0 then
  if LoadSSLCrypto('c:\Projects\TForge\SSL32\libeay32.dll') < 0 then
    Writeln(' Error Loading OpenSSL')
  else begin
    Writeln('OpenSSL version: ', IntToHex(SSLeay(), 8));
    Writeln(SSLeay_version(_SSLEAY_VERSION));
    Writeln(SSLeay_version(_SSLEAY_CFLAGS));
    Writeln(SSLeay_version(_SSLEAY_BUILT_ON));
    Writeln(SSLeay_version(_SSLEAY_PLATFORM));
    Writeln(SSLeay_version(_SSLEAY_DIR));
  end;
end;

begin
  try
    ReportMemoryLeaksOnShutdown:= True;
    PrintInfo;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
