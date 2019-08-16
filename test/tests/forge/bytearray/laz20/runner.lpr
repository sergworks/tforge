program runner;

uses
  SysUtils, Loggers, TestClasses, ByteArrayAddBytesTests;

procedure Run;
var
  Logger: TLogger;

begin
  Logger:= TLogger.Create(LOG_NORMAL, LOG_DETAILED);
  try
    TTestRunner.RunTests(TByteArrayAddBytesRunner, Logger);
  finally
    Logger.Free;
  end;
end;

begin
  try
    Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln;
  Write('Press Enter ... ');
  Readln;
end.

