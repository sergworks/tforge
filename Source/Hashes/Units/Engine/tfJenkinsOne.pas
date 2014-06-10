{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfJenkinsOne;

{$I TFL.inc}

interface

uses tfTypes;

function GetJenkinsOneAlgorithm(var Alg: IHashAlgorithm): TF_RESULT;

implementation

uses tfRecords, tfUtils;

type
  PJenkinsOneAlg = ^TJenkinsOneAlg;
  TJenkinsOneAlg = record
  private
    FVTable: Pointer;
    FRefCount: Integer;
    FValue: LongWord;
  public
    procedure Init;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Update(Data: PByte; DataSize: LongWord);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Done(PDigest: PLongWord);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetHashSize: LongInt;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Purge;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

const
  VTable: array[0..8] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfRecord.Addref,
    @TtfRecord.Release,
    nil,

    @TJenkinsOneAlg.Init,
    @TJenkinsOneAlg.Update,
    @TJenkinsOneAlg.Done,
    @TJenkinsOneAlg.GetHashSize,
    @TJenkinsOneAlg.Purge
  );

function GetJenkinsOneAlgorithm(var Alg: IHashAlgorithm): TF_RESULT;
var
  P: PJenkinsOneAlg;

begin
  Alg:= nil;
  try
    New(P);
    P^.FVTable:= @VTable;
    P^.FRefCount:= 1;
    P^.FValue:= 0;
    Pointer(Alg):= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

{ TJenkinsOneAlg }

procedure TJenkinsOneAlg.Init;
begin
  FValue:= 0;
end;

procedure TJenkinsOneAlg.Done(PDigest: PLongWord);
begin
  FValue:= FValue + (FValue shl 3);
  FValue:= FValue xor (FValue shr 11);
  FValue:= FValue + (FValue shl 15);
  PDigest^:= FValue;
  FValue:= 0;
end;

function TJenkinsOneAlg.GetHashSize: LongInt;
begin
  Result:= 4;
end;

procedure TJenkinsOneAlg.Purge;
begin
  FValue:= 0;
end;

procedure TJenkinsOneAlg.Update(Data: PByte; DataSize: LongWord);
begin
  while DataSize > 0 do begin
    FValue:= FValue + Data^;
    FValue:= FValue + (FValue shl 10);
    FValue:= FValue xor (FValue shr 6);
    Inc(Data);
    Dec(DataSize);
  end;
end;

end.
