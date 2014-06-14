unit UseList;

interface

uses SysUtils, Classes, tfNumerics;

// ListSize must be a power of 2
function DLog(const Value, Base, Modulo: BigInteger;
                    ListSize: Integer = 1024 * 1024): Int64;

implementation

type
  PData = ^TData;
  TData = record
    Index: Integer;
    Value: BigInteger;
  end;

function ItemCompare(P1, P2: Pointer): Integer;
begin
  Result:= BigInteger.Compare(PData(P1).Value, PData(P2).Value);
end;

function ValueExists(List: TList; Acc: BigInteger): Integer;
var
  L, H, I, C: Integer;

begin
  Result:= -1;
  L:= 0;
  H:= List.Count - 1;
  while L <= H do begin
    I:= (L + H) shr 1;
    C:= BigInteger.Compare(PData(List[I]).Value, Acc);
    if C < 0 then L:= I + 1
    else begin
      H:= I - 1;
      if C = 0 then begin
        Result:= PData(List[I]).Index;
        Exit;
        {if List.Duplicates <> dupAccept then} L := I;
      end;
    end;
  end;
end;

function DLog(const Value, Base, Modulo: BigInteger;
                    ListSize: Integer): Int64;
var
  List: TList;
  Factor, Acc: BigInteger;
  I, J: Integer;
  P: PData;

begin
  Assert(Base > 1);
  if Value = 1 then begin
    Result:= 0;
    Exit;
  end;
// todo: BigInteger
  Factor:= BigInteger.ModInverse(Base, Modulo);
  Assert((Base * Factor) mod Modulo = 1, 'ModInverse');
  List:= TList.Create;
  try
    Acc:= Value;
    for I:= 0 to ListSize - 1 do begin
      New(P);
      P.Index:= I;
      P.Value:= Acc;
      List.Add(P);
      Acc:= (Acc * Factor) mod Modulo;
    end;
    List.Sort(@ItemCompare);
// todo: BigInteger
    Factor:= BigInteger.ModPow(Base, ListSize, Modulo);
    Acc:= 1;
    for I:= 0 to ListSize - 1 do begin   // 2^20 - 1
      J:= ValueExists(List, Acc);
      if J >= 0 then begin
        Result:= I;
        Result:= Result * ListSize + J;
        Exit;
      end;
      Acc:= (Acc * Factor) mod Modulo;
//      if I mod 1000 = 0 then Writeln(I);
    end;
    raise Exception.Create('DLog failed');
  finally
    for I:= 0 to ListSize - 1 do begin
      Dispose(PData(List[I]));
    end;
    List.Free;
  end;
end;

end.
