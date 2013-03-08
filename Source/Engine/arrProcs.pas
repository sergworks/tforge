{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ * ------------------------------------------------------- * }
{ *   # engine unit                                         * }
{ *********************************************************** }
{ *   De Morgan's laws:                                     * }
{ *   # not(A and B) = (not A) or (not B)                   * }
{ *   # not(A or B) = (not A) and (not B)                   * }
{ *   also used:                                            * }
{ *   # -A = (not A) + 1 = not(A - 1)                       * }
{ *   # not(A xor B) = (not A) xor B = A xor (not B)        * }
{ *   # (not A) xor (not B) = A xor B                       * }
{ *********************************************************** }

unit arrProcs;

{$I TFL.inc}

{$IFDEF TFL_LIMB32_ASM86}
  {.$DEFINE LIMB32_ASM86}
{$ENDIF}

interface

uses tfLimbs;

{ Utilities}
function arrGetLimbCount(A: PLimb; L: Cardinal): Cardinal;

{ Addition primitives }
function arrAdd(A, B, Res: PLimb; LA, LB: Cardinal): Boolean;
function arrSelfAdd(A, B: PLimb; LA, LB: Cardinal): Boolean;
function arrAddLimb(A: PLimb; Limb: TLimb; Res: PLimb; L: Cardinal): Boolean;
function arrSelfAddLimb(A: PLimb; Limb: TLimb; L: Cardinal): Boolean;

{ Subtraction primitives }
function arrSub(A, B, Res: PLimb; LA, LB: Cardinal): Boolean;
function arrSelfSub(A, B: PLimb; LA, LB: Cardinal): Boolean;
function arrSubLimb(A: PLimb; Limb: TLimb; Res: PLimb; L: Cardinal): Boolean;
function arrSelfSubLimb(A: PLimb; Limb: TLimb; L: Cardinal): Boolean;

{ Multiplication primitives }
procedure arrMul(A, B, Res: PLimb; LA, LB: Cardinal);
function arrMulLimb(A: PLimb; Limb: TLimb; Res: PLimb; L: Cardinal): Boolean;
function arrSelfMulLimb(A: PLimb; Limb: TLimb; L: Cardinal): Boolean;

{ Division primitives }

// normalized division (Divisor[DsrLen-1] and $80000000 <> 0)
// in: Dividend: Dividend;
//     Divisor: Divisor;
//     DndLen: Dividend Length
//     DsrLen: Divisor Length
// out: Quotient:= Dividend div Divisor
//      Dividend:= Dividend mod Divisor

procedure arrNormDivMod(Dividend, Divisor, Quotient: PLimb;
                        DndLen, DsrLen: TLimb);
function arrDivModLimb(A, Q: PLimb; L, D: TLimb): TLimb;
function arrSelfDivModLimb(A: PLimb; L: Cardinal; D: TLimb): TLimb;

function arrCmp(A, B: PLimb; L: Cardinal): Integer;

function arrNormSqrtRem(A, Root, Rem: PLimb; LA: Cardinal): Cardinal;
function arrSqrt(A, Root: PLimb; LA: Cardinal): Cardinal;

{ Bitwise shifts }
function arrShlShort(A, Res: PLimb; LA, Shift: Cardinal): Cardinal;
function arrShrShort(A, Res: PLimb; LA, Shift: Cardinal): Cardinal;

function arrShlOne(A, Res: PLimb; LA: Cardinal): Cardinal;
function arrShrOne(A, Res: PLimb; LA: Cardinal): Cardinal;
function arrSelfShrOne(A: PLimb; LA: Cardinal): Cardinal;

{ Bitwise boolean }
procedure arrAnd(A, B, Res: PLimb; L: Cardinal);
procedure arrAndTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
function arrAndTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal): Boolean;

procedure arrOr(A, B, Res: PLimb; LA, LB: Cardinal);
procedure arrOrTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
procedure arrOrTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal);

procedure arrXor(A, B, Res: PLimb; LA, LB: Cardinal);
procedure arrXorTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
procedure arrXorTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal);

implementation

{$IFDEF TFL_POINTERMATH}
{$POINTERMATH ON}
{$ELSE}
function GetLimb(P: PLimb; Offset: Cardinal): TLimb;
begin
  Inc(P, Offset);
  Result:= P^;
end;
{$ENDIF}

function arrGetLimbCount(A: PLimb; L: Cardinal): Cardinal;
begin
  Assert(L > 0);
  Inc(A, L - 1);
  while (A^ = 0) and (L > 1) do begin
    Dec(A);
    Dec(L);
  end;
  Result:= L;
end;

{$IFDEF LIMB32_ASM86}
function arrAdd(A, B, Res: PLongWord; LA, LB: LongWord): Boolean;
asm
        PUSH  ESI
        PUSH  EDI
        MOV   EDI,ECX     // EDI <-- Res
        MOV   ESI,EAX     // ESI <-- A
        MOV   ECX,LA
        SUB   ECX,LB
        PUSH  ECX         // -(SP) <-- LA - LB;
        MOV   ECX,LB
        CLC
@@Loop:
        LODSD             // EAX <-- [ESI], ESI <-- ESI + 4
        ADC   EAX,[EDX]
        STOSD             // [EDI] <-- EAX, EDI <-- EDI + 4
        LEA   EDX,[EDX+4]
        LOOP  @@Loop

        POP   ECX         // ECX <-- LA - LB;
        JECXZ @@Done
@@Loop2:
        LODSD
        ADC   EAX, 0
        STOSD
        LOOP  @@Loop2
@@Done:
        MOV   EAX,0
        JNC   @@Skip
        INC   EAX
@@Skip:
        MOV   [EDI],EAX
        POP   EDI
        POP   ESI
end;
{$ELSE}
function arrAdd(A, B, Res: PLimb; LA, LB: Cardinal): Boolean;
var
  CarryOut, CarryIn: Boolean;
  Tmp: TLimb;

begin
  Dec(LA, LB);
  CarryIn:= False;
  while LB > 0 do begin
    Tmp:= A^ + B^;
    CarryOut:= Tmp < A^;
    Inc(A);
    Inc(B);
    if CarryIn then begin
      Inc(Tmp);
      CarryOut:= CarryOut or (Tmp = 0);
    end;
    CarryIn:= CarryOut;
    Res^:= Tmp;
    Inc(Res);
    Dec(LB);
  end;
  while (LA > 0) and CarryIn do begin
    Tmp:= A^ + 1;
    CarryIn:= Tmp = 0;
    Inc(A);
    Res^:= Tmp;
    Inc(Res);
    Dec(LA);
  end;
  while (LA > 0) do begin
    Res^:= A^;
    Inc(A);
    Inc(Res);
    Dec(LA);
  end;
  Res^:= Ord(CarryIn);
  Result:= CarryIn;
end;
{$ENDIF}

{$IFDEF LIMB32_ASM86}
function arrSelfAdd(A, B: PLongWord; LA, LB: LongInt): Boolean;
asm
        PUSH  ESI
        PUSH  EDI
        MOV   EDI,EAX     // EDI <-- A
        MOV   ESI,EDX     // ESI <-- B
        SUB   ECX,LB
        PUSH  ECX         // -(SP) <-- LA - LB;
        MOV   ECX,LB
        CLC
@@Loop:
        LODSD             // EAX <-- [ESI], ESI <-- ESI + 4
        ADC   EAX,[EDI]
        STOSD             // [EDI] <-- EAX, EDI <-- EDI + 4
        LOOP  @@Loop

        MOV   EAX,0
        POP   ECX         // ECX <-- LA - LB;
        JECXZ @@Done
@@Loop2:
        ADC   [EDI], 0
        LEA   EDI,[EDI+4]
        JNC   @@Exit
        LOOP  @@Loop2
@@Done:
        JNC   @@Skip
        INC   EAX
@@Skip:
        MOV   [EDI+4*ECX],EAX
@@Exit:
        POP   EDI
        POP   ESI
end;
{$ELSE}
function arrSelfAdd(A, B: PLimb; LA, LB: Cardinal): Boolean;
var
  CarryOut, CarryIn: Boolean;
  Tmp: TLimb;

begin
  Dec(LA, LB);
  CarryIn:= False;
  while LB > 0 do begin
    Tmp:= A^ + B^;
    CarryOut:= Tmp < A^;
    Inc(B);
    if CarryIn then begin
      Inc(Tmp);
      CarryOut:= CarryOut or (Tmp = 0);
    end;
    CarryIn:= CarryOut;
    A^:= Tmp;
    Inc(A);
    Dec(LB);
  end;
  while (LA > 0) and CarryIn do begin
    Tmp:= A^ + 1;
    CarryIn:= Tmp = 0;
    A^:= Tmp;
    Inc(A);
    Dec(LA);
  end;
  Inc(A, LA);
  A^:= Ord(CarryIn);
  Result:= CarryIn;
end;
{$ENDIF}

{
  Description:
    Res:= A + Limb
  Asserts:
    L >= 1
    Res must have enough space for L + 1 limbs
  Remarks:
    function returns True if carry is propagated out of A[L-1];
    if function returns True the Res senior limb is set: Res[L] = 1
}
function arrAddLimb(A: PLimb; Limb: TLimb; Res: PLimb; L: Cardinal): Boolean;
var
  CarryIn: Boolean;
  Tmp: TLimb;

begin
  Tmp:= A^ + Limb;
  CarryIn:= Tmp < Limb;
  Inc(A);
  Dec(L);
  Res^:= Tmp;
  Inc(Res);
  while (L > 0) and CarryIn do begin
    Tmp:= A^ + 1;
    CarryIn:= Tmp = 0;
    Inc(A);
    Res^:= Tmp;
    Inc(Res);
    Dec(L);
  end;
  while (L > 0) do begin
    Res^:= A^;
    Inc(A);
    Inc(Res);
    Dec(L);
  end;
//  Res^:= LongWord(CarryIn);
  if CarryIn then Res^:= 1;
//  else Res^:= 0;
  Result:= CarryIn;
end;

{
  Description:
    A:= A + Limb
  Asserts:
    L >= 1                                             +
    A must have enougth space for L + 1 limbs
  Remarks:
    function returns True if carry is propagated out of A[L-1];
    if function returns True the A senior limb is set: A[L] = 1
}
{$IFDEF LIMB32_ASM86}
function arrSelfAddLimb(A: PLongWord; Limb: LongWord; L: LongInt): Boolean;
asm
        ADD   [EAX],EDX
        JNC   @@Exit
        DEC   ECX
        JECXZ @@Done
@@Loop:
        LEA   EAX,[EAX+4]
        ADC   [EAX], 0
        JNC   @@Exit
        LOOP  @@Loop
        JNC   @@Exit
@@Done:
        LEA   EAX,[EAX+4]
        MOV   [EAX],1
@@Exit:
        MOV   EAX,0
        SETC  AL
end;
{$ELSE}
function arrSelfAddLimb(A: PLimb; Limb: TLimb; L: Cardinal): Boolean;
var
  CarryIn: Boolean;
  Tmp: TLimb;

begin
  Tmp:= A^ + Limb;
  CarryIn:= Tmp < Limb;
  A^:= Tmp;
  Inc(A);
  Dec(L);
  while (L > 0) and CarryIn do begin
    Tmp:= A^ + 1;
    CarryIn:= Tmp = 0;
    A^:= Tmp;
    Inc(A);
    Dec(L);
  end;
  if CarryIn then A^:= 1;
//  if (L = 0) then A^:= LongWord(CarryIn);
  Result:= CarryIn;
end;
{$ENDIF}

{
  Description:
    Res:= A - B
  Asserts:
    LA >= LB >= 1
    Res must have enough space for LA limbs
  Remarks:
    function returns True if borrow is propagated out of A[LA-1] (A < B);
    if function returns True the Res is invalid
    any (A = B = Res) coincidence is allowed
}
{$IFDEF LIMB32_ASM86}
function arrSub(A, B, Res: PLongWord; LA, LB: LongInt): Boolean;
asm
        PUSH  ESI
        PUSH  EDI
        MOV   EDI,ECX     // EDI <-- Res
        MOV   ESI,EAX     // ESI <-- A
        MOV   ECX,LA
        SUB   ECX,LB
        PUSH  ECX         // -(SP) <-- LA - LB;
        MOV   ECX,LB
        CLC
@@Loop:
        LODSD             // EAX <-- [ESI], ESI <-- ESI + 4
        SBB   EAX,[EDX]
        STOSD             // [EDI] <-- EAX, EDI <-- EDI + 4
        LEA   EDX,[EDX+4]
        LOOP  @@Loop

        POP   ECX         // ECX <-- LA - LB;
        JECXZ @@Done
@@Loop2:
        LODSD
        SBB   EAX, 0
        STOSD
        LOOP  @@Loop2
@@Done:
        MOV   EAX,0
        SETC  AL
@@Exit:
        POP   EDI
        POP   ESI
end;
{$ELSE}
function arrSub(A, B, Res: PLimb; LA, LB: Cardinal): Boolean;
var
  BorrowOut, BorrowIn: Boolean;
  Tmp: TLimb;

begin
  Assert(LA >= LB);
  Assert(LB >= 1);
  Dec(LA, LB);
  BorrowIn:= False;
  while LB > 0 do begin
    Tmp:= A^ - B^;
    BorrowOut:= Tmp > A^;
    Inc(A);
    Inc(B);
    if BorrowIn then begin
      BorrowOut:= BorrowOut or (Tmp = 0);
      Dec(Tmp);
    end;
    BorrowIn:= BorrowOut;
    Res^:= Tmp;
    Inc(Res);
    Dec(LB);
  end;
  while (LA > 0) and BorrowIn do begin
    Tmp:= A^;
    BorrowIn:= Tmp = 0;
    Dec(Tmp);
    Inc(A);
    Res^:= Tmp;
    Inc(Res);
    Dec(LA);
  end;
  while (LA > 0) do begin
    Res^:= A^;
    Inc(A);
    Inc(Res);
    Dec(LA);
  end;
  Result:= BorrowIn;
end;
{$ENDIF}

{
  Description:
    A:= A - B
  Asserts:
    LA >= LB >= 1
  Remarks:
    function returns True if borrow is propagated out of A[LA-1] (A < B);
    if function returns True the A is invalid
    (A = B) coincidence is allowed
}
function arrSelfSub(A, B: PLimb; LA, LB: Cardinal): Boolean;
var
  BorrowOut, BorrowIn: Boolean;
  Tmp: LongWord;

begin
  Dec(LA, LB);
  BorrowIn:= False;
  while LB > 0 do begin
    Tmp:= A^ - B^;
    BorrowOut:= Tmp > A^;
    Inc(B);
    if BorrowIn then begin
      BorrowOut:= BorrowOut or (Tmp = 0);
      Dec(Tmp);
    end;
    BorrowIn:= BorrowOut;
    A^:= Tmp;
    Inc(A);
    Dec(LB);
  end;
  while (LA > 0) and BorrowIn do begin
    Tmp:= A^;
    BorrowIn:= Tmp = 0;
    Dec(Tmp);
    A^:= Tmp;
    Inc(A);
    Dec(LA);
  end;
  Result:= BorrowIn;
end;

{
  Description:
    Res:= A - Limb
  Asserts:
    L >= 1
    Res must have enough space for L limbs
  Remarks:
    function returns True if borrow is propagated out of A[L-1] (A < B);
    if function returns True the Res is invalid
}
function arrSubLimb(A: PLimb; Limb: TLimb; Res: PLimb; L: Cardinal): Boolean;
var
  BorrowIn: Boolean;
  Tmp: TLimb;

begin
  Tmp:= A^ - Limb;
  BorrowIn:= Tmp > A^;
  Inc(A);
  Dec(L);
  Res^:= Tmp;
  while (L > 0) and BorrowIn do begin
    Tmp:= A^;
    BorrowIn:= Tmp = 0;
    Dec(Tmp);
    Inc(A);
    Inc(Res);
    Res^:= Tmp;
    Dec(L);
  end;
  while (L > 0) do begin
    Inc(Res);
    Res^:= A^;
    Inc(A);
    Dec(L);
  end;
{
  if BorrowIn then
// we get here if L = 1 and A[0] < Limb; set Res[0] = Limb - A[0]
    Res^:= LongWord(-LongInt(Res^));
}
  Result:= BorrowIn;
end;

{
  Description:
    A:= A - Limb
  Asserts:
    L >= 1
  Remarks:
    function returns True if borrow is propagated out of A[L-1] (A < B);
    if function returns True the A is invalid
}
function arrSelfSubLimb(A: PLimb; Limb: TLimb; L: Cardinal): Boolean;
var
  BorrowIn: Boolean;
  Tmp: TLimb;

begin
  Tmp:= A^ - Limb;
  BorrowIn:= Tmp > A^;
  A^:= Tmp;
  Inc(A);
  Dec(L);
  while (L > 0) and BorrowIn do begin
    Tmp:= A^;
    BorrowIn:= Tmp = 0;
    Dec(Tmp);
    A^:= Tmp;
    Inc(A);
    Dec(L);
  end;

  Result:= BorrowIn;
end;

{
  Description:
    Res:= A * B
  Asserts:
    LA >= 1, LB >= 1
    Res must have enough space for LA + LB limbs
  Remarks:
    none
}
procedure arrMul(A, B, Res: PLimb; LA, LB: Cardinal);
var
  PA, PRes: PLimb;
  Cnt: Integer;
  TmpB: TLimbVector;
  TmpRes: TLimbVector;
  Carry: TLimb;

begin
  FillChar(Res^, (LA + LB) * SizeOf(TLimb), 0);
  while LB > 0 do begin
    if B^ <> 0 then begin
      TmpB.Value:= B^;
      PA:= A;
      PRes:= Res;
      Cnt:= LA;
      Carry:= 0;
      while Cnt > 0 do begin
        TmpRes.Value:= TmpB.Value * PA^ + Carry;
        TmpRes.Value:= TmpRes.Value + PRes^;
        PRes^:= TmpRes.Lo;
        Inc(PRes);
        Carry:= TmpRes.Hi;
        Inc(PA);
        Dec(Cnt);
      end;
      PRes^:= Carry;
    end;
    Inc(B);
    Inc(Res);
    Dec(LB);
  end;
end;

{ Bitwise boolean }

procedure arrAnd(A, B, Res: PLimb; L: Cardinal);
begin
  Assert(L > 0);
  repeat
    Res^:= A^ and B^;
    Inc(A);
    Inc(B);
    Inc(Res);
    Dec(L);
  until L = 0;
end;

// Res = A and (-B)) = A and not(B-1)
// B[0..LB-1] <> 0 because is abs of negative value
// Res[0..LA-1]
procedure arrAndTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
var
  Borrow: Boolean;
  Tmp: TLimb;

begin
  Assert(LA > 0);
  Assert(LB > 0);
  if LA >= LB then begin
    Dec(LA, LB);
    repeat
      Tmp:= B^;
      Borrow:= Tmp = 0;
      Dec(Tmp);
      Res^:= A^ and not Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
//    until (LB = 0) or not Borrow;
    until not Borrow;
    while (LB > 0) do begin
      Res^:= A^ and not B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    end;
    if (LA > 0) then
      Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin    { LA < LB }
    repeat
      Tmp:= B^;
      Borrow:= Tmp = 0;
      Dec(Tmp);
      Res^:= A^ and not Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    until (LA = 0) or not Borrow;
    while (LA > 0) do begin
      Res^:= A^ and not B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    end;
  end;
end;

(*
procedure arrAndTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
var
  Carry: Boolean;
  Tmp: TLimb;

begin
  if LA >= LB then begin
    Assert(LB > 0);
    Dec(LA, LB);
//    Carry:= True;
    repeat
      Tmp:= not B^;
      Inc(Tmp);
      Carry:= Tmp = 0;
      Res^:= A^ and Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0) or not Carry;
    while (LB > 0) do begin
      Res^:= A^ and not B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    end;
    while (LA > 0) and Carry do begin
      Tmp:= A^ and TLimbInfo.MaxLimb;
      Inc(Tmp);
      Carry:= Tmp = 0;
      Res^:= Tmp;
      Inc(A);
      Inc(Res);
      Dec(LA);
    end;
    while (LA > 0) do begin
      Res^:= A^ and TLimbInfo.MaxLimb;
      Inc(A);
      Inc(Res);
      Dec(LA);
    end;
  end
  else begin
    Assert(LA > 0);
//    Carry:= True;
    repeat
      Tmp:= not B^;
      Inc(Tmp);
      Carry:= Tmp = 0;
      Res^:= A^ and Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    until (LA = 0) or not Carry;
    while (LA > 0) do begin
      Res^:= A^ and not B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    end;
  end;
end;
*)

// A < 0, B < 0
// Res = -((-A) and (-B)) = -(not(A - 1) and not(B - 1)) =
//     = not(not(A - 1) and not(B - 1)) + 1 =
//     = ((A - 1) or (B - 1)) + 1
function arrAndTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal): Boolean;
var
  CarryA, CarryB, CarryR: Boolean;
  TmpA, TmpB: TLimb;
  SaveRes: PLimb;

begin
  Assert(LA >= LB);
  Assert(LB > 0);
  CarryA:= True;
  CarryB:= True;
  SaveRes:= Res;
  Dec(LA, LB);
  repeat
    TmpA:= not A^;
    if CarryA then begin
      Inc(TmpA);
      CarryA:= TmpA = 0;
    end;
    TmpB:= not B^;
    if CarryB then begin
      Inc(TmpB);
      CarryB:= TmpB = 0;
    end;
    Res^:= TmpA and TmpB;
    Inc(A);
    Inc(B);
    Inc(Res);
    Dec(LB);
  until (LB = 0);

  while (LA > 0) do begin
    TmpA:= not A^;
    if CarryA then begin
      Inc(TmpA);
      CarryA:= TmpA = 0;
    end;
                            // should be B = -0 to produce CarryB here
    Assert(CarryB = False);
    TmpB:= TLimbInfo.MaxLimb;
    Res^:= TmpA and TmpB;
    Inc(A);
    Inc(Res);
    Dec(LA);
  end;
//  CarryR:= True;
  Result:= True;
  repeat
    SaveRes^:= not SaveRes^ + 1;
    CarryR:= (SaveRes^ = 0);
    Result:= Result and (SaveRes^ = 0);
    Inc(SaveRes);
  until (SaveRes = Res) or not CarryR;
  while (SaveRes <> Res) do begin
    SaveRes^:= not SaveRes^;
    Result:= Result and (SaveRes^ = 0);
    Inc(SaveRes);
  end;
  Res^:= Ord(Result);
end;

procedure arrOr(A, B, Res: PLimb; LA, LB: Cardinal);
begin
  if (LA >= LB) then begin
    LA:= LA - LB;
    repeat
      Res^:= A^ or B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0);
    if (LA > 0) then
      Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin
    LB:= LB - LA;
    repeat
      Res^:= A^ or B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    until (LA = 0);
    Move(B^, Res^, LB * SizeOf(TLimb));
  end;
end;

// Res = -(A or (-B)) = -(A or not(B-1)) = not(A or not(B-1)) + 1 =
//     = (not(A) and (B-1)) + 1
// B[0..LB-1] <> 0 because is abs of negative value
// Res[0..LB-1]
procedure arrOrTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
var
  Borrow, Carry: Boolean;
  Tmp: TLimb;

begin
  if LA >= LB then begin
    Assert(LB > 0);
    Dec(LA, LB);
    Borrow:= True;
    Carry:= True;
    repeat
      Tmp:= B^;
      if Borrow then begin
        Borrow:= Tmp = 0;
        Dec(Tmp);
      end;
      Tmp:= not (A^) and Tmp;
      if Carry then begin
        Inc(Tmp);
        Carry:= Tmp = 0;
      end;
      Res^:= Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0);
  end
  else begin
    Assert(LA > 0);
    Dec(LB, LA);
    Borrow:= True;
    Carry:= True;

    repeat
      Tmp:= B^;
      if Borrow then begin
        Borrow:= Tmp = 0;
        Dec(Tmp);
      end;
      Tmp:= not (A^) and Tmp;
      if Carry then begin
        Inc(Tmp);
        Carry:= Tmp = 0;
      end;
      Res^:= Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    until (LA = 0);

    repeat
      Tmp:= B^;
      if Borrow then begin
        Borrow:= Tmp = 0;
        Dec(Tmp);
      end;
      if Carry then begin
        Inc(Tmp);
        Carry:= Tmp = 0;
      end;
      Res^:= Tmp;
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0);
  end;
