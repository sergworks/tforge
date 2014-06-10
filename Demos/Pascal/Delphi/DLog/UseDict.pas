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

begin
  Assert(Base > 1);
  if Value = 1 then begin
    Result:= 0;
    Exit;
  end;
// todo: BigInteger
  Factor:= BigInteger.ModInverse(Base, Modulo);
  Assert((Base * Factor) mod Modulo = 1, 'ModInverse');
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
  end;
end;

end.
