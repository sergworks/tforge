{
  Usage example: BinomCoff 120 42
  Demonstrates how to use BigCardinal type
  see also:
    http://rosettacode.org/wiki/Evaluate_binomial_coefficients#Delphi
}
program BinomCoff;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfNumerics;

function BinomialCoff(N, K: Cardinal): BigCardinal;
var
  L: Cardinal;

begin
  if N < K then
    Result:= 0      // Error
  else begin
    if K > N - K then
      K:= N - K;    // Optimization
    Result:= 1;
    L:= 0;
    while L < K do begin
      Result:= Result * (N - L);
      Inc(L);
      Result:= Result div L;
    end;
  end;
end;

var
  A: BigCardinal;
  M, N: Cardinal;

begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    if ParamCount <> 2 then begin
      Writeln('Usage example: BinomCoff 120 42');
      ReadLn;
      Exit;
    end;
    N:= StrToInt(ParamStr(1));
    M:= StrToInt(ParamStr(2));
    A:= BinomialCoff(N, M);
    Writeln('C(', N, ', ', M, ') = ', A.AsString);
    A:= BigCardinal(nil);   // A is global var and should be freed explicitely
                            //   to prevent memory leak on shutdown
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
