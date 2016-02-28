{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2016         * }
{ *********************************************************** }

unit tfLocks;

{$I TFL.inc}

interface

// currently only Windows OS supported
uses tfTypes, Windows; // {$IFDEF WINDOWS}, Windows{$ENDIF};

type
  TtfLock = record
    FMutex: THandle;
    function Acquire: TF_RESULT;
    function Resease: TF_RESULT;
  end;

implementation

{ TtfLock }

{ Initially FMutex field contains zero; TtfLock does not provide constructor
    or method to initialize the field because
    TtfLock instances are designed to be declared as a global variables.
    ===================================================================

  On the first lock attempt, FMutex field is initialized by a non-zero value.
  On collision, each thread attempts to create a mutex and compare-and-swap it
   into place as the FMutex field. On failure to swap in the FMutex field,
   the mutex is closed.
}

function TtfLock.Acquire: TF_RESULT;
var
  Tmp: THandle;

begin
  if FMutex = 0 then begin
    Tmp:= CreateMutex(nil, False, nil);
    if InterlockedCompareExchangePointer(Pointer(FMutex), Pointer(Tmp), nil) <> nil
      then CloseHandle(Tmp);
  end;
  if WaitForSingleObject(FMutex, INFINITE) = WAIT_OBJECT_0
    then Result:= TF_S_OK
    else Result:= TF_E_UNEXPECTED;
end;

function TtfLock.Resease: TF_RESULT;
begin
  ReleaseMutex(FMutex);
  Result:= TF_S_OK;
end;

end.
