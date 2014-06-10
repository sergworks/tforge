{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfGNumerics;

interface

uses tfNumerics, Generics.Defaults, Generics.Collections;
(*
type
  TCustComparer<T> = class(TSingletonImplementation, IComparer<T>, IEqualityComparer<T>)
  protected
    function Compare(const Left, Right: T): Integer; virtual; abstract;
    function Equals(const Left, Right: T): Boolean; virtual; abstract;
    function GetHashCode(const Value: T): Integer; virtual; abstract;
  end;

  TBigCardinalComparer = class(TCustComparer<BigCardinal>)
  private
    class var
      FOrdinal: TCustComparer<BigCardinal>;
  public
    class function Ordinal: TBigCardinalComparer;
  end;

  TBigIntegerComparer = class(TCustComparer<BigInteger>)
  private
    class var
      FOrdinal: TCustComparer<BigInteger>;
  public
    class function Ordinal: TBigIntegerComparer;
  end;
*)
//  IBigIntegerEqualityComparer = interface(IEqualityComparer<BigInteger>) end;

function GetBigCardinalEqualityComparer: IEqualityComparer<BigCardinal>;
function GetBigIntegerEqualityComparer: IEqualityComparer<BigInteger>;

type
  TBigCardinalDictionary<TValue> = class(TDictionary<BigCardinal,TValue>)
  public
    constructor Create(ACapacity: Integer = 0); overload;
  end;

  TBigIntegerDictionary<TValue> = class(TDictionary<BigInteger,TValue>)
  public
    constructor Create(ACapacity: Integer = 0); overload;
  end;

implementation

function NopAddref(Inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopRelease(Inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopQueryInterface(Inst: Pointer; const IID: TGUID; out Obj): HResult; stdcall;
begin
  Result := E_NOINTERFACE;
end;

function Equals_BigCardinal(Inst: Pointer; const Left, Right: BigCardinal): Boolean;
begin
  Result:= BigCardinal.Equals(Left, Right);
end;

function GetHashCode_BigCardinal(Inst: Pointer; const Value: BigCardinal): Integer;
begin
  Result:= Value.HashCode;
end;

function Equals_BigInteger(Inst: Pointer; const Left, Right: BigInteger): Boolean;
begin
  Result:= BigInteger.Equals(Left, Right);
end;

function GetHashCode_BigInteger(Inst: Pointer; const Value: BigInteger): Integer;
begin
  Result:= Value.HashCode;
end;

const
  EqualityComparer_BigCardinal: array[0..4] of Pointer =
  (
    @NopQueryInterface,
    @NopAddref,
    @NopRelease,
    @Equals_BigCardinal,
    @GetHashCode_BigCardinal
  );

  EqualityComparer_BigInteger: array[0..4] of Pointer =
  (
    @NopQueryInterface,
    @NopAddref,
    @NopRelease,
    @Equals_BigInteger,
    @GetHashCode_BigInteger
  );

type
  PDummyInstance = ^TDummyInstance;
  TDummyInstance = record
    VTable: Pointer;
  end;

const
  EqualityComparer_BigCardinal_Instance: TDummyInstance =
    (VTable: @EqualityComparer_BigCardinal);

  EqualityComparer_BigInteger_Instance: TDummyInstance =
    (VTable: @EqualityComparer_BigInteger);

function GetBigCardinalEqualityComparer: IEqualityComparer<BigCardinal>;
begin
  Pointer(Result):= @EqualityComparer_BigCardinal_Instance;
end;

function GetBigIntegerEqualityComparer: IEqualityComparer<BigInteger>;
begin
  Pointer(Result):= @EqualityComparer_BigInteger_Instance;
end;


(*
{ TOrdinalBigIntegerComparer }

type
  TOrdinalBigIntegerComparer = class(TBigIntegerComparer)
  public
    function Compare(const Left, Right: BigInteger): Integer; override;
    function Equals(const Left, Right: BigInteger): Boolean; override;
    function GetHashCode(const Value: BigInteger): Integer; override;
  end;

function TOrdinalBigIntegerComparer.Compare(const Left, Right: BigInteger): Integer;
begin
  Result:= BigInteger.Compare(Left, Right);
end;

function TOrdinalBigIntegerComparer.Equals(const Left, Right: BigInteger): Boolean;
begin
  Result:= BigInteger.Equals(Left, Right);
end;

function TOrdinalBigIntegerComparer.GetHashCode(const Value: BigInteger): Integer;
begin
  Result:= Value.HashCode;
end;

{ TBigIntegerComparer }

class function TBigIntegerComparer.Ordinal: TBigIntegerComparer;
begin
//  if FOrdinal = nil then
//    FOrdinal:= TOrdinalBigIntegerComparer.Create;
  Result:= TBigIntegerComparer(FOrdinal);
end;

{ TOrdinalBigCardinalComparer }

type
  TOrdinalBigCardinalComparer = class(TBigCardinalComparer)
  public
    function Compare(const Left, Right: BigCardinal): Integer; override;
    function Equals(const Left, Right: BigCardinal): Boolean; override;
    function GetHashCode(const Value: BigCardinal): Integer; override;
  end;

function TOrdinalBigCardinalComparer.Compare(const Left, Right: BigCardinal): Integer;
begin
  Result:= BigCardinal.Compare(Left, Right);
end;

function TOrdinalBigCardinalComparer.Equals(const Left, Right: BigCardinal): Boolean;
begin
  Result:= BigCardinal.Equals(Left, Right);
end;

function TOrdinalBigCardinalComparer.GetHashCode(const Value: BigCardinal): Integer;
begin
  Result:= Value.HashCode;
end;

{ TBigCardinalComparer }

class function TBigCardinalComparer.Ordinal: TBigCardinalComparer;
begin
  if FOrdinal = nil then
    FOrdinal:= TOrdinalBigCardinalComparer.Create;
  Result:= TBigCardinalComparer(FOrdinal);
end;
*)

{ TBigCardinalDictionary<TValue> }

constructor TBigCardinalDictionary<TValue>.Create(ACapacity: Integer);
begin
  inherited Create(ACapacity, GetBigCardinalEqualityComparer);
end;

{ TBigIntegerDictionary<TValue> }

constructor TBigIntegerDictionary<TValue>.Create(ACapacity: Integer);
begin
//  inherited Create(ACapacity, TBigIntegerComparer.Ordinal);
  inherited Create(ACapacity, GetBigIntegerEqualityComparer);
end;

(*
initialization
  TBigIntegerComparer.FOrdinal:= TOrdinalBigIntegerComparer.Create;

finalization
  TBigIntegerComparer(TBigIntegerComparer.FOrdinal).Free;
*)

end.
