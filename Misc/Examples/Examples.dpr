program Examples;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  tfNumerics,
  tfRandoms,
  tfHashes,
  MontEx in 'MontEx.pas',
  StreamCipherEx in 'StreamCipherEx.pas';

procedure BigCardExamples;
var
  A, B, C, D, G: BigCardinal;
  S: string;

begin
  Writeln;
  Writeln('== BigCardinal==');
  Writeln;
// DivRem
  A:= 42;
  B:= 77;

  A:= BigCardinal.DivRem(B, A, B);
  Writeln('77 div 42 = ', A.ToString);    // outputs '1'
  Writeln('77 mod 42 = ', B.ToString);    // outputs '35'

// Pow
  A:= 10;
  Writeln(BigCardinal.Pow(A, 5).ToString);    // outputs '100000'

  Writeln(BigCardinal.PowerOfTwo(16).ToString);  // outputs '65536' = 2^16
  A:= 10;
  Writeln(BigCardinal.Sqr(A).ToString);    // outputs '100'

  if BigCardinal.PowerOfTwo(16).IsPowerOfTwo
    then Writeln(BigCardinal.PowerOfTwo(16).ToString + ' is a power of 2');


  A:= 100;
  Writeln(BigInteger.Sqrt(A).ToString);    // outputs '10'
  A:= 99;
  Writeln(BigInteger.Sqrt(A).ToString);    // outputs '9'

  Writeln('BigCardinal.GCD');
  A:= 100;
  B:= 80;
  Writeln(BigCardinal.GCD(A, B).ToString);    // outputs '20'

  Writeln('BigCardinal.LCM');
  A:= 100;
  B:= 80;
  Writeln(BigCardinal.LCM(A, B).ToString);    // outputs '400'

  Writeln('BigCardinal.ModPow');
  A:= 10;
  B:= 3;
  C:= 512;
  Writeln(BigCardinal.ModPow(A, B, C).ToString);    // outputs '488' = 10^3 mod 512

  Writeln('BigCardinal.ModInverse');
  A:= 10;
  B:= 511;
  C:= BigCardinal.ModInverse(A, B);
  Writeln(C.ToString);                  // outputs '460'
  Writeln(((C * A) mod B).ToString);    // outputs '1'

  Writeln('BigCardinal.Parse');
  Writeln(BigCardinal.Parse('123').ToString);          // outputs '123'
//  Writeln(BigCardinal.Parse('-123').ToString);         // outputs '-123'
  Writeln(BigCardinal.Parse('$80').ToString);          // outputs '128'
  Writeln(BigCardinal.Parse('0x80').ToString);         // outputs '128'
  Writeln(BigCardinal('0x80').ToString);         // outputs '128'

  Writeln('BigCardinal.Next');
  A:= 10;
  Writeln(A.Next.ToString);          // outputs '11'


  A:= 0;
  B:= A + 1;
  C:= A.Next;
  Assert(B = C);

//  B:= A - 1;
//  C:= A.Prev;
//  Assert(B = C);
end;

procedure BigIntExamples;
var
  A, B, C, D, G: BigInteger;
  S: String;

begin
// Abs
  A:= 42;
  Writeln(BigInteger.Abs(A).ToString);    // outputs '42'
  A:= -77;
  Writeln(BigInteger.Abs(A).ToString);    // outputs '77'

// DivRem
  A:= -42;
  B:= 77;

  A:= BigInteger.DivRem(B, A, B);
  Writeln('77 div -42 = ', A.ToString);    // outputs '-1'
  Writeln('77 mod -42 = ', B.ToString);    // outputs '35'

