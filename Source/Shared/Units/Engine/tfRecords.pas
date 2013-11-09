{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ *********************************************************** }

unit tfRecords;

{$I TFL.inc}

interface

uses tfTypes;

type
  PtfRecord = ^TtfRecord;
  TtfRecord = record
    FVTable: Pointer;
    FRefCount: Integer;
    class function QueryIntf(Inst: Pointer; const IID: TGUID;
                             out Obj): TF_RESULT; stdcall; static;
    class function Addref(Inst: Pointer): Integer; stdcall; static;
    class function Release(Inst: Pointer): Integer; stdcall; static;
  end;

implementation

class function TtfRecord.QueryIntf(Inst: Pointer; const IID: TGUID;
  out Obj): TF_RESULT;
begin
  Result:= TF_E_NOINTERFACE;
end;

{
  Warning: IUnknown uses ULONG (Longword) type for refcount;
           TtfRecord implementation uses LongInt because
           FRefCount = -1 is reserved for read-only constants
}

{$IFDEF xxCPU386}
function InterlockedAdd(var Addend: Integer; Increment: Integer): Integer;
asm
      MOV   ECX,EAX
      MOV   EAX,EDX
 LOCK XADD  [ECX],EAX
      ADD   EAX,EDX
end;

function InterlockedIncrement(var Addend: Integer): Integer;
asm
      MOV   EDX,1
      JMP   InterlockedAdd
end;

function InterlockedDecrement(var Addend: Integer): Integer;
asm
      MOV   EDX,-1
      JMP   InterlockedAdd
end;

class function TtfRecord.Addref(Inst: Pointer): Integer;
begin
// we need this check because FRefCount = -1 is allowed
  if PtfRecord(Inst).FRefCount > 0 then
    Result:= InterlockedIncrement(PtfRecord(Inst).FRefCount)
  else
    Result:= PtfRecord(Inst).FRefCount;
end;

class function TtfRecord.Release(Inst: Pointer): Integer;
begin
// we need this check because FRefCount = -1 is allowed
  if PtfRecord(Inst).FRefCount > 0 then begin
    Result:= InterlockedDecrement(PtfRecord(Inst).FRefCount);
    if Result = 0 then FreeMem(Inst);
  end
  else
    Result:= PtfRecord(Inst).FRefCount;
end;

{$ELSE}
class function TtfRecord.Addref(Inst: Pointer): Integer;
begin
// we need this check because FRefCount = -1 is allowed
  if PtfRecord(Inst).FRefCount > 0 then
    Inc(PtfRecord(Inst).FRefCount);
  Result:= PtfRecord(Inst).FRefCount;
end;

class function TtfRecord.Release(Inst: Pointer): Integer;
begin
// we need this check because FRefCount = -1 is allowed
  if PtfRecord(Inst).FRefCount > 0 then begin
    Dec(PtfRecord(Inst).FRefCount);
    Result:= PtfRecord(Inst).FRefCount;
    if Result = 0 then FreeMem(Inst);
  end
  else
    Result:= PtfRecord(Inst).FRefCount;
end;
{$ENDIF}

end.