end;

// Res = -((-A) or (-B)) = -(not(A-1) or not(B-1)) =
//     = not(not(A-1) or not(B-1)) + 1 =
//     = (A-1) and (B-1) + 1
procedure arrOrTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal);
var
  BorrowA, BorrowB, CarryR: Boolean;
  TmpA, TmpB, TmpR: TLimb;
  L: Cardinal;

begin
  BorrowA:= True;
  BorrowB:= True;
  CarryR:= True;
  if (LA >= LB)
    then L:= LB
    else L:= LA;
  Assert(L > 0);
  repeat
    TmpA:= A^;
    if BorrowA then begin
      BorrowA:= TmpA = 0;
      Dec(TmpA);
    end;
    TmpB:= B^;
    if BorrowB then begin
      BorrowB:= TmpB = 0;
      Dec(TmpB);
    end;
    TmpR:= TmpA and TmpB;
    if CarryR then begin
      Inc(TmpR);
      CarryR:= TmpR = 0;
    end;
    Res^:= TmpR;
    Inc(A);
    Inc(B);
    Inc(Res);
    Dec(L);
  until (L = 0);
end;

procedure arrXor(A, B, Res: PLimb; LA, LB: Cardinal);
begin
  if (LA >= LB) then begin
    LA:= LA - LB;
    repeat
      Res^:= A^ xor B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0);
    if (LA > 0) then
      Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin
    LB:= LB - LA;
    repeat
      Res^:= A^ xor B^;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    until (LA = 0);
    Move(B^, Res^, LB * SizeOf(TLimb));
  end;
