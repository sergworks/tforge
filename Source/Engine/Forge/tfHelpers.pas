{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # due to inlining the unit should be 'used'
      in implementation section of other units
}

unit tfHelpers;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  TForgeHelper = record
  private type
    TVTable = array[0..4] of Pointer;
    PVTable = ^TVTable;
    PPVTable = ^PVTable;
  public type
//  not used so commented out
//    TQueryIntfFunc = function(Inst: Pointer; const IID: TGUID; out Obj): TF_RESULT; stdcall;
    TStdInstFunc = function(Inst: Pointer): Integer; stdcall;
    TInstProc = procedure(Inst: Pointer); {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TCloneFunc = function(Inst: Pointer; var NewInst: Pointer): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

  public
    class procedure AddRef(Inst: Pointer); static; inline;
    class procedure Release(Inst: Pointer); static; inline;
    class procedure Free(Inst: Pointer); static; inline;
    class procedure Burn(Inst: Pointer); static; inline;
    class function Clone(Inst: Pointer; var NewInst: Pointer): TF_RESULT; static; inline;
  end;

implementation

const
  INDEX_ADDREF  = 1;
  INDEX_RELEASE = 2;
  INDEX_BURN    = 3;
  INDEX_CLONE   = 4;

{ TForgeHelper }

class procedure TForgeHelper.AddRef(Inst: Pointer);
begin
  TStdInstFunc(PPVTable(Inst)^^[INDEX_ADDREF])(Inst);
end;

class procedure TForgeHelper.Release(Inst: Pointer);
begin
  TStdInstFunc(PPVTable(Inst)^^[INDEX_RELEASE])(Inst);
end;

class procedure TForgeHelper.Free(Inst: Pointer);
begin
  if Inst <> nil then TStdInstFunc(PPVTable(Inst)^^[INDEX_RELEASE])(Inst);
end;

class procedure TForgeHelper.Burn(Inst: Pointer);
begin
  TInstProc(PPVTable(Inst)^^[INDEX_BURN])(Inst);
end;

class function TForgeHelper.Clone(Inst: Pointer; var NewInst: Pointer): TF_RESULT;
begin
  Result:= TCloneFunc(PPVTable(Inst)^^[INDEX_CLONE])(Inst, NewInst);
end;

end.
