{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfJenkinsOne;

{$I TFL.inc}

interface

uses tfTypes;

type
  PJenkinsOneAlg = ^TJenkinsOneAlg;
  TJenkinsOneAlg = record
  private
    FVTable: Pointer;
    FRefCount: Integer;
    FValue: LongWord;
  public
//    class function Release(Inst: PJenkinsOneAlg): Integer; stdcall; static;
    class procedure Init(Inst: PJenkinsOneAlg);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Update(Inst: PJenkinsOneAlg; Data: PByte; DataSize: LongWord);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Done(Inst: PJenkinsOneAlg; PDigest: PLongWord);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class procedure Purge(Inst: PJenkinsOneAlg);  -- redirected to Init
//         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetDigestSize(Inst: PJenkinsOneAlg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize(Inst: PJenkinsOneAlg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Duplicate(Inst: PJenkinsOneAlg; var DupInst: PJenkinsOneAlg): TF_RESULT;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetJenkinsOneAlgorithm(var Inst: PJenkinsOneAlg): TF_RESULT;

implementation

uses tfRecords, tfUtils;

const
  VTable: array[0..9] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfRecord.Addref,
    @HashAlgRelease,

    @TJenkinsOneAlg.Init,
    @TJenkinsOneAlg.Update,
    @TJenkinsOneAlg.Done,
    @TJenkinsOneAlg.Init,
    @TJenkinsOneAlg.GetDigestSize,
    @TJenkinsOneAlg.GetBlockSize,
    @TJenkinsOneAlg.Duplicate
  );

function GetJenkinsOneAlgorithm(var Inst: PJenkinsOneAlg): TF_RESULT;
var
  P: PJenkinsOneAlg;

begin
  try
    New(P);
    P^.FVTable:= @VTable;
    P^.FRefCount:= 1;
    P^.FValue:= 0;
    if Inst <> nil then HashAlgRelease(Inst);
    Inst:= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

{ TJenkinsOneAlg }

class procedure TJenkinsOneAlg.Init(Inst: PJenkinsOneAlg);
begin
  Inst.FValue:= 0;
end;

class procedure TJenkinsOneAlg.Update(Inst: PJenkinsOneAlg;
                                      Data: PByte; DataSize: LongWord);
begin
  while DataSize > 0 do begin
    Inst.FValue:= Inst.FValue + Data^;
    Inst.FValue:= Inst.FValue + (Inst.FValue shl 10);
    Inst.FValue:= Inst.FValue xor (Inst.FValue shr 6);
    Inc(Data);
    Dec(DataSize);
  end;
end;

class procedure TJenkinsOneAlg.Done(Inst: PJenkinsOneAlg; PDigest: PLongWord);
var
  P, PD: PByte;
  L: Integer;

begin
  Inst.FValue:= Inst.FValue + (Inst.FValue shl 3);
  Inst.FValue:= Inst.FValue xor (Inst.FValue shr 11);
  Inst.FValue:= Inst.FValue + (Inst.FValue shl 15);

//  PDigest^:= Inst.FValue;
  L:= 4;
  P:= @Inst.FValue;
  PD:= PByte(PDigest) + 4;
  repeat
    Dec(PD);
    PD^:= P^;
    Inc(P);
    Dec(L);
  until L = 0;

  Inst.FValue:= 0;
end;

class function TJenkinsOneAlg.GetDigestSize(Inst: PJenkinsOneAlg): LongInt;
begin
  Result:= SizeOf(LongWord);
end;

class function TJenkinsOneAlg.GetBlockSize(Inst: PJenkinsOneAlg): LongInt;
begin
  Result:= 0;
end;

class function TJenkinsOneAlg.Duplicate(Inst: PJenkinsOneAlg;
                                  var DupInst: PJenkinsOneAlg): TF_RESULT;
begin
  Result:= GetJenkinsOneAlgorithm(DupInst);
  if Result = TF_S_OK then
    DupInst.FValue:= Inst.FValue;
end;

end.
