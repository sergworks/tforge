{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
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

function tfAddrefInstance(Inst: Pointer): Integer;
function tfReleaseInstance(Inst: Pointer): Integer;
procedure tfFreeInstance(Inst: Pointer);
function tfTryAllocMem(var P: Pointer; Size: Integer): TF_RESULT;
function tfTryGetMem(var P: Pointer; Size: Integer): TF_RESULT;

function HashAlgRelease(Inst: Pointer): Integer; stdcall;

implementation

function tfTryAllocMem(var P: Pointer; Size: Integer): TF_RESULT;
begin
  try
    P:= AllocMem(Size);
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

function tfTryGetMem(var P: Pointer; Size: Integer): TF_RESULT;
begin
  try
    GetMem(P, Size);
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;


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

{$IFDEF TFL_CPUX86_32}
{ We assume register calling conventions for any 32-bit OS}
(*
function InterlockedAdd(var Addend: Integer; Increment: Integer): Integer;
{$IFDEF FPC}nostackframe;{$ENDIF}
asm
      MOV   ECX,EAX
      MOV   EAX,EDX
 LOCK XADD  [ECX],EAX
      ADD   EAX,EDX
end;
*)

function tfIncrement(var Value: Integer): Integer;
{$IFDEF FPC}assembler; nostackframe;{$ENDIF}
asm
      MOV   ECX,EAX
      MOV   EAX,1
 LOCK XADD  [ECX],EAX
      INC   EAX
end;

function tfDecrement(var Value: Integer): Integer;
{$IFDEF FPC}assembler; nostackframe;{$ENDIF}
asm
      MOV   ECX,EAX
      MOV   EAX,-1
 LOCK XADD  [ECX],EAX
      DEC   EAX
end;

{$ELSE}
{$IFDEF TFL_CPUX86_WIN64}
(*
function InterlockedAdd(var Addend: Integer; Increment: Integer): Integer;
{$IFDEF FPC}nostackframe;{$ENDIF}
asm
      MOV   EAX,EDX
 LOCK XADD  DWORD [RCX],EAX
      ADD   EAX,EDX
end;
*)
function tfIncrement(var Value: Integer): Integer;
{$IFDEF FPC}assembler; nostackframe;{$ENDIF}
asm
      MOV   EAX,1
 LOCK XADD  DWORD [RCX],EAX
      INC   EAX
end;

function tfDecrement(var Value: Integer): Integer;
{$IFDEF FPC}assembler; nostackframe;{$ENDIF}
asm
      MOV   EAX,-1
 LOCK XADD  DWORD [RCX],EAX
      DEC   EAX
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

function tfAddrefInstance(Inst: Pointer): Integer;
type
  TVTable = array[0..2] of Pointer;
  PVTable = ^TVTable;
  PPVTable = ^PVTable;

  TAddref = function(Inst: Pointer): Integer; stdcall;

begin
  Result:= TAddref(PPVTable(Inst)^^[1])(Inst);
end;


function tfReleaseInstance(Inst: Pointer): Integer;
type
  TVTable = array[0..2] of Pointer;
  PVTable = ^TVTable;
  PPVTable = ^PVTable;

  TRelease = function(Inst: Pointer): Integer; stdcall;

begin
  Result:= TRelease(PPVTable(Inst)^^[2])(Inst);
end;

procedure tfFreeInstance(Inst: Pointer);
begin
  if Inst <> nil then tfReleaseInstance(Inst);
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
