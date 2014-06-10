unit UseList;

interface

uses SysUtils, Classes, tfNumerics;

// ListSize must be a power of 2
function DLog(const Value, Base, Modulo: BigInteger;
                    ListSize: Integer = 1024 * 1024): Int64;

implementation

(*
procedure Solve;
var
  P, G, H, B: BigInteger;
  Factor, Acc: BigInteger;
//  HashTable: TDictionary<BigInteger, Integer>;
  List: TList;
  I, J: Integer;
  Tmp: BigInteger;
  Ptr: PData;

begin
  P:= BigInteger(pStr);
  Writeln('P = ', P.ToString);
  G:= BigInteger(gStr);
  Writeln('G = ', G.ToString);
  H:= BigInteger(hStr);
  Writeln('H = ', H.ToString);
  B:= BigInteger.Pow(2, 20);
  Writeln('B = ', B.ToString);
//  HashTable:= TDictionary<BigInteger, Integer>.Create;
  List:= TList.Create;
  try
    if (G < P) then Writeln( 'G < P');
    Factor:= BigInteger.ModInverse(G, P);
    Tmp:= (G * Factor) mod P;
    Assert(Tmp = 1, 'ModInverse');
    Acc:= H;
    Writeln('Building Hash Table .. ');
    for I:= 0 to 1024 * 1024 - 1 do begin   // 2^20 - 1
      New(Ptr);
      Ptr.Index:= I;
      Ptr.Value:= Acc;
      List.Add(Ptr);
//      HashTable.Add(Acc, I);
      Acc:= (Acc * Factor) mod P;
    end;
    Writeln('Hash Table Completed');
    try
      List.Sort(@ItemCompare);
    except
      Writeln('AV');
    end;
    Factor:= BigInteger.ModPow(G, B, P);
    Writeln('PowMod = ', Factor.ToString);

    Acc:= 1;
    Writeln('Checking Hash Table .. ');
    for I:= 0 to 1024 * 1024 - 1 do begin   // 2^20 - 1
//      if HashTable.ContainsKey(Acc) then begin
      J:= ValueExists(List, Acc);
      if J >= 0 then begin
        Writeln('DLog = ', I, ', ', J);
        Writeln('DLog = ', (B * I + J).ToString);
        Exit;
      end;
      Acc:= (Acc * Factor) mod P;
      if I mod 1000 = 0 then Writeln(I);
    end;
    Writeln('Failed!');
  finally
    for I:= 0 to List.Count - 1 do begin
      Dispose(PData(List[I]));
    end;
    List.Free;
//    HashTable.Free;
  end;
end;
*)

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
