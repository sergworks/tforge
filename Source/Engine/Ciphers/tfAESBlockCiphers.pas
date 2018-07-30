{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # AES in block cipher mode (ECB, CBC)
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TBlockCipherInstance <--
         <-- TAESBlockCipherInstance
}

unit tfAESBlockCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfBlockCiphers, tfAlgAES;

type
  PAESBlockCipherInstance = ^TAESBlockCipherInstance;
  TAESBlockCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: UInt32;
    FPos:      Cardinal;
    FIVector:  TAESAlgorithm.TBlock;
{$HINTS ON}
    FState:    TAESAlgorithm;
  public
    class procedure Burn(Inst: PAESBlockCipherInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Clone(Inst: PAESBlockCipherInstance; var NewInst: PAESBlockCipherInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKeyIV(Inst: PAESBlockCipherInstance; Key: PByte; KeySize: Cardinal;
                     IV: PByte; IVSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PAESBlockCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptBlock(Inst: PAESBlockCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

uses
  tfHelpers;

{ TAESBlockCipherInstance }

class procedure TAESBlockCipherInstance.Burn(Inst: PAESBlockCipherInstance);
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TAESBlockCipherInstance) - Integer(@PAESBlockCipherInstance(nil)^.FKeyFlags);
  FillChar(Inst.FKeyFlags, BurnSize, 0);
end;

class function TAESBlockCipherInstance.Clone(Inst: PAESBlockCipherInstance;
                 var NewInst: PAESBlockCipherInstance): TF_RESULT;
var
  Tmp: PAESBlockCipherInstance;

begin
  try
    GetMem(Tmp, SizeOf(TAESBlockCipherInstance));
    Move(Inst^, Tmp^, SizeOf(TAESBlockCipherInstance));
    Tmp.FRefCount:= 1;

    TForgeHelper.Free(NewInst);
    NewInst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TAESBlockCipherInstance.EncryptBlock(
                 Inst: PAESBlockCipherInstance; Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.EncryptBlock(Data);
end;

class function TAESBlockCipherInstance.ExpandKeyIV(Inst: PAESBlockCipherInstance;
                 Key: PByte; KeySize: Cardinal; IV: PByte; IVSize: Cardinal): TF_RESULT;
begin
  Result:= Inst.FState.ExpandKey(Key, KeySize);
  if Result = TF_S_OK then
    Result:= TBlockCipherInstance.SetIV(Inst, IV, IVSize);
  if Result = TF_S_OK then
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_KEY;
end;

class function TAESBlockCipherInstance.DecryptBlock(
                 Inst: PAESBlockCipherInstance; Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.DecryptBlock(Data);
end;

end.