end;

// Res = -(A xor (-B)) = -(A xor not(B-1)) = not(A xor not(B-1)) + 1 =
//     = (A xor (B-1)) + 1
// B[0..LB-1] <> 0 because is abs of negative value
procedure arrXorTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
var
  Borrow, Carry: Boolean;
  Tmp: TLimb;

begin
  if LA >= LB then begin
    Assert(LB > 0);
    Dec(LA, LB);
    Borrow:= True;
    Carry:= True;
    repeat
      Tmp:= B^;
      if Borrow then begin
        Borrow:= Tmp = 0;
        Dec(Tmp);
      end;
      Tmp:= A^ xor Tmp;
      if Carry then begin
        Inc(Tmp);
        Carry:= Tmp = 0;
      end;
      Res^:= Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0);
    Assert(not Borrow);
    while Carry and (LA > 0) do begin
      Tmp:= A^ + 1;
      Carry:= Tmp = 0;
      Res^:= Tmp;
      Inc(A);
      Inc(Res);
      Dec(LA);
    end;
    if (LA > 0) then
      Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin
    Assert(LA > 0);
    Dec(LB, LA);
    Borrow:= True;
    Carry:= True;
    repeat
      Tmp:= B^;
      if Borrow then begin
        Borrow:= Tmp = 0;
        Dec(Tmp);
      end;
      Tmp:= A^ xor Tmp;
      if Carry then begin
        Inc(Tmp);
        Carry:= Tmp = 0;
      end;
      Res^:= Tmp;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    until (LA = 0);

    repeat
      Tmp:= B^;
      if Borrow then begin
        Borrow:= Tmp = 0;
        Dec(Tmp);
      end;
      if Carry then begin
        Inc(Tmp);
        Carry:= Tmp = 0;
      end;
      Res^:= Tmp;
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0);
  end;
