unit ChUtils;

{$ifdef FPC}
  {$mode delphi}
{$endif}

interface

uses SysUtils, tfNumerics, tfHashes, tfCRCs;

type
  TDerivedKey = array[0..8] of Byte;
  THashedKey = array[0..31] of Byte;

  TSerialKey = record
    DerivedKey: TDerivedKey;
    CheckSum: Word;
    class function FromString(const S: string): TSerialKey; static;
    class function FromDerived(const D: TDerivedKey): TSerialKey; static;
    function Validate: Boolean;
    function ToString: string;
    function ToHash: THashedKey;
  end;

implementation

{ TSerialKey }

class function TSerialKey.FromDerived(const D: TDerivedKey): TSerialKey;
begin
  Result.DerivedKey:= D;
  Result.CheckSum:= TCRC.CRC16.Hash(D, SizeOf(D));
end;

// expects Serial as XXXX-XXXX-XXXX-XXXX-XXXX
class function TSerialKey.FromString(const S: string): TSerialKey;
var
  I: Integer;
  N: Cardinal;
  Output: BigInteger;
//  CheckSum: ByteArray;

begin
  if Length(S) <> 24 then
    raise Exception.Create(
      'Invalid Serial Number Length, Expected: 24, Found: '
       + IntToStr(Length(S)));

  Output:= 0;
  for I:= 1 to 24 do begin
    if I mod 5 <> 0 then begin
      if (S[I] < 'A') or (S[I] = 'O') or (S[I] > 'Z') then
        raise Exception.Create('Invalid Serial Number Format');
      N:= Ord(S[I]) - Ord('A');
      if S[I] > 'O' then Dec(N);
      Assert(N < 25);
      Output:= Output * 25 + N;
    end
    else if S[I] <> '-' then
      raise Exception.Create('Invalid Serial Number Format');
  end;
//    Writeln(Output.ToHexString);
  if Output >= BigInteger('$10000000000000000000000') then begin
      raise Exception.Create('Invalid Serial Number');
  end;

  Result.CheckSum:= Output mod (256 * 256);
  Output:= Output shr 16;

  for I:= 8 downto 0 do begin
    Result.DerivedKey[I]:= Output mod 256;
    Output:= Output shr 8;
  end;

  if not Result.Validate then
    raise Exception.Create('Checksum Error');
end;

// only DerivedKey field is hashed
function TSerialKey.ToHash: THashedKey;
begin
  THash.SHA256
       .UpdateData(DerivedKey, SizeOf(DerivedKey))
       .GetDigest(Result, SizeOf(Result));
end;

function TSerialKey.ToString: string;
var
  I, N: Integer;
  Tmp: BigInteger;

begin
  Tmp:= 0;
  Result:= '';
  SetLength(Result, 24);
  for I:= 0 to SizeOf(DerivedKey) - 1 do
    Tmp:= Tmp shl 8 + DerivedKey[I];
  Tmp:= Tmp shl 16 + CheckSum;
//    Writeln(Tmp.ToHexString);
  for I:= 24 downto 1 do begin
    if I mod 5 <> 0 then begin
      Tmp:= BigInteger.DivRem(Tmp, 25, N);
      Inc(N, Ord('A'));
      if N >= Ord('O') then Inc(N);
      Result[I]:= Char(N);
    end
    else
      Result[I]:= '-';
  end;
end;

function TSerialKey.Validate: Boolean;
begin
  Result:= CheckSum = TCRC.CRC16.Hash(DerivedKey, SizeOf(DerivedKey));
end;

end.
