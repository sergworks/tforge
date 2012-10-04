{
  Usage example: BinomCoff 120 42
  Demonstrates how to use BigCardinal type
  see also:
    http://rosettacode.org/wiki/Evaluate_binomial_coefficients#Delphi
}
program BinomCoff;

{$mode delphi}

uses
  SysUtils, tfNumerics;
{  in '..\..\Source\Common\tfNumerics.pas',
  tfTypes in '..\..\Source\Common\tfTypes.pas',
  tfNumbers in '..\..\Source\Numbers\tfNumbers.pas',
  tfLimbs in '..\..\Source\Numbers\tfLimbs.pas',
  arrProcs in '..\..\Source\Numbers\arrProcs.pas'; }

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

begin
//  ReportMemoryLeaksOnShutdown:= True;
  try
    if ParamCount <> 2 then begin
      Writeln('Usage example: BinomCoff 120 42');
      ReadLn;
      Exit;
    end;
    A:= BinomialCoff(StrToInt(ParamStr(1)), StrToInt(ParamStr(2)));
    Writeln(A.AsString);
    A:= BigCardinal(nil);   // A is global var and should be freed explicitely
                            //   to prevent memory leak on shutdown
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.

