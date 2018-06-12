{
  pi / 4 = 4 * arctan(1 / 5) - arctan(1 / 239)
  arctan(x) = x - x^3 / 3 + x^5 / 5 - x^7 / 7 + ..
}
program PiBench;

{$mode delphi}

uses
  SysUtils, PiCalcs, tfNumerics;

const
  MillisPerDay = 24 * 60 * 60 * 1000;

var
  StartTime: TDateTime;
  ElapsedMillis: Integer;
  PiValue: BigCardinal;
  S: string;

begin
//  ReportMemoryLeaksOnShutdown:= True;
  try
    Writeln('Benchmark test started ...');
    StartTime:= Now;
    PiValue:= CalcPi;
    ElapsedMillis:= Round((Now - StartTime) * MillisPerDay);
    S:= PiValue.ToString;
    Writeln('Pi = ', S[1] + '.' + Copy(S, 2, Length(S) - 1));
    PiValue.Free;
    Writeln;
    Writeln('Time elapsed: ', ElapsedMillis, ' ms.');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

