{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # implements:
      TAesCipherInstance, TAesGcmCipherInstance
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TBlockCipherInstance <--
         <-- TAESCipherInstance
      TForgeInstance <-- TCipherInstance <-- TBlockCipherInstance <--
         <-- TGcmCipherInstance <-- TAesGcmCipherInstance
}

unit tfAESCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfAlgAES, tfGHash, tfCipherInstances,
   tfBlockCiphers, tfGcmCiphers;

type
  PAESCipherInstance = ^TAESCipherInstance;
  TAESCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
    FPos:      Integer;
    FCache:    TAESAlgorithm.TBlock;
    FIVector:  TAESAlgorithm.TBlock;
{$HINTS ON}
    FState:    TAESAlgorithm;
  public
    class procedure Burn(Inst: PAESCipherInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Clone(Inst: PAESCipherInstance; var NewInst: PAESCipherInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKey(Inst: PAESCipherInstance; Key: PByte; KeySize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PAESCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptBlock(Inst: PAESCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

  PAesGcmCipherInstance = ^TAesGcmCipherInstance;
  TAesGcmCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
    FPos:      Integer;
    FCache:    array[0..15] of Byte;
    FCounter:  array[0..15] of Byte;
    FH:        array[0..15] of Byte;
    FAuthSize: UInt64;
    FDataSize: UInt64;
    FGHash:    TGHash;
{$HINTS ON}
    FState:    TAESAlgorithm;
  public
    class procedure Burn(Inst: PAesGcmCipherInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Clone(Inst: PAesGcmCipherInstance; var NewInst: PAesGcmCipherInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKey(Inst: PAesGcmCipherInstance; Key: PByte; KeySize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PAesGcmCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptBlock(Inst: PAesGcmCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

uses
  tfHelpers;

{ TAESBlockCipherInstance }

class procedure TAESCipherInstance.Burn(Inst: PAESCipherInstance);
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TAESCipherInstance) - Integer(@PAESCipherInstance(nil)^.FKeyFlags);
  FillChar(Inst.FKeyFlags, BurnSize, 0);
end;

class function TAESCipherInstance.Clone(Inst: PAESCipherInstance;
                 var NewInst: PAESCipherInstance): TF_RESULT;
var
  Tmp: PAESCipherInstance;

begin
  try
    GetMem(Tmp, SizeOf(TAESCipherInstance));
    Move(Inst^, Tmp^, SizeOf(TAESCipherInstance));
    Tmp.FRefCount:= 1;

    TForgeHelper.Free(NewInst);
    NewInst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TAESCipherInstance.EncryptBlock(
                 Inst: PAESCipherInstance; Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.EncryptBlock(Data);
end;

class function TAESCipherInstance.ExpandKey(Inst: PAESCipherInstance;
                 Key: PByte; KeySize: Cardinal): TF_RESULT;
begin
  if not TBlockCipherInstance.InitInstance(Inst, TAESAlgorithm.BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  Result:= Inst.FState.ExpandKey(Key, KeySize);
  if Result = TF_S_OK then
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_KEY;
end;

class function TAESCipherInstance.DecryptBlock(
                 Inst: PAESCipherInstance; Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.DecryptBlock(Data);
end;

{ TAesGcmCipherInstance }

class procedure TAesGcmCipherInstance.Burn(Inst: PAesGcmCipherInstance);
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TAesGcmCipherInstance) - Integer(@PAesGcmCipherInstance(nil)^.FKeyFlags);
  FillChar(Inst.FKeyFlags, BurnSize, 0);
end;

class function TAesGcmCipherInstance.Clone(Inst: PAesGcmCipherInstance;
                 var NewInst: PAesGcmCipherInstance): TF_RESULT;
var
  Tmp: PAesGcmCipherInstance;

begin
  try
    GetMem(Tmp, SizeOf(TAesGcmCipherInstance));
    Move(Inst^, Tmp^, SizeOf(TAesGcmCipherInstance));
    Tmp.FRefCount:= 1;

    TForgeHelper.Free(NewInst);
    NewInst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TAesGcmCipherInstance.DecryptBlock(Inst: PAesGcmCipherInstance;
  Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.DecryptBlock(Data);
end;

class function TAesGcmCipherInstance.EncryptBlock(Inst: PAesGcmCipherInstance;
  Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.EncryptBlock(Data);
end;

class function TAesGcmCipherInstance.ExpandKey(Inst: PAesGcmCipherInstance;
                 Key: PByte; KeySize: Cardinal): TF_RESULT;
begin
  if not TBlockCipherInstance.InitInstance(Inst, TAESAlgorithm.BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  Result:= Inst.FState.ExpandKey(Key, KeySize);
  if Result = TF_S_OK then
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_KEY;
end;

end.
