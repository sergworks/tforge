unit CRC32Utils;

interface

uses SysUtils, tfBytes;



function PolyModDirect(const Dividend: ByteArray; G: LongWord): LongWord;
function PolyModRevers(const Dividend: ByteArray; G: LongWord): LongWord;

function BitCRC32(const Msg: ByteArray): LongWord;
function RefCRC32(const Msg: ByteArray): LongWord;
procedure Test;

procedure Test2;

procedure Find;

implementation

function PolyModDirect(const Dividend: ByteArray; G: LongWord): LongWord;
var
  I, L: Cardinal;
  P: PByte;
  B: Byte;
  Carry: Boolean;

begin
  L:= Dividend.Len;
  Result:= 0;
  P:= Dividend.RawData;
  while L > 0 do begin
    B:= P^;
    Inc(P);
// push B through the Result register
    I:= 8;
    repeat
      Carry:= LongInt(Result) < 0;
      Result:= Result shl 1;
      if ShortInt(B) < 0 then
        Result:= Result or 1;
      B:= B shl 1;
      if Carry then Result:= Result xor G;
      Dec(I);
    until I = 0;
    Dec(L);
  end;
end;

function PolyModRevers(const Dividend: ByteArray; G: LongWord): LongWord;
var
  I, L: Cardinal;
  P: PByte;
  B: Byte;
  Carry: Boolean;

begin
  L:= Dividend.Len;
  Result:= 0;
  P:= Dividend.RawData;
  while L > 0 do begin
    B:= P^;
    Inc(P);
// push B through the Result register
    I:= 8;
    repeat
      Carry:= Odd(Result);
      Result:= Result shr 1;
      if Odd(B) then
//      if ShortInt(B) < 0 then
        Result:= Result or $80000000;
      B:= B shr 1;
      if Carry then Result:= Result xor G;
      Dec(I);
    until I = 0;
    Dec(L);
  end;
end;

function PolyMod32(Dividend, G: LongWord): LongWord;
var
  I, L: Cardinal;
  P: PByte;
  B: Byte;
  Carry: Boolean;

begin
  L:= 4;
  Result:= 0;
  P:= @Dividend;
  while L > 0 do begin
    B:= P^;
    Inc(P);
// push B through the Result register
    I:= 8;
    repeat
      Carry:= Odd(Result);
      Result:= Result shr 1;
      if Odd(B) then
//      if ShortInt(B) < 0 then
        Result:= Result or $80000000;
      B:= B shr 1;
      if Carry then Result:= Result xor G;
      Dec(I);
    until I = 0;
    Dec(L);
  end;
end;

procedure Find;
var
  Dividend: ByteArray;
  N, R: LongWord;

begin
  N:= 0;
  repeat
    Dividend:= ByteArray.FromInt(N, SizeOf(N), True) + ByteArray.Allocate(4, 0);
    R:= PolyModRevers(Dividend, $EDB88320);
    if R = $FFFFFFFF then begin
      Writeln('N: ', Dividend.ToHex);
      Exit;
    end;
    Inc(N);
    if N and $ffffff = 0 then writeln(n);
  until N = 0;
  Writeln('Failed');
end;


function CRC32Helper(const Msg: ByteArray): LongWord;
var
  Dividend: ByteArray;

begin
  Dividend:= Msg + ByteArray.Allocate(4, 0);
  Result:= PolyModRevers(Dividend, $EDB88320);
end;

function BitCRC32(const Msg: ByteArray): LongWord;
var
  Dividend: ByteArray;
  Prefix: LongWord;

begin
//62F5269200000000
//  Dividend:= ByteArray.FromBytes([$62, $F5, $26, $92]) + Msg + ByteArray.Allocate(4, 0);
//  Dividend:= Msg + ByteArray.Allocate(4, 0);
  Prefix:= $62F52692;
  Dividend:= ByteArray.FromInt(Prefix, SizeOf(Prefix), True) + Msg + ByteArray.Allocate(4, 0);
  Writeln('Dividend :', Dividend.ToHex);
  Result:= {not} PolyModRevers(Dividend, $EDB88320);
//                             $04C11DB7);
end;

function RefCRC32(const Msg: ByteArray): LongWord;
begin
  Result:= TCRC32.Hash(Msg.RawData^, Msg.Len);
end;

procedure Test;
var
  Data: ByteArray;
  CRC1, CRC2: LongWord;

begin
//  Data:= ByteArray.FromText('Hello, World!');
  Data:= ByteArray.FromBytes([2]);
  CRC1:= BitCRC32(Data);
  CRC2:= RefCRC32(Data);
  Writeln('BitCRC: ', IntToHex(CRC1, 8));
  Writeln('RefCRC: ', IntToHex(CRC2, 8));
end;

procedure Test2;
var
  Data: ByteArray;
  CRC1, CRC2: LongWord;

begin
//  repeat
//  until N = 0;;
//  Writeln(PolyModRevers(ByteArray.FromBytes([$FF, $FF, $FF, $FF, 0, 0, 0, 0]),
  Data:= ByteArray.FromBytes([1, 2]);
  CRC1:= PolyModRevers(ByteArray.FromBytes([1, 2, 0, 0, 0, 0]),
    $EDB88320);
  CRC2:= RefCRC32(Data);
  Writeln('BitCRC: ', IntToHex(CRC1, 8));
  Writeln('RefCRC: ', IntToHex(CRC2, 8));
end;

end.
