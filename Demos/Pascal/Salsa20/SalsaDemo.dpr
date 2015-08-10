program SalsaDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfBytes, tfCiphers;

type
  PExtKey = ^TExtKey;
  TExtKey = array[0..63] of Byte;

procedure TestVectors;
var
  Salsa20: TCipher;

procedure TestKeystream(AKey, ANonce: string; APos: UInt64; ASeq: string);
var
  ExpectedKeystream: ByteArray;
  ActualKeystream: ByteArray;

begin
  ExpectedKeystream:= ByteArray.ParseHex(ASeq);
  ActualKeystream:= TCipher.Salsa20
                   .ExpandKey(ByteArray.ParseHex(AKey))
                   .SetNonce(ByteArray.ParseHex(ANonce))
                   .Skip(APos)
                   .KeyStream(ExpectedKeystream.Len);
  Writeln('Expected: ', ExpectedKeystream.ToHex);
  Writeln('Actual  : ', ActualKeystream.ToHex);
  Writeln;
  Assert(ExpectedKeystream = ActualKeystream);
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
    ActualDigest:= ActualDigest xor Salsa20.KeyStream(ExpectedDigest.Len);
    Dec(ASize, ExpectedDigest.Len);
  end;
  Writeln('Expected Digest: ', ExpectedDigest.ToHex);
  Writeln('Actual Digest  : ', ActualDigest.ToHex);
  Writeln;
  Assert(ExpectedDigest = ActualDigest);
end;

begin

  TestKeyStream('80000000000000000000000000000000',
                '0000000000000000',
                0,
                '4DFA5E481DA23EA09A31022050859936' +
                'DA52FCEE218005164F267CB65F5CFD7F' +
                '2B4F97E0FF16924A52DF269515110A07' +
                'F9E460BC65EF95DA58F740B7D1DBB0AA'
                );

  TestKeystream(
   '8000000000000000000000000000000000000000000000000000000000000000', // key
   '0000000000000000', // Nonce
   0,                  // Position
   'E3BE8FDD8BECA2E3EA8EF9475B29A6E7' +    // Keystream
   '003951E1097A5C38D23B7A5FAD9F6844' +
   'B22C97559E2723C7CBBD3FE4FC8D9A07' +
   '44652A83E72A9C461876AF4D7EF1A117'
  );

  TestKeystream(
   '8000000000000000000000000000000000000000000000000000000000000000', // key
   '0000000000000000', // Nonce
   3,                  // Position
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

procedure TestKey;
const
  KeyStr = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,' +
    '201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216';

  NonceStr = '101, 102, 103, 104, 105, 106, 107, 108';
  NoStr = '109, 110, 111, 112, 113, 114, 115, 116';
//  NoStr = '116, 115, 114, 113, 112, 111, 110, 109';

  IVStr = NonceStr + ', ' + NoStr;

var
  Key, Nonce, KeyStream: ByteArray;
  No: UInt64;
  IV: ByteArray;
  I, J: Integer;
  Tmp: ByteArray;

begin
  Key:= ByteArray.Parse(KeyStr, ',');
  Writeln('Key: ', Key.ToString);
  Nonce:= ByteArray.Parse(NonceStr, ',');
  Writeln('Nonce: ', Nonce.ToString);
  No:= UInt64(ByteArray.Parse(NoStr, ','));
  Writeln('No: ', No);
  IV:= ByteArray.Parse(IVStr, ',');
  Keystream:= TCipher.Salsa20
                   .ExpandKey(Key)
                   .SetIV(IV)
//                   .SetNonce(Nonce)
//                   .Skip(No)
                   .KeyStream(64);
  Writeln(KeyStream.ToString);
//  for I:= 0 to KeyStream.Len - 1 do begin
//    Writeln(KeyStream[I]);
//    Tmp:= ByteArray.Copy(KeyStream, I*4, 4);
//    Writeln(ByteArray.Reverse(Tmp).ToHex);
//    J:= LongWord(Tmp);
//    Writeln(IntToHex(J, 4));
//  end;
  Writeln;
end;


type
  PSalsaBlock = ^TSalsaBlock;
  TSalsaBlock = array[0..15] of LongWord;

procedure DoubleRound(x: PSalsaBlock);
var
  y: LongWord;

begin
  y := x[ 0] + x[12]; x[ 4] := x[ 4] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 4] + x[ 0]; x[ 8] := x[ 8] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 8] + x[ 4]; x[12] := x[12] xor ((y shl 13) or (y shr (32-13)));
  y := x[12] + x[ 8]; x[ 0] := x[ 0] xor ((y shl 18) or (y shr (32-18)));
  y := x[ 5] + x[ 1]; x[ 9] := x[ 9] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 9] + x[ 5]; x[13] := x[13] xor ((y shl 09) or (y shr (32-09)));
  y := x[13] + x[ 9]; x[ 1] := x[ 1] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 1] + x[13]; x[ 5] := x[ 5] xor ((y shl 18) or (y shr (32-18)));
  y := x[10] + x[ 6]; x[14] := x[14] xor ((y shl 07) or (y shr (32-07)));
  y := x[14] + x[10]; x[ 2] := x[ 2] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 2] + x[14]; x[ 6] := x[ 6] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 6] + x[ 2]; x[10] := x[10] xor ((y shl 18) or (y shr (32-18)));
  y := x[15] + x[11]; x[ 3] := x[ 3] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 3] + x[15]; x[ 7] := x[ 7] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 7] + x[ 3]; x[11] := x[11] xor ((y shl 13) or (y shr (32-13)));
  y := x[11] + x[ 7]; x[15] := x[15] xor ((y shl 18) or (y shr (32-18)));
  y := x[ 0] + x[ 3]; x[ 1] := x[ 1] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 1] + x[ 0]; x[ 2] := x[ 2] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 2] + x[ 1]; x[ 3] := x[ 3] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 3] + x[ 2]; x[ 0] := x[ 0] xor ((y shl 18) or (y shr (32-18)));
  y := x[ 5] + x[ 4]; x[ 6] := x[ 6] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 6] + x[ 5]; x[ 7] := x[ 7] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 7] + x[ 6]; x[ 4] := x[ 4] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 4] + x[ 7]; x[ 5] := x[ 5] xor ((y shl 18) or (y shr (32-18)));
  y := x[10] + x[ 9]; x[11] := x[11] xor ((y shl 07) or (y shr (32-07)));
  y := x[11] + x[10]; x[ 8] := x[ 8] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 8] + x[11]; x[ 9] := x[ 9] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 9] + x[ 8]; x[10] := x[10] xor ((y shl 18) or (y shr (32-18)));
  y := x[15] + x[14]; x[12] := x[12] xor ((y shl 07) or (y shr (32-07)));
  y := x[12] + x[15]; x[13] := x[13] xor ((y shl 09) or (y shr (32-09)));
  y := x[13] + x[12]; x[14] := x[14] xor ((y shl 13) or (y shr (32-13)));
  y := x[14] + x[13]; x[15] := x[15] xor ((y shl 18) or (y shr (32-18)));
