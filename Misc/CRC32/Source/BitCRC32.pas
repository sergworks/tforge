unit BitCRC32;

interface

uses SysUtils, tfBytes, RefCRC32;


function PolyModDirect(const Dividend: ByteArray; G: LongWord): LongWord;
function PolyModRevers(const Dividend: ByteArray; G: LongWord): LongWord;

function BitCRC32Reversed(const Msg: ByteArray): LongWord;
function OptCRC32Reversed(const Msg: ByteArray): LongWord;
function OptCRC32Direct(const Msg: ByteArray): LongWord;

function CalcRefCRC32(const Msg: ByteArray): LongWord;


procedure Test;

procedure Test2;

procedure Find;

function BitReverse(Value: LongWord): LongWord;

implementation

function BitReverse(Value: LongWord): LongWord;
begin
  Value:= ((Value and $AAAAAAAA) shr 1) or ((Value and $55555555) shl 1);
  Value:= ((Value and $CCCCCCCC) shr 2) or ((Value and $33333333) shl 2);
  Value:= ((Value and $F0F0F0F0) shr 4) or ((Value and $0F0F0F0F) shl 4);
  Value:= ((Value and $FF00FF00) shr 8) or ((Value and $00FF00FF) shl 8);
  Result:= (Value shr 16) or (Value shl 16);
end;

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

function BitCRC32Reversed(const Msg: ByteArray): LongWord;
var
  Dividend: ByteArray;
  Prefix: LongWord;

begin
//62F5269200000000
  Prefix:= $62F52692;
  Dividend:= ByteArray.FromInt(Prefix, SizeOf(Prefix), True) + Msg + ByteArray.Allocate(4, 0);
  Writeln('Dividend :', Dividend.ToHex);
  Result:= not PolyModRevers(Dividend, $EDB88320);
end;

function OptCRC32Reversed(const Msg: ByteArray): LongWord;
var
  I, L: Cardinal;
  P: PByte;
  Carry: Boolean;

begin
  L:= Msg.Len;
  Result:= $FFFFFFFF;
  P:= Msg.RawData;
  while L > 0 do begin
    Result:= Result xor P^;
    I:= 8;
    Inc(P);
    repeat
      Carry:= Odd(Result);
      Result:= Result shr 1;
      if Carry then
        Result:= Result xor $EDB88320;
      Dec(I);
    until I = 0;
    Dec(L);
  end;
  Result:= not(Result);
end;

function OptCRC32Direct(const Msg: ByteArray): LongWord;
type
  TByteArr = array[0..3] of Byte;

var
  I, L: Cardinal;
  P: PByte;
  Carry: Boolean;

begin
  L:= Msg.Len;
  Result:= $FFFFFFFF;
  P:= Msg.RawData;
  while L > 0 do begin
    TByteArr(Result)[3]:= TByteArr(Result)[3] xor P^;
    I:= 8;
    Inc(P);
    repeat
      Carry:= LongInt(Result) < 0;
      Result:= Result shl 1;
      if Carry then
        Result:= Result xor $04C11DB7;
      Dec(I);
    until I = 0;
    Dec(L);
  end;
  Result:= not(Result);
end;

function CalcRefCRC32(const Msg: ByteArray): LongWord;
begin
  Result:= TCRC32.Hash(Msg.RawData^, Msg.Len);
end;

procedure Test;
var
  Data: ByteArray;
  CRC1, CRC2, CRC3, CRC4, CRC5: LongWord;

begin
//  Data:= ByteArray.FromText('Hello, World!');
  Data:= ByteArray.FromBytes([$FF, $EE, $DD, $CC]);
  CRC1:= BitCRC32Reversed(Data);
  CRC2:= CalcRefCRC32(Data);
  CRC3:= OptCRC32Reversed(Data);
  CRC4:= OptCRC32Direct(Data);
  CRC5:= BitReverse(CRC4);
  Writeln('BitCRC: ', IntToHex(CRC1, 8));
  Writeln('RefCRC: ', IntToHex(CRC2, 8));
  Writeln('BitCRC (Opt, Rev): ', IntToHex(CRC3, 8));
  Writeln('BitCRC (Opt, Dir, Rev): ', IntToHex(CRC4, 8));
  Writeln('BitCRC (Opt, Dir): ', IntToHex(CRC5, 8));
  Assert(CRC1 = CRC2);
  Assert(CRC1 = CRC3);
  Assert(CRC1 = CRC4);
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
  CRC2:= CalcRefCRC32(Data);
  Writeln('BitCRC: ', IntToHex(CRC1, 8));
  Writeln('RefCRC: ', IntToHex(CRC2, 8));
end;

end.
