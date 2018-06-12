program DivByConst;

{$mode delphi}

uses
  SysUtils, tfNumerics;
{$IFDEF Win32}
function Div5(Dividend: LongWord): LongWord; nostackframe;
const
  Mult = $CCCCCCCD;

asm
        MOV     EDX,Mult
        MUL     EDX
        MOV     EAX,EDX
        SHR     EAX,2
end;

function Div5_2(Dividend: LongWord): LongWord; nostackframe;
const
  Mult = $9999999A;

asm
        MOV     ECX,EAX     // save dividend
        MOV     EDX,Mult
        MUL     EDX
        MOV     EAX,ECX     // restore dividend
        ADD     EAX,EDX
        RCR     EAX,1       // because addition could produce carry
        SHR     EAX,2
end;

procedure GetConsts(Divisor: LongWord; BitSize: LongWord);
var
  L: LongWord;
  Tmp: LongWord;
  N, M, Mult: BigInteger;

begin
  Assert(Divisor > 1);
  Tmp:= Divisor;
  L:= 0;
  repeat            // count number of significant bits in Divisor
    Tmp:= Tmp shr 1;
    Inc(L);
  until Tmp = 0;
  N:= BigInteger(1) shl L;         // N = 2^L
  M:= BigInteger(1) shl BitSize;   // 2^32
  M:= (M * (N - Divisor)) div Divisor + 1;
  Mult:= LongWord(M);
  Writeln('Mult  = ' + Mult.ToHexString);
  Writeln('Shift = ' + IntToStr(L));
end;

function Div5Test: Boolean;
var
  Dividend: LongWord;

begin
  Dividend:= 0;
  repeat
    if Dividend div 5 <> Div5(Dividend) then begin
      Result:= False;
      Exit;
    end;
    Inc(Dividend);
  until Dividend = 0;
  Result:= True;
end;
{$ENDIF}
function TestDiv100(Dividend: UInt64): UInt64;
begin
  Result:= Dividend div 100;
end;

begin
//  GetConsts(641, 32);
//  GetConsts(100, 64);
//  Div5test;
  TestDiv100(1000);
  Readln;
end.

