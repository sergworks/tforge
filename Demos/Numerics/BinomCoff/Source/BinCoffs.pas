unit BinCoffs;

interface

uses tfNumerics;

function BinomialCoff(N, K: Cardinal): BigCardinal;
procedure WriteCoff(N, K: Cardinal);

implementation

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

procedure WriteCoff(N, K: Cardinal);
begin
  Writeln(' C(', N, ',', K, ')= ', BinomialCoff(N, K).ToString);
end;

end.
