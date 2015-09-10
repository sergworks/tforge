program HashCalc;

{$mode delphi}

uses
  SysUtils,
  CalcAll;

begin
  try
    if ParamCount = 1 then begin
      Writeln('File: ', ParamStr(1));
      Writeln;
      CalcHash(ParamStr(1));
    end
    else
      Writeln('Usage: > HashCalc filename');
      Writeln('File: ', ExtractFileName(ParamStr(0)));
      Writeln;
      CalcHash(ParamStr(0));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln;
  Write('Press <Enter> ..');
  Readln;
end.