end;

// Res = (-A) xor (-B) = not(A-1) xor not(B-1) =
//     = (A-1) xor (B-1)
procedure arrXorTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal);
var
  BorrowA, BorrowB: Boolean;
  TmpA, TmpB: TLimb;

begin
  Assert(LA > 0);
  Assert(LB > 0);
  BorrowA:= True;
  BorrowB:= True;
  if (LA >= LB) then begin
    Dec(LA, LB);
    repeat
      TmpA:= A^;
      if BorrowA then begin
        BorrowA:= TmpA = 0;
        Dec(TmpA);
      end;
      TmpB:= B^;
      if BorrowB then begin
        BorrowB:= TmpB = 0;
        Dec(TmpB);
      end;
      Res^:= TmpA xor TmpB;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LB);
    until (LB = 0);
    if (LA > 0) then
      Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin
    Dec(LB, LA);
    repeat
      TmpA:= A^;
      if BorrowA then begin
        BorrowA:= TmpA = 0;
        Dec(TmpA);
      end;
      TmpB:= B^;
      if BorrowB then begin
        BorrowB:= TmpB = 0;
        Dec(TmpB);
      end;
      Res^:= TmpA xor TmpB;
      Inc(A);
      Inc(B);
      Inc(Res);
      Dec(LA);
    until (LA = 0);
    Move(B^, Res^, LB * SizeOf(TLimb));
  end;
end;

function arrMulLimb(A: PLimb; Limb: TLimb; Res: PLimb; L: Cardinal): Boolean;
var
  Tmp: TLimbVector;
  Carry: Cardinal;

begin
  Carry:= 0;
  while L > 0 do begin
    Tmp.Lo:= A^;
    Tmp.Hi:= 0;
    Tmp.Value:= Tmp.Value * Limb + Carry;
    Res^:= Tmp.Lo;
    Inc(A);
    Inc(Res);
    Carry:= Tmp.Hi;
    Dec(L);
  end;
  Res^:= Carry;
  Result:= Carry <> 0;
end;

// A:= A * Limb;
// A must have enough space for L + 1 limbs
// returns: True if senior (L+1)-th limb of the multiplication result is nonzero
function arrSelfMulLimb(A: PLimb; Limb: TLimb; L: Cardinal): Boolean;
var
  Tmp: TLimbVector;
  Carry: Cardinal;

begin
  Carry:= 0;
  while L > 0 do begin
    Tmp.Lo:= A^;
    Tmp.Hi:= 0;
    Tmp.Value:= Tmp.Value * Limb + Carry;
    A^:= Tmp.Lo;
    Inc(A);
    Carry:= Tmp.Hi;
    Dec(L);
  end;
  A^:= Carry;
  Result:= Carry <> 0;
end;

function arrCmp(A, B: PLimb; L: Cardinal): Integer;
begin
  if L > 0 then begin
    Inc(A, L - 1);
    Inc(B, L - 1);
    repeat
{$IFDEF TFL_EXITPARAM}
      if A^ > B^ then Exit(1);
      if A^ < B^ then Exit(-1);
{$ELSE}
      if A^ > B^ then begin
        Result:= 1;
        Exit;
      end;
      if A^ < B^ then begin
        Result:= -1;
        Exit;
      end;
{$ENDIF}
      Dec(A);
      Dec(B);
      Dec(L);
    until L = 0;
  end;
{$IFDEF TFL_EXITPARAM}
  Exit(0);
{$ELSE}
  Result:= 0;
  Exit;
{$ENDIF}
end;

