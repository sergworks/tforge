program ByteArrDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfBytes;

procedure RunDemo;
var
  A1, A2, A3: ByteArray;
  P: PByte;
  I, L: Integer;
  Sum: Integer;

begin
// initialization examples
  A1:= 1;
  A2:= TBytes.Create(2, 3, 4);
  Writeln('A1 = ', A1.ToString);
  Writeln('A2 = ', A2.ToString);

// concatenation
  A3:= A1 + A2;
  Writeln('A3 = A1 + A2 = ', A3.ToString);

// fast access to array elements
  P:= PByte(A3);
  L:= A3.Len;
  Sum:= 0;
  while (L > 0) do begin
    Inc(Sum, P^);
    Inc(P);
    Dec(L);
  end;
  Writeln('Sum of elements = ', Sum);

// slow access to array elements
  Sum:= 0;
  for I:= 0 to A3.Len - 1 do begin
    Inc(Sum, A3[I]);
  end;
  Writeln('Sum of elements = ', Sum);

// bitwise 'xor' example
  Writeln('A2 xor A3 = ', (A2 xor A3).ToString);

end;

begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    RunDemo;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
