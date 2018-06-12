{
  pi / 4 = 4 * arctan(1 / 5) - arctan(1 / 239)
  arctan(x) = x - x^3 / 3 + x^5 / 5 - x^7 / 7 + ..
}
program PiBench;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Diagnostics,
  tfNumerics,
  PiCalcs in '..\Source\PiCalcs.pas';

var
  StopWatch: TStopWatch;
  PiValue: BigCardinal;
  S: string;

begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    Writeln('Benchmark test started ...');
    StopWatch:= TStopWatch.StartNew;
    PiValue:= CalcPi;
    StopWatch.Stop;
    S:= PiValue.ToString;
    Writeln('Pi = ', S[1] + '.' + Copy(S, 2, Length(S) - 1));
    PiValue.Free;
    Writeln;
    Writeln('Time elapsed: ', StopWatch.ElapsedMilliseconds, ' ms.');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