// returns:
// - 0: error occured (EOutOfMemory raised)
// > 0: Rem Length in limbs
function arrNormSqrtRem(A, Root, Rem: PLimb; LA: Cardinal): Cardinal;
const
  SqrtTab1: array[0..255] of Byte = (
    $00, $00, $00, $01, $01, $02, $02, $03,
    $03, $04, $04, $05, $05, $06, $06, $07,
    $07, $08, $08, $09, $09, $0A, $0A, $0B,
    $0B, $0C, $0C, $0D, $0D, $0E, $0E, $0F,
    $0F, $10, $10, $10, $11, $11, $12, $12,
    $13, $13, $14, $14, $15, $15, $16, $16,
    $16, $17, $17, $18, $18, $19, $19, $1A,
    $1A, $1B, $1B, $1B, $1C, $1C, $1D, $1D,
    $1E, $1E, $1F, $1F, $20, $20, $20, $21,
    $21, $22, $22, $23, $23, $23, $24, $24,
    $25, $25, $26, $26, $27, $27, $27, $28,
    $28, $29, $29, $2A, $2A, $2A, $2B, $2B,
    $2C, $2C, $2D, $2D, $2D, $2E, $2E, $2F,
    $2F, $30, $30, $30, $31, $31, $32, $32,
    $32, $33, $33, $34, $34, $35, $35, $35,
    $36, $36, $37, $37, $37, $38, $38, $39,
    $39, $39, $3A, $3A, $3B, $3B, $3B, $3C,
    $3C, $3D, $3D, $3D, $3E, $3E, $3F, $3F,
    $40, $40, $40, $41, $41, $41, $42, $42,
    $43, $43, $43, $44, $44, $45, $45, $45,
    $46, $46, $47, $47, $47, $48, $48, $49,
    $49, $49, $4A, $4A, $4B, $4B, $4B, $4C,
    $4C, $4C, $4D, $4D, $4E, $4E, $4E, $4F,
    $4F, $50, $50, $50, $51, $51, $51, $52,
    $52, $53, $53, $53, $54, $54, $54, $55,
    $55, $56, $56, $56, $57, $57, $57, $58,
    $58, $59, $59, $59, $5A, $5A, $5A, $5B,
    $5B, $5B, $5C, $5C, $5D, $5D, $5D, $5E,
    $5E, $5E, $5F, $5F, $60, $60, $60, $61,
    $61, $61, $62, $62, $62, $63, $63, $63,
    $64, $64, $65, $65, $65, $66, $66, $66,
    $67, $67, $67, $68, $68, $68, $69, $69
);

  SqrtTab2: array[0..255] of Byte = (
    $6A, $6A, $6B, $6C, $6C, $6D, $6E, $6E,
    $6F, $70, $71, $71, $72, $73, $73, $74,
    $75, $75, $76, $77, $77, $78, $79, $79,
    $7A, $7B, $7B, $7C, $7D, $7D, $7E, $7F,
    $80, $80, $81, $81, $82, $83, $83, $84,
    $85, $85, $86, $87, $87, $88, $89, $89,
    $8A, $8B, $8B, $8C, $8D, $8D, $8E, $8F,
    $8F, $90, $90, $91, $92, $92, $93, $94,
    $94, $95, $96, $96, $97, $97, $98, $99,
    $99, $9A, $9B, $9B, $9C, $9C, $9D, $9E,
    $9E, $9F, $A0, $A0, $A1, $A1, $A2, $A3,
    $A3, $A4, $A4, $A5, $A6, $A6, $A7, $A7,
    $A8, $A9, $A9, $AA, $AA, $AB, $AC, $AC,
    $AD, $AD, $AE, $AF, $AF, $B0, $B0, $B1,
    $B2, $B2, $B3, $B3, $B4, $B5, $B5, $B6,
    $B6, $B7, $B7, $B8, $B9, $B9, $BA, $BA,
    $BB, $BB, $BC, $BD, $BD, $BE, $BE, $BF,
    $C0, $C0, $C1, $C1, $C2, $C2, $C3, $C3,
    $C4, $C5, $C5, $C6, $C6, $C7, $C7, $C8,
    $C9, $C9, $CA, $CA, $CB, $CB, $CC, $CC,
    $CD, $CE, $CE, $CF, $CF, $D0, $D0, $D1,
    $D1, $D2, $D3, $D3, $D4, $D4, $D5, $D5,
    $D6, $D6, $D7, $D7, $D8, $D9, $D9, $DA,
    $DA, $DB, $DB, $DC, $DC, $DD, $DD, $DE,
    $DE, $DF, $E0, $E0, $E1, $E1, $E2, $E2,
    $E3, $E3, $E4, $E4, $E5, $E5, $E6, $E6,
    $E7, $E7, $E8, $E8, $E9, $EA, $EA, $EB,
    $EB, $EC, $EC, $ED, $ED, $EE, $EE, $EF,
    $EF, $F0, $F0, $F1, $F1, $F2, $F2, $F3,
    $F3, $F4, $F4, $F5, $F5, $F6, $F6, $F7,
    $F7, $F8, $F8, $F9, $F9, $FA, $FA, $FB,
    $FB, $FC, $FC, $FD, $FD, $FE, $FE, $FF
);

var
  HighLimb0: TLimb;
  InitA, InitRoot: Cardinal;
  IsNorm: Boolean;
  NormalizedA: PLimb;
  DivRem: PLimb;
  X, Y, TmpXY: PLimb; //, NextX: PLimb;
  L, SaveL: Cardinal;
  Diff: Integer;
  Buffer: PLimb;
// Buffer structure:
// - NormalizedA: LA Limbs;
// - X: LA Limbs;
// - Y: LA Limbs;
begin
{$IFNDEF TFL_DLL}
                            // operand is at least 2 limbs long
  Assert(LA >= 2);
                            // operand consists of even number of limbs
  Assert(not Odd(LA));
                            // one or both of two most significant bits are set
  Assert(A[LA-1] shr (TLimbInfo.BitSize - 2) <> 0);
{$ENDIF}
  try
    GetMem(Buffer, LA * 3 * SizeOf(TLimb));
    X:= Buffer + LA;
    Y:= X + LA;

    HighLimb0:= A[LA-1];
    IsNorm:= HighLimb0 and (1 shl (TLimbInfo.BitSize - 1)) <> 0;

                              // get initial 9 bit approximation from tables
    InitA:= Cardinal(HighLimb0);
{$IF SizeOf(TLimb) = 1}
    InitA:= (InitA shl 8) or A[LA-2];
{$IFEND}

    if not IsNorm then begin
// the most significant bit of A is unset, the second most significant is set.
{$IF SizeOf(TLimb) = 1}
      InitRoot:= SqrtTab1[(InitA shr 6) and $FF];
{$ELSE}
      InitRoot:= SqrtTab1[(InitA shr (TLimbInfo.BitSize - 10)) and $FF];
{$IFEND}
    end
    else begin
// the most significant bit of A is set.
{$IF SizeOf(TLimb) = 1}
      InitRoot:= SqrtTab2[(InitA shr 7) and $FF];
{$ELSE}
      InitRoot:= SqrtTab2[(InitA shr (TLimbInfo.BitSize - 9)) and $FF];
{$IFEND}
    end;

{$IF SizeOf(TLimb) = 1}
    InitRoot:= (InitRoot or $100) shr 1;
{$ELSE}
    InitRoot:= ((InitRoot or $100) shl (SizeOf(Word) * 8 - 9)) or $7F;
{$IFEND}

{$IF SizeOf(TLimb) = 4}
    InitRoot:= ((InitRoot + (HighLimb0 div InitRoot)) shl 15) or $7FFF;
{$IFEND}

    if IsNorm then begin
      NormalizedA:= A;
    end
    else begin
      NormalizedA:= Buffer;
      arrShlOne(A, NormalizedA, LA);
    end;

    Move(InitRoot, X^, SizeOf(TLimb));

    L:= 1;
    repeat
      Move(NormalizedA^, DivRem^, L * (2 * SizeOf(TLimb)));
      arrNormDivMod(DivRem, X, Y, L * 2, L);

      if not IsNorm then
  // Quotient length is L+1 here, most significant bit is ignored
        arrShrOne(Y, Y, L);

      if L * 2 = LA then begin
  // fix most significant bit
        Y[L - 1]:= Y[L - 1] or (1 shl (TLimbInfo.BitSize - 1));
        Break;
      end;

      arrSelfAdd(X, Y, L, L);
      arrSelfShrOne(X, L);

  // fix most significant bit
      X[L - 1]:= X[L - 1] or (1 shl (TLimbInfo.BitSize - 1));

      SaveL:= L;
      L:= 2 * L;
      if L > (LA shr 1) then L:= LA shr 1;
      Move(X^, X[L - SaveL], SaveL);
      FillChar(X, (L - SaveL) * SizeOf(TLimb), $FF);

    until False;

    Diff:= arrCmp(X, Y, L);
    if Diff <> 0 then begin

