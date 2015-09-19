{
  demonstrates:
  1) how to enumerate hash algorithms supported by THash class
  2) how to calculate several hashes of a file using a single file read pass
}
program HashCalc;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  CalcAll in '..\Source\CalcAll.pas';

begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    if ParamCount = 1 then begin
      Writeln('File: ', ParamStr(1));
      Writeln;
      CalcHash(ParamStr(1));
    end
    else begin
      Writeln('Usage: > HashCalc filename');
      Writeln('File: ', ExtractFileName(ParamStr(0)));
      Writeln;
      CalcHash(ParamStr(0));
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln;
  Write('Press <Enter> ..');
  Readln;
end.
