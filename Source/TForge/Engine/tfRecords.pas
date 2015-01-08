{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfRecords;

{$I TFL.inc}

interface

uses tfTypes;

type
  PtfRecord = ^TtfRecord;
  TtfRecord = record
    FVTable: PPointer;
    FRefCount: Integer;
    class function QueryIntf(Inst: Pointer; const IID: TGUID;
                             out Obj): TF_RESULT; stdcall; static;
    class function AddRef(Inst: Pointer): Integer; stdcall; static;
    class function Release(Inst: Pointer): Integer; stdcall; static;
  end;

  PtfSingleton = ^TtfSingleton;
  TtfSingleton = record
    FVTable: PPointer;
//    FRefCount: Integer;
//    class function QueryIntf(Inst: Pointer; const IID: TGUID;
//                             out Obj): TF_RESULT; stdcall; static;
    class function AddRef(Inst: Pointer): Integer; stdcall; static;
    class function Release(Inst: Pointer): Integer; stdcall; static;
  end;

function tfIncrement(var Value: Integer): Integer;
function tfDecrement(var Value: Integer): Integer;

function ReleaseInstance(Inst: Pointer): Integer;
function HashAlgRelease(Inst: Pointer): Integer; stdcall;

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

{$IFDEF CPU386}
function InterlockedAdd(var Addend: Integer; Increment: Integer): Integer;
asm
      MOV   ECX,EAX
      MOV   EAX,EDX
 LOCK XADD  [ECX],EAX
      ADD   EAX,EDX
end;

function tfIncrement(var Value: Integer): Integer;
asm
      MOV   EDX,1
      JMP   InterlockedAdd
end;

function tfDecrement(var Value: Integer): Integer;
asm
      MOV   EDX,-1
      JMP   InterlockedAdd
end;

{$ELSE}
function tfIncrement(var Value: Integer): Integer;
begin
  Result:= Value + 1;
  Value:= Result;
end;

function tfDecrement(var Value: Integer): Integer;
begin
  Result:= Value - 1;
  Value:= Result;
end;
{$ENDIF}

class function TtfRecord.Addref(Inst: Pointer): Integer;
begin
// we need this check because FRefCount = -1 is allowed
  if PtfRecord(Inst).FRefCount > 0 then
    Result:= tfIncrement(PtfRecord(Inst).FRefCount)
  else
    Result:= PtfRecord(Inst).FRefCount;
end;

class function TtfRecord.Release(Inst: Pointer): Integer;
begin
// we need this check because FRefCount = -1 is allowed
  if PtfRecord(Inst).FRefCount > 0 then begin
    Result:= tfDecrement(PtfRecord(Inst).FRefCount);
    if Result = 0 then
//     begin
//      if PtfRecord(Inst).FVTable[3] <> nil then
//        TClearMemProc(PtfRecord(Inst).FVTable[3])(Inst);
      FreeMem(Inst);
//    end;
  end
  else
    Result:= PtfRecord(Inst).FRefCount;
end;

function ReleaseInstance(Inst: Pointer): Integer;
type
  TVTable = array[0..2] of Pointer;
  PVTable = ^TVTable;
  PPVTable = ^PVTable;

  TRelease = function(Inst: Pointer): Integer; stdcall;

begin
  Result:= TRelease(PPVTable(Inst)^^[2])(Inst);
end;

// release with purging sensitive information for hash algorithms
function HashAlgRelease(Inst: Pointer): Integer;
type
  TVTable = array[0..9] of Pointer;
  PVTable = ^TVTable;
  PPVTable = ^PVTable;

  TPurgeProc = procedure(Inst: Pointer);
               {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
var
  PurgeProc: Pointer;

begin
  if PtfRecord(Inst).FRefCount > 0 then begin
    Result:= tfDecrement(PtfRecord(Inst).FRefCount);
    if Result = 0 then begin
      PurgeProc:= PPVTable(Inst)^^[6];  // 6 is 'Purge' index
      TPurgeProc(PurgeProc)(Inst);
      FreeMem(Inst);
    end;
  end
  else
    Result:= PtfRecord(Inst).FRefCount;
end;

{ TtfSingleton }
{
class function TtfSingleton.QueryIntf(Inst: Pointer; const IID: TGUID;
  out Obj): TF_RESULT;
begin
  Result:= E_NOINTERFACE;
end;
}
class function TtfSingleton.Addref(Inst: Pointer): Integer;
begin
  Result:= -1;
end;

class function TtfSingleton.Release(Inst: Pointer): Integer;
begin
  Result:= -1;
end;

end.