//  Writeln('-77 div -42 = ', -77 div -42);    // outputs '-1'
//  Writeln('-77 mod -42 = ', -77 mod -42);    // outputs '35'

  A:= 10;
  Writeln(BigInteger.Pow(A, 5).ToString);    // outputs '100000'

  A:= 10;
  Writeln(BigInteger.Sqr(A).ToString);

  A:= 100;
  Writeln(BigInteger.Sqrt(A).ToString);    // outputs '10'
  A:= 99;
  Writeln(BigInteger.Sqrt(A).ToString);    // outputs '9'

  Writeln('BigInteger.GCD');
  A:= 100;
  B:= 80;
  Writeln(BigInteger.GCD(A, B).ToString);    // outputs '20'

  Writeln('BigInteger.LCM');
  A:= 100;
  B:= 80;
  Writeln(BigInteger.LCM(A, B).ToString);    // outputs '400'

  Writeln('BigInteger.EGCD');
  A:= 200;
  B:= 80;
  G:= BigInteger.EGCD(A, B, C, D);
  Writeln(G.ToString);    // outputs '40'
  Writeln(C.ToString);    // outputs '1'
  Writeln(D.ToString);    // outputs '-2'

  Writeln('BigInteger.ModPow');
  A:= 10;
  B:= 3;
  C:= 512;
  Writeln(BigInteger.ModPow(A, B, C).ToString);    // outputs '488' = 10^3 mod 512

  Writeln('BigInteger.ModInverse');
  A:= 10;
  B:= 511;
  C:= BigInteger.ModInverse(A, B);
  Writeln(C.ToString);                  // outputs '460'
  Writeln(((C * A) mod B).ToString);    // outputs '1'

  Writeln('BigInteger.Parse');
  Writeln(BigInteger.Parse('123').ToString);          // outputs '123'
  Writeln(BigInteger.Parse('-123').ToString);         // outputs '-123'
  Writeln(BigInteger.Parse('$80').ToString);          // outputs '128'
  Writeln(BigInteger.Parse('-$80').ToString);         // outputs '-128'
  Writeln(BigInteger.Parse('0x80').ToString);         // outputs '128'
  Writeln(BigInteger.Parse('-0x80').ToString);        // outputs '-128'
  Writeln(BigInteger.Parse('$80', True).ToString);    // outputs '-128'
  Writeln(BigInteger.Parse('$080', True).ToString);   // outputs '128'
  Writeln(BigInteger.Parse('0x80', True).ToString);   // outputs '-128'
  Writeln(BigInteger.Parse('0x080', True).ToString);  // outputs '128'

  Writeln('BigInteger.TryParse');
  S:= '1234';
  if BigInteger.TryParse(S, A)
    then Writeln(A.ToString)
    else Writeln('Error Parsing '+S);

  Writeln('conversion to integer types');
  Writeln(Byte(BigInteger.Parse('123')));             // outputs '123'
  Writeln(ShortInt(BigInteger.Parse('123')));         // outputs '123'
  Writeln(Byte(BigInteger.Parse('223')));             // outputs '123'
  Writeln(ShortInt(BigInteger.Parse('223')));         // outputs '-33'
  Writeln(Byte(BigInteger.Parse('2223')));            // outputs '175'
  Writeln(ShortInt(BigInteger.Parse('2223')));        // outputs '-81'
  Writeln(Byte(BigInteger.Parse('$80')));             // outputs '128'
  Writeln(ShortInt(BigInteger.Parse('$80')));         // outputs '-128'
  Writeln(UInt64(BigInteger.Parse('$8000000000000000')));
  Writeln(Int64(BigInteger.Parse('$8000000000000000')));

//PowerOf

end;

procedure PowerOfTwo;
var
  Power: Cardinal;
  Expected, Actual: BigCardinal;

begin
  Power:= 0;
  Expected:= 1;
  while Power < 1024 do begin
    Actual:= BigCardinal.PowerOfTwo(Power);
    if Power < 16 then Writeln(Actual.ToString);
    Assert(Expected = Actual);
    Assert(Actual.IsPowerOfTwo);
    Actual:= Actual or 3;
    Assert(not Actual.IsPowerOfTwo);
    Inc(Power);
    Expected:= Expected shl 1;
  end;
end;

procedure RandExamples;
var
  I, N: Integer;
  Rand: TRandom;

begin
  Writeln;
  Writeln('Random');
  try
    for I:= 0 to 11 do begin
      Rand.GetRand(N, SizeOf(N));
      Writeln(IntToHex(N, 8));
    end;
  finally
    Rand.Burn;
  end;
end;


procedure TestAssigned;
var
  SHA256: THash;

begin
  Writeln(SHA256.IsAssigned);     // FALSE
  SHA256:= THash.SHA256;
  Writeln(SHA256.IsAssigned);     // TRUE
  SHA256.Free;
  Writeln(SHA256.IsAssigned);     // FALSE
end;


begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    BigIntExamples;
//    RandExamples;
//    RandExamples;
//    RandExamples;
    BigCardExamples;
    PowerOfTwo;
    TestAssigned;
    MontExamples;
    StreamCipherExamples;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
