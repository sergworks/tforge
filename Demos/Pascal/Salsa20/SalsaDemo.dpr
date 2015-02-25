program SalsaDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfBytes, tfCiphers;


procedure TestVectors;
var
  Salsa20: TCipher;

procedure TestSequence(AKey, ANonce: string; APos: UInt64; ASeq: string);
var
  ExpectedSequence: ByteArray;
  ActualSequence: ByteArray;

begin
  ExpectedSequence:= ByteArray.ParseHex(ASeq);
  ActualSequence:= TCipher.Salsa20
                   .ExpandKey(ByteArray.ParseHex(AKey))
                   .SetNonce(ByteArray.ParseHex(ANonce))
                   .SetPos(APos)
                   .Sequence(ExpectedSequence.Len);
  Writeln('Expected Sequence: ', ExpectedSequence.ToHex);
  Writeln('Actual Sequence  : ', ActualSequence.ToHex);
  Writeln;
  Assert(ExpectedSequence = ActualSequence);
end;

procedure TestDigest(AKey, ANonce: string; ASize: Integer; ADigest: string);
var
  ExpectedDigest: ByteArray;
  ActualDigest: ByteArray;
  Salsa20: TCipher;

begin
  ExpectedDigest:= ByteArray.ParseHex(ADigest);
  ActualDigest  := ByteArray.Allocate(ExpectedDigest.Len, 0);
  Salsa20:= TCipher.Salsa20
                   .ExpandKey(ByteArray.ParseHex(AKey))
                   .SetNonce(ByteArray.ParseHex(ANonce));
  while ASize > 0 do begin
    ActualDigest:= ActualDigest xor Salsa20.Sequence(ExpectedDigest.Len);
    Dec(ASize, ExpectedDigest.Len);
  end;
  Writeln('Expected Digest: ', ExpectedDigest.ToHex);
  Writeln('Actual Digest  : ', ActualDigest.ToHex);
  Writeln;
  Assert(ExpectedDigest = ActualDigest);
end;

begin
  TestSequence(
   '8000000000000000000000000000000000000000000000000000000000000000', // key
   '0000000000000000', // Nonce
   0,                  // Position
   'E3BE8FDD8BECA2E3EA8EF9475B29A6E7' +    // sequence
   '003951E1097A5C38D23B7A5FAD9F6844' +
   'B22C97559E2723C7CBBD3FE4FC8D9A07' +
   '44652A83E72A9C461876AF4D7EF1A117'
  );

  TestSequence(
   '8000000000000000000000000000000000000000000000000000000000000000', // key
   '0000000000000000', // Nonce
   192,                  // Position
   '57BE81F47B17D9AE7C4FF15429A73E10' +
   'ACF250ED3A90A93C711308A74C6216A9' +
   'ED84CD126DA7F28E8ABF8BB63517E1CA' +
   '98E712F4FB2E1A6AED9FDC73291FAA17'
  );

  TestDigest(
   '8000000000000000000000000000000000000000000000000000000000000000', // key
   '0000000000000000', // Nonce
   512,                // Size
   '50EC2485637DB19C6E795E9C73938280' +
   '6F6DB320FE3D0444D56707D7B456457F' +
   '3DB3E8D7065AF375A225A70951C8AB74' +
   '4EC4D595E85225F08E2BC03FE1C42567'
  );


end;

begin
  try
    TestVectors;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
