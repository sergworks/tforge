program Examples;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  MontEx in '..\Source\MontEx.pas',
  StreamCipherEx in '..\Source\StreamCipherEx.pas',
  MiscEx in '..\Source\MiscEx.pas';

begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    BigIntExamples;
    BigCardExamples;
    RandExamples;
    PowerOfTwo;
    TestAssigned;
    MontExamples;
    StreamCipherExamples;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
