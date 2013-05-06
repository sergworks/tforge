{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ * ------------------------------------------------------- * }
{ *   # Numerics dll import for Pascal                      * }
{ *   # Free Pascal & Delphi compilers supported            * }
{ * ------------------------------------------------------- * }
{ *********************************************************** }

unit Numerics;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}

interface

uses Windows, SysUtils;

const
                                            // = common microsoft codes =
  TFL_S_OK          = HRESULT(0);           // Operation successful
  TFL_S_FALSE       = HRESULT(1);           // Operation successful
  TFL_E_FAIL        = HRESULT($80004005);   // Unspecified failure
  TFL_E_INVALIDARG  = HRESULT($80070057);   // One or more arguments are not valid
  TFL_E_NOINTERFACE = HRESULT($80004002);   // No such interface supported
  TFL_E_NOTIMPL     = HRESULT($80004001);   // Not implemented
  TFL_E_OUTOFMEMORY = HRESULT($8007000E);   // Failed to allocate necessary memory
  TFL_E_UNEXPECTED  = HRESULT($8000FFFF);   // Unexpected failure
                                            // = TFL specific codes =
  TFL_E_ZERODIVIDE  = HRESULT($A0000001);   // Division by zero
  TFL_E_INVALIDSUB  = HRESULT($A0000002);   // Unsigned subtract greater from lesser
  TFL_E_NOMEMORY    = HRESULT($A0000003);   // specific TFL memory error
  TFL_E_LOADERROR   = HRESULT($A0000004);   // Error loading tforge dll

{$IFDEF FPC}
type
  TBytes = array of Byte;
{$ENDIF}

type
  IBigNumber = interface

    function GetIsEven: Boolean; stdcall;
    function GetIsOne: Boolean; stdcall;
    function GetIsPowerOfTwo: Boolean; stdcall;
    function GetIsZero: Boolean; stdcall;
    function GetSign: Integer; stdcall;

    function CompareNumber(Num: IBigNumber): Integer; stdcall;
    function CompareNumberU(Num: IBigNumber): Integer; stdcall;

    function AddNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function AddNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function SubNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function SubNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function MulNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function MulNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function DivRemNumber(Num: IBigNumber; var Q, R: IBigNumber): HRESULT; stdcall;
    function DivRemNumberU(Num: IBigNumber; var Q, R: IBigNumber): HRESULT; stdcall;

    function AndNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function AndNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function OrNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function OrNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function XorNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;

    function ShlNumber(Shift: Cardinal; var Res: IBigNumber): HRESULT; stdcall;
    function ShrNumber(Shift: Cardinal; var Res: IBigNumber): HRESULT; stdcall;

    function AbsNumber(var Res: IBigNumber): HRESULT; stdcall;
    function Pow(Value: Cardinal; var IRes: IBigNumber): HRESULT; stdcall;
    function PowU(Value: Cardinal; var IRes: IBigNumber): HRESULT; stdcall;
    function PowerMod(IExp, IMod: IBigNumber; var IRes: IBigNumber): HRESULT; stdcall;

    function ToCardinal(var Value: Cardinal): HRESULT; stdcall;
    function ToInteger(var Value: Integer): HRESULT; stdcall;
    function ToWideString(var S: WideString): HRESULT; stdcall;
    function ToWideHexString(var S: WideString; Digits: Cardinal; TwoCompl: Boolean): HRESULT; stdcall;
    function ToPByte(P: PByte; var L: Cardinal): HRESULT; stdcall;

    function CompareToLimb(Limb: LongWord): Integer; stdcall;
    function CompareToLimbU(Limb: LongWord): Integer; stdcall;
    function CompareToIntLimb(Limb: LongInt): Integer; stdcall;
    function CompareToIntLimbU(Limb: LongInt): Integer; stdcall;

    function AddLimb(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function AddLimbU(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function AddIntLimb(Limb: LongInt; var Res: IBigNumber): HRESULT; stdcall;

    function SubLimb(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function SubLimbU(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
//    function SubLimbU2(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function SubLimbU2(Limb: LongWord; var Res: LongWord): HRESULT; stdcall;
    function SubIntLimb(Limb: LongInt; var Res: IBigNumber): HRESULT; stdcall;

    function MulLimb(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function MulLimbU(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function MulIntLimb(Limb: LongInt; var Res: IBigNumber): HRESULT; stdcall;

    function DivRemLimbU(Limb: LongWord; var Q: IBigNumber; var R: LongWord): HRESULT; stdcall;
    function DivRemIntLimb(Limb: LongInt; var Q: IBigNumber; var R: LongInt): HRESULT; stdcall;
  end;

type
  BigCardinal = record
  private
    FNumber: IBigNumber;
  public
    function ToString: string;
    function ToHexString(Digits: Cardinal; TwoCompl: Boolean): string;
    function ToBytes: TBytes;
    function TryParse(const S: string): Boolean;
    procedure Free;

    class function Compare(const A, B: BigCardinal): Integer; static;
    function CompareTo(const B: BigCardinal): Integer; overload;

    class function Pow(const Base: BigCardinal; Value: Cardinal): BigCardinal; static;
    class function DivRem(const Dividend, Divisor: BigCardinal;
                          var Remainder: BigCardinal): BigCardinal; static;

    class operator Explicit(const Value: BigCardinal): Cardinal;
    class operator Explicit(const Value: BigCardinal): Integer;
    class operator Implicit(const Value: Cardinal): BigCardinal;
    class operator Explicit(const Value: Integer): BigCardinal;
    class operator Explicit(const Value: TBytes): BigCardinal;
    class operator Explicit(const Value: string): BigCardinal;

    class operator Equal(const A, B: BigCardinal): Boolean; inline;
    class operator NotEqual(const A, B: BigCardinal): Boolean; inline;
    class operator GreaterThan(const A, B: BigCardinal): Boolean; inline;
    class operator GreaterThanOrEqual(const A, B: BigCardinal): Boolean; inline;
    class operator LessThan(const A, B: BigCardinal): Boolean; inline;
    class operator LessThanOrEqual(const A, B: BigCardinal): Boolean; inline;

    class operator Add(const A, B: BigCardinal): BigCardinal;
    class operator Subtract(const A, B: BigCardinal): BigCardinal;
    class operator Multiply(const A, B: BigCardinal): BigCardinal;
    class operator IntDivide(const A, B: BigCardinal): BigCardinal;
    class operator Modulus(const A, B: BigCardinal): BigCardinal;

    class operator LeftShift(const A: BigCardinal; Shift: Cardinal): BigCardinal;
    class operator RightShift(const A: BigCardinal; Shift: Cardinal): BigCardinal;

    class operator BitwiseAnd(const A, B: BigCardinal): BigCardinal;
    class operator BitwiseOr(const A, B: BigCardinal): BigCardinal;

    function CompareToCard(const B: Cardinal): Integer;
    function CompareToInt(const B: Integer): Integer;
    function CompareTo(const B: Cardinal): Integer; overload; inline;
    function CompareTo(const B: Integer): Integer; overload; inline;
    class operator Equal(const A: BigCardinal; const B: Cardinal): Boolean; inline;
    class operator Equal(const A: Cardinal; const B: BigCardinal): Boolean; inline;
    class operator Equal(const A: BigCardinal; const B: Integer): Boolean; inline;
    class operator Equal(const A: Integer; const B: BigCardinal): Boolean; inline;
    class operator NotEqual(const A: BigCardinal; const B: Cardinal): Boolean; inline;
    class operator NotEqual(const A: Cardinal; const B: BigCardinal): Boolean; inline;
    class operator NotEqual(const A: BigCardinal; const B: Integer): Boolean; inline;
    class operator NotEqual(const A: Integer; const B: BigCardinal): Boolean; inline;
    class operator GreaterThan(const A: BigCardinal; const B: Cardinal): Boolean; inline;
    class operator GreaterThan(const A: Cardinal; const B: BigCardinal): Boolean; inline;
    class operator GreaterThan(const A: BigCardinal; const B: Integer): Boolean; inline;
    class operator GreaterThan(const A: Integer; const B: BigCardinal): Boolean; inline;
    class operator GreaterThanOrEqual(const A: BigCardinal; const B: Cardinal): Boolean; inline;
    class operator GreaterThanOrEqual(const A: Cardinal; const B: BigCardinal): Boolean; inline;
    class operator GreaterThanOrEqual(const A: BigCardinal; const B: Integer): Boolean; inline;
    class operator GreaterThanOrEqual(const A: Integer; const B: BigCardinal): Boolean; inline;
    class operator LessThan(const A: BigCardinal; const B: Cardinal): Boolean; inline;
    class operator LessThan(const A: Cardinal; const B: BigCardinal): Boolean; inline;
    class operator LessThan(const A: BigCardinal; const B: Integer): Boolean; inline;
    class operator LessThan(const A: Integer; const B: BigCardinal): Boolean; inline;
    class operator LessThanOrEqual(const A: BigCardinal; const B: Cardinal): Boolean; inline;
    class operator LessThanOrEqual(const A: Cardinal; const B: BigCardinal): Boolean; inline;
    class operator LessThanOrEqual(const A: BigCardinal; const B: Integer): Boolean; inline;
    class operator LessThanOrEqual(const A: Integer; const B: BigCardinal): Boolean; inline;

    class operator Add(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator Add(const A: Cardinal; const B: BigCardinal): BigCardinal;
    class operator Subtract(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator Subtract(const A: Cardinal; const B: BigCardinal): Cardinal;
    class operator Multiply(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator Multiply(const A: Cardinal; const B: BigCardinal): BigCardinal;
  end;

  BigInteger = record
  private
    FNumber: IBigNumber;
    function GetSign: Integer;
  public
    function ToString: string;
    function ToHexString(Digits: Cardinal; TwoCompl: Boolean): string;
    function ToBytes: TBytes;
    function TryParse(const S: string): Boolean;
    procedure Free;

    property Sign: Integer read GetSign;

    class function Compare(const A, B: BigInteger): Integer; overload; static;
    class function Compare(const A: BigInteger; const B: BigCardinal): Integer; overload; static;
    class function Compare(const A: BigCardinal; const B: BigInteger): Integer; overload; static;
    function CompareTo(const B: BigInteger): Integer; overload; inline;
    function CompareTo(const B: BigCardinal): Integer; overload; inline;

    class function Abs(const A: BigInteger): BigInteger; static;
    class function Pow(const Base: BigInteger; Value: Cardinal): BigInteger; static;
    class function DivRem(const Dividend, Divisor: BigCardinal;
                          var Remainder: BigCardinal): BigCardinal; static;

    class operator Implicit(const Value: BigCardinal): BigInteger; inline;
    class operator Explicit(const Value: BigInteger): BigCardinal; inline;

    class operator Explicit(const Value: BigInteger): Cardinal;
    class operator Explicit(const Value: BigInteger): Integer;
    class operator Implicit(const Value: Cardinal): BigInteger;
    class operator Implicit(const Value: Integer): BigInteger;
    class operator Explicit(const Value: TBytes): BigInteger;
    class operator Explicit(const Value: string): BigInteger;

    class operator Equal(const A, B: BigInteger): Boolean; inline;
    class operator Equal(const A: BigInteger; const B: BigCardinal): Boolean; inline;
    class operator Equal(const A: BigCardinal; const B: BigInteger): Boolean; inline;
    class operator NotEqual(const A, B: BigInteger): Boolean; inline;
    class operator NotEqual(const A: BigInteger; const B: BigCardinal): Boolean; inline;
    class operator NotEqual(const A: BigCardinal; const B: BigInteger): Boolean; inline;
    class operator GreaterThan(const A, B: BigInteger): Boolean; inline;
    class operator GreaterThan(const A: BigInteger; const B: BigCardinal): Boolean; inline;
    class operator GreaterThan(const A: BigCardinal; const B: BigInteger): Boolean; inline;
    class operator GreaterThanOrEqual(const A, B: BigInteger): Boolean; inline;
    class operator GreaterThanOrEqual(const A: BigInteger; const B: BigCardinal): Boolean; inline;
    class operator GreaterThanOrEqual(const A: BigCardinal; const B: BigInteger): Boolean; inline;
    class operator LessThan(const A, B: BigInteger): Boolean; inline;
    class operator LessThan(const A: BigInteger; const B: BigCardinal): Boolean; inline;
    class operator LessThan(const A: BigCardinal; const B: BigInteger): Boolean; inline;
    class operator LessThanOrEqual(const A, B: BigInteger): Boolean; inline;
    class operator LessThanOrEqual(const A: BigInteger; const B: BigCardinal): Boolean; inline;
    class operator LessThanOrEqual(const A: BigCardinal; const B: BigInteger): Boolean; inline;

    class operator Add(const A, B: BigInteger): BigInteger;
    class operator Subtract(const A, B: BigInteger): BigInteger;
    class operator Multiply(const A, B: BigInteger): BigInteger;
    class operator IntDivide(const A, B: BigInteger): BigInteger;
    class operator Modulus(const A, B: BigInteger): BigInteger;

    class operator LeftShift(const A: BigInteger; Shift: Cardinal): BigInteger;
    class operator RightShift(const A: BigInteger; Shift: Cardinal): BigInteger;

    class operator BitwiseAnd(const A, B: BigInteger): BigInteger;
    class operator BitwiseOr(const A, B: BigInteger): BigInteger;
    class operator BitwiseXor(const A, B: BigInteger): BigInteger;

    function CompareToCard(const B: Cardinal): Integer;
    function CompareToInt(const B: Integer): Integer;
    function CompareTo(const B: Cardinal): Integer; overload; inline;
    function CompareTo(const B: Integer): Integer; overload; inline;
    class operator Equal(const A: BigInteger; const B: Cardinal): Boolean; inline;
    class operator Equal(const A: Cardinal; const B: BigInteger): Boolean; inline;
    class operator Equal(const A: BigInteger; const B: Integer): Boolean; inline;
    class operator Equal(const A: Integer; const B: BigInteger): Boolean; inline;
    class operator NotEqual(const A: BigInteger; const B: Cardinal): Boolean; inline;
    class operator NotEqual(const A: Cardinal; const B: BigInteger): Boolean; inline;
    class operator NotEqual(const A: BigInteger; const B: Integer): Boolean; inline;
    class operator NotEqual(const A: Integer; const B: BigInteger): Boolean; inline;
    class operator GreaterThan(const A: BigInteger; const B: Cardinal): Boolean; inline;
    class operator GreaterThan(const A: Cardinal; const B: BigInteger): Boolean; inline;
    class operator GreaterThan(const A: BigInteger; const B: Integer): Boolean; inline;
    class operator GreaterThan(const A: Integer; const B: BigInteger): Boolean; inline;
    class operator GreaterThanOrEqual(const A: BigInteger; const B: Cardinal): Boolean; inline;
    class operator GreaterThanOrEqual(const A: Cardinal; const B: BigInteger): Boolean; inline;
    class operator GreaterThanOrEqual(const A: BigInteger; const B: Integer): Boolean; inline;
    class operator GreaterThanOrEqual(const A: Integer; const B: BigInteger): Boolean; inline;
    class operator LessThan(const A: BigInteger; const B: Cardinal): Boolean; inline;
    class operator LessThan(const A: Cardinal; const B: BigInteger): Boolean; inline;
    class operator LessThan(const A: BigInteger; const B: Integer): Boolean; inline;
    class operator LessThan(const A: Integer; const B: BigInteger): Boolean; inline;
    class operator LessThanOrEqual(const A: BigInteger; const B: Cardinal): Boolean; inline;
    class operator LessThanOrEqual(const A: Cardinal; const B: BigInteger): Boolean; inline;
    class operator LessThanOrEqual(const A: BigInteger; const B: Integer): Boolean; inline;
    class operator LessThanOrEqual(const A: Integer; const B: BigInteger): Boolean; inline;

    class operator Add(const A: BigInteger; const B: Cardinal): BigInteger;
    class operator Add(const A: Cardinal; const B: BigInteger): BigInteger;
    class operator Add(const A: BigInteger; const B: Integer): BigInteger;
    class operator Add(const A: Integer; const B: BigInteger): BigInteger;
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

type
  TBigNumberFromCardinal = function(var A: IBigNumber; Value: Cardinal): HResult; stdcall;
  TBigNumberFromInteger = function(var A: IBigNumber; Value: Integer): HResult; stdcall;
  TBigNumberFromPWideChar = function(var A: IBigNumber;
    P: PWideChar; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;
  TBigNumberFromPByte = function(var A: IBigNumber;
    P: PByte; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;

var
  BigNumberFromCardinal: TBigNumberFromCardinal;
  BigNumberFromInteger: TBigNumberFromInteger;
  BigNumberFromPWideChar: TBigNumberFromPWideChar;
  BigNumberFromPByte: TBigNumberFromPByte;

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

function BigCardinal.ToString: string;
var
  S: WideString;

begin
  HResCheck(FNumber.ToWideString(S),
    'BigCardinal -> string conversion error');
  Result:= S;
end;

function BigCardinal.ToHexString(Digits: Cardinal; TwoCompl: Boolean): string;
var
  S: WideString;

begin
  HResCheck(FNumber.ToWideHexString(S, Digits, TwoCompl),
    'BigCardinal -> hex string conversion error');
  Result:= S;
end;

function BigCardinal.ToBytes: TBytes;
var
  HR: HResult;
  L: Cardinal;

begin
  L:= 0;
  HR:= FNumber.ToPByte(nil, L);
  if (HR = TFL_E_INVALIDARG) and (L > 0) then begin
    SetLength(Result, L);
    HR:= FNumber.ToPByte(Pointer(Result), L);
  end;
  HResCheck(HR, 'BigCardinal -> TBytes conversion error');
end;

function BigCardinal.TryParse(const S: string): Boolean;
begin
  Result:= BigNumberFromPWideChar(FNumber, Pointer(S), Length(S),
              False) = TFL_S_OK;
end;

procedure BigCardinal.Free;
begin
  FNumber:= nil;
end;

class function BigCardinal.Compare(const A, B: BigCardinal): Integer;
begin
  Result:= A.FNumber.CompareNumberU(B.FNumber);
end;

function BigCardinal.CompareTo(const B: BigCardinal): Integer;
begin
  Result:= Compare(Self, B);
end;

class function BigCardinal.Pow(const Base: BigCardinal; Value: Cardinal): BigCardinal;
begin
  HResCheck(Base.FNumber.PowU(Value, Result.FNumber), 'BigCardinal.Power');
end;

class function BigCardinal.DivRem(const Dividend, Divisor: BigCardinal;
                                  var Remainder: BigCardinal): BigCardinal;
begin
  HResCheck(Dividend.FNumber.DivRemNumberU(Divisor.FNumber,
            Result.FNumber, Remainder.FNumber),
            'BigCardinal.DivRem');
end;

class operator BigCardinal.Explicit(const Value: BigCardinal): Cardinal;
begin
  HResCheck(Value.FNumber.ToCardinal(Result),
    'BigCardinal -> Cardinal conversion error');
end;

class operator BigCardinal.Explicit(const Value: BigCardinal): Integer;
begin
  HResCheck(Value.FNumber.ToInteger(Result),
    'BigCardinal -> Integer conversion error');
end;

class operator BigCardinal.Implicit(const Value: Cardinal): BigCardinal;
begin
  HResCheck(BigNumberFromCardinal(Result.FNumber, Value),
            'TBigNumber.FromCardinal');
end;

class operator BigCardinal.Explicit(const Value: Integer): BigCardinal;
begin
  if Value < 0 then
    BigNumberError(TFL_E_INVALIDARG,
      'Integer -> BigCardinal conversion error')
  else begin
    HResCheck(BigNumberFromInteger(Result.FNumber, Cardinal(Value)),
            'TBigNumber.FromInteger');
  end;
end;

class operator BigCardinal.Explicit(const Value: TBytes): BigCardinal;
begin
  HResCheck(BigNumberFromPByte(Result.FNumber,
            Pointer(Value), Length(Value), False),
    'TBytes -> BigCardinal conversion error');
end;

class operator BigCardinal.Explicit(const Value: string): BigCardinal;
begin
  HResCheck(BigNumberFromPWideChar(Result.FNumber, Pointer(Value),
            Length(Value), False),
    'string -> BigCardinal conversion error');
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

class operator BigCardinal.Add(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.AddNumberU(B.FNumber, Result.FNumber),
            'BigCardinal.Add');
end;

class operator BigCardinal.Subtract(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.SubNumberU(B.FNumber, Result.FNumber),
            'BigCardinal.Subtract');
end;

class operator BigCardinal.Multiply(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.MulNumberU(B.FNumber, Result.FNumber),
            'BigCardinal.Multiply');
end;

class operator BigCardinal.IntDivide(const A, B: BigCardinal): BigCardinal;
var
  Remainder: IBigNumber;

begin
  HResCheck(A.FNumber.DivRemNumberU(B.FNumber, Result.FNumber, Remainder),
            'BigCardinal.IntDivide');
end;

class operator BigCardinal.Modulus(const A, B: BigCardinal): BigCardinal;
var
  Quotient: IBigNumber;

begin
  HResCheck(A.FNumber.DivRemNumberU(B.FNumber, Quotient, Result.FNumber),
            'BigCardinal.Modulus');
end;


class operator BigCardinal.LeftShift(const A: BigCardinal; Shift: Cardinal): BigCardinal;
begin
  HResCheck(A.FNumber.ShlNumber(Shift, Result.FNumber),
            'BigCardinal.Shl');
end;

class operator BigCardinal.RightShift(const A: BigCardinal; Shift: Cardinal): BigCardinal;
begin
  HResCheck(A.FNumber.ShrNumber(Shift, Result.FNumber),
            'BigCardinal.Shr');
end;

class operator BigCardinal.BitwiseAnd(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.AndNumberU(B.FNumber, Result.FNumber),
            'BigCardinal.And');
end;

class operator BigCardinal.BitwiseOr(const A, B: BigCardinal): BigCardinal;
begin
  HResCheck(A.FNumber.OrNumberU(B.FNumber, Result.FNumber),
            'BigCardinal.Or');
end;

function BigCardinal.CompareToCard(const B: Cardinal): Integer;
begin
  Result:= FNumber.CompareToLimbU(B);
end;

function BigCardinal.CompareToInt(const B: Integer): Integer;
begin
  Result:= FNumber.CompareToIntLimbU(B);
end;

function BigCardinal.CompareTo(const B: Cardinal): Integer;
begin
  Result:= CompareToCard(B);
end;

function BigCardinal.CompareTo(const B: Integer): Integer;
begin
  Result:= CompareToInt(B);
end;

class operator BigCardinal.Equal(const A: BigCardinal; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) = 0;
end;

class operator BigCardinal.Equal(const A: Cardinal; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToCard(A) = 0;
end;

class operator BigCardinal.Equal(const A: BigCardinal; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) = 0;
end;

class operator BigCardinal.Equal(const A: Integer; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToInt(A) = 0;
end;

class operator BigCardinal.NotEqual(const A: BigCardinal; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) <> 0;
end;

class operator BigCardinal.NotEqual(const A: Cardinal; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToCard(A) <> 0;
end;

class operator BigCardinal.NotEqual(const A: BigCardinal; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) <> 0;
end;

class operator BigCardinal.NotEqual(const A: Integer; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToInt(A) <> 0;
end;

class operator BigCardinal.GreaterThan(const A: BigCardinal; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) > 0;
end;

class operator BigCardinal.GreaterThan(const A: Cardinal; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToCard(A) < 0;
end;

class operator BigCardinal.GreaterThan(const A: BigCardinal; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) > 0;
end;

class operator BigCardinal.GreaterThan(const A: Integer; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToInt(A) < 0;
end;

class operator BigCardinal.GreaterThanOrEqual(const A: BigCardinal; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) >= 0;
end;

class operator BigCardinal.GreaterThanOrEqual(const A: Cardinal; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToCard(A) <= 0;
end;

class operator BigCardinal.GreaterThanOrEqual(const A: BigCardinal; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) >= 0;
end;

class operator BigCardinal.GreaterThanOrEqual(const A: Integer; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToInt(A) <= 0;
end;

class operator BigCardinal.LessThan(const A: BigCardinal; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) < 0;
end;

class operator BigCardinal.LessThan(const A: Cardinal; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToCard(A) > 0;
end;

class operator BigCardinal.LessThan(const A: BigCardinal; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) < 0;
end;

class operator BigCardinal.LessThan(const A: Integer; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToInt(A) > 0;
end;

class operator BigCardinal.LessThanOrEqual(const A: BigCardinal; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) <= 0;
end;

class operator BigCardinal.LessThanOrEqual(const A: Cardinal; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToCard(A) >= 0;
end;

class operator BigCardinal.LessThanOrEqual(const A: BigCardinal; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) <= 0;
end;

class operator BigCardinal.LessThanOrEqual(const A: Integer; const B: BigCardinal): Boolean;
begin
  Result:= B.CompareToInt(A) >= 0;
end;

class operator BigCardinal.Add(const A: BigCardinal; const B: Cardinal): BigCardinal;
begin
  HResCheck(A.FNumber.AddLimbU(B, Result.FNumber),
            'BigCardinal.AddLimbU');
end;

class operator BigCardinal.Add(const A: Cardinal; const B: BigCardinal): BigCardinal;
begin
  HResCheck(B.FNumber.AddLimbU(A, Result.FNumber),
            'BigCardinal.AddLimbU');
end;

class operator BigCardinal.Subtract(const A: BigCardinal; const B: Cardinal): BigCardinal;
begin
  HResCheck(A.FNumber.SubLimbU(B, Result.FNumber),
            'BigCardinal.SubLimbU');
end;

class operator BigCardinal.Subtract(const A: Cardinal; const B: BigCardinal): Cardinal;
begin
  HResCheck(B.FNumber.SubLimbU2(A, Result),
            'BigCardinal.SubLimbU2');
end;

class operator BigCardinal.Multiply(const A: BigCardinal; const B: Cardinal): BigCardinal;
begin
  HResCheck(A.FNumber.MulLimbU(B, Result.FNumber),
            'BigCardinal.MulLimbU');
end;

class operator BigCardinal.Multiply(const A: Cardinal; const B: BigCardinal): BigCardinal;
begin
  HResCheck(B.FNumber.MulLimbU(A, Result.FNumber),
            'BigCardinal.MulLimbU');
end;


{ -------------------------- BigCardinal -------------------------- }

function BigInteger.GetSign: Integer;
begin
  Result:= FNumber.GetSign;
end;

function BigInteger.ToString: string;
var
  S: WideString;

begin
  HResCheck(FNumber.ToWideString(S),
    'BigInteger -> string conversion error');
  Result:= S;
end;

function BigInteger.ToHexString(Digits: Cardinal; TwoCompl: Boolean): string;
var
  S: WideString;

begin
  HResCheck(FNumber.ToWideHexString(S, Digits, TwoCompl),
    'BigInteger -> hex string conversion error');
  Result:= S;
end;

function BigInteger.ToBytes: TBytes;
var
  HR: HResult;
  L: Cardinal;

begin
  L:= 0;
  HR:= FNumber.ToPByte(nil, L);
  if (HR = TFL_E_INVALIDARG) and (L > 0) then begin
    SetLength(Result, L);
    HR:= FNumber.ToPByte(Pointer(Result), L);
  end;
  HResCheck(HR, 'BigInteger -> TBytes conversion error');
end;

function BigInteger.TryParse(const S: string): Boolean;
begin
  Result:= BigNumberFromPWideChar(FNumber, Pointer(S), Length(S),
              True) = TFL_S_OK;
end;

procedure BigInteger.Free;
begin
  FNumber:= nil;
end;

class function BigInteger.Compare(const A, B: BigInteger): Integer;
begin
  Result:= A.FNumber.CompareNumber(B.FNumber);
end;

class function BigInteger.Compare(const A: BigInteger; const B: BigCardinal): Integer;
begin
  Result:= A.FNumber.CompareNumber(B.FNumber);
end;

class function BigInteger.Compare(const A: BigCardinal; const B: BigInteger): Integer;
begin
  Result:= A.FNumber.CompareNumber(B.FNumber);
end;

function BigInteger.CompareTo(const B: BigInteger): Integer;
begin
  Result:= Compare(Self, B);
end;

function BigInteger.CompareTo(const B: BigCardinal): Integer;
begin
  Result:= Compare(Self, B);
end;

class function BigInteger.Abs(const A: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.AbsNumber(Result.FNumber), 'BigInteger.Abs');
end;

class function BigInteger.Pow(const Base: BigInteger; Value: Cardinal): BigInteger;
begin
  HResCheck(Base.FNumber.Pow(Value, Result.FNumber),
                        'BigInteger.Power');
end;

class function BigInteger.DivRem(const Dividend, Divisor: BigCardinal;
               var Remainder: BigCardinal): BigCardinal;
begin
  HResCheck(Dividend.FNumber.DivRemNumber(Divisor.FNumber,
            Result.FNumber, Remainder.FNumber),
            'BigInteger.DivRem');
end;

class operator BigInteger.Implicit(const Value: BigCardinal): BigInteger;
begin
  Result.FNumber:= Value.FNumber;
end;

class operator BigInteger.Explicit(const Value: BigInteger): BigCardinal;
begin
  if (Value.FNumber.GetSign < 0) then
      BigNumberError(TFL_E_INVALIDARG, 'Negative value');
  Result.FNumber:= Value.FNumber;
end;

class operator BigInteger.Explicit(const Value: BigInteger): Cardinal;
begin
  HResCheck(Value.FNumber.ToCardinal(Result),
    'BigInteger -> Cardinal conversion error');
end;

class operator BigInteger.Explicit(const Value: BigInteger): Integer;
begin
  HResCheck(Value.FNumber.ToInteger(Result),
    'BigInteger -> Integer conversion error');
end;

class operator BigInteger.Implicit(const Value: Cardinal): BigInteger;
begin
  HResCheck(BigNumberFromCardinal(Result.FNumber, Value),
            'TBigNumber.FromCardinal');
end;

class operator BigInteger.Implicit(const Value: Integer): BigInteger;
begin
  HResCheck(BigNumberFromInteger(Result.FNumber, Value),
            'TBigNumber.FromInteger');
end;

class operator BigInteger.Explicit(const Value: TBytes): BigInteger;
begin
  HResCheck(BigNumberFromPByte(Result.FNumber,
            Pointer(Value), Length(Value), True),
            'TBytes -> BigInteger conversion error');
end;

class operator BigInteger.Explicit(const Value: string): BigInteger;
begin
  HResCheck(BigNumberFromPWideChar(Result.FNumber, Pointer(Value),
            Length(Value), True),
            'string -> BigInteger conversion error');
end;

class operator BigInteger.Equal(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) = 0;
end;

class operator BigInteger.Equal(const A: BigCardinal; const B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) = 0;
end;

class operator BigInteger.Equal(const A: BigInteger; const B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) = 0;
end;

class operator BigInteger.NotEqual(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) <> 0;
end;

class operator BigInteger.NotEqual(const A: BigCardinal; const B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) <> 0;
end;

class operator BigInteger.NotEqual(const A: BigInteger; const B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) <> 0;
end;

class operator BigInteger.GreaterThan(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) > 0;
end;

class operator BigInteger.GreaterThan(const A: BigInteger; const B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) > 0;
end;

class operator BigInteger.GreaterThan(const A: BigCardinal; const B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) > 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) >= 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A: BigInteger; const B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) >= 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A: BigCardinal; const B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) >= 0;
end;

class operator BigInteger.LessThan(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) < 0;
end;

class operator BigInteger.LessThan(const A: BigInteger; const B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) < 0;
end;

class operator BigInteger.LessThan(const A: BigCardinal; const B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) < 0;
end;

class operator BigInteger.LessThanOrEqual(const A, B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) <= 0;
end;

class operator BigInteger.LessThanOrEqual(const A: BigInteger; const B: BigCardinal): Boolean;
begin
  Result:= Compare(A, B) <= 0;
end;

class operator BigInteger.LessThanOrEqual(const A: BigCardinal; const B: BigInteger): Boolean;
begin
  Result:= Compare(A, B) <= 0;
end;

class operator BigInteger.Add(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.AddNumber(B.FNumber, Result.FNumber), 'BigInteger.Add');
end;

class operator BigInteger.Subtract(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.SubNumber(B.FNumber, Result.FNumber), 'BigInteger.Subtract');
end;

class operator BigInteger.Multiply(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.MulNumber(B.FNumber, Result.FNumber), 'BigInteger.Multiply');
end;

class operator BigInteger.IntDivide(const A, B: BigInteger): BigInteger;
var
  Remainder: IBigNumber;

begin
  HResCheck(A.FNumber.DivRemNumber(B.FNumber, Result.FNumber, Remainder),
            'BigInteger.IntDivide');
end;

class operator BigInteger.Modulus(const A, B: BigInteger): BigInteger;
var
  Quotient: IBigNumber;

begin
  HResCheck(A.FNumber.DivRemNumber(B.FNumber, Quotient, Result.FNumber),
            'BigInteger.Modulus');
end;

class operator BigInteger.LeftShift(const A: BigInteger; Shift: Cardinal): BigInteger;
begin
  HResCheck(A.FNumber.ShlNumber(Shift, Result.FNumber),
   'BigInteger.Shl');
end;

class operator BigInteger.RightShift(const A: BigInteger; Shift: Cardinal): BigInteger;
begin
  HResCheck(A.FNumber.ShrNumber(Shift, Result.FNumber),
   'BigInteger.Shr');
end;

class operator BigInteger.BitwiseAnd(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.AndNumber(B.FNumber, Result.FNumber),
                       'BigInteger.And');
end;

class operator BigInteger.BitwiseOr(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.OrNumber(B.FNumber, Result.FNumber),
                       'BigInteger.Or');
end;

class operator BigInteger.BitwiseXor(const A, B: BigInteger): BigInteger;
begin
  HResCheck(A.FNumber.XorNumber(B.FNumber, Result.FNumber),
                       'BigInteger.Xor');
end;

function BigInteger.CompareToCard(const B: Cardinal): Integer;
begin
  Result:= FNumber.CompareToLimb(B);
end;

function BigInteger.CompareToInt(const B: Integer): Integer;
begin
  Result:= FNumber.CompareToIntLimb(B);
end;

function BigInteger.CompareTo(const B: Cardinal): Integer;
begin
  Result:= CompareToCard(B);
end;

function BigInteger.CompareTo(const B: Integer): Integer;
begin
  Result:= CompareToInt(B);
end;

class operator BigInteger.Equal(const A: BigInteger; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) = 0;
end;

class operator BigInteger.Equal(const A: Cardinal; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToCard(A) = 0;
end;

class operator BigInteger.Equal(const A: BigInteger; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) = 0;
end;

class operator BigInteger.Equal(const A: Integer; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToInt(A) = 0;
end;

class operator BigInteger.NotEqual(const A: BigInteger; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) <> 0;
end;

class operator BigInteger.NotEqual(const A: Cardinal; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToCard(A) <> 0;
end;

class operator BigInteger.NotEqual(const A: BigInteger; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) <> 0;
end;

class operator BigInteger.NotEqual(const A: Integer; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToInt(A) <> 0;
end;

class operator BigInteger.GreaterThan(const A: BigInteger; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) > 0;
end;

class operator BigInteger.GreaterThan(const A: Cardinal; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToCard(A) < 0;
end;

class operator BigInteger.GreaterThan(const A: BigInteger; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) > 0;
end;

class operator BigInteger.GreaterThan(const A: Integer; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToInt(A) < 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A: BigInteger; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) >= 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A: Cardinal; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToCard(A) <= 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A: BigInteger; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) >= 0;
end;

class operator BigInteger.GreaterThanOrEqual(const A: Integer; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToInt(A) <= 0;
end;

class operator BigInteger.LessThan(const A: BigInteger; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) < 0;
end;

class operator BigInteger.LessThan(const A: Cardinal; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToCard(A) > 0;
end;

class operator BigInteger.LessThan(const A: BigInteger; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) < 0;
end;

class operator BigInteger.LessThan(const A: Integer; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToInt(A) > 0;
end;

class operator BigInteger.LessThanOrEqual(const A: BigInteger; const B: Cardinal): Boolean;
begin
  Result:= A.CompareToCard(B) <= 0;
end;

class operator BigInteger.LessThanOrEqual(const A: Cardinal; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToCard(A) >= 0;
end;

class operator BigInteger.LessThanOrEqual(const A: BigInteger; const B: Integer): Boolean;
begin
  Result:= A.CompareToInt(B) <= 0;
end;

class operator BigInteger.LessThanOrEqual(const A: Integer; const B: BigInteger): Boolean;
begin
  Result:= B.CompareToInt(A) >= 0;
end;

class operator BigInteger.Add(const A: BigInteger; const B: Cardinal): BigInteger;
begin
  HResCheck(A.FNumber.AddLimb(B, Result.FNumber),
            'BigCardinal.AddLimb');
end;

class operator BigInteger.Add(const A: Cardinal; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.AddLimb(A, Result.FNumber),
            'BigCardinal.AddLimb');
end;

class operator BigInteger.Add(const A: BigInteger; const B: Integer): BigInteger;
begin
  HResCheck(A.FNumber.AddIntLimb(B, Result.FNumber),
           'BigInteger.AddIntLimb');
end;

class operator BigInteger.Add(const A: Integer; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.AddIntLimb(A, Result.FNumber),
            'BigInteger.AddIntLimb');
end;

// -------------------------------------------------------------- //

const
  LibName = 'numerics32.dll';
//  LibName = 'numerics64.dll';

var
  LibHandle: THandle = 0;

function BigNumberFromCardinalStub(var A: IBigNumber; Value: Cardinal): HResult; stdcall;
begin
  Result:= TFL_E_LOADERROR;
end;

function BigNumberFromPByteStub(var A: IBigNumber;
           P: PByte; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;
begin
  Result:= TFL_E_LOADERROR;
end;

function LoadLib: Boolean;
begin
  if LibHandle <> 0 then begin
    Result:= True;
    Exit;
  end;
  Result:= False;
  LibHandle:= LoadLibrary(LibName);
  if LibHandle <> 0 then begin
    @BigNumberFromCardinal:= GetProcAddress(LibHandle, 'BigNumberFromCardinal');
    @BigNumberFromInteger:= GetProcAddress(LibHandle, 'BigNumberFromInteger');
    @BigNumberFromPWideChar:= GetProcAddress(LibHandle, 'BigNumberFromPWideChar');
    @BigNumberFromPByte:= GetProcAddress(LibHandle, 'BigNumberFromPByte');
    Result:= (@BigNumberFromCardinal <> nil)
             and (@BigNumberFromInteger <> nil)
             and (@BigNumberFromPWideChar <> nil)
             and (@BigNumberFromPByte <> nil)
  end;
  if not Result then begin
    @BigNumberFromCardinal:= @BigNumberFromCardinalStub;
    @BigNumberFromInteger:= @BigNumberFromCardinalStub;
    @BigNumberFromPWideChar:= @BigNumberFromPByteStub;
    @BigNumberFromPByte:= @BigNumberFromPByteStub;
  end;
end;

initialization
  LoadLib;

end.
