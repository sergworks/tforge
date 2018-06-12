program ByteArrDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  tfBytes,
  demo in '..\Source\demo.pas';

begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    RunDemo;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
