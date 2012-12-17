{
  pi / 4 = 4 * arctan(1 / 5) - arctan(1 / 239)
  arctan(x) = x - x^3 / 3 + x^5 / 5 - x^7 / 7 + ..
}
program PiBench;

{$mode delphi}

uses
  SysUtils, tfNumerics;

var
  PiDigits: BigCardinal;

procedure BenchMark;
var
  Factor, Num, Den: BigCardinal;
  Term: BigCardinal;
  N, M: Cardinal;

begin
  PiDigits:= 0;
  Factor:= BigCardinal.Pow(10, 10000);    // = 10^10000;
  Num:= 16 * Factor;
  Den:= 5;
  N:= 1;
  repeat
    Term:= Num div (Den * (2 * N - 1));
    if Term = 0 then Break;
    if Odd(N)
      then PiDigits:= PiDigits + Term
      else PiDigits:= PiDigits - Term;
    Den:= Den * 25;
    Inc(N);
  until N = 0;
  M:= N;
  Num:= 4 * Factor;
  Den:= 239;
  N:= 1;
  repeat
    Term:= Num div (Den * (2 * N - 1));
    if Term = 0 then Break;
    if Odd(N)
      then PiDigits:= PiDigits - Term
      else PiDigits:= PiDigits + Term;
    Den:= Den * 239 * 239;
    Inc(N);
  until N = 0;
  M:= (M + N) div 2;
// M last digits may be wrong
  PiDigits:= PiDigits div BigCardinal.Pow(10, M);
end;

begin
//  ReportMemoryLeaksOnShutdown:= True;
  try
    Writeln('Benchmark test started ...');
    BenchMark;
    Writeln(PiDigits.ToString);
    PiDigits.Free;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

