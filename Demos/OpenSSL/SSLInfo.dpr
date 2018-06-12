program SSLInfo;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfTypes, tfWindows, tfOpenSSL;

procedure PrintInfo;
begin
//  if LoadSSLCrypto < 0 then
  if LoadLibCrypto() < 0 then
    Writeln(' Error Loading OpenSSL')
  else begin
    Writeln('OpenSSL version number: ', IntToHex(SSLeay(), 8));
    Writeln('OpenSSL version: ', SSLeay_version(_SSLEAY_VERSION));
    Writeln('OpenSSL compile flags: ', SSLeay_version(_SSLEAY_CFLAGS));
    Writeln(SSLeay_version(_SSLEAY_BUILT_ON));
    Writeln('OpenSSL platform: ', SSLeay_version(_SSLEAY_PLATFORM));
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