// make sure X is approximation from above
      if Diff < 0 then begin
        TmpXY:= X;
        X:= Y;
        Y:= TmpXY;
      end;

      repeat

        Move(NormalizedA^, DivRem^, L * (2 * SizeOf(TLimb)));
        arrNormDivMod(DivRem, X, Y, L * 2, L);

        if not IsNorm then
          arrSelfShrOne(Y, L + 1);

        arrSelfAdd(Y, X, L, L);
        arrSelfShrOne(Y, L);

// fix most significant bit
        Y[L - 1]:= Y[L - 1] or (1 shl (TLimbInfo.BitSize - 1));

      until arrCmp(X, Y, L) <= 0;
    end;

    Move(X^, Root^, L * SizeOf(TLimb));
    if Rem <> nil then begin
      if not IsNorm then
        arrSelfShrOne(DivRem, L + 1);
      Move(DivRem^, Rem^, L * SizeOf(TLimb));
      Result:= arrGetLimbCount(DivRem, L);
    end
    else Result:= 1;

  except
    Result:= 0;
  end;

end;

// LA >= 1
// Root should have (LA + 1) shr 1 limbs at least
// returns:
// - 0: error occured (EOutOfMemory raised)
// > 0: Root Length in limbs
function arrSqrt(A, Root: PLimb; LA: Cardinal): Cardinal;

// the tables are used to obtain the initial root approximation
//   the initial approximation can also (and faster) be obtained
//   by using float SQRT function
const
  SqrtTabs: array[Boolean, Byte] of Byte = (
   (
    $00, $00, $00, $01, $01, $02, $02, $03,
    $03, $04, $04, $05, $05, $06, $06, $07,
    $07, $08, $08, $09, $09, $0A, $0A, $0B,
    $0B, $0C, $0C, $0D, $0D, $0E, $0E, $0F,
    $0F, $10, $10, $10, $11, $11, $12, $12,
    $13, $13, $14, $14, $15, $15, $16, $16,
    $16, $17, $17, $18, $18, $19, $19, $1A,
    $1A, $1B, $1B, $1B, $1C, $1C, $1D, $1D,
    $1E, $1E, $1F, $1F, $20, $20, $20, $21,
    $21, $22, $22, $23, $23, $23, $24, $24,
    $25, $25, $26, $26, $27, $27, $27, $28,
    $28, $29, $29, $2A, $2A, $2A, $2B, $2B,
    $2C, $2C, $2D, $2D, $2D, $2E, $2E, $2F,
    $2F, $30, $30, $30, $31, $31, $32, $32,
    $32, $33, $33, $34, $34, $35, $35, $35,
    $36, $36, $37, $37, $37, $38, $38, $39,
    $39, $39, $3A, $3A, $3B, $3B, $3B, $3C,
    $3C, $3D, $3D, $3D, $3E, $3E, $3F, $3F,
    $40, $40, $40, $41, $41, $41, $42, $42,
    $43, $43, $43, $44, $44, $45, $45, $45,
    $46, $46, $47, $47, $47, $48, $48, $49,
    $49, $49, $4A, $4A, $4B, $4B, $4B, $4C,
    $4C, $4C, $4D, $4D, $4E, $4E, $4E, $4F,
    $4F, $50, $50, $50, $51, $51, $51, $52,
    $52, $53, $53, $53, $54, $54, $54, $55,
    $55, $56, $56, $56, $57, $57, $57, $58,
    $58, $59, $59, $59, $5A, $5A, $5A, $5B,
    $5B, $5B, $5C, $5C, $5D, $5D, $5D, $5E,
    $5E, $5E, $5F, $5F, $60, $60, $60, $61,
    $61, $61, $62, $62, $62, $63, $63, $63,
    $64, $64, $65, $65, $65, $66, $66, $66,
    $67, $67, $67, $68, $68, $68, $69, $69),
   (
    $6A, $6A, $6B, $6C, $6C, $6D, $6E, $6E,
    $6F, $70, $71, $71, $72, $73, $73, $74,
    $75, $75, $76, $77, $77, $78, $79, $79,
    $7A, $7B, $7B, $7C, $7D, $7D, $7E, $7F,
    $80, $80, $81, $81, $82, $83, $83, $84,
    $85, $85, $86, $87, $87, $88, $89, $89,
    $8A, $8B, $8B, $8C, $8D, $8D, $8E, $8F,
    $8F, $90, $90, $91, $92, $92, $93, $94,
    $94, $95, $96, $96, $97, $97, $98, $99,
    $99, $9A, $9B, $9B, $9C, $9C, $9D, $9E,
    $9E, $9F, $A0, $A0, $A1, $A1, $A2, $A3,
    $A3, $A4, $A4, $A5, $A6, $A6, $A7, $A7,
    $A8, $A9, $A9, $AA, $AA, $AB, $AC, $AC,
    $AD, $AD, $AE, $AF, $AF, $B0, $B0, $B1,
    $B2, $B2, $B3, $B3, $B4, $B5, $B5, $B6,
    $B6, $B7, $B7, $B8, $B9, $B9, $BA, $BA,
    $BB, $BB, $BC, $BD, $BD, $BE, $BE, $BF,
    $C0, $C0, $C1, $C1, $C2, $C2, $C3, $C3,
    $C4, $C5, $C5, $C6, $C6, $C7, $C7, $C8,
    $C9, $C9, $CA, $CA, $CB, $CB, $CC, $CC,
    $CD, $CE, $CE, $CF, $CF, $D0, $D0, $D1,
    $D1, $D2, $D3, $D3, $D4, $D4, $D5, $D5,
    $D6, $D6, $D7, $D7, $D8, $D9, $D9, $DA,
    $DA, $DB, $DB, $DC, $DC, $DD, $DD, $DE,
    $DE, $DF, $E0, $E0, $E1, $E1, $E2, $E2,
    $E3, $E3, $E4, $E4, $E5, $E5, $E6, $E6,
    $E7, $E7, $E8, $E8, $E9, $EA, $EA, $EB,
    $EB, $EC, $EC, $ED, $ED, $EE, $EE, $EF,
    $EF, $F0, $F0, $F1, $F1, $F2, $F2, $F3,
    $F3, $F4, $F4, $F5, $F5, $F6, $F6, $F7,
    $F7, $F8, $F8, $F9, $F9, $FA, $FA, $FB,
    $FB, $FC, $FC, $FD, $FD, $FE, $FE, $FF)
);

var
  Shift: Cardinal;
  HighLimb0: TLimb;
  InitA, InitX, InitY: Cardinal;
//  IsNorm: Boolean;
  NormalizedA: PLimb;
  DivRem: PLimb;
  X, Y, TmpXY: PLimb; //, NextX: PLimb;
  LNorm, L1, L2: Cardinal;
  Diff: Integer;
  Buffer: PLimb;
// Buffer structure:
// - NormalizedA: LA + 1 Limbs;
// - X: LA Limbs;
// - Y: LA Limbs;
// - DivRem: LA Limbs;
begin

  Assert(LA > 0);

  if LA = 1 then begin
// this may be incorrect if SizeOf(Limb) >= 8
//   because Double mantisse < 64 bits
    Root^:= TLimb(Trunc(Sqrt(A^)));
    Result:= 1;
    Exit;
  end;

  HighLimb0:= A[LA-1];

  Shift:= SizeOf(TLimb) * 8;
  while HighLimb0 <> 0 do begin
    Dec(Shift);
    HighLimb0:= HighLimb0 shr 1;
  end;

//  IsNorm:= not Odd(Shift);
  Shift:= Shift and $FE;        // Shift should be even
