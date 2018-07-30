{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # abstract cipher class
  # inheritance:
      TForgeInstance <-- TCipherInstance
}

unit tfCipherInstances;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  PCipherInstance = ^TCipherInstance;
  TCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: UInt32;
    FPos:      Cardinal;
{$HINTS ON}

  public
(*    class function GetAlgID(Inst: PCipherInstance): TAlgID;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
    class function GetKeyBlockStub(Inst: Pointer; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyStreamStub(Inst: Pointer; Data: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ApplyKeyStreamStub(Inst: Pointer; Data, OutData: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function IncBlockNoStub(Inst: Pointer; Count: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlockStub(Inst: Pointer; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

{ TCipherInstance }
(*
class function TCipherInstance.GetAlgID(Inst: PCipherInstance): TAlgID;
begin
  Result:= Inst.FAlgID;
end;
*)

class function TCipherInstance.GetKeyBlockStub(Inst: Pointer;
                 Data: PByte): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TCipherInstance.GetKeyStreamStub(Inst: Pointer;
                 Data: PByte; DataSize: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TCipherInstance.ApplyKeyStreamStub(Inst: Pointer; Data,
  OutData: PByte; DataSize: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

// IncBlocNo/DecBlockNo stub
class function TCipherInstance.IncBlockNoStub(Inst: Pointer;
  Count: UInt64): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

// EncryptBlock/DecryptBlock stub
class function TCipherInstance.EncryptBlockStub(Inst: Pointer;
  Data: PByte): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

end.
