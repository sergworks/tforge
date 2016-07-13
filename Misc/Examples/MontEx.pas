unit MontEx;

interface

uses tfNumerics;

procedure MontExamples;

implementation

// demonstrates what ModMul is doing
procedure ModMulExample;
var
  Mont: TMont;
  A, B: BigInteger;

begin
  A:= (12 * 23) mod 37;
  Writeln('(12 * 23) mod 37 = ', A.ToString);
  Mont:= Mont.GetInstance(37);
  B:= Mont.ModMul(12, 23);
  Assert(A = B);
end;

// demonstrates what Free and IsAssigned are doing
procedure FreeExample;
var
  Mont: TMont;

begin
  Writeln(Mont.IsAssigned);     // FALSE
  Mont:= TMont.GetInstance(37);
  Writeln(Mont.IsAssigned);     // TRUE
  Mont.Free;
  Writeln(Mont.IsAssigned);     // FALSE
end;

// demonstrates how Burn is used
procedure BurnExample;
var
  Mont: TMont;

begin
  Mont:= TMont.GetInstance(37);
  try
    Writeln(Mont.ModMul(12, 23).ToString);
  finally
    Mont.Burn;
  end;
end;

// demonstrates what Convert and Reduce are doing
procedure ConvertExample;
var
  Mont: TMont;
  A, B, C: BigInteger;

begin
  Mont:= TMont.GetInstance(37);
  A:= 12;
  B:= Mont.Convert(A);
  Writeln(A.ToString, ' in Montgomery form = ', B.ToString);
  C:= Mont.Reduce(B);
  Assert(A = C);
end;

// demonstrates what Add and Subtract are doing
procedure AddExample;
var
  Mont: TMont;
  A, B, C: BigInteger;

begin
  Mont:= TMont.GetInstance(37);
  A:= 22;
  B:= Mont.Add(A, 32);
  Writeln(A.ToString, ' + 32 = ', B.ToString, ' (mod 37)');
  C:= Mont.Subtract(B, 32);
  Writeln(B.ToString, ' - 32 = ', C.ToString, ' (mod 37)');
  Assert(A = C);
end;

// demonstrates what Multiply and ModMul are doing
procedure MulExample;
var
  Mont: TMont;
  A, B, C1, C2, C3: BigInteger;

begin
  C1:= (22 * 32) mod 37;
  Writeln('(22 * 32) mod 37 = ', C1.ToString);

  Mont:= TMont.GetInstance(37);
  A:= Mont.Convert(22);   // convert 22 into Montgomery form
  B:= Mont.Convert(32);   // convert 32 into Montgomery form
// multiply in Montgomery form and convert product out of Montgomery form
  C2:= Mont.Reduce(Mont.Multiply(A, B));
  Assert(C1 = C2);

  C3:= Mont.ModMul(22, 32);
  Assert(C1 = C3);
end;

// demonstrates what ModPow is doing
procedure PowExample;
var
  Mont: TMont;
  C1, C2: BigInteger;

begin
  C1:= BigInteger.ModPow(22, 32, 37);   // 22^32 mod 37
  Writeln('22^32 mod 37 = ', C1.ToString);

  Mont:= TMont.GetInstance(37);
  C2:= Mont.ModPow(22, 32);

  Assert(C1 = C2);
end;

procedure MontExamples;
begin
  Writeln;
  Writeln('== Montgomery modular arithmetic ==');
  Writeln;
  ModMulExample;
  FreeExample;
  BurnExample;
  ConvertExample;
  AddExample;
  MulExample;
  PowExample;
end;

end.