(*
  if LA = 1 then begin
{$IF SizeOf(TLimb) = 1}
// get the result from the tables
    Inc(Shift, 8);
    InitA:= Cardinal(HighLimb0) shl Shift;
    InitX:= SqrtTabs[IsNorm, (InitA shr 7) and $FF] or $100;
{$ELSE}
    InitA:= Cardinal(HighLimb0) shl Shift;
    InitX:= SqrtTabs[IsNorm, (InitA shr (TLimbInfo.BitSize - 9)) and $FF];

// InitX is approximation from above, so +1
    InitX:= InitX or $100 + 1;

    if not IsNorm
      then InitA:= InitA shr 1;

{$IF SizeOf(TLimb) = 4}
    InitX:= InitX shl 8;
{$IFEND}

    repeat
      InitY:= (InitX + InitA div InitX) shr 1;
      if InitY >= InitX then Break;
      InitX:= InitY;
    until False;
{$IFEND}
    Root^:= TLimb(InitX shr (Shift shr 1));
    Result:= 1;
    Exit;
  end;
*)
  Assert(LA > 1);

  try
    GetMem(Buffer, (LA + 1) * 4 * SizeOf(TLimb));

    NormalizedA:= Buffer;
    X:= Buffer + LA + 1;
    Y:= X + LA;
    DivRem:= Y + LA;


    if Odd(LA) then begin
      arrShlShort(A, @NormalizedA[1], LA, Shift);
      NormalizedA[0]:= 0;
      LNorm:= LA + 1;
    end
    else begin
      arrShlShort(A, NormalizedA, LA, Shift);
      LNorm:= LA;
    end;

    HighLimb0:= NormalizedA[LNorm-1];
//    if not IsNorm then
//      HighLimb0:= HighLimb0 shr 1;
(*
                              // get initial 9 bit approximation from tables
    InitA:= Cardinal(HighLimb0);
{$IF SizeOf(TLimb) = 1}
    InitA:= InitA shl 8;
    if LA > 1 then InitA:= InitA or NormalizedA[LA-2];
{$IFEND}

{$IF SizeOf(TLimb) = 1}
    InitX:= SqrtTabs[IsNorm, (InitA shr 7) and $FF];
    InitX:= (InitX or $100) shr 1;
{$ELSE}
    InitX:= SqrtTabs[IsNorm, (InitA shr (TLimbInfo.BitSize - 9)) and $FF];
    InitX:= ((InitX or $100) shl (SizeOf(Word) * 8 - 9)) or $7F;
{$IFEND}

{$IF SizeOf(TLimb) = 4}
    if IsNorm then
      InitY:= HighLimb0 div InitX
    else
      InitY:= (HighLimb0 shr 1) div InitX;
    InitX:= ((InitX + InitY) shl 15) or $7FFF;
{$IFEND}
*)

// this may be incorrect if SizeOf(Limb) >= 8
//   because Double mantisse < 64 bits

//    InitX:= Trunc(Sqrt(HighLimb0 shl (Shift and $FE))) + 1;
//    Move(InitX, X^, SizeOf(TLimb));

    X^:= Trunc(Sqrt(HighLimb0));
    X^:= (X^ shl (TLimbInfo.BitSize shr 1))
         or (TLimbInfo.MaxLimb shr (TLimbInfo.BitSize shr 1));

// the first iteration gives lower half of X^

    Move(NormalizedA[LNorm-2], DivRem^, 2 * SizeOf(TLimb));

    arrDivModLimb(DivRem, Y, 2, X^);     // Y:= DivRem div X^



    if LNorm = 2 then begin
      if X^ <> Y^ then begin
// todo:
      end;
      X^:= ((X^ + Y^) shr 1) or (1 shl (TLimbInfo.BitSize - 1));
    end
    else begin
      X^:= ((X^ + Y^) shr 1) or (1 shl (TLimbInfo.BitSize - 1));
      L1:= 1;
      L2:= 2;
      repeat
        Move(NormalizedA[LA-L2], DivRem^, L2 * SizeOf(TLimb));

        arrNormDivMod(DivRem, X, Y, L2, L1);

        if L2 = LNorm then Break;

        arrSelfAdd(X, Y, L1, L1);
        arrSelfShrOne(X, L1 + 1);

        L1:= L2;
        L2:= L2 * 2;
        if L2 > LNorm then begin
          L2:= LNorm;
          L1:= L2 shr 1;
        end;

        Move(X^, X[L2 - L1], L1 * SizeOf(TLimb));
        FillChar(X^, (L2 - L1) * SizeOf(TLimb), $FF);

      until False;

      Diff:= arrCmp(X, Y, L1);
      if Diff <> 0 then begin

  // make sure X is approximation from above
        if Diff < 0 then begin
          TmpXY:= X;
          X:= Y;
          Y:= TmpXY;
        end;

        arrSelfAdd(Y, X, L1, L1);
        arrSelfShrOne(Y, L1 + 1);

        if arrCmp(X, Y, L1) > 0 then begin
          repeat
            Move(NormalizedA^, DivRem^, L2 * SizeOf(TLimb));

            if (L1 = 1) then begin
              arrDivModLimb(DivRem, Y, L2, X^);
            end
            else begin
              arrNormDivMod(DivRem, X, Y, L2, L1);
            end;

  //          if not IsNorm then
  //            arrSelfShrOne(Y, L1 + 1);

            arrSelfAdd(Y, X, L1, L1);
            arrSelfShrOne(Y, L1 + 1);

            if arrCmp(X, Y, L1) <= 0 then Break;
            TmpXY:= X;
            X:= Y;
            Y:= TmpXY;
          until False;
        end;
      end;
    end;
    arrShrShort(X, Root, L1, Shift shr 1);
    Result:= arrGetLimbCount(Root, L1);
  except
    Result:= 0;
  end;

end;

function arrShlShort(A, Res: PLimb; LA, Shift: Cardinal): Cardinal;
var
  Tmp, Carry: TLimb;

begin
  Assert(Shift < TLimbInfo.BitSize);
  Result:= LA;
  if Shift = 0 then begin
    Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin
    Carry:= 0;
    repeat
      Tmp:= (A^ shl Shift) or Carry;
      Carry:= A^ shr (TLimbInfo.BitSize - Shift);
      Res^:= Tmp;
      Inc(A);
      Inc(Res);
      Dec(LA);
    until (LA = 0);
    if Carry <> 0 then begin
      Res^:= Carry;
      Inc(Result);
    end;
  end;
end;

// Short Shift Right
// A = Res is acceptable
// LA >= 1
// Shift < 32
function arrShrShort(A, Res: PLimb; LA, Shift: Cardinal): Cardinal;
var
  Carry: TLimb;

begin
//  Assert(Shift < 32);
  Result:= LA;
  if Shift = 0 then begin
    Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin
    Carry:= A^ shr Shift;
    Inc(A);
    Dec(LA);
    while (LA > 0) do begin
      Res^:= (A^ shl (TLimbInfo.BitSize - Shift)) or Carry;
      Carry:= A^ shr Shift;
      Inc(A);
      Inc(Res);
      Dec(LA);
    end;
    if (Carry <> 0) or (Result = 1) then begin
      Res^:= Carry;
    end
    else begin
      Dec(Result);
    end;
  end;
end;

function arrShlOne(A, Res: PLimb; LA: Cardinal): Cardinal;
var
  Tmp, Carry: TLimb;

begin
  Result:= LA;
  Carry:= 0;
  repeat
    Tmp:= (A^ shl 1) or Carry;
    Carry:= A^ shr (TLimbInfo.BitSize - 1);
    Res^:= Tmp;
    Inc(A);
    Inc(Res);
    Dec(LA);
  until (LA = 0);
  if Carry <> 0 then begin
    Res^:= Carry;
    Inc(Result);
  end;
end;

function arrShrOne(A, Res: PLimb; LA: Cardinal): Cardinal;
var
  Carry: TLimb;

