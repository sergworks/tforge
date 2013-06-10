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

    function ToUInt32(var Value: Cardinal): HRESULT; stdcall;
    function ToInt32(var Value: Integer): HRESULT; stdcall;
    function ToUInt64(var Value: UInt64): HRESULT; stdcall;
    function ToInt64(var Value: Int64): HRESULT; stdcall;
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
    function SubLimb2(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function SubLimbU(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
//    function SubLimbU2(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function SubLimbU2(Limb: LongWord; var Res: LongWord): HRESULT; stdcall;
    function SubIntLimb(Limb: LongInt; var Res: IBigNumber): HRESULT; stdcall;
    function SubIntLimb2(Limb: LongInt; var Res: IBigNumber): HRESULT; stdcall;

    function MulLimb(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function MulLimbU(Limb: LongWord; var Res: IBigNumber): HRESULT; stdcall;
    function MulIntLimb(Limb: LongInt; var Res: IBigNumber): HRESULT; stdcall;

    function DivRemLimb(Limb: LongWord; var Q: IBigNumber; var R: LongWord): HRESULT; stdcall;
    function DivRemLimb2(Limb: LongWord; var Q: LongWord; var R: LongWord): HRESULT; stdcall;
    function DivRemLimbU(Limb: LongWord; var Q: IBigNumber; var R: LongWord): HRESULT; stdcall;
    function DivRemLimbU2(Limb: LongWord; var Q: LongWord; var R: LongWord): HRESULT; stdcall;
    function DivRemIntLimb(Limb: LongInt; var Q: IBigNumber; var R: LongInt): HRESULT; stdcall;
    function DivRemIntLimb2(Limb: LongInt; var Q: LongInt; var R: LongInt): HRESULT; stdcall;
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
                          var Remainder: BigCardinal): BigCardinal; overload; static;

    class operator Explicit(const Value: BigCardinal): UInt32;
    class operator Explicit(const Value: BigCardinal): Int32;
    class operator Explicit(const Value: BigCardinal): UInt64;
    class operator Explicit(const Value: BigCardinal): Int64;
    class operator Implicit(const Value: UInt32): BigCardinal;
    class operator Implicit(const Value: UInt64): BigCardinal;
    class operator Explicit(const Value: Int32): BigCardinal;
    class operator Explicit(const Value: Int64): BigCardinal;
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

    class function DivRem(const Dividend: BigCardinal; Divisor: Cardinal;
                          var Remainder: Cardinal): BigCardinal; overload; static;
    class function DivRem(const Dividend: Cardinal; Divisor: BigCardinal;
                          var Remainder: Cardinal): Cardinal; overload; static;

    class operator Add(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator Add(const A: Cardinal; const B: BigCardinal): BigCardinal;
    class operator Subtract(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator Subtract(const A: Cardinal; const B: BigCardinal): Cardinal;
    class operator Multiply(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator Multiply(const A: Cardinal; const B: BigCardinal): BigCardinal;
    class operator IntDivide(const A: BigCardinal; const B: Cardinal): BigCardinal;
    class operator IntDivide(const A: Cardinal; const B: BigCardinal): Cardinal;
    class operator Modulus(const A: BigCardinal; const B: Cardinal): Cardinal;
    class operator Modulus(const A: Cardinal; const B: BigCardinal): Cardinal;
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

    class operator Explicit(const Value: BigInteger): UInt32;
    class operator Explicit(const Value: BigInteger): UInt64;
    class operator Explicit(const Value: BigInteger): Int32;
    class operator Explicit(const Value: BigInteger): Int64;
    class operator Implicit(const Value: UInt32): BigInteger;
    class operator Implicit(const Value: UInt64): BigInteger;
    class operator Implicit(const Value: Int32): BigInteger;
    class operator Implicit(const Value: Int64): BigInteger;
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
    class operator Subtract(const A: BigInteger; const B: Cardinal): BigInteger;
    class operator Subtract(const A: Cardinal; const B: BigInteger): BigInteger;
    class operator Subtract(const A: BigInteger; const B: Integer): BigInteger;
    class operator Subtract(const A: Integer; const B: BigInteger): BigInteger;
    class operator Multiply(const A: BigInteger; const B: Cardinal): BigInteger;
    class operator Multiply(const A: Cardinal; const B: BigInteger): BigInteger;
    class operator Multiply(const A: BigInteger; const B: Integer): BigInteger;
    class operator Multiply(const A: Integer; const B: BigInteger): BigInteger;
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
  TBigNumberFromUInt32 = function(var A: IBigNumber; Value: UInt32): HResult; stdcall;
  TBigNumberFromUInt64 = function(var A: IBigNumber; Value: UInt64): HResult; stdcall;
  TBigNumberFromInt32 = function(var A: IBigNumber; Value: Int32): HResult; stdcall;
  TBigNumberFromInt64 = function(var A: IBigNumber; Value: Int64): HResult; stdcall;
  TBigNumberFromPWideChar = function(var A: IBigNumber;
    P: PWideChar; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;
  TBigNumberFromPByte = function(var A: IBigNumber;
    P: PByte; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;

var
  BigNumberFromUInt32: TBigNumberFromUInt32;
  BigNumberFromUInt64: TBigNumberFromUInt64;
  BigNumberFromInt32: TBigNumberFromInt32;
  BigNumberFromInt64: TBigNumberFromInt64;
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
  HResCheck(Value.FNumber.ToUInt32(Result),
    'BigCardinal -> Cardinal conversion error');
end;

class operator BigCardinal.Explicit(const Value: BigCardinal): Integer;
begin
  HResCheck(Value.FNumber.ToInt32(Result),
    'BigCardinal -> Integer conversion error');
end;

class operator BigCardinal.Explicit(const Value: BigCardinal): UInt64;
begin
  HResCheck(Value.FNumber.ToUInt64(Result),
    'BigCardinal -> UInt64 conversion error');
end;

class operator BigCardinal.Explicit(const Value: BigCardinal): Int64;
begin
  HResCheck(Value.FNumber.ToInt64(Result),
    'BigCardinal -> Int64 conversion error');
end;

class operator BigCardinal.Implicit(const Value: Cardinal): BigCardinal;
begin
  HResCheck(BigNumberFromUInt32(Result.FNumber, Value),
            'BigNumberFromLimb');
end;

class operator BigCardinal.Implicit(const Value: UInt64): BigCardinal;
begin
  HResCheck(BigNumberFromUInt64(Result.FNumber, Value),
            'BigNumberFromDblLimb');
end;

class operator BigCardinal.Explicit(const Value: Integer): BigCardinal;
begin
  if Value < 0 then
    BigNumberError(TFL_E_INVALIDARG,
      'Integer -> BigCardinal conversion error')
  else begin
    HResCheck(BigNumberFromInt32(Result.FNumber, Value),
            'TBigNumber.FromInteger');
  end;
end;

class operator BigCardinal.Explicit(const Value: Int64): BigCardinal;
begin
  if Value < 0 then
    BigNumberError(TFL_E_INVALIDARG,
      'Int64 -> BigCardinal conversion error')
  else begin
    HResCheck(BigNumberFromInt64(Result.FNumber, Value),
            'BigNumberFromDblIntLimb');
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


class function BigCardinal.DivRem(const Dividend: BigCardinal;
               Divisor: Cardinal; var Remainder: Cardinal): BigCardinal;
begin
  HResCheck(Dividend.FNumber.DivRemLimbU(Divisor, Result.FNumber, Remainder),
            'BigCardinal.DivRemLimbU');
end;

class function BigCardinal.DivRem(const Dividend: Cardinal;
               Divisor: BigCardinal; var Remainder: Cardinal): Cardinal;
begin
  HResCheck(Divisor.FNumber.DivRemLimbU2(Dividend, Result, Remainder),
            'BigCardinal.DivRemLimbU2');
end;

class operator BigCardinal.IntDivide(const A: BigCardinal; const B: Cardinal): BigCardinal;
var
  Remainder: Cardinal;

begin
  HResCheck(A.FNumber.DivRemLimbU(B, Result.FNumber, Remainder),
            'BigCardinal.IntDivide');
end;

class operator BigCardinal.IntDivide(const A: Cardinal; const B: BigCardinal): Cardinal;
var
  Remainder: Cardinal;

begin
  HResCheck(B.FNumber.DivRemLimbU2(A, Result, Remainder),
            'BigCardinal.IntDivide');
end;

class operator BigCardinal.Modulus(const A: BigCardinal; const B: Cardinal): Cardinal;
var
  Quotient: IBigNumber;

begin
  HResCheck(A.FNumber.DivRemLimbU(B, Quotient, Result),
            'BigCardinal.Modulus');
end;


class operator BigCardinal.Modulus(const A: Cardinal; const B: BigCardinal): Cardinal;
var
  Quotient: Cardinal;

begin
  HResCheck(B.FNumber.DivRemLimbU2(A, Quotient, Result),
            'BigCardinal.Modulus');
end;

{ -------------------------- BigInteger -------------------------- }

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

class operator BigInteger.Explicit(const Value: BigInteger): UInt32;
begin
  HResCheck(Value.FNumber.ToUInt32(Result),
    'BigInteger -> UInt32 conversion error');
end;

class operator BigInteger.Explicit(const Value: BigInteger): UInt64;
begin
  HResCheck(Value.FNumber.ToUInt64(Result),
    'BigInteger -> UInt64 conversion error');
end;

class operator BigInteger.Explicit(const Value: BigInteger): Int32;
begin
  HResCheck(Value.FNumber.ToInt32(Result),
    'BigInteger -> Int32 conversion error');
end;

class operator BigInteger.Explicit(const Value: BigInteger): Int64;
begin
  HResCheck(Value.FNumber.ToInt64(Result),
    'BigInteger -> Int64 conversion error');
end;

class operator BigInteger.Implicit(const Value: UInt32): BigInteger;
begin
  HResCheck(BigNumberFromUInt32(Result.FNumber, Value),
            'BigNumberFromLimb');
end;

class operator BigInteger.Implicit(const Value: UInt64): BigInteger;
begin
  HResCheck(BigNumberFromUInt64(Result.FNumber, Value),
            'BigNumberFromDblLimb');
end;

class operator BigInteger.Implicit(const Value: Int32): BigInteger;
begin
  HResCheck(BigNumberFromInt32(Result.FNumber, Value),
            'BigNumberFromIntLimb');
end;

class operator BigInteger.Implicit(const Value: Int64): BigInteger;
begin
  HResCheck(BigNumberFromInt64(Result.FNumber, Value),
            'BigNumberFromDblIntLimb');
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

class operator BigInteger.Subtract(const A: BigInteger; const B: Cardinal): BigInteger;
begin
  HResCheck(A.FNumber.SubLimb(B, Result.FNumber),
            'BigInteger.Subtract');
end;

class operator BigInteger.Subtract(const A: Cardinal; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.SubLimb2(A, Result.FNumber),
            'BigInteger.Subtract');
end;

class operator BigInteger.Subtract(const A: BigInteger; const B: Integer): BigInteger;
begin
  HResCheck(A.FNumber.SubIntLimb(B, Result.FNumber),
            'BigInteger.Subtract');
end;

class operator BigInteger.Subtract(const A: Integer; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.SubIntLimb2(A, Result.FNumber),
            'BigInteger.Subtract');
end;

class operator BigInteger.Multiply(const A: BigInteger; const B: Cardinal): BigInteger;
begin
  HResCheck(A.FNumber.MulLimb(B, Result.FNumber),
            'BigInteger.MulLimb');
end;

class operator BigInteger.Multiply(const A: Cardinal; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.MulLimb(A, Result.FNumber),
            'BigInteger.MulLimb');
end;

class operator BigInteger.Multiply(const A: BigInteger; const B: Integer): BigInteger;
begin
  HResCheck(A.FNumber.MulIntLimb(B, Result.FNumber),
            'BigInteger.MulIntLimb');
end;

class operator BigInteger.Multiply(const A: Integer; const B: BigInteger): BigInteger;
begin
  HResCheck(B.FNumber.MulIntLimb(A, Result.FNumber),
            'BigInteger.MulIntLimb');
end;


// -------------------------------------------------------------- //

const
  LibName = 'numerics32.dll';
//  LibName = 'numerics64.dll';

var
  LibHandle: THandle = 0;

function BigNumberFrom32Stub(var A: IBigNumber; Value: UInt32): HResult; stdcall;
begin
  Result:= TFL_E_LOADERROR;
end;

function BigNumberFrom64Stub(var A: IBigNumber; Value: UInt64): HResult; stdcall;
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
    @BigNumberFromUInt32:= GetProcAddress(LibHandle, 'BigNumberFromLimb');
    @BigNumberFromUInt64:= GetProcAddress(LibHandle, 'BigNumberFromDblLimb');
    @BigNumberFromInt32:= GetProcAddress(LibHandle, 'BigNumberFromIntLimb');
    @BigNumberFromInt64:= GetProcAddress(LibHandle, 'BigNumberFromDblIntLimb');
    @BigNumberFromPWideChar:= GetProcAddress(LibHandle, 'BigNumberFromPWideChar');
    @BigNumberFromPByte:= GetProcAddress(LibHandle, 'BigNumberFromPByte');
    Result:= (@BigNumberFromUInt32 <> nil)
             and (@BigNumberFromUInt64 <> nil)
             and (@BigNumberFromInt32 <> nil)
             and (@BigNumberFromInt64 <> nil)
             and (@BigNumberFromPWideChar <> nil)
             and (@BigNumberFromPByte <> nil)
  end;
  if not Result then begin
    @BigNumberFromUInt32:= @BigNumberFrom32Stub;
    @BigNumberFromUInt64:= @BigNumberFrom64Stub;
    @BigNumberFromInt32:= @BigNumberFrom32Stub;
    @BigNumberFromInt64:= @BigNumberFrom64Stub;
    @BigNumberFromPWideChar:= @BigNumberFromPByteStub;
    @BigNumberFromPByte:= @BigNumberFromPByteStub;
  end;
end;

initialization
  LoadLib;

end.
