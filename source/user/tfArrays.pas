{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2019
}

unit tfArrays;

{$I TFL.inc}

interface

uses SysUtils, tfTypes, tfConsts, tfExceptions, tfArrayInstances;

type
  ByteArray = record
  private
    FInstance: IInterface;
    function GetByte(Index: Integer): Byte;
    procedure SetByte(Index: Integer; const Value: Byte);
    function GetLen: Integer;
    procedure SetLen(Value: Integer);
  public
    function IsAssigned: Boolean;
    procedure Free;
    procedure Burn;
    function Clone: ByteArray;

    function GetEnumerator: IBytesEnumerator;
    function HashCode: Integer;

    function Raw: PByte;

    class function Alloc(ASize: Cardinal): ByteArray; overload; static;
    class function Alloc(ASize: Cardinal; Filler: Byte): ByteArray; overload; static;
    class procedure ReAlloc(var A: ByteArray; ASize: Cardinal); static;

    class function FromBytes(const A: array of Byte): ByteArray; static;
    class function FromText(const S: string): ByteArray; static;
    class function FromAnsiText(const S: RawByteString): ByteArray; static;
//    class function FromMem(P: Pointer; Count: Cardinal): ByteArray; static;
    class function FromData(const Data; DataLen: Cardinal; Reversed: Boolean): ByteArray; static;

    class function Parse(const S: string; Delimiter: Char = #0): ByteArray; static;
    class function TryParse(const S: string; var R: ByteArray): Boolean; overload; static;
    class function TryParse(const S: string; Delimiter: Char; var R: ByteArray): Boolean; overload; static;
    class function ParseHex(const S: string): ByteArray; overload; static;
    class function ParseHex(const S: string; Delimiter: Char): ByteArray; overload; static;
    class function TryParseHex(const S: string; var R: ByteArray): Boolean; overload; static;
    class function TryParseHex(const S: string; Delimiter: Char; var R: ByteArray): Boolean; overload; static;
//    class function ParseBitString(const S: string; ABitLen: Integer): ByteArray; static;


    function ToText: string;
    function ToString: string;
    function ToHex: string;
    procedure ToData(var Data; DataLen: Cardinal; Reversed: Boolean);

    class procedure Incr(const A: ByteArray); static;
    class procedure Decr(const A: ByteArray); static;

//    procedure IncrLE;
//    procedure DecrLE;

    class procedure Fill(const A: ByteArray; AValue: Byte); static;

    class function Copy(const A: ByteArray; I: Cardinal): ByteArray; overload; static;
    class function Copy(const A: ByteArray; I, L: Cardinal): ByteArray; overload; static;

    class function Insert(const A: ByteArray; I: Cardinal; B: Byte): ByteArray; overload; static;
    class function Insert(const A: ByteArray; I: Cardinal; const B: ByteArray): ByteArray; overload; static;
    class function Insert(const A: ByteArray; I: Cardinal; const B: TBytes): ByteArray; overload; static;

    class function Remove(const A: ByteArray; I: Cardinal): ByteArray; overload; static;
    class function Remove(const A: ByteArray; I, L: Cardinal): ByteArray; overload; static;

    class procedure Delete(const A: ByteArray; I, L: Cardinal); static;

    function Reverse: ByteArray; overload;

    class function TestBit(const A: ByteArray; BitNo: Cardinal): Boolean; static;
//    class procedure FlipBit(const A: ByteArray; BitNo: Cardinal); static;
//    class procedure SetBit(const A: ByteArray; BitNo: Cardinal); static;
//    class procedure ClearBit(const A: ByteArray; BitNo: Cardinal); static;
    function SeniorBit: Integer;

    class function Concat(const A, B: ByteArray): ByteArray; static;

    class function AddBytes(const A, B: ByteArray): ByteArray; static;
    class function SubBytes(const A, B: ByteArray): ByteArray; static;
{
    class function AndBytes(const A, B: ByteArray): ByteArray; static;
    class function OrBytes(const A, B: ByteArray): ByteArray; static;
    class function XorBytes(const A, B: ByteArray): ByteArray; static;
    class function NotBytes(const A: ByteArray): ByteArray; static;

    class function ShlBytes(const A: ByteArray; Shift: Cardinal): ByteArray; static;
    class function ShrBytes(const A: ByteArray; Shift: Cardinal): ByteArray; static;
}

    class operator Explicit(const Value: ByteArray): Byte;
//    class operator Explicit(const Value: ByteArray): Word;
//    class operator Explicit(const Value: ByteArray): LongWord;
//    class operator Explicit(const Value: ByteArray): UInt64;

    class operator Explicit(const Value: Byte): ByteArray;
//    class operator Explicit(const Value: Word): ByteArray;
//    class operator Explicit(const Value: LongWord): ByteArray;
//    class operator Explicit(const Value: UInt64): ByteArray;

    class operator Implicit(const Value: ByteArray): TBytes;
    class operator Implicit(const Value: TBytes): ByteArray;

    class operator Implicit(const Value: ByteArray): string;
    class operator Implicit(const Value: string): ByteArray;

    class operator Equal(const A, B: ByteArray): Boolean;
    class operator Equal(const A: ByteArray; const B: TBytes): Boolean;
    class operator Equal(const A: TBytes; const B: ByteArray): Boolean;
    class operator Equal(const A: ByteArray; const B: Byte): Boolean;
    class operator Equal(const A: Byte; const B: ByteArray): Boolean;

    class operator NotEqual(const A, B: ByteArray): Boolean;
    class operator NotEqual(const A: ByteArray; const B: TBytes): Boolean;
    class operator NotEqual(const A: TBytes; const B: ByteArray): Boolean;
    class operator NotEqual(const A: ByteArray; const B: Byte): Boolean;
    class operator NotEqual(const A: Byte; const B: ByteArray): Boolean;

    class operator Add(const A, B: ByteArray): ByteArray;
    class operator Add(const A: ByteArray; const B: TBytes): ByteArray;
    class operator Add(const A: ByteArray; const B: Byte): ByteArray;
    class operator Add(const A: TBytes; const B: ByteArray): ByteArray;
    class operator Add(const A: Byte; const B: ByteArray): ByteArray;

    class operator BitwiseAnd(const A, B: ByteArray): ByteArray;
    class operator BitwiseOr(const A, B: ByteArray): ByteArray;
    class operator BitwiseXor(const A, B: ByteArray): ByteArray;
    class operator LogicalNot(const A: ByteArray): ByteArray;

    class operator LeftShift(const A: ByteArray; Shift: Cardinal): ByteArray;
    class operator RightShift(const A: ByteArray; Shift: Cardinal): ByteArray;

    property Len: Integer read GetLen write SetLen;
    property Bytes[Index: Integer]: Byte read GetByte write SetByte; default;
  end;

implementation

procedure ByteArrayError(ACode: TF_RESULT; const Msg: string = '');
begin
  raise EByteArrayError.Create(ACode, Msg);
end;

procedure HResCheck(ACode: TF_RESULT); inline;
begin
  if ACode <> TF_S_OK then
    raise EByteArrayError.Create(ACode, '');
end;

{ ByteArray }
{.$POINTERMATH ON}

function ByteArray.GetByte(Index: Integer): Byte;
begin
  if Cardinal(Index) < Cardinal(GetLen) then
    Result:= Raw[Index]
  else
    raise EArgumentOutOfRangeException.CreateResFmt(@SIndexOutOfRange, [Index]);
end;

procedure ByteArray.SetByte(Index: Integer; const Value: Byte);
begin
  if Cardinal(Index) < Cardinal(GetLen) then
    Raw[Index]:= Value
  else
    raise EArgumentOutOfRangeException.CreateResFmt(@SIndexOutOfRange, [Index]);
end;

function ByteArray.IsAssigned: Boolean;
begin
  Result:= FInstance <> nil;
end;

procedure ByteArray.Free;
begin
  FInstance:= nil;
end;

function ByteArray.GetEnumerator: IBytesEnumerator;
begin
  HResCheck(TByteArrayInstance.GetEnum(PByteArrayInstance(FInstance),
                                       PByteArrayEnum(Result)));
end;

function ByteArray.HashCode: Integer;
begin
  Result:= TByteArrayInstance.GetHashCode(PByteArrayInstance(FInstance));
end;

function ByteArray.GetLen: Integer;
begin
  Result:= PPByteArrayInstance(@Self)^^.FUsed;
end;

procedure ByteArray.SetLen(Value: Integer);
begin
  HResCheck(TByteArrayInstance.SetLen(PByteArrayInstance(FInstance), Value));
end;

function ByteArray.Raw: PByte;
begin
  Result:= @PPByteArrayInstance(@Self)^^.FData;
end;

class function ByteArray.TestBit(const A: ByteArray; BitNo: Cardinal): Boolean;
begin
  Result:= TByteArrayInstance.TestBit(PByteArrayInstance(A.FInstance), BitNo);
end;

function ByteArray.SeniorBit: Integer;
begin
  Result:= TByteArrayInstance.GetSeniorBit(PByteArrayInstance(FInstance));
end;

class function ByteArray.Alloc(ASize: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.Alloc(PByteArrayInstance(Result.FInstance), ASize));
end;

class function ByteArray.Alloc(ASize: Cardinal; Filler: Byte): ByteArray;
begin
  HResCheck(TByteArrayInstance.AllocEx(PByteArrayInstance(Result.FInstance), ASize, Filler));
end;

class procedure ByteArray.ReAlloc(var A: ByteArray; ASize: Cardinal);
begin
  HResCheck(TByteArrayInstance.ReAlloc(PByteArrayInstance(A.FInstance), ASize));
end;

class function ByteArray.FromText(const S: string): ByteArray;
var
  S8: UTF8String;

begin
  S8:= UTF8String(S);
  HResCheck(TByteArrayInstance.FromPByte(PByteArrayInstance(Result.FInstance), Pointer(S8), Length(S8)));
// burn temporary string
  if Pointer(S8) <> Pointer(S) then begin
    FillChar(Pointer(S8)^, Length(S8), 32);
  end;
end;

class function ByteArray.FromAnsiText(const S: RawByteString): ByteArray;
begin
  HResCheck(TByteArrayInstance.FromPByte(PByteArrayInstance(Result.FInstance), Pointer(S), Length(S)));
end;

class function ByteArray.FromBytes(const A: array of Byte): ByteArray;
var
  I: Integer;
  P: PByte;

begin
  Result:= ByteArray.Alloc(Length(A));
  P:= Result.Raw;
  for I:= 0 to Length(A) - 1 do begin
    P^:= A[I];
    Inc(P);
  end;
end;

class function ByteArray.FromData(const Data; DataLen: Cardinal;
                 Reversed: Boolean): ByteArray;
begin
  HResCheck(TByteArrayInstance.FromPByteEx(PByteArrayInstance(Result.FInstance),
                                 @Data, DataLen, Reversed));
end;

(*
class function ByteArray.FromMem(P: Pointer; Count: Cardinal): ByteArray;
begin
{$IFDEF TFL_INTFCALL}
  HResCheck(ByteVectorFromPByte(Result.FBytes, P, Count));
{$ELSE}
  HResCheck(ByteVectorFromPByte(PByteVector(Result.FInstance), P, Count));
{$ENDIF}
end;
*)

class function ByteArray.Parse(const S: string; Delimiter: Char): ByteArray;
begin
  HResCheck(TByteArrayInstance.Parse(PByteArrayInstance(Result.FInstance),
            Pointer(S), Length(S), SizeOf(Char), Byte(Delimiter)));
end;

class function ByteArray.ParseHex(const S: string): ByteArray;
begin
  HResCheck(TByteArrayInstance.FromPCharHex(PByteArrayInstance(Result.FInstance),
                                   Pointer(S), Length(S), SizeOf(Char)));
end;

class function ByteArray.ParseHex(const S: string; Delimiter: Char): ByteArray;
begin
  HResCheck(TByteArrayInstance.ParseHex(PByteArrayInstance(Result.FInstance),
            Pointer(S), Length(S), SizeOf(Char), Byte(Delimiter)));
end;

class function ByteArray.TryParseHex(const S: string; var R: ByteArray): Boolean;
begin
  Result:= TByteArrayInstance.FromPCharHex(PByteArrayInstance(R.FInstance),
             Pointer(S), Length(S), SizeOf(Char)) = TF_S_OK;
end;

class function ByteArray.TryParse(const S: string; var R: ByteArray): Boolean;
begin
  Result:= TByteArrayInstance.Parse(PByteArrayInstance(R.FInstance),
             Pointer(S), Length(S), SizeOf(Char), 0) = TF_S_OK;
end;

class function ByteArray.TryParse(const S: string; Delimiter: Char;
  var R: ByteArray): Boolean;
begin
  Result:= TByteArrayInstance.Parse(PByteArrayInstance(R.FInstance), Pointer(S),
             Length(S), SizeOf(Char), Byte(Delimiter)) = TF_S_OK;
end;

class function ByteArray.TryParseHex(const S: string; Delimiter: Char;
  var R: ByteArray): Boolean;
begin
  Result:= TByteArrayInstance.ParseHex(PByteArrayInstance(R.FInstance), Pointer(S),
             Length(S), SizeOf(Char), Byte(Delimiter)) = TF_S_OK;
end;

(*
class function ByteArray.ParseBitString(const S: string; ABitLen: Integer): ByteArray;
var
  Ch: Char;
  I: Integer;
  Tmp: Cardinal;
  P: PByte;

begin
  if (ABitLen <= 0) or (ABitLen > 8) or (Length(S) mod ABitLen <> 0) then
    raise Exception.Create('Wrong string length');

{$IFDEF TFL_INTFCALL}
  HResCheck(ByteVectorAlloc(Result.FBytes, Length(S) div ABitLen));
{$ELSE}
  HResCheck(ByteVectorAlloc(PByteVector(Result.FInstance), Length(S) div ABitLen));
{$ENDIF}

//  SetLength(Result.FInstance, Length(S) div 7);
  P:= Result.FInstance.GetRawData;
  I:= 0;
  Tmp:= 0;
  for Ch in S do begin
    Tmp:= Tmp shl 1;
    if Ch = '1' then Tmp:= Tmp or 1
    else if Ch <> '0' then
      raise Exception.Create('Wrong string char');
    Inc(I);
    if I mod 7 = 0 then begin
//      Result.FInstance[I div 7 - 1]:= Tmp;
      P^:= Tmp;
      Inc(P);
      Tmp:= 0;
    end;
  end;
end;
*)

class operator ByteArray.Implicit(const Value: ByteArray): TBytes;
var
  L: Integer;

begin
  Result:= nil;
  L:= PPByteArrayInstance(@Value)^^.FUsed;
  if L > 0 then begin
    SetLength(Result, L);
    Move(PPByteArrayInstance(@Value)^^.FData, Pointer(Result)^, L);
  end;
end;

class operator ByteArray.Implicit(const Value: TBytes): ByteArray;
begin
  HResCheck(TByteArrayInstance.FromPByte(PByteArrayInstance(Result.FInstance),
              Pointer(Value), Length(Value)));
end;

class operator ByteArray.Implicit(const Value: ByteArray): string;
begin
  Result:= Value.ToHex;
end;

class operator ByteArray.Implicit(const Value: string): ByteArray;
begin
  Result:= ParseHex(Value);
end;


class function ByteArray.Insert(const A: ByteArray; I: Cardinal; B: Byte): ByteArray;
begin
  HResCheck(TByteArrayInstance.InsertByte(PByteArrayInstance(A.FInstance), I, B,
                                          PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.Insert(const A: ByteArray; I: Cardinal; const B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.InsertBytes(PByteArrayInstance(A.FInstance), I,
                                           PByteArrayInstance(B.FInstance),
                                           PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.Insert(const A: ByteArray; I: Cardinal; const B: TBytes): ByteArray;
begin
  HResCheck(TByteArrayInstance.InsertPByte(PByteArrayInstance(A.FInstance),
                                           I, Pointer(B), Length(B),
                                           PByteArrayInstance(Result.FInstance)));
end;

(*
function ByteArray.Insert(I: Cardinal; B: Byte): ByteArray;
begin
{$IFDEF TFL_INTFCALL}
  HResCheck(FBytes.InsertByte(I, B, Result.FBytes));
{$ELSE}
  HResCheck(TByteVector.InsertByte(PByteVector(FInstance), I, B, PByteVector(Result.FInstance)));
{$ENDIF}
end;

function ByteArray.Insert(I: Cardinal; const B: ByteArray): ByteArray;
begin
{$IFDEF TFL_INTFCALL}
  HResCheck(FBytes.InsertBytes(I, B.FBytes, Result.FBytes));
{$ELSE}
  HResCheck(TByteVector.InsertBytes(PByteVector(FInstance), I, PByteVector(B.FInstance),
                                    PByteVector(Result.FInstance)));
{$ENDIF}
end;

function ByteArray.Insert(I: Cardinal; const B: TBytes): ByteArray;
begin
{$IFDEF TFL_INTFCALL}
  HResCheck(FBytes.InsertPByte(I, Pointer(B), Length(B), Result.FBytes));
{$ELSE}
  HResCheck(TByteVector.InsertPByte(PByteVector(FInstance), I, Pointer(B), Length(B),
                        PByteVector(Result.FInstance)));
{$ENDIF}
end;
*)

procedure ByteArray.Burn;
begin
  TByteArrayInstance.Burn(PByteArrayInstance(FInstance));
end;

class procedure ByteArray.Fill(const A: ByteArray; AValue: Byte);
begin
  TByteArrayInstance.Fill(PByteArrayInstance(A.FInstance), AValue);
end;

class procedure ByteArray.Incr(const A: ByteArray);
begin
  HResCheck(TByteArrayInstance.Incr(PByteArrayInstance(A.FInstance)));
end;

class procedure ByteArray.Decr(const A: ByteArray);
begin
  HResCheck(TByteArrayInstance.Decr(PByteArrayInstance(A.FInstance)));
end;

(*
procedure ByteArray.IncrLE;
begin
{$IFDEF TFL_INTFCALL}
  HResCheck(FBytes.IncrLE);
{$ELSE}
  HResCheck(TByteVector.IncrLE(PByteVector(FInstance)));
{$ENDIF}
end;

procedure ByteArray.DecrLE;
begin
{$IFDEF TFL_INTFCALL}
  HResCheck(FBytes.DecrLE);
{$ELSE}
  HResCheck(TByteVector.DecrLE(PByteVector(FInstance)));
{$ENDIF}
end;

*)

class function ByteArray.Remove(const A: ByteArray; I: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.RemoveBytes1(PByteArrayInstance(A.FInstance),
                                 PByteArrayInstance(Result.FInstance), I));
end;

class function ByteArray.Remove(const A: ByteArray; I, L: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.RemoveBytes2(PByteArrayInstance(A.FInstance),
                                 PByteArrayInstance(Result.FInstance), I, L));
end;

class procedure ByteArray.Delete(const A: ByteArray; I, L: Cardinal);
begin
  HResCheck(TByteArrayInstance.DeleteBytes(PByteArrayInstance(A.FInstance), I, L));
end;

function ByteArray.Reverse: ByteArray;
begin
  HResCheck(TByteArrayInstance.ReverseBytes(PByteArrayInstance(FInstance),
                                 PByteArrayInstance(Result.FInstance)));
end;

{$WARNINGS OFF}
class operator ByteArray.Explicit(const Value: ByteArray): Byte;
var
  L: Integer;

begin
  L:= Value.GetLen;
  if L >= 1 then
    Result:= PByte(Value.Raw)[L-1]
  else
    ByteArrayError(TF_E_INVALIDARG);
end;
{$WARNINGS ON}

(*
class operator ByteArray.Explicit(const Value: ByteArray): Word;
var
  L: Integer;
  P: PByte;

begin
  L:= Value.GetLen;
  if L = 1 then begin
    Result:= 0;
    WordRec(Result).Lo:= PByte(Value.GetRawData)^;
  end
  else if L >= 2 then begin
    P:= Value.GetRawData;
    WordRec(Result).Lo:= P[L-1];
    WordRec(Result).Hi:= P[L-2];
  end
  else
    ByteArrayError(TF_E_INVALIDARG);
end;

class operator ByteArray.Explicit(const Value: ByteArray): LongWord;
var
  L: Integer;
  P, PR: PByte;

begin
  L:= Value.GetLen;
  if (L > 0) then begin
    Result:= 0;
    P:= Value.GetRawData;
    Inc(P, L);
    if (L > SizeOf(LongWord)) then L:= SizeOf(LongWord);
    PR:= @Result;
    repeat
      Dec(P);
      PR^:= P^;
      Inc(PR);
      Dec(L);
    until L = 0;
  end
  else
    ByteArrayError(TF_E_INVALIDARG);
end;

class operator ByteArray.Explicit(const Value: ByteArray): UInt64;
var
  L: Integer;
  P, PR: PByte;

begin
  L:= Value.GetLen;
  if (L > 0) then begin
    Result:= 0;
    P:= Value.GetRawData;
    Inc(P, L);
    if (L > SizeOf(UInt64)) then L:= SizeOf(UInt64);
    PR:= @Result;
    repeat
      Dec(P);
      PR^:= P^;
      Inc(PR);
      Dec(L);
    until L = 0;
  end
  else
    ByteArrayError(TF_E_INVALIDARG);
end;
*)

class operator ByteArray.Explicit(const Value: Byte): ByteArray;
begin
  HResCheck(TByteArrayInstance.FromByte(PByteArrayInstance(Result.FInstance), Value));
end;

(*
class operator ByteArray.Explicit(const Value: Word): ByteArray;
var
  P: PByte;

begin
  if Value >= 256 then begin
    Result:= ByteArray.Allocate(SizeOf(Word));
    P:= Result.RawData;
    P[0]:= WordRec(Value).Hi;
    P[1]:= WordRec(Value).Lo;
  end
  else begin
    Result:= ByteArray.Allocate(SizeOf(Byte));
    P:= Result.RawData;
    P[0]:= WordRec(Value).Lo;
  end;
end;

class operator ByteArray.Explicit(const Value: LongWord): ByteArray;
var
  P, P1: PByte;
  L: Integer;

begin
  L:= SizeOf(LongWord);
  P1:= @Value;
  Inc(P1, SizeOf(LongWord) - 1);
  while (P1^ = 0) do begin
    Dec(L);
    Dec(P1);
    if L = 1 then Break;
  end;
  Result:= ByteArray.Allocate(L);
  P:= Result.RawData;
  repeat
    P^:= P1^;
    Inc(P);
    Dec(P1);
    Dec(L);
  until L = 0;
end;

class operator ByteArray.Explicit(const Value: UInt64): ByteArray;
var
  P, P1: PByte;
  L: Integer;

begin
  L:= SizeOf(UInt64);
  P1:= @Value;
  Inc(P1, SizeOf(UInt64) - 1);
  while (P1^ = 0) do begin
    Dec(L);
    Dec(P1);
    if L = 1 then Break;
  end;
  Result:= ByteArray.Allocate(L);
  P:= Result.RawData;
  repeat
    P^:= P1^;
    Inc(P);
    Dec(P1);
    Dec(L);
  until L = 0;
end;
*)

procedure ByteArray.ToData(var Data; DataLen: Cardinal; Reversed: Boolean);
begin
  HResCheck(TByteArrayInstance.ToData(PByteArrayInstance(FInstance),
                                      @Data, DataLen, Reversed));
end;

function ByteArray.ToHex: string;
const
  ASCII_0 = Ord('0');
  ASCII_A = Ord('A');

var
  L: Integer;
  P: PByte;
  B: Byte;
  PS: PChar;

begin
  L:= GetLen;
  SetLength(Result, 2 * L);
  P:= Raw;
  PS:= PChar(Result);
  while L > 0 do begin
    B:= P^ shr 4;
    if B < 10 then
      PS^:= Char(B + ASCII_0)
    else
      PS^:= Char(B - 10 + ASCII_A);
    Inc(PS);
    B:= P^ and $0F;
    if B < 10 then
      PS^:= Char(B + ASCII_0)
    else
      PS^:= Char(B - 10 + ASCII_A);
    Inc(PS);
    Inc(P);
    Dec(L);
  end;
end;

function ByteArray.ToString: string;
var
  Tmp: PByteArrayInstance;
//  Tmp: IBytes;
  L, N: Integer;
  P: PByte;
  P1: PChar;

begin
  Result:= '';
  L:= GetLen;
  if L = 0 then Exit;
  Tmp:= nil;
  HResCheck(TByteArrayInstance.ToDec(PByteArrayInstance(FInstance),
                                     PByteArrayInstance(Tmp)));
  P:= TByteArrayInstance.GetRawData(Tmp);
  N:= TByteArrayInstance.GetLen(Tmp);
  SetLength(Result, N);
  P1:= PChar(Result);
  repeat
    if P^ <> 0 then begin
      P1^:= Char(P^);
    end
    else begin
      P1^:= Char($20); // space
    end;
    Inc(P);
    Inc(P1);
    Dec(N);
  until N = 0;
end;

function ByteArray.ToText: string;
var
  S8: UTF8String;
  L: Integer;

begin
  if FInstance = nil then Result:= ''
  else begin
    L:= TByteArrayInstance.GetLen(PByteArrayInstance(FInstance));
    SetLength(S8, L);
    Move(TByteArrayInstance.GetRawData(PByteArrayInstance(FInstance))^, Pointer(S8)^, L);
    Result:= string(S8);
    if Pointer(S8) <> Pointer(Result) then
      FillChar(Pointer(S8)^, Length(S8), 32);
  end;
end;

class operator ByteArray.Add(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.ConcatBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.Add(const A: ByteArray; const B: TBytes): ByteArray;
begin
  HResCheck(TByteArrayInstance.AppendPByte(PByteArrayInstance(A.FInstance),
            Pointer(B), Length(B), PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.Add(const A: TBytes; const B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.InsertPByte(PByteArrayInstance(B.FInstance), 0,
            Pointer(A), Length(A), PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.Add(const A: ByteArray; const B: Byte): ByteArray;
begin
  HResCheck(TByteArrayInstance.AppendByte(PByteArrayInstance(A.FInstance),
            B, PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.Add(const A: Byte; const B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.InsertByte(PByteArrayInstance(B.FInstance), 0,
            A, PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.AddBytes(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.AddBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.SubBytes(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.SubBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

{
class function ByteArray.AndBytes(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.AndBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.OrBytes(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.OrBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.XorBytes(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.XorBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.NotBytes(const A: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.NotBytes(PByteArrayInstance(A.FInstance),
                                        PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.ShlBytes(const A: ByteArray;
  Shift: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.ShiftLeft(PByteArrayInstance(A.FInstance), Shift,
                       PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.ShrBytes(const A: ByteArray;
  Shift: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.ShiftRight(PByteArrayInstance(A.FInstance), Shift,
                       PByteArrayInstance(Result.FInstance)));
end;
}

class operator ByteArray.BitwiseAnd(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.AndBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.BitwiseOr(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.OrBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.BitwiseXor(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.XorBytes(PByteArrayInstance(A.FInstance),
            PByteArrayInstance(B.FInstance), PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.LogicalNot(const A: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.NotBytes(PByteArrayInstance(A.FInstance),
                                        PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.LeftShift(const A: ByteArray;
  Shift: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.ShiftLeft(PByteArrayInstance(A.FInstance), Shift,
                       PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.RightShift(const A: ByteArray;
  Shift: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.ShiftRight(PByteArrayInstance(A.FInstance), Shift,
                       PByteArrayInstance(Result.FInstance)));
end;

class operator ByteArray.Equal(const A, B: ByteArray): Boolean;
begin
  Result:= TByteArrayInstance.EqualBytes(PByteArrayInstance(A.FInstance), PByteArrayInstance(B.FInstance));
end;

class operator ByteArray.Equal(const A: ByteArray; const B: TBytes): Boolean;
begin
  Result:= TByteArrayInstance.EqualToPByte(PByteArrayInstance(A.FInstance), Pointer(B), Length(B));
end;

class operator ByteArray.Equal(const A: TBytes; const B: ByteArray): Boolean;
begin
  Result:= TByteArrayInstance.EqualToPByte(PByteArrayInstance(B.FInstance), Pointer(A), Length(A));
end;

class operator ByteArray.Equal(const A: ByteArray; const B: Byte): Boolean;
begin
  Result:= TByteArrayInstance.EqualToByte(PByteArrayInstance(A.FInstance), B);
end;

class operator ByteArray.Equal(const A: Byte; const B: ByteArray): Boolean;
begin
  Result:= TByteArrayInstance.EqualToByte(PByteArrayInstance(B.FInstance), A);
end;

class operator ByteArray.NotEqual(const A, B: ByteArray): Boolean;
begin
  Result:= not TByteArrayInstance.EqualBytes(PByteArrayInstance(A.FInstance), PByteArrayInstance(B.FInstance));
end;

class operator ByteArray.NotEqual(const A: ByteArray; const B: TBytes): Boolean;
begin
  Result:= not TByteArrayInstance.EqualToPByte(PByteArrayInstance(A.FInstance), Pointer(B), Length(B));
end;

class operator ByteArray.NotEqual(const A: TBytes; const B: ByteArray): Boolean;
begin
  Result:= not TByteArrayInstance.EqualToPByte(PByteArrayInstance(B.FInstance), Pointer(A), Length(A));
end;

class operator ByteArray.NotEqual(const A: ByteArray; const B: Byte): Boolean;
begin
  Result:= not TByteArrayInstance.EqualToByte(PByteArrayInstance(A.FInstance), B);
end;

class operator ByteArray.NotEqual(const A: Byte; const B: ByteArray): Boolean;
begin
  Result:= not TByteArrayInstance.EqualToByte(PByteArrayInstance(B.FInstance), A);
end;

class function ByteArray.Concat(const A, B: ByteArray): ByteArray;
begin
  HResCheck(TByteArrayInstance.ConcatBytes(PByteArrayInstance(A.FInstance), PByteArrayInstance(B.FInstance),
                                    PByteArrayInstance(Result.FInstance)));
end;

function ByteArray.Clone: ByteArray;
begin
  HResCheck(TByteArrayInstance.CopyBytes(PByteArrayInstance(FInstance),
                                  PByteArrayInstance(Result.FInstance)));
end;

class function ByteArray.Copy(const A:ByteArray; I: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.CopyBytes1(PByteArrayInstance(A.FInstance),
                                   PByteArrayInstance(Result.FInstance), I));
end;

class function ByteArray.Copy(const A:ByteArray; I, L: Cardinal): ByteArray;
begin
  HResCheck(TByteArrayInstance.CopyBytes2(PByteArrayInstance(A.FInstance),
                                   PByteArrayInstance(Result.FInstance), I, L));
end;

end.
