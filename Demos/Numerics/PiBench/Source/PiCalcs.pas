unit PiCalcs;

interface

uses
  tfNumerics;

function CalcPi: BigCardinal;

implementation

function CalcPi: BigCardinal;
var
  Factor, Num, Den: BigCardinal;
  Term: BigCardinal;
  PiDigits: BigCardinal;
  N, M: Cardinal;
  MaxError: Cardinal;
  ValidDigits: BigCardinal;

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
  MaxError:= (M + N) div 2 + 2;
  Term:= 1;
  repeat
    Term:= Term * 10;
  until Term > MaxError;
  repeat
    ValidDigits:= BigCardinal.DivRem(PiDigits, Term, Num);
    if Num > MaxError then Break;
    Term:= Term * 10;
  until False;
  Result:= ValidDigits;
end;

end.
