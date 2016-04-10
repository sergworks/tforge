{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2016         * }
{ ----------------------------------------------------------- }
{     linear congruential pseudorandom number generators      }
{ https://en.wikipedia.org/wiki/Linear_congruential_generator }
{ *********************************************************** }

unit tfLCGs;

interface

{$I TFL.inc}

uses tfRecords, tfTypes,
     {$IFDEF TFL_WINDOWS}tfWindows{$ELSE}tfStubOS{$ENDIF};

type
// linear congruential pseudorandom number generator modulo 2^32
  PLCG32 = ^TLCG32;
  TLCG32 = record
  private
    FVTable: Pointer;
    FRefCount: Integer;
    FSeed: LongWord;
    FMultiplier: LongWord;
    FIncrement: LongWord;
  public

    class function GetBuf(Inst: PLCG32; Buf: PByte; BufSize: LongWord): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function SetSeed(Inst: PLCG32; Buf: PByte; BufSize: LongWord): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

function GetLCG32Instance(var Inst: PLCG32; AMultiplier, AIncrement: LongWord): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

implementation

const
  LCG32VTable: array[0..4] of Pointer = (
   @TtfRecord.QueryIntf,
   @TtfRecord.Addref,
   @TtfRecord.Release,

   @TLCG32.GetBuf,
   @TLCG32.SetSeed
   );

function GetLCG32Instance(var Inst: PLCG32; AMultiplier, AIncrement: LongWord): TF_RESULT;
var
  P: PLCG32;

begin
  try
    GetMem(P, SizeOf(TLCG32));
    P^.FVTable:= @LCG32VTable;
    P^.FRefCount:= 1;
    P^.FMultiplier:= AMultiplier;
    P^.FIncrement:= AIncrement;
    Result:= GenRandom(P^.FSeed, SizeOf(P^.FSeed));
    if Result <> TF_S_OK then begin
      FreeMem(P);
      Exit;
    end;
    if Inst <> nil then TtfRecord.Release(Inst);
    Inst:= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

function Random: LongWord;
begin
  Result:= RandSeed * $08088405 + 1;
  RandSeed:= Result;
end;

{ TLCG32 }

class function TLCG32.GetBuf(Inst: PLCG32; Buf: PByte;
  BufSize: LongWord): TF_RESULT;
begin

end;

class function TLCG32.SetSeed(Inst: PLCG32; Buf: PByte;
  BufSize: LongWord): TF_RESULT;
begin
  if BufSize >= SizeOf(LongWord) then begin
    Inst.FSeed:= PLongWord(Buf)^;
  end
  else begin
    Inst.FSeed:= 0;
    if BufSize > 0 then
      Move(Buf^, Inst.FSeed, BufSize);
  end;
  Result:= TF_S_OK;
end;

end.