end;

const
  Block1: TSalsaBlock = (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  Expected1: TSalsaBlock = ($8186a22d, $0040a284, $82479210, $06929051,
                            $08000090, $02402200, $00004000, $00800000,
                            $00010200, $20400000, $08008104, $00000000,
                            $20500000, $a0000040, $0008180a, $612a8020);

//                         0xde501066 0x6f9eb8f7 0xe4fbbd9b 0x454e3f57;
  Block2: TSalsaBlock =    ($de501066, $6f9eb8f7, $e4fbbd9b, $454e3f57,
//                         0xb75540d3 0x43e93a4c 0x3a6f2aa0 0x726d6b36;
                            $b75540d3, $43e93a4c, $3a6f2aa0, $726d6b36,
//                         0x9243f484 0x9145d1e8 0x4fa9d247 0xdc8dee11;
                            $9243f484, $9145d1e8, $4fa9d247, $dc8dee11,
//                         0x054bf545 0x254dd653 0xd9421b6d 0x67b276c1)
                            $054bf545, $254dd653, $d9421b6d, $67b276c1);

  Expected2: TSalsaBlock = ($ccaaf672, $23d960f7, $9153e63a, $cd9a60d0,
                            $50440492, $f07cad19, $ae344aa0, $df4cfdfc,
                            $ca531c29, $8e7943db, $ac1680cd, $d503ca00,
                            $a74b2ad6, $bc331c5c, $1dda24c7, $ee928277);


procedure TestDoubleRound(const Block, Expected: TSalsaBlock);
var
  Actual: TSalsaBlock;
  I: Integer;

begin
  Writeln;
  Actual:= Block;
  DoubleRound(@Actual);
  for I:= 0 to 15 do begin
    Writeln(IntToHex(Actual[I], 8), ',  ', IntToHex(Expected[I], 8));
    Assert(Actual[I] = Expected[I]);
  end;
end;

type
  TSalsaArray = array[0..63] of Byte;

const
  Salsa20_1: TSalsaArray =
   (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

  Salsa20_1_Expected: TSalsaArray =
   (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

  Salsa20_2: TSalsaArray =
  (211,159, 13,115, 76, 55, 82,183, 3,117,222, 37,191,187,234,136,
    49,237,179, 48, 1,106,178,219,175,199,166, 48, 86, 16,179,207,
    31,240, 32, 63, 15, 83, 93,161,116,147, 48,113,238, 55,204, 36,
    79,201,235, 79, 3, 81,156, 47,203, 26,244,243, 88,118,104, 54);

  Salsa20_2_Expected: TSalsaArray =
  (109, 42,178,168,156,240,248,238,168,196,190,203, 26,110,170,154,
    29, 29,150, 26,150, 30,235,249,190,163,251, 48, 69,144, 51, 57,
    118, 40,152,157,180, 57, 27, 94,107, 42,236, 35, 27,111,114,114,
    219,236,232,135,111,155,110, 18, 24,232, 95,158,179, 19, 48,202);

  Salsa20_10: TSalsaArray =
(101,120,112, 97, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
13, 14, 15, 16,110,100, 32, 51,101,102,103,104,105,106,107,108,
109,110,111,112,113,114,115,116, 50, 45, 98,121,201,202,203,204,
205,206,207,208,209,210,211,212,213,214,215,216,116,101, 32,107);

  Salsa20_10_Expected: TSalsaArray =
( 69, 37, 68, 39, 41, 15,107,193,255,139,122, 6,170,233,217, 98,
89,144,182,106, 21, 51,200, 65,239, 49,222, 34,215,114, 40,126,
104,197, 7,225,197,153, 31, 2,102, 78, 76,176, 84,245,246,184,
177,160,133,130, 6, 72,149,119,192,195,132,236,234,103,246, 74);

procedure TestHash(const Block, Expected: TSalsaArray);
var
  Actual: TSalsaArray;
  I, J: Integer;

begin
  Writeln;
  Actual:= Block;
  for I:= 0 to 9 do
    DoubleRound(@Actual);
  for I:= 0 to 15 do begin
    PSalsaBlock(@Actual)[I]:= PSalsaBlock(@Actual)[I] + PSalsaBlock(@Block)[I];
    for J:= 4 * I to 4 * I + 3 do begin
      Writeln(Actual[I], ',  ', Expected[I]);
      Assert(Actual[I] = Expected[I]);
    end;
  end;
end;

procedure TestCopy;
const
  KeyStr = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,' +
    '201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216';

var
  KeyStream: ByteArray;
  Tmp: ByteArray;
  I: Integer;

begin
  Keystream:= ByteArray.Parse(KeyStr, ',');
  Writeln(KeyStream.ToString);
  I:= 0;
//  Tmp:= ByteArray.Copy(KeyStream, I*4, 4);
  Tmp:= KeyStream.Copy(I*4, 4);
  Writeln(KeyStream.Len, ', ', KeyStream.ToHex);
  Writeln(Tmp.Len, ', ', Tmp.ToHex);
  Writeln;
end;

procedure TestFromText;
var
  A: ByteArray;
  I, Sum: Integer;
  P: PByte;
  B: Byte;

begin
  A:= ByteArray.Parse('10 20 30 40 50');
                  // using 'Bytes' property
  Sum:= 0;
  for I:= 0 to A.Len - 1 do
    Inc(Sum, A[I]);
  Writeln(Sum);
                  // using 'RawData' property
  Sum:= 0;
  P:= A.RawData;
  for I:= 0 to A.Len - 1 do
    Inc(Sum, P[I]);
  Writeln(Sum);
                  // using 'for .. in' loop
  Sum:= 0;
  for B in A do
    Inc(Sum, B);
  Writeln(Sum);
end;

procedure EncryptFiles(const Key: ByteArray; FileNames: array of string);
var
  Cipher: TCipher;
  Nonce: UInt64;
  I: Integer;

begin
  Nonce:= 0;
  for I:= 0 to High(FileNames) do begin
    Cipher:= TCipher.Salsa20;
    Inc(Nonce);
    try
      Cipher.ExpandKey(Key)
            .SetNonce(Nonce)
            .EncryptFile(FileNames[I], FileNames[I] + '.salsa20');
    finally
      Cipher.Burn;
    end;
  end;
end;

begin
  try
{
    TestDoubleRound(Block1, Expected1);
    TestDoubleRound(Block2, Expected2);
    TestHash(Salsa20_1, Salsa20_1_Expected);
    TestHash(Salsa20_2, Salsa20_2_Expected);
    TestHash(Salsa20_10, Salsa20_10_Expected);
}
//    TestKey;
    TestVectors;
//    TestCopy;
//  TestFromText;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