begin
  Result:= LA;
  Carry:= A^ shr 1;
  Inc(A);
  Dec(LA);
  while (LA > 0) do begin
    Res^:= (A^ shl (TLimbInfo.BitSize - 1)) or Carry;
    Carry:= A^ shr 1;
    Inc(A);
    Inc(Res);
    Dec(LA);
  end;
  if (Carry <> 0) or (Result = 1) then begin
    Res^:= Carry;
  end
  else begin
    Dec(Result);
  end;
end;

// LA >= 1
function arrSelfShrOne(A: PLimb; LA: Cardinal): Cardinal;
var
  Res: PLimb;

begin
  Result:= LA;
  Res:= A;
  Inc(A);
  Dec(LA);
  while (LA > 0) do begin
    Res^:= (Res^ shr 1) or (A^ shl (TLimbInfo.BitSize - 1));
    Inc(A);
    Inc(Res);
    Dec(LA);
  end;
  Res^:= Res^ shr 1;
  if Res^ = 0 then Dec(Result);
end;


// Q := A div D;
// Result:= A mod D;
function arrDivModLimb(A, Q: PLimb; L, D: TLimb): TLimb;
var
  Tmp: TLimbVector;

begin
  Dec(L);
  Inc(A, L);
  Inc(Q, L);
  Tmp.Lo:= A^;
  if Tmp.Lo >= D then begin
    Q^:= Tmp.Lo div D;
    Tmp.Hi:= Tmp.Lo mod D;
  end
  else begin
    Q^:= 0;
    Tmp.Hi:= Tmp.Lo;
  end;
  while L > 0 do begin
    Dec(A);
    Dec(Q);
    Tmp.Lo:= A^;
    Q^:= TLimb(Tmp.Value div D);
    Tmp.Hi:= TLimb(Tmp.Value mod D);
    Dec(L);
  end;
  Result:= Tmp.Hi;
end;

function arrSelfDivModLimb(A: PLimb; L: Cardinal; D: TLimb): TLimb;
var
  Tmp: TLimbVector;

begin
  Dec(L);
  Inc(A, L);
  Tmp.Lo:= A^;
  if Tmp.Lo >= D then begin
    A^:= Tmp.Lo div D;
    Tmp.Hi:= Tmp.Lo mod D;
  end
  else begin
    A^:= 0;
    Tmp.Hi:= Tmp.Lo;
  end;
  while L > 0 do begin
    Dec(A);
    Tmp.Lo:= A^;
    A^:= TLimb(Tmp.Value div D);
    Tmp.Hi:= TLimb(Tmp.Value mod D);
    Dec(L);
  end;
  Result:= Tmp.Hi;
end;

// normalized division (Divisor[DsrLen-1] and $80000000 <> 0)
// in: Dividend: Dividend;
//     Divisor: Divisor;
//     DndLen: Dividend Length
//     DsrLen: Divisor Length
// out: Quotient:= Dividend div Divisor
//      Dividend:= Dividend mod Divisor
procedure arrNormDivMod(Dividend, Divisor, Quotient: PLimb;
                        DndLen, DsrLen: TLimb);
var
  Tmp: TLimbVector;
  PDnd, PDsr: PLimb;
  QGuess, RGuess: TLimbVector;
  LoopCount, Count: Integer;
  TmpLimb, Carry: TLimb;
  CarryIn, CarryOut: Boolean;

begin
  Assert(DndLen > DsrLen);
  Assert(DsrLen >= 2);

  LoopCount:= DndLen - DsrLen;
  Inc(Quotient, LoopCount);

{$IFDEF TFL_POINTERMATH}
  PDnd:= Dividend + DndLen;
  PDsr:= Divisor + DsrLen;
{$ELSE}
  PDnd:= Dividend;
  Inc(PDnd, DndLen);
  PDsr:= Divisor;
  Inc(PDsr, DsrLen);
{$ENDIF}

  repeat
    Dec(PDnd);    // PDnd points to (current) senior dividend/remainder limb
    Dec(PDsr);    // PDns points to senior divisor limb
    Assert(PDnd^ <= PDsr^);

    Dec(Quotient);

// Делим число, составленное из двух старших цифр делимого на старшую цифру
//   делителя; это даст нам оценку очередной цифры частного QGuess

    if PDnd^ < PDsr^ then begin
{$IFDEF TFL_POINTERMATH}
      Tmp.Lo:= (PDnd - 1)^;
{$ELSE}
      Tmp.Lo:= GetLimb(PDnd, -1);
{$ENDIF}
      Tmp.Hi:= PDnd^;
      QGuess.Lo:= Tmp.Value div PDsr^;
      QGuess.Hi:= 0;
      RGuess.Lo:= Tmp.Value mod PDsr^;
      RGuess.Hi:= 0;
    end
    else begin
      QGuess.Lo:= 0;
      QGuess.Hi:= 1;
{$IFDEF TFL_POINTERMATH}
      RGuess.Lo:= (PDnd - 1)^;
{$ELSE}
      RGuess.Lo:= GetLimb(PDnd, -1);
{$ENDIF}
      RGuess.Hi:= 0;
    end;

// Для точного значения цифры частного Q имеем
//   QGuess - 2 <= Q <= QGuess;
//   улучшаем оценку

    repeat
      if (QGuess.Hi = 0) then begin
//   yмножаем вторую по старшинству цифру делителя на QGuess
{$IFDEF TFL_POINTERMATH}
        Tmp.Value:= (PDsr - 1)^ * QGuess.Value;
        if (Tmp.Hi < RGuess.Lo) then Break;
        if (Tmp.Hi = RGuess.Lo) and
           (Tmp.Lo <= (PDnd - 2)^) then Break;
{$ELSE}
        Tmp.Value:= GetLimb(PDsr, -1) * QGuess.Value;
        if (Tmp.Hi < RGuess.Lo) then Break;
        if (Tmp.Hi = RGuess.Lo) and
           (Tmp.Lo <= GetLimb(PDnd, -2)) then Break;
{$ENDIF}
        Dec(QGuess.Lo);
      end
      else begin
        QGuess.Lo:= TLimbInfo.MaxLimb;
        QGuess.Hi:= 0;
      end;
      RGuess.Value:= RGuess.Value + PDsr^;
    until RGuess.Hi <> 0;

// Здесь имеем QGuess - 1 <= Q <= QGuess;
// Вычитаем из делимого умноженный на QGuess делитель

    Count:= DsrLen;
{$IFDEF TFL_POINTERMATH}
    PDnd:= PDnd - Count;
{$ELSE}
    PDnd:= PDnd;
    Dec(PDnd, Count);
{$ENDIF}
    PDsr:= Divisor;
    Carry:= 0;
    repeat
      Tmp.Value:= PDsr^ * QGuess.Value + Carry;
      Carry:= Tmp.Hi;
      TmpLimb:= PDnd^ - Tmp.Lo;
      if (TmpLimb > PDnd^) then Inc(Carry);
      PDnd^:= TmpLimb;
      Inc(PDnd);
      Inc(PDsr);
      Dec(Count);
    until Count = 0;

    TmpLimb:= PDnd^ - Carry;
    if (TmpLimb > PDnd^) then begin
// если мы попали сюда значит QGuess = Q + 1;
// прибавляем делитель
      Count:= DsrLen;
{$IFDEF TFL_POINTERMATH}
      PDnd:= PDnd - Count;
{$ELSE}
      PDnd:= PDnd;
      Dec(PDnd, Count);
{$ENDIF}
      PDsr:= Divisor;
      CarryIn:= False;

      repeat
        TmpLimb:= PDnd^ + PDsr^;
        CarryOut:= TmpLimb < PDnd^;
        Inc(PDsr);
        if CarryIn then begin
          Inc(TmpLimb);
          CarryOut:= CarryOut or (TmpLimb = 0);
        end;
        CarryIn:= CarryOut;
        PDnd^:= TmpLimb;
        Inc(PDnd);
        Dec(Count);
      until Count = 0;

      Assert(CarryIn);

      Dec(QGuess.Lo);
    end;

// Возможно этот лимб больше не нужен и обнулять его необязательно
    PDnd^:= 0;

    Quotient^:= QGuess.Lo;
    Dec(LoopCount);
  until LoopCount = 0;

end;

end.
