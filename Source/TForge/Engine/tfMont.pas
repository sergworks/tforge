{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2016         * }
{ * ------------------------------------------------------- * }
{ *   # Arithmetic in Montgomery form                       * }
{ *   # all numbers should be in range [0..N-1]             * }
{ *   # Reduce converts from Montgomery form                * }
{ *********************************************************** }

unit tfMont;

{$I TFL.inc}

interface

uses tfLimbs, tfRecords, tfTypes, tfNumbers;

type
  TMontEngine = record
    FVTable: Pointer;
    FRefCount: Integer;
    FShift: Integer;        // number of bits in R; R = 2^FShift
    FN: IBigNumber;         // modulus
    FRR: IBigNumber;        // R^2 mod N, to convert to montgomery form
    FNi: IBigNumber;        // R*Ri - N*Ni = 1

    function Init(Modulus: PBigNumber): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Reduce(A: PBigNumber; var T: PBigNumber): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ToMont(A: PBigNumber; var T: PBigNumber): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Add(A, B: PBigNumber; var T: PBigNumber): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Sub(A, B: PBigNumber; var T: PBigNumber): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Mul(A, B: PBigNumber; var T: PBigNumber): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Pow(BaseValue, ExpValue: PBigNumber; var T: PBigNumber): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

implementation

(* todo: limbwise implementation of Montgomery reduction,
{$IFDEF MONT_LIMB}
{$ELSE}
{$ENDIF}
*)

{ TMontEngine }

function TMontEngine.Init(Modulus: PBigNumber): TF_RESULT;
var
  Tmp: PBigNumber;

begin
// Modulus should be odd to be coprime with powers of 2
  if not Odd(Modulus.FLimbs[0]) or (Modulus.FSign < 0) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// setup N
  Result:= TBigNumber.DuplicateNumber(Modulus, PBigNumber(FN));
  if Result <> TF_S_OK then Exit;

// setup Shift, R = 2^Shift
  FShift:= TBigNumber(PBigNumber(FN)).NumBits;

// store R in Tmp
// Shift + 1 bits needed
  Result:= TBigNumber.AllocNumber(Tmp,
            (FShift + TLimbInfo.BitSize) shr TLimbInfo.BitShift);
  if Result <> TF_S_OK then Exit;

// R:= 2^Shift; R > N; return code can be ignored cause always TF_S_OK here
  Result:= TBigNumber.SetBit(Tmp, FShift);
  if Result <> TF_S_OK then Exit;

// store Ri in Tmp
// Ri:= R^(-1) mod N
  Result:= TBigNumber.ModInverse(Tmp, FN, Tmp);
  if Result <> TF_S_OK then Exit;

// Tmp:= R * Ri - 1
  Result:= TBigNumber.ShlNumber(Tmp, FShift, Tmp);
  if Result <> TF_S_OK then Exit;
  Result:= TBigNumber.SubLimbU(Tmp, 1, Tmp);
  if Result <> TF_S_OK then Exit;

// setup Ni
// Ni:= (R * Ri - 1) div N
  Result:= TBigNumber.DivRemNumbers(Tmp, FN, FNi, Tmp);
  if Result <> TF_S_OK then Exit;

// setup RR
// 2 * FShift + 1 bits needed
  Result:= BigNumberAlloc(FRR,
            (FShift shl 1 + TLimbInfo.BitSize) shr TLimbInfo.BitShift);
  if Result <> TF_S_OK then Exit;

// RR:= R^2; return code can be ignored cause always TF_S_OK here
  Result:= TBigNumber.SetBit(FRR, FShift shl 1);
  if Result <> TF_S_OK then Exit;

  Result:= TBigNumber.DivRemNumbers(FRR, FN, Tmp, FRR);
end;

function TMontEngine.Reduce(A: PBigNumber; var T: PBigNumber): TF_RESULT;
var
  Tmp: PBigNumber;

begin
  Tmp:= nil;

// Tmp:= ((A mod R)*Ni) mod R
  Result:= TBigNumber.DuplicateNumber(A, Tmp);
  if Result <> TF_S_OK then Exit;
  TBigNumber.MaskBits(Tmp, FShift);

  Result:= TBigNumber.MulNumbers(Tmp, FNi, Tmp);
  if Result = TF_S_OK then begin
    TBigNumber.MaskBits(Tmp, FShift);

// Tmp:= (A + Tmp*N) div R
    Result:= TBigNumber.MulNumbers(Tmp, FN, Tmp);
    if Result = TF_S_OK then begin

      Result:= TBigNumber.AddNumbers(A, Tmp, Tmp);
      if Result = TF_S_OK then begin

        Result:= TBigNumber.ShrNumber(Tmp, FShift, Tmp);
        if Result = TF_S_OK then begin

// if Tmp >= N then Tmp:= Tmp - N
          if TBigNumber.CompareNumbersU(Tmp, FN) >= 0 then
            Result:= TBigNumber.SubNumbersU(Tmp, FN, Tmp);
        end;
      end;
    end;
  end;

  if Result <> TF_S_OK then begin
    TtfRecord.Release(Tmp);
  end
  else begin
    if (T <> nil) then TtfRecord.Release(T);
    T:= Tmp;
  end;
end;

function TMontEngine.ToMont(A: PBigNumber; var T: PBigNumber): TF_RESULT;
var
  Tmp: PBigNumber;

begin
  Tmp:= nil;
  Result:= TBigNumber.MulNumbersU(A, FRR, Tmp);
  if Result = TF_S_OK then begin
    Result:= Reduce(Tmp, T);
    TtfRecord.Release(Tmp);
  end;
end;

function TMontEngine.Add(A, B: PBigNumber; var T: PBigNumber): TF_RESULT;
var
  Tmp: PBigNumber;

begin
  Tmp:= nil;
  Result:= TBigNumber.AddNumbersU(A, B, Tmp);
  if Result = TF_S_OK then begin
    if TBigNumber.CompareNumbersU(Tmp, FN) >= 0 then begin
      Result:= TBigNumber.SubNumbersU(Tmp, FN, T);
      TtfRecord.Release(Tmp);
    end
    else begin
      if (T <> nil) then TtfRecord.Release(T);
      T:= Tmp;
    end;
  end;
end;

function TMontEngine.Sub(A, B: PBigNumber; var T: PBigNumber): TF_RESULT;
var
  Tmp: PBigNumber;

begin
  Tmp:= nil;
  Result:= TBigNumber.SubNumbers(A, B, Tmp);
  if Result = TF_S_OK then begin
    if Tmp.FSign < 0 then begin
      Result:= TBigNumber.AddNumbers(Tmp, FN, T);
      TtfRecord.Release(Tmp);
    end
    else begin
      if (T <> nil) then TtfRecord.Release(T);
      T:= Tmp;
    end;
  end;
end;

function TMontEngine.Mul(A, B: PBigNumber; var T: PBigNumber): TF_RESULT;
var
  Tmp: PBigNumber;

begin
  Tmp:= nil;
  Result:= TBigNumber.MulNumbersU(A, B, Tmp);
  if Result = TF_S_OK then begin
    Result:= Reduce(Tmp, T);
    TtfRecord.Release(Tmp);
  end;
end;

function TMontEngine.Pow(BaseValue, ExpValue: PBigNumber;
           var T: PBigNumber): TF_RESULT;
var
  Tmp, TmpR: PBigNumber;
  Used, I: Cardinal;
  Limb: TLimb;
  P, Sentinel: PLimb;

begin
                                  // ExpValue = 0
  if ExpValue.IsZero then begin
    if T <> nil then TtfRecord.Release(T);
    if BaseValue.IsZero then T:= @BigNumZero
    else T:= @BigNumOne;
    Result:= TF_S_OK;
    Exit;
  end;
                                  // Assert( ExpValue > 0 )
  TmpR:= @BigNumOne;
  Tmp:= BaseValue;
  TtfRecord.Addref(Tmp);
//  Q:= nil;

  Used:= ExpValue.FUsed;
  P:= @ExpValue.FLimbs;
  Sentinel:= P + Used;
  Result:= TF_S_OK;
  while P <> Sentinel do begin
    I:= 0;
    Limb:= P^;
    while Limb > 0 do begin
      if Odd(Limb) then begin
                                              // TmpR:= Tmp * TmpR
        Result:= TBigNumber.MulNumbersU(Tmp, TmpR, TmpR);
        if Result = TF_S_OK then
                                              // TmpR:= TmpR mod Modulus
          Result:= Reduce(TmpR, TmpR);
        if Result <> TF_S_OK then begin
          TtfRecord.Release(Tmp);
          TtfRecord.Release(TmpR);
          Exit;
        end;
        if Limb = 1 then Break;
      end;
      Result:= TBigNumber.MulNumbersU(Tmp, Tmp, Tmp);
      if Result = TF_S_OK then
        Result:= Reduce(Tmp, Tmp);
      if Result <> TF_S_OK then begin
        TtfRecord.Release(Tmp);
        TtfRecord.Release(TmpR);
        Exit;
      end;
      Limb:= Limb shr 1;
      Inc(I);
    end;
    Inc(P);
    if P = Sentinel then Break;
    while I < TLimbInfo.BitSize do begin
      Result:= TBigNumber.MulNumbers(Tmp, Tmp, Tmp);
      if Result = TF_S_OK then
        Result:= Reduce(Tmp, Tmp);
      if Result <> TF_S_OK then begin
        TtfRecord.Release(Tmp);
        TtfRecord.Release(TmpR);
        Exit;
      end;
      Inc(I);
    end;
  end;
  TtfRecord.Release(Tmp);
  if T <> nil then TtfRecord.Release(T);
  T:= TmpR;
end;

end.
