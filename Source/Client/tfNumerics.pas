{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ * ------------------------------------------------------- * }
{ *   # client unit                                         * }
{ *   # exports: BigCardinal, BigInteger                    * }
{ *********************************************************** }

unit tfNumerics;

{$I TFL.inc}

{$IFDEF TFL_LIMB32}
  {$DEFINE LIMB32}
{$ENDIF}

interface

uses SysUtils, tfTypes,
    {$IFDEF TFL_DLL} tfImport {$ELSE} tfNumbers {$ENDIF};

type
  BigCardinal = record
  private
    FNumber: IBigNumber;
  public
    function AsString: string;
    function TryFromString(const S: string): Boolean;
    procedure Free;

    class function Compare(const A, B: BigCardinal): Integer; static;
    class function Pow(const Base: BigCardinal; Value: Cardinal): BigCardinal; static;

    class operator Explicit(const Value: BigCardinal): Cardinal;
    class operator Explicit(const Value: BigCardinal): Integer;
    class operator Implicit(const Value: Cardinal): BigCardinal;
    class operator Explicit(const Value: Integer): BigCardinal;
    class operator Explicit(const Value: string): BigCardinal;

    class operator Equal(const A, B: BigCardinal): Boolean;
    class operator NotEqual(const A, B: BigCardinal): Boolean;
    class operator GreaterThan(const A, B: BigCardinal): Boolean;
    class operator GreaterThanOrEqual(const A, B: BigCardinal): Boolean;
    class operator LessThan(const A, B: BigCardinal): Boolean;
    class operator LessThanOrEqual(const A, B: BigCardinal): Boolean;

    class operator Add(const A, B: BigCardinal): BigCardinal;
    class operator Subtract(const A, B: BigCardinal): BigCardinal;
    class operator Multiply(const A, B: BigCardinal): BigCardinal;
    class operator IntDivide(const A, B: BigCardinal): BigCardinal;
    class operator Modulus(const A, B: BigCardinal): BigCardinal;

{$IFDEF LIMB32}
    class operator Add(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator Add(const A: Cardinal; const B: BigCardinal): BigCardinal;
{$ENDIF}
  end;

  BigInteger = record
  private
    FNumber: IBigNumber;
    function GetSign: Integer;
  public
    function AsString: string;
    function TryFromString(const S: string): Boolean;
    procedure Free;

    property Sign: Integer read GetSign;

    class function Abs(const A: BigInteger): BigInteger; static;
    class function Compare(const A, B: BigInteger): Integer; static;
    class function Pow(const Base: BigInteger; Value: Cardinal): BigInteger; static;

    class operator Implicit(const Value: BigCardinal): BigInteger; inline;
    class operator Explicit(const Value: BigInteger): BigCardinal; inline;

    class operator Explicit(const Value: BigInteger): Cardinal;
    class operator Explicit(const Value: BigInteger): Integer;
    class operator Implicit(const Value: Cardinal): BigInteger;
    class operator Implicit(const Value: Integer): BigInteger;
    class operator Explicit(const Value: string): BigInteger;

    class operator Equal(const A, B: BigInteger): Boolean;
    class operator NotEqual(const A, B: BigInteger): Boolean;
    class operator GreaterThan(const A, B: BigInteger): Boolean;
    class operator GreaterThanOrEqual(const A, B: BigInteger): Boolean;
    class operator LessThan(const A, B: BigInteger): Boolean;
    class operator LessThanOrEqual(const A, B: BigInteger): Boolean;

    class operator Add(const A, B: BigInteger): BigInteger;
    class operator Subtract(const A, B: BigInteger): BigInteger;
    class operator Multiply(const A, B: BigInteger): BigInteger;
    class operator IntDivide(const A, B: BigInteger): BigInteger;
    class operator Modulus(const A, B: BigInteger): BigInteger;

{$IFDEF LIMB32}
    class operator Add(const A: BigInteger; const B: Cardinal): BigInteger;
    class operator Add(const A: Cardinal; const B: BigInteger): BigInteger;
    class operator Add(const A: BigInteger; const B: Integer): BigInteger;
    class operator Add(const A: Integer; const B: BigInteger): BigInteger;
{$ENDIF}
  end;

type
  EBigNumberError = class(Exception)
  private
    FCode: HResult;
  public
    constructor Create(ACode: HResult; const Msg: string);
    property Code: HResult read FCode;
  end;

procedure BigNumberError(ACode: HResult; const Msg: string);

implementation

{ EBigNumberError }

constructor EBigNumberError.Create(ACode: HResult; const Msg: string);
begin
  inherited Create(Msg);
  FCode:= ACode;
end;

procedure BigNumberError(ACode: HResult; const Msg: string);
begin
  raise EBigNumberError.Create(ACode, Msg);
end;

procedure HResCheck(Value: HResult; const ErrMsg: string); inline;
begin
  if Value <> S_OK then
    BigNumberError(Value, ErrMsg);
end;

{ BigCardinal }

function BigCardinal.AsString: string;
{$IFDEF TFL_DLL}
var
  S: WideString;

begin
  HResCheck(FNumber.ToWideString(S),
    'BigCardinal -> string conversion error');
  Result:= S;
{$ELSE}
begin
  HResCheck(TBigNumber.ToString(PBigNumber(FNumber), Result),
    'BigCardinal -> string conversion error');
{$ENDIF}
end;

class function BigCardinal.Compare(const A, B: BigCardinal): Integer;
begin
{$IFDEF TFL_DLL}
  Result:= A.FNumber.CompareNumberU(B.FNumber);
{$ELSE}
  Result:= TBigNumber.CompareNumbersU(PBigNumber(A.FNumber),
                      PBigNumber(B.FNumber));
{$ENDIF}
end;

function BigCardinal.TryFromString(const S: string): Boolean;
{$IFDEF TFL_DLL}
var
  WS: WideString;

begin
  WS:= WideString(S);
  Result:= WideStringToBigNumberU(FNumber, WS) = TFL_S_OK;
{$ELSE}
begin
  Result:= TBigNumber.FromStringU(PBigNumber(FNumber), S) = TFL_S_OK;
{$ENDIF}
end;

class function BigCardinal.Pow(const Base: BigCardinal; Value: Cardinal): BigCardinal;
begin
{$IFDEF TFL_DLL}
  HResCheck(Base.FNumber.PowU(Value, Result.FNumber), 'BigCardinal.Power');
{$ELSE}
  HResCheck(TBigNumber.PowU(PBigNumber(Base.FNumber), Value,
                       PBigNumber(Result.FNumber)), 'BigCardinal.Power');
{$ENDIF}
end;

class operator BigCardinal.Equal(const A, B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) = 0;
end;

class operator BigCardinal.NotEqual(const A, B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) <> 0;
end;

class operator BigCardinal.GreaterThan(const A, B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) > 0;
end;

class operator BigCardinal.GreaterThanOrEqual(const A, B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) >= 0;
end;

class operator BigCardinal.LessThan(const A, B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) < 0;
end;

class operator BigCardinal.LessThanOrEqual(const A, B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) <= 0;
end;

class operator BigCardinal.Explicit(const Value: string): BigCardinal;
{$IFDEF TFL_DLL}
var
  WS: WideString;

begin
  WS:= WideString(S);
  HResCheck(WideStringToBigNumberU(FNumber, WS),
{$ELSE}
begin
  HResCheck(TBigNumber.FromStringU(PBigNumber(Result.FNumber), Value),
{$ENDIF}
    'string -> BigCardinal conversion error');
end;

procedure BigCardinal.Free;
begin
  FNumber:= nil;
end;

class operator BigCardinal.Explicit(const Value: BigCardinal): Cardinal;
begin
{$IFDEF TFL_DLL}
  HResCheck(FNumber.ToCardinal(Result),
{$ELSE}
  HResCheck(TBigNumber.ToCardinal(PBigNumber(Value.FNumber), Result),
{$ENDIF}
    'BigCardinal -> Cardinal conversion error');
end;

class operator BigCardinal.Explicit(const Value: BigCardinal): Integer;
begin
{$IFDEF TFL_DLL}
  HResCheck(FNumber.ToInteger(Result),
{$ELSE}
  HResCheck(TBigNumber.ToInteger(PBigNumber(Value.FNumber), Result),
{$ENDIF}
    'BigCardinal -> Integer conversion error');
end;

class operator BigCardinal.Explicit(const Value: Integer): BigCardinal;
begin
  if Value < 0 then
    BigNumberError(TFL_E_INVALIDARG,
      'Integer -> BigCardinal conversion error')
  else begin
{$IFDEF TFL_DLL}
    HResCheck(CardinalToBigNumber(Result.FNumber, Cardinal(Value)),
{$ELSE}
    HResCheck(TBigNumber.FromCardinal(PBigNumber(Result.FNumber), Cardinal(Value)),
{$ENDIF}
            'TBigNumber.FromCardinal');
  end;
end;

class operator BigCardinal.Implicit(const Value: Cardinal): BigCardinal;
begin
{$IFDEF TFL_DLL}
  HResCheck(CardinalToBigNumber(Result.FNumber, Value),
{$ELSE}
  HResCheck(TBigNumber.FromCardinal(PBigNumber(Result.FNumber), Value),
{$ENDIF}
            'TBigNumber.FromCardinal');
end;

class operator BigCardinal.Add(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.AddNumberU(B.FNumber, Result.FNumber), 'BigCardinal.Add');
end;

class operator BigCardinal.Subtract(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.SubNumberU(B.FNumber, Result.FNumber), 'BigCardinal.Subtract');
end;

class operator BigCardinal.Multiply(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.MulNumberU(B.FNumber, Result.FNumber), 'BigCardinal.Multiply');
end;

class operator BigCardinal.IntDivide(const A, B: BigCardinal): BigCardinal;
var
  Remainder: IBigNumber;

begin
  HResCheck(A.FNumber.DivModNumberU(B.FNumber, Result.FNumber, Remainder),
            'BigCardinal.IntDivide');
end;

class operator BigCardinal.Modulus(const A, B: BigCardinal): BigCardinal;
var
  Quotient: IBigNumber;

begin
  HResCheck(A.FNumber.DivModNumberU(B.FNumber, Quotient, Result.FNumber),
            'BigCardinal.Modulus');
end;

{$IFDEF LIMB32}

class operator BigCardinal.Add(const A: BigCardinal; const B: Cardinal): BigCardinal;
begin
  HResCheck(A.FNumber.AddLimbU(B, Result.FNumber), 'BigCardinal.AddLimb');
end;

class operator BigCardinal.Add(const A: Cardinal; const B: BigCardinal): BigCardinal;
begin
  HResCheck(B.FNumber.AddLimbU(A, Result.FNumber), 'BigCardinal.AddLimb');
end;

{$ENDIF}

{ BigInteger }

function BigInteger.AsString: string;
{$IFDEF TFL_DLL}
var
  S: WideString;

begin
  HResCheck(FNumber.ToWideString(S),
    'BigInteger -> string conversion error');
  Result:= S;
{$ELSE}
begin
  HResCheck(TBigNumber.ToString(PBigNumber(FNumber), Result),
    'BigInteger -> string conversion error');
{$ENDIF}
end;

class function BigInteger.Compare(const A, B: BigInteger): Integer;
begin
{$IFDEF TFL_DLL}
  Result:= A.FNumber.CompareNumber(B.FNumber);
{$ELSE}
  Result:= TBigNumber.CompareNumbers(PBigNumber(A.FNumber),
                      PBigNumber(B.FNumber));
{$ENDIF}
end;

function BigInteger.GetSign: Integer;
begin
{$IFDEF TFL_DLL}
  Result:= A.FNumber.GetSign;
{$ELSE}
  Result:= TBigNumber.GetSign(PBigNumber(FNumber));
{$ENDIF}
end;

class operator BigInteger.Explicit(const Value: BigInteger): Cardinal;
begin
{$IFDEF TFL_DLL}
  HResCheck(FNumber.ToCardinal(Result),
{$ELSE}
  HResCheck(TBigNumber.ToCardinal(PBigNumber(Value.FNumber), Result),
{$ENDIF}
    'BigInteger -> Cardinal conversion error');
end;

class operator BigInteger.Explicit(const Value: BigInteger): Integer;
begin
{$IFDEF TFL_DLL}
  HResCheck(FNumber.ToInteger(Result),
{$ELSE}
  HResCheck(TBigNumber.ToInteger(PBigNumber(Value.FNumber), Result),
{$ENDIF}
    'BigInteger -> Integer conversion error');
end;

class operator BigInteger.Implicit(const Value: BigCardinal): BigInteger;
begin
  Result.FNumber:= Value.FNumber;
end;

class operator BigInteger.Explicit(const Value: BigInteger): BigCardinal;
begin
{$IFDEF TFL_DLL}
  if (Value.FNumber.GetSign < 0) then
{$ELSE}
  if (PBigNumber(Value.FNumber).FSign < 0) then
{$ENDIF}
    BigNumberError(TFL_E_INVALIDARG, 'Negative value');
  Result.FNumber:= Value.FNumber;
end;

class operator BigInteger.Explicit(const Value: string): BigInteger;
{$IFDEF TFL_DLL}
var
  WS: WideString;

begin
  WS:= WideString(S);
  HResCheck(WideStringToBigNumber(FNumber, WS),
{$ELSE}
begin
  HResCheck(TBigNumber.FromString(PBigNumber(Result.FNumber), Value),
{$ENDIF}
    'string -> BigInteger conversion error');
end;

class function BigInteger.Pow(const Base: BigInteger; Value: Cardinal): BigInteger;
begin
{$IFDEF TFL_DLL}
  HResCheck(Base.FNumber.Pow(Value, Result.FNumber),
{$ELSE}
  HResCheck(TBigNumber.Pow(PBigNumber(Base.FNumber), Value,
                       PBigNumber(Result.FNumber)),
{$ENDIF}
                       'BigInteger.Power');
end;

class operator BigInteger.Equal(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) = 0;
end;

class operator BigInteger.NotEqual(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) <> 0;
end;

class operator BigInteger.GreaterThan(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) > 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) >= 0;
end;

class operator BigInteger.LessThan(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) < 0;
end;

class operator BigInteger.LessThanOrEqual(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) <= 0;
end;

procedure BigInteger.Free;
begin
  FNumber:= nil;
end;

function BigInteger.TryFromString(const S: string): Boolean;
{$IFDEF TFL_DLL}
var
  WS: WideString;

begin
  WS:= WideString(S);
  Result:= WideStringToBigNumber(FNumber, WS) = TFL_S_OK;
{$ELSE}
begin
  Result:= TBigNumber.FromString(PBigNumber(FNumber), S) = TFL_S_OK;
{$ENDIF}
end;

class operator BigInteger.Implicit(const Value: Cardinal): BigInteger;
begin
{$IFDEF TFL_DLL}
  HResCheck(CardinalToBigNumber(Result.FNumber, Value),
{$ELSE}
  HResCheck(TBigNumber.FromCardinal(PBigNumber(Result.FNumber), Value),
            'TBigNumber.FromCardinal');
{$ENDIF}
end;

class operator BigInteger.Implicit(const Value: Integer): BigInteger;
begin
{$IFDEF TFL_DLL}
  HResCheck(IntegerToBigNumber(Result.FNumber, Value),
{$ELSE}
  HResCheck(TBigNumber.FromInteger(PBigNumber(Result.FNumber), Value),
{$ENDIF}
            'TBigNumber.FromInteger');
end;

class function BigInteger.Abs(const A: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.AbsNumber(Result.FNumber), 'BigInteger.Abs');
end;

class operator BigInteger.Add(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.AddNumber(B.FNumber, Result.FNumber), 'BigInteger.Add');
end;

class operator BigInteger.Subtract(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.SubNumber(B.FNumber, Result.FNumber), 'BigCardinal.Subtract');
end;

class operator BigInteger.Multiply(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.MulNumber(B.FNumber, Result.FNumber), 'BigCardinal.Multiply');
end;

class operator BigInteger.IntDivide(const A, B: BigInteger): BigInteger;
var
  Remainder: IBigNumber;

begin
  HResCheck(A.FNumber.DivModNumber(B.FNumber, Result.FNumber, Remainder),
            'BigCardinal.IntDivide');
end;

class operator BigInteger.Modulus(const A, B: BigInteger): BigInteger;
var
  Quotient: IBigNumber;

begin
  HResCheck(A.FNumber.DivModNumber(B.FNumber, Quotient, Result.FNumber),
            'BigCardinal.Modulus');
end;

{$IFDEF LIMB32}

class operator BigInteger.Add(const A: BigInteger; const B: Cardinal): BigInteger;
begin
  HResCheck(A.FNumber.AddLimb(B, Result.FNumber), 'BigCardinal.AddLimb');
end;

class operator BigInteger.Add(const A: Cardinal; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.AddLimb(A, Result.FNumber), 'BigInteger.AddLimb');
end;

class operator BigInteger.Add(const A: BigInteger; const B: Integer): BigInteger;
begin
  HResCheck(A.FNumber.AddIntLimb(B, Result.FNumber), 'BigInteger.AddIntLimb');
end;

class operator BigInteger.Add(const A: Integer; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.AddIntLimb(A, Result.FNumber), 'BigInteger.AddIntLimb');
end;

{$ENDIF}

{$IFDEF TFL_DLL}
initialization
  LoadForge;
{$ENDIF}
end.
