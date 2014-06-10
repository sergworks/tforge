unit UseDict;

interface

uses SysUtils, Generics.Defaults, Generics.Collections, tfNumerics, tfGNumerics;

// HashTableSize must be a power of 2
function DLog(const Value, Base, Modulo: BigInteger;
                    HashTableSize: Integer = 1024 * 1024): Int64;

implementation

function DLog(const Value, Base, Modulo: BigInteger;
                    HashTableSize: Integer): Int64;
var
  HashTable: TBigIntegerDictionary<Integer>;
  Factor, Acc: BigInteger;
  I: Integer;
//  Comparer: TBigIntegerComparer;

begin
  Assert(Base > 1);
  if Value = 1 then begin
    Result:= 0;
    Exit;
  end;
// todo: BigInteger
  Factor:= BigInteger.ModInverse(Base, Modulo);
  Assert((Base * Factor) mod Modulo = 1, 'ModInverse');
//  Comparer:= TBigIntegerComparer.Ordinal;
//  HashTable:= TDictionary<BigInteger, Integer>.Create(TBigIntegerComparer.Ordinal);
  HashTable:= TBigIntegerDictionary<Integer>.Create;
  try
    Acc:= Value;
    for I:= 0 to HashTableSize - 1 do begin
      HashTable.Add(Acc, I);
      Acc:= (Acc * Factor) mod Modulo;
    end;
// todo: BigInteger
    Factor:= BigInteger.ModPow(Base, HashTableSize, Modulo);
    Acc:= 1;
    for I:= 0 to HashTableSize - 1 do begin   // 2^20 - 1
      if HashTable.ContainsKey(Acc) then begin
        Result:= I;
        Result:= HashTable[Acc] + Result * HashTableSize;
        Exit;
      end;
      Acc:= (Acc * Factor) mod Modulo;
//      if I mod 1000 = 0 then Writeln(I);
    end;
    raise Exception.Create('DLog failed');
  finally
    HashTable.Free;
//    Comparer.Free;
  end;
end;

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
//    Factor:= BigInteger.ModPow(G, B, P);
//    Writeln('ModPow = ', Factor.ToString);

    Factor:= G;
    Factor:= (Factor * Factor) mod P;    // ^2
    Factor:= (Factor * Factor) mod P;    // ^4
    Factor:= (Factor * Factor) mod P;    // ^8
    Factor:= (Factor * Factor) mod P;    // ^16
    Factor:= (Factor * Factor) mod P;    // ^32
    Factor:= (Factor * Factor) mod P;    // ^64
    Factor:= (Factor * Factor) mod P;    // ^128
    Factor:= (Factor * Factor) mod P;    // ^256
    Factor:= (Factor * Factor) mod P;    // ^512
    Factor:= (Factor * Factor) mod P;    // ^1024
    Factor:= (Factor * Factor) mod P;    // ^2 * 1024
    Factor:= (Factor * Factor) mod P;    // ^4
    Factor:= (Factor * Factor) mod P;    // ^8
    Factor:= (Factor * Factor) mod P;    // ^16
    Factor:= (Factor * Factor) mod P;    // ^32
    Factor:= (Factor * Factor) mod P;    // ^64
    Factor:= (Factor * Factor) mod P;    // ^128
    Factor:= (Factor * Factor) mod P;    // ^256
    Factor:= (Factor * Factor) mod P;    // ^512
    Factor:= (Factor * Factor) mod P;    // ^1024

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
end.
