{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ * ------------------------------------------------------- * }
{ *   # engine unit                                         * }
{ *********************************************************** }

unit arrProcs;

{$I TFL.inc}

{$IFDEF TFL_LIMB32_ASM86}
  {.$DEFINE LIMB32_ASM86}
{$ENDIF}

interface

uses tfLimbs;

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

function arrShlShort(A, Res: PLimb; LA, Shift: Cardinal): Cardinal;
function arrShrShort(A, Res: PLimb; LA, Shift: Cardinal): Cardinal;

function arrShlOne(A, Res: PLimb; LA: Cardinal): Cardinal;
function arrShrOne(A, Res: PLimb; LA: Cardinal): Cardinal;

{ Bitwise boolean }
procedure arrAnd(A, B, Res: PLimb; LA, LB: Cardinal);
procedure arrAndTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
function arrAndTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal): Boolean;

procedure arrOr(A, B, Res: PLimb; LA, LB: Cardinal);
procedure arrOrTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
procedure arrOrTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal);

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
        JNC   @@Exit
        INC   EAX
        MOV   [EDI],1
@@Exit:
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
  if CarryIn then Res^:= 1;
//  else Res^:= 0;
  Result:= CarryIn;
end;
{$ENDIF}

{
  .Description:
    A:= A + B
  .Asserts:
    LA >= LB >= 1
    A must have enough space for LA + 1 limbs
  .Remarks:
    function returns True if carry is propagated out of A[LA-1];
    if function returns True the A senior limb is set: A[LA] = 1
    (A = B) coincidence is allowed
}
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
        JNC   @@Exit
        INC   EAX
        MOV   [EDI],1
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
//    Inc(A);
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
  if CarryIn then A^:= 1;
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
procedure arrAnd(A, B, Res: PLimb; LA, LB: Cardinal);
var
  L: Cardinal;

begin
  if (LA >= LB)
    then L:= LB
    else L:= LA;
  Assert(L > 0);
  repeat
     Res^:= A^ and B^;
     Inc(A);
     Inc(B);
     Inc(Res);
     Dec(L);
  until L = 0;
end;

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

// A < 0, B < 0
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
var
  LMin, L: Cardinal;

begin
  if (LA >= LB) then begin
    LMin:= LB;
    L:= LA - LB;
  end
  else begin
    LMin:= LA;
    L:= LB - LA;
  end;
  Assert(LMin > 0);
  repeat
    Res^:= A^ or B^;
    Inc(A);
    Inc(B);
    Inc(Res);
    Dec(LMin);
  until (LMin > 0);
  if (L > 0) then
    Move(A^, Res^, L * SizeOf(TLimb));
end;

procedure arrOrTwoCompl(A, B, Res: PLimb; LA, LB: Cardinal);
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
      Res^:= A^ or Tmp;
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
    if (LA > 0) then
      Move(A^, Res^, LA * SizeOf(TLimb));
  end
  else begin
    Assert(LA > 0);
    Dec(LB, LA);
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
    if (LB > 0) then
      Move(B^, Res^, LB * SizeOf(TLimb));
  end;
end;

procedure arrOrTwoCompl2(A, B, Res: PLimb; LA, LB: Cardinal);
var
  CarryA, CarryB, CarryR: Boolean;
  TmpA, TmpB: TLimb;
  SaveRes: PLimb;
  LMin, L: Cardinal;

begin
  CarryA:= True;
  CarryB:= True;
  SaveRes:= Res;
  if (LA >= LB) then begin
    LMin:= LB;
    L:= LA - LB;
  end
  else begin
    LMin:= LA;
    L:= LB - LA;
  end;
  Assert(LMin > 0);
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
    Res^:= TmpA or TmpB;
    Inc(A);
    Inc(B);
    Inc(Res);
    Dec(L);
  until (L = 0);
//  CarryR:= True;
  repeat
    SaveRes^:= not SaveRes^ + 1;
    CarryR:= (SaveRes^ = 0);
    Inc(SaveRes);
  until (SaveRes = Res) or not CarryR;
  while (SaveRes <> Res) do begin
    SaveRes^:= not SaveRes^;
    Inc(SaveRes);
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
//  QLen: LongWord;
  LoopCount, Count: Integer;
//  Tmp32, Carry: Cardinal;
  TmpLimb, Carry: Cardinal;
  CarryIn, CarryOut: Boolean;

begin
  Assert(DndLen > DsrLen);
  Assert(DsrLen >= 2);
//  QLen:= DndLen - DsrLen + 1;

//  Inc(Quotient, QLen);

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
        Tmp.Value:= UInt64((PDsr - 1)^) * QGuess.Value;
        if (Tmp.Hi < RGuess.Lo) then Break;
        if (Tmp.Hi = RGuess.Lo) and
           (Tmp.Lo <= (PDnd - 2)^) then Break;
{$ELSE}
        Tmp.Value:= UInt64(GetLimb(PDsr, -1)) * QGuess.Value;
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

//todo:

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

    Quotient^:= QGuess.Lo;
//    Dec(Quotient);
    Dec(LoopCount);
  until LoopCount = 0;

end;

end.
