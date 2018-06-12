{
  Usage example: BinomCoff 120 42
  Demonstrates how to use BigCardinal type
  see also:
    http://rosettacode.org/wiki/Evaluate_binomial_coefficients#Delphi
}
program BinomCoff;

{$mode delphi}

uses
  SysUtils, BinCoffs;

begin
  try
    if ParamCount <> 2 then begin
      Writeln('Usage example: BinomCoff 120 42');
      Writeln;
      WriteCoff(120, 42);
    end
    else
      WriteCoff(StrToInt(ParamStr(1)), StrToInt(ParamStr(2)));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.

