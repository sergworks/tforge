program FileEncryptDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  EncryptedStreams in 'Source\EncryptedStreams.pas',
  Demos in 'Source\Demos.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
