{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ * ------------------------------------------------------- * }
{ *   # client unit                                         * }
{ *   # exports: BigCardinal, BigInteger                    * }
{ *********************************************************** }

unit tfNumerics;

{$I TFL.inc}

interface

uses SysUtils, tfTypes {$IFNDEF TFL_DLL}, tfNumbers{$ENDIF};

type
  BigCardinal = record
  private
    FNumber: IBigNumber;
  public
    function AsString: string;
    function TryFromString(const S: string): Boolean;

    class operator Implicit(const Value: BigCardinal): IBigNumber; inline;
    class operator Explicit(const Value: IBigNumber): BigCardinal; inline;
    class operator Implicit(const Value: Cardinal): BigCardinal;
    class operator Explicit(const Value: Integer): BigCardinal;
    class operator Add(const A, B: BigCardinal): BigCardinal;
    class operator Subtract(const A, B: BigCardinal): BigCardinal;
    class operator Multiply(const A, B: BigCardinal): BigCardinal;
    class operator IntDivide(const A, B: BigCardinal): BigCardinal;
    class operator Modulus(const A, B: BigCardinal): BigCardinal;
  end;

  BigInteger = record
  private
    FNumber: IBigNumber;
  public
    class operator Implicit(const Value: BigInteger): IBigNumber; inline;
    class operator Explicit(const Value: IBigNumber): BigInteger; inline;
    class operator Implicit(const Value: Cardinal): BigInteger;
    class operator Implicit(const Value: Integer): BigInteger;
    class operator Add(const A, B: BigInteger): BigInteger;
    class operator Subtract(const A, B: BigInteger): BigInteger;
    class operator Multiply(const A, B: BigInteger): BigInteger;
    class operator IntDivide(const A, B: BigInteger): BigInteger;
    class operator Modulus(const A, B: BigInteger): BigInteger;
  end;

implementation

procedure HResCheck(Value: HResult; const ErrMsg: string); inline;
begin
  if Value <> S_OK then
    raise Exception.Create(ErrMsg);
end;

function BigCardinal.AsString: string;
var
  S: WideString;

begin
  HResCheck(FNumber.AsWideStringU(S), 'BigCardinal.AsString');
  Result:= S
end;

function BigCardinal.TryFromString(const S: string): Boolean;
begin
{$IFNDEF TFL_DLL}
  Result:= TBigNumber.FromStringU(PBigNumber(FNumber), S) = S_OK;
{$ELSE}
//TODO:
{$ENDIF}
end;

{ BigCardinal }

class operator BigCardinal.Explicit(const Value: IBigNumber): BigCardinal;
begin
  if (Value = nil) or (Value.GetSign >= 0)
    then Result.FNumber:= Value
// TODO:
    else raise Exception.Create('InvalidBigCardinal');
end;

class operator BigCardinal.Explicit(const Value: Integer): BigCardinal;
begin
  if Value < 0 then begin
// TODO:
    raise Exception.Create('InvalidBigCardinal');
  end;
{$IFNDEF TFL_DLL}
  HResCheck(TBigNumber.FromCardinal(PBigNumber(Result.FNumber), Cardinal(Value)),
            'TBigNumber.FromCardinal');
{$ELSE}
//TODO:
{$ENDIF}
end;

class operator BigCardinal.Implicit(const Value: BigCardinal): IBigNumber;
begin
  Result:= Value.FNumber;
end;

class operator BigCardinal.Implicit(const Value: Cardinal): BigCardinal;
begin
{$IFNDEF TFL_DLL}
  HResCheck(TBigNumber.FromCardinal(PBigNumber(Result.FNumber), Value),
            'TBigNumber.FromCardinal');
{$ELSE}
//TODO:
{$ENDIF}
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

{ BigInteger }

class operator BigInteger.Implicit(const Value: BigInteger): IBigNumber;
begin
  Result:= Value.FNumber;
end;

class operator BigInteger.Explicit(const Value: IBigNumber): BigInteger;
begin
  Result.FNumber:= Value;
end;

class operator BigInteger.Implicit(const Value: Integer): BigInteger;
begin
{$IFNDEF TFL_DLL}
  HResCheck(TBigNumber.FromInteger(PBigNumber(Result.FNumber), Value),
            'TBigNumber.FromInteger');
{$ELSE}
//TODO:
{$ENDIF}
end;

class operator BigInteger.Implicit(const Value: Cardinal): BigInteger;
begin
{$IFNDEF TFL_DLL}
  HResCheck(TBigNumber.FromCardinal(PBigNumber(Result.FNumber), Value),
            'TBigNumber.FromCardinal');
{$ELSE}
//TODO:
{$ENDIF}
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

end.
