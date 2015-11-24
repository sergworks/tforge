program CRC32Demo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  BitCRC32 in '..\Source\BitCRC32.pas',
  RefCRC32 in '..\Source\RefCRC32.pas';

begin
  try
//    Test2;
    Test;
//    Find;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
