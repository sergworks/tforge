{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ * ------------------------------------------------------- * }
{ *   # engine unit                                         * }
{ *   # exports: TBigNumber                                 * }
{ *********************************************************** }

unit tfNumbers;

{$I TFL.inc}

{$IFDEF TFL_LOG}
  {.$DEFINE LOG}
{$ENDIF}

{$IFDEF TFL_LIMB32_ASM86}
  {.$DEFINE LIMB32_ASM86}
{$ENDIF}

interface

uses SysUtils, tfTypes, tfLimbs
     {$IFDEF LOG}, Loggers{$ENDIF};

type
  PBigNumber = ^TBigNumber;
  PPBigNumber = ^PBigNumber;
  TBigNumber = record
  private const
    FUsedSize = SizeOf(Cardinal); // because SizeOf(FUsed) does not compile
  public type
{$IFDEF DEBUG}
    TLimbArray = array[0..7] of TLimb;
{$ELSE}
    TLimbArray = array[0..0] of TLimb;
{$ENDIF}

  public
    FVTable: Pointer;
{$IF SizeOf(Pointer) = 4}
    FReserved: Cardinal;          // to keep FLimbs field 8 byte aligned
{$IFEND}
    FRefCount: Integer;
    FCapacity: Cardinal;          // number of limbs allocated
    FSign: Integer;

    FUsed: Cardinal;              // number of limbs used
    FLimbs: TLimbArray;

// -- IBigNumber implementation

    class function QueryIntf(Inst: PBigNumber; const IID: TGUID;
                             out Obj): HResult; stdcall; static;
    class function Addref(Inst: PBigNumber): Integer; stdcall; static;
    class function Release(Inst: PBigNumber): Integer; stdcall; static;

    class function GetSign(Inst: PBigNumber): Integer; stdcall; static;

    class function CompareNumbers(A, B: PBigNumber): Integer; stdcall; static;
    class function CompareNumbersU(A, B: PBigNumber): Integer; stdcall; static;

    class function AddNumbers(A, B: PBigNumber; var R: PBigNumber): HResult; stdcall; static;
    class function AddNumbersU(A, B: PBigNumber; var R: PBigNumber): HResult; stdcall; static;

    class function SubNumbers(A, B: PBigNumber; var R: PBigNumber): HResult; stdcall; static;
    class function SubNumbersU(A, B: PBigNumber; var R: PBigNumber): HResult; stdcall; static;

    class function MulNumbers(A, B: PBigNumber; var R: PBigNumber): HResult; stdcall; static;
    class function MulNumbersU(A, B: PBigNumber; var R: PBigNumber): HResult; stdcall; static;

    class function DivModNumbers(A, B: PBigNumber; var Q, R: PBigNumber): HResult; stdcall; static;
    class function DivModNumbersU(A, B: PBigNumber; var Q, R: PBigNumber): HResult; stdcall; static;

    class function Power(A: PBigNumber; APower: Cardinal; var R: PBigNumber): HResult; stdcall; static;
    class function PowerU(A: PBigNumber; APower: Cardinal; var R: PBigNumber): HResult; stdcall; static;
    class function PowerMod(BaseValue, ExpValue, Modulo: PBigNumber; var R: PBigNumber): HResult; stdcall; static;

    class function ToWideString(A: PBigNumber; var S: WideString): HResult; stdcall; static;

    class function AddLimb(A: PBigNumber; Limb: TLimb; var R: PBigNumber): HResult; stdcall; static;
    class function AddLimbU(A: PBigNumber; Limb: TLimb; var R: PBigNumber): HResult; stdcall; static;
    class function AddIntLimb(A: PBigNumber; Limb: TIntLimb; var R: PBigNumber): HResult; stdcall; static;
    class function AddIntLimbU(A: PBigNumber; Limb: TIntLimb; var R: PBigNumber): HResult; stdcall; static;

    class function SubLimb(A: PBigNumber; Limb: TLimb; var R: PBigNumber): HResult; stdcall; static;
    class function SubLimbU(A: PBigNumber; Limb: TLimb; var R: PBigNumber): HResult; stdcall; static;
    class function SubIntLimb(A: PBigNumber; Limb: TIntLimb; var R: PBigNumber): HResult; stdcall; static;
    class function SubIntLimbU(A: PBigNumber; Limb: TIntLimb; var R: PBigNumber): HResult; stdcall; static;

// -- end of IBigNumber implementation

    class function FromWideString(var A: PBigNumber; const S: WideString): HResult; stdcall; static;
    class function FromWideStringU(var A: PBigNumber; const S: WideString): HResult; stdcall; static;

    class procedure Normalize(Inst: PBigNumber); static;

    class function AllocNumber(var A: PBigNumber; NLimbs: Cardinal = 0): HResult; static;

    class function AssignNumber(var A: PBigNumber; B: PBigNumber;
                                ASign: Integer = 0): HResult; static;

    class function AssignCardinal(var A: PBigNumber; const Value: Cardinal;
                                ASign: Integer = 0): HResult; static;

    class function AssignInteger(var A: PBigNumber; const Value: Integer;
                                ASign: Integer = 0): HResult; static;

    class function ToString(A: PBigNumber; var S: string): HResult; static;
    class function FromPCharU(var A: PBigNumber; const S: PChar; L: Integer): HResult; static;
    class function FromString(var A: PBigNumber; const S: string): HResult; static;
    class function FromStringU(var A: PBigNumber; const S: string): HResult; static;

    class function FromCardinal(var A: PBigNumber; Value: Cardinal): HResult; static;
    class function FromInteger(var A: PBigNumber; Value: Integer): HResult; static;

    class function ToCardinal(A: PBigNumber; var Value: Cardinal): HResult; static;
    class function ToInteger(A: PBigNumber; var Value: Integer): HResult; static;

    class function MulLimb(A: PBigNumber; Limb: TLimb; var R: PBigNumber): HResult; stdcall; static;
    class function MulLimbU(A: PBigNumber; Limb: TLimb; var R: PBigNumber): HResult; stdcall; static;

    class function DivModLimbU(A: PBigNumber; Limb: TLimb;
                               var Q: PBigNumber; var R: TLimb): HResult; stdcall; static;

    procedure Free; inline;
    class procedure FreeAndNil(var Inst: PBigNumber); static;

    function IsNegative: Boolean; inline;
    function IsZero: Boolean; inline;

    function AsString: string;

    function SelfCopy(Inst: PBigNumber): HResult;
    function SelfAddLimb(Value: TLimb): HResult;
    function SelfAddLimbU(Value: TLimb): HResult;

    function SelfSubLimbU(Value: TLimb): HResult;
    function SelfSubLimb(Value: TLimb): HResult;

    function SelfMulLimb(Value: TLimb): HResult;
    function SelfDivModLimbU(Value: TLimb; var Remainder: TLimb): HResult;
  end;

implementation

uses arrProcs;

const
  BigNumVTable: array[0..24] of Pointer = (
   @TBigNumber.QueryIntf,
   @TBigNumber.Addref,
   @TBigNumber.Release,

   @TBigNumber.GetSign,

   @TBigNumber.AddNumbers,
   @TBigNumber.AddNumbersU,
   @TBigNumber.SubNumbers,
   @TBigNumber.SubNumbersU,
   @TBigNumber.MulNumbers,
   @TBigNumber.MulNumbersU,
   @TBigNumber.DivModNumbers,
   @TBigNumber.DivModNumbersU,

   @TBigNumber.Power,
   @TBigNumber.PowerMod,

   @TBigNumber.ToWideString,

   @TBigNumber.AddLimb,
   @TBigNumber.AddLimbU,
   @TBigNumber.AddIntLimb,
   @TBigNumber.AddIntLimbU,

   @TBigNumber.SubLimb,
   @TBigNumber.SubLimbU,
   @TBigNumber.SubIntLimb,
   @TBigNumber.SubIntLimbU,

   @TBigNumber.MulLimb,
   @TBigNumber.MulLimbU
   );

const
  BigNumZero: TBigNumber = (
    FVTable: @BigNumVTable;
    FRefCount: -1;
    FCapacity: 0;
    FSign: 0;
    FUsed: 1;
{$IFDEF DEBUG}
    FLimbs: (0, 0, 0, 0, 0, 0, 0, 0);
{$ELSE}
    FLimbs: (0);
{$ENDIF}
    );

  BigNumOne: TBigNumber = (
    FVTable: @BigNumVTable;
    FRefCount: -1;
    FCapacity: 0;
    FSign: 0;
    FUsed: 1;
{$IFDEF DEBUG}
    FLimbs: (1, 0, 0, 0, 0, 0, 0, 0);
{$ELSE}
    FLimbs: (1);
{$ENDIF}
    );

  BigNumMinusOne: TBigNumber = (
    FVTable: @BigNumVTable;
    FRefCount: -1;
    FCapacity: 0;
    FSign: -1;
    FUsed: 1;
{$IFDEF DEBUG}
    FLimbs: (1, 0, 0, 0, 0, 0, 0, 0);
{$ELSE}
    FLimbs: (1);
{$ENDIF}
    );

class function TBigNumber.AssignNumber(var A: PBigNumber; B: PBigNumber;
                                       ASign: Integer = 0): HResult;
var
  Used: Cardinal;
  Tmp: PBigNumber;

begin
  Used:= B.FUsed;
  Result:= AllocNumber(Tmp, Used);
  if Result = S_OK then begin
    Move(B.FUsed, Tmp.FUsed, FUsedSize + Used * SizeOf(TLimb));
    if ASign = 0 then
      Tmp.FSign:= B.FSign
// to avoid negative zero
    else if (ASign < 0) and ((Used > 1) or (Tmp.FLimbs[0] <> 0)) then
      Tmp.FSign:= -1
    else Tmp.FSign:= 0;
    if A <> nil then Release(A);
    A:= Tmp;
  end;
end;

function TBigNumber.AsString: string;
begin
  Result:= '';
  ToString(@Self, Result);
end;

class function TBigNumber.CompareNumbers(A, B: PBigNumber): Integer;
begin
  if A.FSign xor B.FSign < 0
    then begin
      if (A.FSign >= 0)
        then Result:= 1
        else Result:= -1;
    end
    else begin
      Result:= A.FUsed - B.FUsed;
      if Result = 0 then
        Result:= arrCmp(@A.FLimbs, @B.FLimbs, A.FUsed);
      if (A.FSign < 0) then Result:= - Result;
    end;
end;

class function TBigNumber.CompareNumbersU(A, B: PBigNumber): Integer;
begin
  Result:= A.FUsed - B.FUsed;
  if Result = 0 then
    Result:= arrCmp(@A.FLimbs, @B.FLimbs, A.FUsed);
end;

class function TBigNumber.AddNumbers(A, B: PBigNumber; var R: PBigNumber): HResult;
var
  UsedA, UsedB: Cardinal;
  LimbsA, LimbsB: PLimb;
  Diff: Integer;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  LimbsA:= @A.FLimbs;
  LimbsB:= @B.FLimbs;

  if A = B then begin
    Result:= AllocNumber(Tmp, UsedA + 1);
    if Result <> TFL_S_OK then Exit;
    if arrShlOne(@A.FLimbs, @Tmp.FLimbs, A.FUsed) <> 0
      then
        Tmp.FUsed:= UsedA + 1
      else
        Tmp.FUsed:= UsedA;
    Tmp.FSign:= A.FSign;
    if (R <> nil) {and (R <> A)} then Release(R);
    R:= Tmp;
  end

  else { A <> B } begin
    if (UsedB = 1) and (LimbsB^ = 0) { B = 0 } then begin
      if R <> A then begin
        if R <> nil then Release(R);
        R:= A;
        AddRef(R);
      end;
      Result:= S_OK;
      Exit;
    end;

    if (UsedA = 1) and (LimbsA^ = 0) { A = 0 } then begin
      if R <> B then begin
        if R <> nil then Release(R);
        R:= B;
        AddRef(R);
      end;
      Result:= S_OK;
      Exit;
    end;

    if A.FSign xor B.FSign >= 0 then begin
// Values have the same sign - ADD lesser to greater

      if UsedA >= UsedB then begin
        Result:= AllocNumber(Tmp, UsedA + 1);
        if Result <> S_OK then Exit;
        if arrAdd(LimbsA, LimbsB, @Tmp.FLimbs, UsedA, UsedB)
          then
            Tmp.FUsed:= UsedA + 1
          else
            Tmp.FUsed:= UsedA;
        Tmp.FSign:= A.FSign;
      end
      else begin
        Result:= AllocNumber(Tmp, UsedB + 1);
        if Result <> S_OK then Exit;
        if arrAdd(LimbsB, LimbsA, @Tmp.FLimbs, UsedB, UsedA)
          then
            Tmp.FUsed:= UsedB + 1
          else
            Tmp.FUsed:= UsedB;
        Tmp.FSign:= B.FSign;
      end;

      if (R <> A) and (R <> B) and (R <> nil)
        then Release(R);
      R:= Tmp;

    end
    else begin
// Values have opposite signs - SUB lesser from greater

      if (UsedA = UsedB) then begin
        Diff:= arrCmp(LimbsA, LimbsB, UsedA);
        if Diff = 0 then begin
          if (R <> A) and (R <> B) and (R <> nil)
            then Release(R);
          R:= @BigNumZero;
          Result:= TFL_S_OK;
          Exit;
        end;
      end
      else
        Diff:= Ord(UsedA > UsedB) shl 1 - 1;

      if Diff > 0 then begin
        Result:= AllocNumber(Tmp, UsedA + 1);
        if Result <> TFL_S_OK then Exit;
        arrSub(LimbsA, LimbsB, @Tmp.FLimbs, UsedA, UsedB);
        Tmp.FUsed:= UsedA;
        Tmp.FSign:= A.FSign;
        Normalize(Tmp);

        if (R <> A) and (R <> B) and (R <> nil)
          then Release(R);
        R:= Tmp;
      end
      else begin
        Result:= AllocNumber(Tmp, UsedB + 1);
        if Result <> TFL_S_OK then Exit;
        arrSub(LimbsB, LimbsA, @Tmp.FLimbs, UsedB, UsedA);

        Tmp.FUsed:= UsedB;
        Tmp.FSign:= B.FSign;
        Normalize(Tmp);

        if (R <> A) and (R <> B) and (R <> nil)
          then Release(R);
        R:= Tmp;
      end;
    end;
  end;
  Result:= TFL_S_OK;
end;

class function TBigNumber.AddNumbersU(A, B: PBigNumber; var R: PBigNumber): HResult;
var
  UsedA, UsedB: Cardinal;
  LimbsA, LimbsB: PLimb;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  LimbsA:= @A.FLimbs;
  LimbsB:= @B.FLimbs;

  if A = B then begin
    Result:= AllocNumber(Tmp, UsedA + 1);
    if Result <> TFL_S_OK then Exit;
    if arrShlOne(@A.FLimbs, @Tmp.FLimbs, A.FUsed) <> 0
      then
        Tmp.FUsed:= UsedA + 1
      else
        Tmp.FUsed:= UsedA;

    if (R <> nil) and (R <> A) then Release(R);
    R:= Tmp;
  end

  else { A <> B } begin

    if (UsedB = 1) and (LimbsB^ = 0) { B = 0 } then begin
      if R <> A then begin
        if R <> nil then Release(R);
        R:= A;
        AddRef(R);
      end;
      Result:= S_OK;
      Exit;
    end;

    if (UsedA = 1) and (LimbsA^ = 0) { A = 0 } then begin
      if R <> B then begin
        if R <> nil then Release(R);
        R:= B;
        AddRef(R);
      end;
      Result:= S_OK;
      Exit;
    end;

    if UsedA >= UsedB then begin
      Result:= AllocNumber(Tmp, UsedA + 1);
      if Result <> TFL_S_OK then Exit;
      if arrAdd(LimbsA, LimbsB, @Tmp.FLimbs, UsedA, UsedB)
        then
          Tmp.FUsed:= UsedA + 1
        else
          Tmp.FUsed:= UsedA;

      if (R <> A) and (R <> B) and (R <> nil)
        then Release(R);
      R:= Tmp;

    end
    else begin
      Result:= AllocNumber(Tmp, UsedB + 1);
      if Result <> TFL_S_OK then Exit;
      if arrAdd(LimbsB, LimbsA, @Tmp.FLimbs, UsedB, UsedA)
        then
          Tmp.FUsed:= UsedB + 1
        else
          Tmp.FUsed:= UsedB;

      if (R <> A) and (R <> B) and (R <> nil)
        then Release(R);
      R:= Tmp;
    end
  end;
  Result:= TFL_S_OK;
end;

class function TBigNumber.SubNumbers(A, B: PBigNumber; var R: PBigNumber): HResult;
var
  UsedA, UsedB: Cardinal;
  LimbsA, LimbsB: PLimb;
  Diff: Integer;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  LimbsA:= @A.FLimbs;
  LimbsB:= @B.FLimbs;

  if A = B then begin
    if (R <> nil) and (R <> A) then Release(R);
    R:= @BigNumZero;
    Result:= S_OK;
    Exit;
  end

  else { A <> B } begin
    if (UsedB = 1) and (LimbsB^ = 0) { B = 0 } then begin
      if R <> A then begin
        if R <> nil then Release(R);
        R:= A;
        AddRef(R);
      end;
      Result:= S_OK;
      Exit;
    end;

    if (UsedA = 1) and (LimbsA^ = 0) { A = 0, B <> 0 } then begin

      Result:= AllocNumber(Tmp, B.FUsed);
      if Result <> S_OK then Exit;

      Move(B.FUsed, Tmp.FUsed, FUsedSize + B.FUsed * SizeOf(TLimb));
      Tmp.FSign:= not B.FSign;

      if (R <> nil) and (R <> A) and (R <> B) then Release(R);
      R:= Tmp;
      Result:= S_OK;
      Exit;
    end;

    if A.FSign xor B.FSign >= 0 {Sign(A) = Sign(B)} then begin
// Values have the same sign - SUB lesser from greater
      if (UsedA = UsedB) then begin
        Diff:= arrCmp(@A.FLimbs, @B.FLimbs, UsedA);
        if Diff = 0 then begin
          if (R <> A) and (R <> B) and (R <> nil)
            then Release(R);
          R:= @BigNumZero;
          Result:= S_OK;
          Exit;
        end;
      end
      else
        Diff:= Ord(UsedA > UsedB) shl 1 - 1;

      if Diff > 0 { Abs(A) > Abs(B) } then begin
        Result:= AllocNumber(Tmp, UsedA + 1);
        if Result <> S_OK then Exit;
        arrSub(LimbsA, LimbsB, @Tmp.FLimbs, UsedA, UsedB);
        Tmp.FUsed:= UsedA;
        Tmp.FSign:= A.FSign;
        Normalize(Tmp);
      end
      else { Abs(A) < Abs(B) } begin
        Result:= AllocNumber(Tmp, UsedB + 1);
        if Result <> S_OK then Exit;
        arrSub(LimbsB, LimbsA, @Tmp.FLimbs, UsedB, UsedA);

        Tmp.FUsed:= UsedB;
        Tmp.FSign:= not B.FSign;
        Normalize(Tmp);

      end;

      if (R <> A) and (R <> B) and (R <> nil)
        then Release(R);
      R:= Tmp;

    end {Sign(A) = Sign(B)}
    else {Sign(A) <> Sign(B)} begin
// Values have opposite signs - ADD lesser to greater

      if UsedA >= UsedB then begin
        Result:= AllocNumber(Tmp, UsedA + 1);
        if Result <> S_OK then Exit;
        if arrAdd(LimbsA, LimbsB, @Tmp.FLimbs, UsedA, UsedB)
          then
            Tmp.FUsed:= UsedA + 1
          else
            Tmp.FUsed:= UsedA;
      end
      else begin
        Result:= AllocNumber(Tmp, UsedB + 1);
        if Result <> S_OK then Exit;
        if arrAdd(LimbsB, LimbsA, @Tmp.FLimbs, UsedB, UsedA)
          then
            Tmp.FUsed:= UsedB + 1
          else
            Tmp.FUsed:= UsedB;
      end;

// знак разности равен знаку первого операнда
      Tmp.FSign:= A.FSign;

      if (R <> A) and (R <> B) and (R <> nil)
        then Release(R);
      R:= Tmp;

    end {Sign(A) <> Sign(B)};
  end { A <> B };
  Result:= S_OK;
end;

class function TBigNumber.SubNumbersU(A, B: PBigNumber; var R: PBigNumber): HResult;
var
  UsedA, UsedB: Cardinal;
  LimbsA, LimbsB: PLimb;
  Diff: Integer;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  LimbsA:= @A.FLimbs;
  LimbsB:= @B.FLimbs;

  if A = B then begin  { A - B = 0 }
    if (R <> nil) and (R <> A) then Release(R);
    R:= @BigNumZero;
    Result:= S_OK;
    Exit;
  end

  else { A <> B } begin
    if (UsedB = 1) and (LimbsB^ = 0) { B = 0 } then begin
      if R <> A then begin
        if R <> nil then Release(R);
        R:= A;
        AddRef(R);
      end;
      Result:= S_OK;
      Exit;
    end;

    if (UsedA = 1) and (LimbsA^ = 0) { A = 0, B <> 0 } then begin
      Result:= TFL_E_INVALIDSUB;
      Exit;
    end;

// Subtract lesser from greater
    if (UsedA = UsedB) then begin
      Diff:= arrCmp(@A.FLimbs, @B.FLimbs, UsedA);
      if Diff = 0 then begin
        if (R <> A) and (R <> B) and (R <> nil)
          then Release(R);
        R:= @BigNumZero;
        Result:= S_OK;
        Exit;
      end;
    end
    else
      Diff:= Ord(UsedA > UsedB) shl 1 - 1;

    if Diff > 0 { A > B } then begin
      Result:= AllocNumber(Tmp, UsedA + 1);
      if Result <> S_OK then Exit;
      arrSub(LimbsA, LimbsB, @Tmp.FLimbs, UsedA, UsedB);
      Tmp.FUsed:= UsedA;
      Normalize(Tmp);
      if (R <> A) and (R <> B) and (R <> nil)
        then Release(R);
      R:= Tmp;
    end
    else { A < B } begin
      Result:= TFL_E_INVALIDSUB;
      Exit;
    end;
  end;
  Result:= S_OK;
end;

class function TBigNumber.MulNumbers(A, B: PBigNumber; var R: PBigNumber): HResult;
var
  UsedA, UsedB, Used: Cardinal;
  Tmp: PBigNumber;

begin
  if A.IsZero or B.IsZero then begin
    if (R <> nil) then Release(R);
    R:= @BigNumZero;
    Result:= TFL_S_OK;
  end
  else begin
    Tmp:= nil;

    UsedA:= A^.FUsed;
    UsedB:= B^.FUsed;
    Used:= UsedA + UsedB;

    Result:= AllocNumber(Tmp, Used);
    if Result <> TFL_S_OK then Exit;

    if UsedA >= UsedB
      then
        arrMul(@A.FLimbs, @B.FLimbs, @Tmp.FLimbs, UsedA, UsedB)
      else
        arrMul(@B.FLimbs, @A.FLimbs, @Tmp.FLimbs, UsedB, UsedA);

    Tmp.FSign:= A.FSign xor B.FSign;
    Tmp.FUsed:= Used;
    Normalize(Tmp);
    if (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

class function TBigNumber.MulNumbersU(A, B: PBigNumber; var R: PBigNumber): HResult;
var
  UsedA, UsedB, Used: Cardinal;
  Tmp: PBigNumber;

begin
  if A.IsZero or B.IsZero then begin
    if (R <> nil) then Release(R);
    R:= @BigNumZero;
    Result:= TFL_S_OK;
  end
  else begin
    Tmp:= nil;

    UsedA:= A^.FUsed;
    UsedB:= B^.FUsed;
    Used:= UsedA + UsedB;

    Result:= AllocNumber(Tmp, Used);
    if Result <> TFL_S_OK then Exit;

    if UsedA >= UsedB
      then
        arrMul(@A.FLimbs, @B.FLimbs, @Tmp.FLimbs, UsedA, UsedB)
      else
        arrMul(@B.FLimbs, @A.FLimbs, @Tmp.FLimbs, UsedB, UsedA);

    Tmp.FUsed:= Used;
    Normalize(Tmp);
    if (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

function SeniorBit(Value: TLimb): Integer;
{$IFDEF LIMB32_ASM86}
asm
        OR    EAX,EAX
        JZ    @@Done
        BSR   EAX,EAX
        INC   EAX
@@Done:
end;
{$ELSE}
begin
  Result:= 0;
  while Value <> 0 do begin
    Value:= Value shr 1;
    Inc(Result);
  end;
end;
{$ENDIF}

class function TBigNumber.DivModLimbU(A: PBigNumber; Limb: TLimb;
                          var Q: PBigNumber; var R: TLimb): HResult;
var
  Used: Cardinal;
  Tmp: PBigNumber;

begin
  Used:= A.FUsed;
  Result:= AllocNumber(Tmp, Used);
  if Result = S_OK then begin
    R:= arrDivModLimb(@A.FLimbs, @Tmp.FLimbs, Used, Limb);
    if Tmp.FLimbs[Used - 1] = 0 then Dec(Used);
    Tmp.FUsed:= Used;
    if (Q <> A) and (Q <> nil) then Release(Q);
    Q:= Tmp;
  end;
end;

class function TBigNumber.DivModNumbers(A, B: PBigNumber;
                                        var Q, R: PBigNumber): HResult;
var
  Cond: Boolean;
  Diff: Integer;
  Dividend, Divisor: PBigNumber;
  Quotient, Remainder: PBigNumber;
  Limb: TLimb;
  UsedA, UsedB, UsedD, UsedQ: Cardinal;
  Shift: Integer;

begin
  if B.IsZero then begin
    Result:= TFL_E_ZERODIVIDE;
    Exit;
  end;

// Cond = Abs(A) < Abs(B)
  Cond:= A.IsZero;

  if not Cond then begin
    UsedA:= A.FUsed;
    UsedB:= B.FUsed;
    Cond:= (UsedA < UsedB);
    if not Cond and (UsedA = UsedB) then begin
      Diff:= arrCmp(@A.FLimbs, @B.FLimbs, UsedB);

// if Abs(dividend A) = Abs(divisor B) then Q:= +/-1, R:= 0;
      if Diff = 0 then begin
        if (R <> nil) and (R <> A) and (R <> B) and (R <> Q)
          then Release(R);
        R:= @BigNumZero;
        if (Q <> nil) and (Q <> A) and (Q <> B)
          then Release(Q);
        if A.FSign xor B.FSign < 0
          then Q:= @BigNumMinusOne
          else Q:= @BigNumOne;
        Result:= TFL_S_OK;
        Exit;
      end
      else if Diff < 0 then Cond:= True;
    end;
  end;

// if dividend (A) < divisor (B) then Q:= 0, R:= A
  if Cond then begin
//    Q.AssignLimb(0);
    if (Q <> nil) and (Q <> A) and (Q <> B) and (Q <> R)
      then Release(Q);
    Q:= @BigNumZero;
//  R.Assign(A);
    if (R <> A) then begin
      if (R <> nil) and (R <> B)
        then Release(R);
      R:= A;
    end;
    Result:= S_OK;
    Exit;
  end;

  Result:= AllocNumber(Quotient, UsedA - UsedB + 1);
  if Result <> S_OK then Exit;

  Result:= AllocNumber(Remainder, UsedB);
  if Result <> S_OK then Exit;

// divisor (B) has only 1 limb
  if (UsedB = 1) then begin
    if (UsedA = 1) then begin
      Quotient.FLimbs[0]:= A.FLimbs[0] div B.FLimbs[0];
      Remainder.FLimbs[0]:= A.FLimbs[0] mod B.FLimbs[0];
    end
    else begin
      Remainder.FLimbs[0]:= arrDivModLimb(@A.FLimbs, @Quotient.FLimbs, UsedA, B.FLimbs[0]);
      if Quotient.FLimbs[UsedA - 1] = 0 then Dec(UsedA);
    end;

    Quotient.FUsed:= UsedA;
    Remainder.FUsed:= 1;

// -5 div 2 = -2, -5 mod 2 = -1
//  5 div -2 = -2, 5 mod -2 = 1
// -5 div -2 = 2, -5 mod -2 = -1

    if A.FSign xor B.FSign >= 0
//   or ((UsedA = 1) and (Q.FData[1] = 0)) never happens
//      since dividend > divisor here
      then
// dividend and divisor have the same sign
        Quotient.FSign:= 0
      else
        Quotient.FSign:= -1;

// remainder has the same sign as dividend if nonzero
    if (A.FSign >= 0) or (Remainder.FLimbs[0] = 0)
      then
        Remainder.FSign:= 0
      else
        Remainder.FSign:= -1;

    if (Q <> nil) and (Q <> A) and (Q <> B) and (Q <> R)
      then Release(Q);

    Q:= Quotient;

    if (R <> nil) and (R <> A) and (R <> B)
      then Release(R);

    R:= Remainder;

//    Result:= S_OK;
    Exit;
  end;

// Now the real thing - big number division of length (used) > 1

// create normalized divisor by shifting the divisor B left
  Limb:= B.FLimbs[UsedB - 1];
  Shift:= TLimbInfo.BitSize - SeniorBit(Limb);

  Result:= AllocNumber(Divisor, UsedB);
  if Result <> S_OK then Exit;

  Divisor.FUsed:= UsedB;
  arrShlShort(@B.FLimbs, @Divisor.FLimbs, UsedB, Shift);

// create normalized dividend (same shift as divisor)

  Result:= AllocNumber(Dividend, UsedA + 1);
  if Result <> S_OK then Exit;
  UsedD:= arrShlShort(@A.FLimbs, @Dividend.FLimbs, UsedA, Shift);

// normalized dividend is 1 limb longer than non-normalized one (A);
//   if it is actually not longer, just zero senior limb
  if UsedD = UsedA then
    Dividend.FLimbs[UsedA]:= 0;
  Dividend.FUsed:= UsedA + 1;

  UsedQ:= UsedA - UsedB + 1;
//  Q.SetCapacity(UsedQ);

// perform normalized division
  arrNormDivMod(@Dividend.FLimbs, @Divisor.FLimbs, @Quotient.FLimbs,
                UsedA + 1, UsedB);
// and shift the remaider right
  arrShrShort(@Dividend.FLimbs, @Remainder.FLimbs, UsedB, Shift);

  Quotient.FUsed:= UsedQ;
  Remainder.FUsed:= UsedB;

  if A.FSign xor B.FSign >= 0
    then
      Quotient.FSign:= 0
    else
      Quotient.FSign:= -1;

// remainder has the same sign as dividend if nonzero
  if (A.FSign >= 0) or ((Remainder.FUsed = 0) and (Remainder.FLimbs[0] = 0))
    then
      Remainder.FSign:= 0
    else
      Remainder.FSign:= -1;

  Normalize(Quotient);
  Normalize(Remainder);

    if (Q <> nil) and (Q <> A) and (Q <> B) and (Q <> R)
      then Release(Q);

    Q:= Quotient;

    if (R <> nil) and (R <> A) and (R <> B)
      then Release(R);

    R:= Remainder;

    Result:= S_OK;
end;

class function TBigNumber.DivModNumbersU(A, B: PBigNumber; var Q, R: PBigNumber): HResult;
var
  Cond: Boolean;
  Diff: Integer;
  Dividend, Divisor: PBigNumber;
  Quotient, Remainder: PBigNumber;
  Limb: TLimb;
  UsedA, UsedB, UsedD, UsedQ: Cardinal;
  Shift: Integer;

begin
  if B.IsZero then begin
    Result:= TFL_E_ZERODIVIDE;
    Exit;
  end;

// Cond = Abs(A) < Abs(B)
  Cond:= A.IsZero;

  if not Cond then begin
    UsedA:= A.FUsed;
    UsedB:= B.FUsed;
    Cond:= (UsedA < UsedB);
    if not Cond and (UsedA = UsedB) then begin
      Diff:= arrCmp(@A.FLimbs, @B.FLimbs, UsedB);

// if Abs(dividend A) = Abs(divisor B) then Q:= +/-1, R:= 0;
      if Diff = 0 then begin
        if (R <> nil) and (R <> A) and (R <> B) and (R <> Q)
          then Release(R);
        R:= @BigNumZero;
        if (Q <> nil) and (Q <> A) and (Q <> B)
          then Release(Q);
//        if A.FSign xor B.FSign < 0
//          then Q:= @BigNumMinusOne
//          else
        Q:= @BigNumOne;
        Result:= TFL_S_OK;
        Exit;
      end
      else if Diff < 0 then Cond:= True;
    end;
  end;

// if dividend (A) < divisor (B) then Q:= 0, R:= A
  if Cond then begin
// Q:= 0
    if (Q <> nil) and (Q <> A) and (Q <> B) and (Q <> R)
      then Release(Q);
    Q:= @BigNumZero;
// R:= A
    if (R <> A) then begin
      if (R <> nil) and (R <> B)
        then Release(R);
      R:= A;
    end;
    Result:= TFL_S_OK;
    Exit;
  end;

  Result:= AllocNumber(Quotient, UsedA - UsedB + 1);
  if Result <> S_OK then Exit;

  Result:= AllocNumber(Remainder, UsedB);
  if Result <> S_OK then Exit;

// divisor (B) has only 1 limb
  if (UsedB = 1) then begin
    if (UsedA = 1) then begin
      Quotient.FLimbs[0]:= A.FLimbs[0] div B.FLimbs[0];
      Remainder.FLimbs[0]:= A.FLimbs[0] mod B.FLimbs[0];
    end
    else begin
      Remainder.FLimbs[0]:= arrDivModLimb(@A.FLimbs, @Quotient.FLimbs, UsedA, B.FLimbs[0]);
      if Quotient.FLimbs[UsedA - 1] = 0 then Dec(UsedA);
    end;

    Quotient.FUsed:= UsedA;
    Remainder.FUsed:= 1;

    if (Q <> nil) and (Q <> A) and (Q <> B) and (Q <> R)
      then Release(Q);

    Q:= Quotient;

    if (R <> nil) and (R <> A) and (R <> B)
      then Release(R);

    R:= Remainder;

    Result:= S_OK;
    Exit;
  end;

// Now the real thing - big number division of length (used) > 1

// create normalized divisor by shifting the divisor B left
  Limb:= B.FLimbs[UsedB - 1];
  Shift:= TLimbInfo.BitSize - SeniorBit(Limb);

  Result:= AllocNumber(Divisor, UsedB);
  if Result <> S_OK then Exit;

  Divisor.FUsed:= UsedB;
  arrShlShort(@B.FLimbs, @Divisor.FLimbs, UsedB, Shift);

// create normalized dividend (same shift as divisor)

  Result:= AllocNumber(Dividend, UsedA + 1);
  if Result <> S_OK then Exit;
  UsedD:= arrShlShort(@A.FLimbs, @Dividend.FLimbs, UsedA, Shift);

// normalized dividend is 1 limb longer than non-normalized one (A);
//   if it is actually not longer, just zero senior limb
  if UsedD = UsedA then
    Dividend.FLimbs[UsedA]:= 0;
  Dividend.FUsed:= UsedA + 1;

  UsedQ:= UsedA - UsedB + 1;

// perform normalized division
  arrNormDivMod(@Dividend.FLimbs, @Divisor.FLimbs, @Quotient.FLimbs,
                UsedA + 1, UsedB);
// and shift the remaider right
  arrShrShort(@Dividend.FLimbs, @Remainder.FLimbs, UsedB, Shift);

  Quotient.FUsed:= UsedQ;
  Remainder.FUsed:= UsedB;

  Normalize(Quotient);
  Normalize(Remainder);

  if (Q <> nil) and (Q <> A) and (Q <> B) and (Q <> R)
    then Release(Q);
  Q:= Quotient;

  if (R <> nil) and (R <> A) and (R <> B)
    then Release(R);
  R:= Remainder;

  Result:= S_OK;
end;

class function TBigNumber.AddIntLimb(A: PBigNumber; Limb: TIntLimb;
                                     var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  AbsLimb: TLimb;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  AbsLimb:= Abs(Limb);
  Result:= AllocNumber(Tmp, UsedA + 1);
  if Result = S_OK then begin
    if A.FSign xor Integer(Limb) >= 0 then begin
      if arrAddLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA)
        then Tmp.FUsed:= UsedA + 1
        else Tmp.FUsed:= UsedA;
      Tmp.FSign:= A.FSign;
    end
    else begin
      if A.FUsed = 1 then begin
// Assert(Tmp.FUsed = 1)
        if A.FLimbs[0] < AbsLimb then begin
          Tmp.FLimbs[0]:= AbsLimb - A.FLimbs[0];
          Tmp.FSign:= not A.FSign;
        end
        else begin
          Tmp.FLimbs[0]:= A.FLimbs[0] - AbsLimb;
          if Tmp.FLimbs[0] <> 0
            then Tmp.FSign:= A.FSign;
        end;
      end
      else begin { UsedA > 1 }
        arrSubLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA);
        if Tmp.FLimbs[UsedA - 1] = 0
          then Tmp.FUsed:= UsedA - 1
          else Tmp.FUsed:= UsedA;
        Tmp.FSign:= A.FSign;
      end;
    end;
    if (R <> A) and (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

class function TBigNumber.AddIntLimbU(A: PBigNumber; Limb: TIntLimb;
                                      var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  AbsLimb: TLimb;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  AbsLimb:= Abs(Limb);
  if Limb >= 0 then begin
    Result:= AllocNumber(Tmp, UsedA + 1);
    if Result = TFL_S_OK then begin
      if arrAddLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA)
        then Tmp.FUsed:= UsedA + 1
        else Tmp.FUsed:= UsedA;
    end;
  end
  else if (A.FUsed = 1) then begin
    if A.FLimbs[0] >= AbsLimb then begin
      Result:= AllocNumber(Tmp, 1);
      if Result = TFL_S_OK then begin
        Tmp.FLimbs[0]:= A.FLimbs[0] - AbsLimb;
//        Tmp.FUsed:= 1;
      end
    end
    else
      Result:= TFL_E_INVALIDSUB;
  end
  else begin
    Result:= AllocNumber(Tmp, UsedA);
    if Result = TFL_S_OK then begin
      arrSubLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA);
      if Tmp.FLimbs[UsedA - 1] = 0
        then Tmp.FUsed:= UsedA - 1
        else Tmp.FUsed:= UsedA;
    end;
  end;
  if Result = TFL_S_OK then begin
    if (R <> A) and (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

class function TBigNumber.AddLimb(A: PBigNumber; Limb: TLimb;
                                  var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  Result:= AllocNumber(Tmp, UsedA + 1);
  if Result = TFL_S_OK then begin
    if A.FSign >= 0 then begin
      if arrAddLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA)
        then Tmp.FUsed:= UsedA + 1
        else Tmp.FUsed:= UsedA;
    end
    else begin                               // A.FSign < 0
      if UsedA = 1 then begin
        if A.FLimbs[0] <= Limb then begin
          Tmp.FLimbs[0]:= Limb - A.FLimbs[0];
        end
        else begin
          Tmp.FLimbs[0]:= A.FLimbs[0] - Limb;
          Tmp.FSign:= -1;
        end;
      end
      else begin { UsedA > 1 }
        arrSubLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA);
        if Tmp.FLimbs[UsedA - 1] = 0
          then Tmp.FUsed:= UsedA - 1
          else Tmp.FUsed:= UsedA;
        Tmp.FSign:= -1;
      end;
    end;
    if (R <> A) and (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

class function TBigNumber.AddLimbU(A: PBigNumber; Limb: TLimb;
                                   var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  Result:= AllocNumber(Tmp, UsedA + 1);
  if Result = TFL_S_OK then begin
    if arrAddLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA)
      then Tmp.FUsed:= UsedA + 1
      else Tmp.FUsed:= UsedA;

    if (R <> A) and (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

function TBigNumber.SelfCopy(Inst: PBigNumber): HResult;
begin
  if FCapacity <= Inst.FUsed then
    Result:= TFL_E_NOMEMORY
  else begin
    Move(Inst.FSign, FSign, Inst.FUsed * SizeOf(TLimb) + 2 * FUsedSize);
    Result:= TFL_S_OK;
  end;
end;

function TBigNumber.SelfDivModLimbU(Value: TLimb;
                                    var Remainder: TLimb): HResult;
var
  Used: Cardinal;

begin
  Used:= FUsed;
  Remainder:= arrSelfDivModLimb(@FLimbs, Used, Value);
  if (Used > 1) and (FLimbs[Used - 1] = 0) then
    FUsed:= Used - 1;
  Result:= TFL_S_OK;
end;

function TBigNumber.SelfMulLimb(Value: TLimb): HResult;
begin
  if Value = 0 then begin
    FUsed:= 1;
    FSign:= 0;
    FLimbs[0]:= 0;
    Result:= TFL_S_OK;
  end
  else if FCapacity <= FUsed
    then Result:= TFL_E_NOMEMORY
  else begin
    if arrSelfMulLimb(@FLimbs, Value, FUsed) then Inc(FUsed);
    Result:= TFL_S_OK;
  end;
end;

function TBigNumber.SelfAddLimb(Value: TLimb): HResult;
var
  Used: Cardinal;
//  Minus: Boolean;

begin
  Used:= FUsed;
  if FCapacity <= Used then
    Result:= TFL_E_NOMEMORY
  else begin
    if (FSign >= 0) then begin
      if arrSelfAddLimb(@FLimbs, Value, Used) then
        FUsed:= Used + 1;
    end
    else if (Used > 1) then begin
  // sign = minus, used > 1
      arrSelfSubLimb(@FLimbs, Value, Used);
      if FLimbs[Used - 1] = 0 then begin
        FUsed:= Used - 1;
      end;
    end
    else begin
  // sign = minus, used = 1
      if FLimbs[0] > Value then begin
        Dec(FLimbs[0], Value);
      end
      else begin
        FLimbs[0]:= Value - FLimbs[0];
        FSign:= 0;     // sign changed to plus
      end;
    end;
    Result:= TFL_S_OK;
  end;
end;

function TBigNumber.SelfAddLimbU(Value: TLimb): HResult;
var
  Used: Cardinal;

begin
  Used:= FUsed;
  if FCapacity <= Used then
    Result:= TFL_E_NOMEMORY
  else begin
    if arrSelfAddLimb(@FLimbs, Value, Used) then
      FUsed:= Used + 1;
    Result:= TFL_S_OK;
  end;
end;

function TBigNumber.SelfSubLimbU(Value: TLimb): HResult;
var
  Used: Cardinal;

begin
  Used:= FUsed;
  if (Used > 1) then begin
    arrSelfSubLimb(@FLimbs, Value, Used);
    if FLimbs[Used - 1] = 0 then begin
      FUsed:= Used - 1;
      Result:= TFL_S_OK;
    end;
  end
  else begin
    if FLimbs[0] >= Value then begin
      Dec(FLimbs[0], Value);
      Result:= TFL_S_OK;
    end
    else
      Result:= TFL_E_INVALIDSUB;
  end;
end;

function TBigNumber.SelfSubLimb(Value: TLimb): HResult;
var
  Used: Cardinal;

begin
  Used:= FUsed;

  if FSign < 0 then begin
    if FCapacity <= Used then
      Result:= TFL_E_NOMEMORY
    else begin
      if arrSelfAddLimb(@FLimbs, Value, Used) then
        FUsed:= Used + 1;
      Result:= TFL_S_OK;
    end;
  end
  else begin
    if (Used > 1) then begin
// sign = plus, used > 1
      arrSelfSubLimb(@FLimbs, Value, Used);
      if FLimbs[Used - 1] = 0 then begin
        FUsed:= Used - 1;
      end;
    end
    else begin
// sign = plus, used = 1
      if FLimbs[0] >= Value then begin
        Dec(FLimbs[0], Value);
      end
      else begin
        FLimbs[0]:= Value - FLimbs[0];
        FSign:= -1;
      end;
    end;
    Result:= TFL_S_OK;
  end;
end;

class function TBigNumber.SubLimb(A: PBigNumber; Limb: TLimb;
                                  var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  Result:= AllocNumber(Tmp, UsedA);
  if Result = S_OK then begin
    if (A.FSign < 0) then begin
      if arrAddLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA)
        then Tmp.FUsed:= UsedA + 1
        else Tmp.FUsed:= UsedA;
      Tmp.FSign:= -1;
    end
    else begin
      if (UsedA > 1) then begin                   // A.FSign >= 0
        arrSubLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA);
        if Tmp.FLimbs[UsedA - 1] = 0
          then Tmp.FUsed:= UsedA - 1
          else Tmp.FUsed:= UsedA;
      end
      else begin
        if (A.FLimbs[0] >= Limb) then begin    // A.FSign >= 0, A.FUsed = 1
           Tmp.FLimbs[0]:= A.FLimbs[0] - Limb;
        end
        else begin
          Tmp.FLimbs[0]:= Limb - A.FLimbs[0];
          Tmp.FSign:= -1;
        end;
        Tmp.FUsed:= 1;
      end;
    end;
    if (R <> A) and (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

class function TBigNumber.SubLimbU(A: PBigNumber; Limb: TLimb;
                                   var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  if (UsedA = 1) then begin
    if A.FLimbs[0] >= Limb then begin
      Result:= AllocNumber(Tmp, 1);
      if Result = S_OK then begin
        Tmp.FUsed:= 1;
        Tmp.FLimbs[0]:= A.FLimbs[0] - Limb;
        if (R <> A) and (R <> nil) then Release(R);
        R:= Tmp;
      end;
    end
    else begin { A < Limb }
      Result:= TFL_E_INVALIDSUB;
    end;
  end
  else begin { UsedA > 1 }
    Result:= AllocNumber(Tmp, UsedA);
    if Result = S_OK then begin
      arrSubLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA);
      if Tmp.FLimbs[UsedA - 1] = 0
        then Tmp.FUsed:= UsedA - 1
        else Tmp.FUsed:= UsedA;
      if (R <> A) and (R <> nil) then Release(R);
      R:= Tmp;
    end;
  end;
end;

class function TBigNumber.SubIntLimb(A: PBigNumber; Limb: TIntLimb;
                                     var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  AbsLimb: TLimb;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  AbsLimb:= Abs(Limb);
  Result:= AllocNumber(Tmp, UsedA + 1);
  if Result = S_OK then begin
    if A.FSign xor Integer(Limb) < 0 then begin
      if arrAddLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA)
        then Tmp.FUsed:= UsedA + 1
        else Tmp.FUsed:= UsedA;
      Tmp.FSign:= A.FSign;
    end
    else begin
      if A.FUsed = 1 then begin
// Assert(Tmp.FUsed = 1)
        if A.FLimbs[0] < AbsLimb then begin
          Tmp.FLimbs[0]:= AbsLimb - A.FLimbs[0];
          Tmp.FSign:= not A.FSign;
        end
        else begin
          Tmp.FLimbs[0]:= A.FLimbs[0] - AbsLimb;
          if Tmp.FLimbs[0] <> 0
            then Tmp.FSign:= A.FSign;
        end;
      end
      else begin { UsedA > 1 }
        arrSubLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA);
        if Tmp.FLimbs[UsedA - 1] = 0
          then Tmp.FUsed:= UsedA - 1
          else Tmp.FUsed:= UsedA;
        Tmp.FSign:= A.FSign;
      end;
    end;
    if (R <> A) and (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

class function TBigNumber.SubIntLimbU(A: PBigNumber; Limb: TIntLimb;
                                      var R: PBigNumber): HResult;
var
  UsedA: Cardinal;
  AbsLimb: TLimb;
  Tmp: PBigNumber;

begin
  UsedA:= A.FUsed;
  AbsLimb:= Abs(Limb);
  if Limb < 0 then begin
    Result:= AllocNumber(Tmp, UsedA + 1);
    if Result = TFL_S_OK then begin
      if arrAddLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA)
        then Tmp.FUsed:= UsedA + 1
        else Tmp.FUsed:= UsedA;
    end;
  end
  else if (UsedA = 1) then begin
    if A.FLimbs[0] >= AbsLimb then begin
      Result:= AllocNumber(Tmp, 1);
      if Result = TFL_S_OK then begin
        Tmp.FUsed:= 1;
        Tmp.FLimbs[0]:= A.FLimbs[0] - AbsLimb;
        if (R <> A) and (R <> nil) then Release(R);
        R:= Tmp;
      end;
    end
    else begin { A < Limb }
      Result:= TFL_E_INVALIDSUB;
    end;
  end
  else begin { UsedA > 1 }
    Result:= AllocNumber(Tmp, UsedA);
    if Result = TFL_S_OK then begin
      arrSubLimb(@A.FLimbs, AbsLimb, @Tmp.FLimbs, UsedA);
      if Tmp.FLimbs[UsedA - 1] = 0
        then Tmp.FUsed:= UsedA - 1
        else Tmp.FUsed:= UsedA;
    end;
  end;
  if Result = TFL_S_OK then begin
    if (R <> A) and (R <> nil) then Release(R);
    R:= Tmp;
  end;
end;

class function TBigNumber.AssignCardinal(var A: PBigNumber;
               const Value: Cardinal; ASign: Integer = 0): HResult;
const
  CardSize = SizeOf(Cardinal) div SizeOf(TLimb);

var
  Tmp: PBigNumber;

begin
{$IF CardSize = 0}
  Result:= TFL_E_NOTIMPL;
{$ELSE}
  Result:= AllocNumber(Tmp, CardSize);
  if Result <> S_OK then Exit;
  {$IF CardSize = 1}
    Tmp.FLimbs[0]:= Value;
  {$ELSE}
    Move(Value, Tmp.FLimbs, SizeOf(Cardinal));
    Tmp.FUsed:= CardSize;
    Normalize(Tmp);
  {$IFEND}
  if ASign < 0 then Tmp.FSign:= -1;
  if (A <> nil) then Release(A);
  A:= Tmp;
{$IFEND}
end;

class function TBigNumber.AssignInteger(var A: PBigNumber;
               const Value: Integer; ASign: Integer = 0): HResult;

const
  IntSize = SizeOf(Integer) div SizeOf(TLimb);

var
  Tmp: PBigNumber;
{$IF IntSize <> 1}
  AbsValue: Integer;
{$IFEND}

begin
{$IF IntSize = 0}
  Result:= TFL_E_NOTIMPL;
{$ELSE}
  Result:= AllocNumber(Tmp, IntSize);
  if Result <> S_OK then Exit;
  {$IF IntSize = 1}
    Tmp.FLimbs[0]:= Abs(Value);
  {$ELSE}
    AbsValue:= Abs(Value);
    Move(AbsValue, Tmp.FLimbs, SizeOf(Integer));
    Tmp.FUsed:= IntSize;
    Normalize(Tmp);
  {$IFEND}
  if (ASign <= 0) and ((Value < 0) or (ASign < 0)) then Tmp.FSign:= -1;
  if (A <> nil) then Release(A);
  A:= Tmp;
  Result:= S_OK;
{$IFEND}
end;

class function TBigNumber.ToCardinal(A: PBigNumber; var Value: Cardinal): HResult;
const
  CardSize = SizeOf(Cardinal) div SizeOf(TLimb);

begin
{$IF CardSize = 0}
  Result:= TFL_E_NOTIMPL;
{$ELSIF CardSize = 1}
  if (A.FUsed = 1) and (A.FSign >= 0) then begin
    Value:= A.FLimbs[0];
    Result:= TFL_S_OK;
  end
  else
    Result:= TFL_E_INVALIDARG;
{$ELSE}
  if (A.FUsed <= CardSize) and (A.FSign >= 0) then begin
    Value:= 0;
    Move(A.FLimbs, Value, A.FUsed * SizeOf(TLimb));
    Result:= TFL_S_OK;
  end
  else
    Result:= TFL_E_INVALIDARG;
{$IFEND}
end;

class function TBigNumber.ToInteger(A: PBigNumber; var Value: Integer): HResult;
const
  IntSize = SizeOf(Integer) div SizeOf(TLimb);

{$IF IntSize > 1}
var
  Tmp: Integer;
{$IFEND}

begin
{$IF IntSize <= 0}
  Result:= TFL_E_NOTIMPL;
{$ELSIF IntSize = 1}
  if (A.FUsed = 1) then begin
    if FSign >= 0 then begin
      if (A.FLimbs[0] <= Cardinal(MaxInt)) then begin
        Value:= A.FLimbs[0];
        Result:= TFL_S_OK;
      end
      else
        Result:= TFL_E_INVALIDARG;
    end
    else begin
      if (A.FLimbs[0] <= Cardinal(MaxInt)) then begin
        Value:= - Integer(A.FLimbs[0]);
        Result:= TFL_S_OK;
      end
      else if (A.FLimbs[0] = Cardinal(MinInt)) then begin
        Cardinal(Value):= A.FLimbs[0];
        Result:= TFL_S_OK;
      else
        Result:= TFL_E_INVALIDARG;
    end
  end
  else
    Result:= TFL_E_INVALIDARG;
{$ELSEIF IntSize > 1}
  if (A.FUsed <= IntSize) then begin
    Tmp:= 0;
    Move(A.FLimbs, Tmp, A.FUsed * SizeOf(TLimb));
    if (A.FSign >= 0)
      then Value:= Tmp
      else Value:= -Tmp;
    Result:= TFL_S_OK;
  end
  else
    Result:= TFL_E_INVALIDARG;
{$IFEND}
end;

{ TNumber --> string conversions }
class function TBigNumber.ToString(A: PBigNumber; var S: string): HResult;
var
  Tmp: PBigNumber;
  Used: Cardinal;
  I, J: Integer;
  Digits: array of Byte;

begin
  S:= '';
  if A.IsZero then begin
    S:= '0';
    Result:= S_OK;
    Exit;
  end;

  Used:= A.FUsed;

{$IF SizeOf(TLimb) = 1}         // max 3 decimal digits per byte
  SetLength(Digits, Used * 3);
{$ELSEIF SizeOf(TLimb) = 2}     // max 5 decimal digits per word
  SetLength(Digits, Used * 5);
{$ELSEIF SizeOf(TLimb) = 4}     // max 10 decimal digits per longword
  SetLength(Digits, Used * 10);
{$ELSE}
  Result:= E_NOTIMPLEMENTED;
  Exit;
{$IFEND}

  Result:= AllocNumber(Tmp, A.FUsed);
  if Result <> S_OK then Exit;
  Move(A.FUsed, Tmp.FUsed, FUsedSize + A.FUsed * SizeOf(TLimb));

  I:= 0;
  while not Tmp.IsZero do begin
    Used:= Tmp.FUsed;
    Digits[I]:= arrSelfDivModLimb(@Tmp.FLimbs, Used, 10);
    if (Used > 1) and (Tmp.FLimbs[Used - 1] = 0) then
      Tmp.FUsed:= Used - 1;

//    Digits[I]:= SelfDivModLimb(Tmp, 10);
    Inc(I);
  end;

  Release(Tmp);

  if A.FSign < 0 then begin
    Inc(I);
    SetLength(S, I);
    S[1]:= '-';
    J:= 2;
  end
  else begin
    SetLength(S, I);
    J:= 1;
  end;

  while J <= I do begin
    S[J]:= Chr(Ord('0') + Digits[I - J]);
    Inc(J);
  end;

end;

class function TBigNumber.ToWideString(A: PBigNumber; var S: WideString): HResult;
var
  Tmp: string;

begin
  Result:= ToString(A, Tmp);
  if Result = S_OK then
    S:= WideString(Tmp);
end;

const
  BigNumPrefixSize = SizeOf(TBigNumber) - SizeOf(TBigNumber.TLimbArray);

class function TBigNumber.AllocNumber(var A: PBigNumber;
                                       NLimbs: Cardinal = 0): HResult;
var
  BytesRequired: Cardinal;

begin
  if NLimbs >= TLimbInfo.MaxCapacity then begin
    Result:= TFL_E_NOMEMORY;
    Exit;
  end;
  BytesRequired:= NLimbs * SizeOf(TLimb) + BigNumPrefixSize;
  BytesRequired:= (BytesRequired + 7) and not 7;
  try
    GetMem(A, BytesRequired);
    A^.FVTable:= @BigNumVTable;
    A^.FRefCount:= 1;
    A^.FCapacity:= (BytesRequired - BigNumPrefixSize) div SizeOf(TLimb);
    A^.FUsed:= 1;
    A^.FSign:= 0;
    A^.FLimbs[0]:= 0;
    Result:= TFL_S_OK;
  except
    Result:= TFL_E_OUTOFMEMORY;
  end;
end;

class function TBigNumber.FromString(var A: PBigNumber; const S: string): HResult;
var
  L: Integer;

begin
  L:= Length(S);
  if (L > 0) and (S[1] = '-') then
  begin
    Result:= FromPCharU(A, PChar(S) + 1, L - 1);
    if Result = S_OK then A^.FSign:= -1;
  end
  else begin
    Result:= FromPCharU(A, PChar(S), L);
    if Result = S_OK then A^.FSign:= 0;
  end;
end;

class function TBigNumber.FromStringU(var A: PBigNumber; const S: string): HResult;
begin
  Result:= FromPCharU(A, PChar(S), Length(S));
end;

class function TBigNumber.FromWideString(var A: PBigNumber;
  const S: WideString): HResult;

begin
  Result:= FromString(A, string(S));
end;

class function TBigNumber.FromWideStringU(var A: PBigNumber;
  const S: WideString): HResult;
begin
  Result:= FromStringU(A, string(S));
end;

class function TBigNumber.GetSign(Inst: PBigNumber): Integer;
begin
  if (Inst.FUsed = 1) and (Inst.FLimbs[0] = 0) then Result:= 0
  else if Inst.FSign >= 0 then Result:= 1
  else Result:= -1;
end;

class function TBigNumber.FromCardinal(var A: PBigNumber;
                                       Value: Cardinal): HResult;
const
  DataSize = SizeOf(Cardinal) div SizeOf(TLimb);

var
  Tmp: PBigNumber;

begin
{$IF DataSize = 0}
  Result:= TFL_E_NOTIMPL;
{$ELSE}
  Result:= TBigNumber.AllocNumber(Tmp, DataSize);
  if Result <> S_OK then Exit;
  {$IF DataSize = 1}
    Tmp.FLimbs[0]:= Value;
  {$ELSE}
    Move(Value, Tmp.FLimbs, SizeOf(Cardinal));
    Tmp.FUsed:= DataSize;
    TBigNumber.Normalize(Tmp);
  {$IFEND}
  if (A <> nil) then TBigNumber.Release(A);
  A:= Tmp;
{$IFEND}
end;

class function TBigNumber.FromInteger(var A: PBigNumber;
                                      Value: Integer): HResult;
const
  DataSize = SizeOf(Integer) div SizeOf(TLimb);

var
  Tmp: PBigNumber;
{$IF DataSize <> 1}
  TmpValue: Integer;
{$IFEND}

begin
{$IF DataSize = 0}
  Result:= TFL_E_NOTIMPL;
{$ELSE}
  Result:= TBigNumber.AllocNumber(Tmp, DataSize);
  if Result <> S_OK then Exit;
  {$IF DataSize = 1}
    Tmp.FLimbs[0]:= Abs(Value);
  {$ELSE}
    TmpValue:= Abs(Value);
    Move(TmpValue, Tmp.FLimbs, SizeOf(Integer));
    Tmp.FUsed:= DataSize;
    TBigNumber.Normalize(Tmp);
  {$IFEND}
  if Value < 0 then Tmp.FSign:= -1;
  if (A <> nil) then TBigNumber.Release(A);
  A:= Tmp;
{$IFEND}
end;

class function TBigNumber.FromPCharU(var A: PBigNumber; const S: PChar; L: Integer): HResult;
const
{$IF SizeOf(TLimb) = 8}         // 16 hex digits per uint64 limb
   LIMB_SHIFT = 4;
{$ELSEIF SizeOf(TLimb) = 4}     // 8 hex digits per longword limb
   LIMB_SHIFT = 3;
{$ELSEIF SizeOf(TLimb) = 2}     // 4 hex digits per word limb
   LIMB_SHIFT = 2;
{$ELSE}                         // 2 hex digits per byte limb
   LIMB_SHIFT = 1;
{$IFEND}

var
  I, N: Integer;
  Limb: TLimb;
  Digit: Cardinal;
  Ch: Char;
  LimbsRequired: Cardinal;
  Tmp: PBigNumber;

begin
  Tmp:= nil;
  try
    if L <= 0 then begin
      Result:= TFL_E_INVALIDARG;
      Exit;
    end;
    I:= 0;                    // S is zero-based PChar
    if S[I] = '$' then begin
      Inc(I);
      if L <= I then begin
        Result:= TFL_E_INVALIDARG;
        Exit;
      end;
      N:= L - I;              // number of hex digits;
                            //   1 limb holds 2 * SizeOf(TLimb) hex digits

//    SetCapacity((N + 2 * SizeOf(TLimb) - 1) shr LIMB_SHIFT);

      LimbsRequired:= (N + 2 * SizeOf(TLimb) - 1) div (2 * SizeOf(TLimb)); //shr LIMB_SHIFT;
      Result:= AllocNumber(Tmp, LimbsRequired);
      if Result <> S_OK then Exit;

    N:= 0;
    Limb:= 0;
    repeat
                      // moving from end of string
      Ch:= S[L - N - 1];
      case Ch of
        '0'..'9': Digit:= Ord(Ch) - Ord('0');
        'A'..'F': Digit:= 10 + Ord(Ch) - Ord('A');
        'a'..'f': Digit:= 10 + Ord(Ch) - Ord('a');
      else
        Result:= TFL_E_INVALIDARG;
        Exit;
      end;
                        // shift digit to its position in a limb
      Limb:= Limb + (Digit shl ((N and (2 * SizeOf(TLimb) - 1)) shl 2));

      Inc(N);
// todo: n c точностью +/-1 из-за zero based
      if N and (2 * SizeOf(TLimb) - 1) = 0 then begin
        Tmp^.FLimbs[N shr LIMB_SHIFT - 1]:= Limb;
        Limb:= 0;
      end;
    until I + N >= L;
    if N and (2 * SizeOf(TLimb) - 1) <> 0 then
      Tmp^.FLimbs[N shr LIMB_SHIFT]:= Limb;

    N:= (N + 2 * SizeOf(TLimb) - 1) shr LIMB_SHIFT;

    Tmp^.FUsed:= N;
    Normalize(Tmp);
  end
  else begin
               // number of decimal digits
    N:= (L - I);

               // good rational approximations from above
               //   to log2(10) / 8 are:
               //     98981 / 238370;  267 / 643;  49 / 118;  5 / 12

               // number of bytes to hold these digits
    N:= (N * 267) div 643 + 1;

               // number of limbs to hold these digits
{$IF SizeOf(TLimb) > 1}
    N:= (N + SizeOf(TLimb) - 1) shr (LIMB_SHIFT - 1);
{$IFEND}

//    SetCapacity(N);

      Result:= AllocNumber(Tmp, N);
      if Result <> S_OK then Exit;

    Tmp^.FUsed:= 1;
    Tmp^.FLimbs[0]:= 0;
    repeat
      Ch:= S[I];
      case Ch of
        '0'..'9': Digit:= Ord(Ch) - Ord('0');
      else
        Result:= TFL_E_INVALIDARG;
        Exit;
      end;
      Inc(I);

// Tmp:= Tmp * 10 + Digit;
      if arrSelfMulLimb(@Tmp^.FLimbs, 10, Tmp^.FUsed) then
        Inc(Tmp^.FUsed);
      if arrSelfAddLimb(@Tmp^.FLimbs, Digit, Tmp^.FUsed) then
        Inc(Tmp^.FUsed);

//      SelfMulLimb(10);
//      SelfAddLimbU(Digit);
    until I >= L;
  end;
    if A <> nil then Release(A);
    A:= Tmp;
    Result:= S_OK;
  finally
    if (Result <> S_OK) and (Tmp <> nil) then Release(Tmp);
  end;
end;

function TBigNumber.IsNegative: Boolean;
begin
  Result:= FSign < 0;
end;

function TBigNumber.IsZero: Boolean;
begin
  Result:= (FUsed = 1) and (FLimbs[0] = 0);
end;

// R:= A * Limb
class function TBigNumber.MulLimb(A: PBigNumber; Limb: TLimb;
                                  var R: PBigNumber): HResult;
var
  Tmp: PBigNumber;
  UsedA: Cardinal;

begin
                                // special case Limb = 0
  if (Limb = 0) then begin
    if (R <> nil) and (R <> A) then Release(R);
    R:= @BigNumZero;
    Result:= TFL_S_OK;
    Exit;
  end;
                                // general case Limb <> 0
  UsedA:= A.FUsed;
  Result:= AllocNumber(Tmp, UsedA + 1);
  if Result <> TFL_S_OK then Exit;

//  Move(A.FLimbs, Tmp.FLimbs, UsedA * SizeOf(TLimb));
//  if arrSelfMulLimb(@Tmp.FLimbs, Limb, UsedA)
  if arrMulLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA)
    then Tmp.FUsed:= UsedA + 1
    else Tmp.FUsed:= UsedA;

  Tmp.FSign:= A.FSign;

  if (R <> nil) and (R <> A) then Release(R);
  R:= Tmp;
  Result:= TFL_S_OK;
end;

class function TBigNumber.MulLimbU(A: PBigNumber; Limb: TLimb; var R: PBigNumber): HResult;
var
  Tmp: PBigNumber;
  UsedA: Cardinal;

begin
                                // special case Limb = 0
  if (Limb = 0) then begin
    if (R <> nil) and (R <> A) then Release(R);
    R:= @BigNumZero;
    Result:= TFL_S_OK;
    Exit;
  end;
                                // general case Limb <> 0
  UsedA:= A.FUsed;
  Result:= AllocNumber(Tmp, UsedA + 1);
  if Result <> TFL_S_OK then Exit;

  if arrMulLimb(@A.FLimbs, Limb, @Tmp.FLimbs, UsedA)
    then Tmp.FUsed:= UsedA + 1
    else Tmp.FUsed:= UsedA;

  if (R <> nil) and (R <> A) then Release(R);
  R:= Tmp;
  Result:= TFL_S_OK;
end;

class procedure TBigNumber.Normalize(Inst: PBigNumber);
var
  Used: Cardinal;

begin
  Used:= Inst.FUsed;
  while (Used > 0) and (Inst.FLimbs[Used - 1] = 0) do
    Dec(Used);
  if Used = 0 then begin
    Inst.FUsed:= 1;
    Inst.FSign:= 0;     // to avoid negative zero
  end
  else Inst.FUsed:= Used;
end;

(*
  float power(float x, unsigned int n) {
    float aux = 1.0;
    while (n > 0) {
      if (n & 1) {    \\ odd?
        aux *= x;
        if (n == 1) return aux;
      }
      x *= x;
      n /= 2;
    }
    return aux;
  }
*)

class function TBigNumber.Power(A: PBigNumber; APower: Cardinal; var R: PBigNumber): HResult;
var
  Tmp, TmpR: PBigNumber;

begin
  if APower = 0 then begin
    if R <> nil then Release(R);
    if A.IsZero then R:= @BigNumZero
    else R:= @BigNumOne;
    Result:= S_OK;
    Exit;
  end;

  TmpR:= @BigNumOne;
  Tmp:= A;

  Result:= S_OK;
  while APower > 0 do begin
    if Odd(APower) then begin
      Result:= MulNumbers(Tmp, TmpR, TmpR);
      if Result <> S_OK then Break;
      if APower = 1 then Break;
    end;
    Result:= MulNumbers(Tmp, Tmp, Tmp);
    if Result <> S_OK then Break;
    APower:= APower shr 1;
  end;
  if Result = S_OK then begin
    if (R <> A) and (R <> nil)
      then Release(R);
    R:= TmpR;
  end
  else
    Release(TmpR);
  if Tmp <> A then
    Release(Tmp);
end;

class function TBigNumber.PowerU(A: PBigNumber; APower: Cardinal; var R: PBigNumber): HResult;
var
  Tmp, TmpR: PBigNumber;

begin
  if APower = 0 then begin
    if R <> nil then Release(R);
    if A.IsZero then R:= @BigNumZero
    else R:= @BigNumOne;
    Result:= S_OK;
    Exit;
  end;

  TmpR:= @BigNumOne;
  Tmp:= A;

  Result:= TFL_S_OK;
  while APower > 0 do begin
    if Odd(APower) then begin
      Result:= MulNumbersU(Tmp, TmpR, TmpR);
      if Result <> TFL_S_OK then Break;
      if APower = 1 then Break;
    end;
    Result:= MulNumbersU(Tmp, Tmp, Tmp);
    if Result <> TFL_S_OK then Break;
    APower:= APower shr 1;
  end;
  if Result = TFL_S_OK then begin
    if (R <> A) and (R <> nil)
      then Release(R);
    R:= TmpR;
  end
  else
    Release(TmpR);
  if Tmp <> A then
    Release(Tmp);
end;

class function TBigNumber.PowerMod(BaseValue, ExpValue, Modulo: PBigNumber; var R: PBigNumber): HResult;
var
  Tmp, TmpR, Q: PBigNumber;
  Used, I: Cardinal;
  Limb: TLimb;
  P, Sentinel: PLimb;

begin
                                  // ExpValue = 0
  if ExpValue.IsZero then begin
    if R <> nil then Release(R);
    if BaseValue.IsZero then R:= @BigNumZero
    else R:= @BigNumOne;
    Result:= S_OK;
    Exit;
  end;
                                  // Assert( ExpValue > 0 )
  TmpR:= @BigNumOne;
  Tmp:= BaseValue;
  Addref(Tmp);

  Used:= ExpValue.FUsed;
  P:= @ExpValue.FLimbs;
  Sentinel:= P + Used;
  Result:= S_OK;
  while P <> Sentinel do begin
    I:= 0;
    Limb:= P^;
    while Limb > 0 do begin
      if Odd(Limb) then begin
                                              // TmpR:= Tmp * TmpR
        Result:= MulNumbers(Tmp, TmpR, TmpR);
        if Result = S_OK then
                                              // TmpR:= TmpR mod Modulo
          Result:= DivModNumbersU(TmpR, Modulo, Q, TmpR);
        if Result <> S_OK then begin
          Release(Tmp);
          Release(TmpR);
          Exit;
        end;
        if Limb = 1 then Break;
      end;
      Result:= MulNumbers(Tmp, Tmp, Tmp);
      if Result = S_OK then
        Result:= DivModNumbersU(Tmp, Modulo, Q, Tmp);
      if Result <> S_OK then begin
        Release(Tmp);
        Release(TmpR);
        Exit;
      end;
      Limb:= Limb shr 1;
      Inc(I);
    end;
    Inc(P);
    if P = Sentinel then Break;
    while I < TLimbInfo.BitSize do begin
      Result:= MulNumbers(Tmp, Tmp, Tmp);
      if Result = S_OK then
        Result:= DivModNumbersU(Tmp, Modulo, Q, Tmp);
      if Result <> S_OK then begin
        Release(Tmp);
        Release(TmpR);
        Exit;
      end;
      Inc(I);
    end;
  end;
  Release(Tmp);
  if R <> nil then Release(R);
  R:= TmpR;
end;

class function TBigNumber.QueryIntf(Inst: PBigNumber; const IID: TGUID;
  out Obj): HResult;
begin
  Result:= E_NOINTERFACE;
end;

class function TBigNumber.Addref(Inst: PBigNumber): Integer;
begin
  if Inst.FRefCount > 0 then begin
    Inc(Inst.FRefCount);
  end;
  Result:= Inst.FRefCount;
end;

class function TBigNumber.Release(Inst: PBigNumber): Integer;
begin
  if Inst.FRefCount > 0 then begin
    Dec(Inst.FRefCount);
    Result:= Inst.FRefCount;
    if Inst.FRefCount = 0 then FreeMem(Inst);
  end
  else
    Result:= Inst.FRefCount;
end;

procedure TBigNumber.Free;
begin
  if @Self <> nil then Release(@Self);
end;

class procedure TBigNumber.FreeAndNil(var Inst: PBigNumber);
var
  Tmp: PBigNumber;

begin
  if Inst <> nil then begin
    Tmp:= Inst;
    Inst:= nil;
    Release(Tmp);
  end;
end;

end.
