unit Demo;

{$IFDEF FPC}
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, tfBytes;

procedure RunDemo;

implementation

procedure RunDemo;
var
  A1, A2, A3: ByteArray;
  P: PByte;
  I, L: Integer;
  Sum: Integer;
  B: Byte;

begin
// initialization examples
  A1:= ByteArray(1);
  A2:= ByteArray.FromBytes([2, 3, 4]);

{   also possible
  A2:= ByteArray.Allocate(3);
  A2[0]:= 2;
  A2[1]:= 3;
  A2[2]:= 4;

    or else (Delphi only; FPC 2.6 does not support array constructors):
  A2:= TBytes.Create(2, 3, 4);
}

  Writeln('A1 = ', A1.ToString, ';  Hash: ', IntToHex(A1.HashCode, 8), ';  Len: ', A1.Len);
  Writeln('A2 = ', A2.ToString, ';  Hash: ', IntToHex(A2.HashCode, 8), ';  Len: ', A2.Len);

// concatenation
  A3:= A1 + A2;
  Writeln('A3 = A1 + A2 = ', A3.ToString);

// indexed access to array elements:
  Sum:= 0;
  for I:= 0 to A3.Len - 1 do begin
    Inc(Sum, A3[I]);
  end;
  Writeln('Sum of elements = ', Sum);

// for .. in iteration:
  Sum:= 0;
  for B in A3 do begin
    Inc(Sum, B);
  end;
  Writeln('Sum of elements = ', Sum);

// fast access to array elements:
  P:= A3.RawData;
  L:= A3.Len;
  Sum:= 0;
  while (L > 0) do begin
    Inc(Sum, P^);
    Inc(P);
    Dec(L);
  end;
  Writeln('Sum of elements = ', Sum);

// bitwise 'xor':
  Writeln('A2 xor A3 = ', (A2 xor A3).ToString);

// fluent coding
  Writeln(ByteArray.FromText('ABCDEFGHIJ').Insert(3,
    ByteArray.FromText(' 123 ')).Reverse.ToText);

end;

end.

