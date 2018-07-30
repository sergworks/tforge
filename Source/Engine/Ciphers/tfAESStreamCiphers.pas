{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # AES in stream cipher mode (CTR, GCM)
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TStreamCipherInstance <--
         <-- TAESStreamCipherInstance
}

unit tfAESStreamCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfStreamCiphers, tfAlgAES;

type
  PAESStreamCipherInstance = ^TAESStreamCipherInstance;
  TAESStreamCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FValidKey: Boolean;
    FAlgID:    TAlgID;
    FPos:      Cardinal;       // 0 .. BlockSize - 1
{$HINTS ON}
    FState:    TAESAlgorithm;
  public
    class procedure Burn(Inst: PAESStreamCipherInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Clone(Inst: PAESStreamCipherInstance; var NewInst: PAESStreamCipherInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKeyIV(Inst: PAESStreamCipherInstance; Key: PByte; KeySize: Cardinal;
                     IV: PByte; IVSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PAESStreamCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptBlock(Inst: PAESStreamCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

uses
  tfHelpers;

{ TAESStreamCipherInstance }

class procedure TAESStreamCipherInstance.Burn(Inst: PAESStreamCipherInstance);
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TAESStreamCipherInstance) - Integer(@PAESStreamCipherInstance(nil)^.FPos);
  FillChar(Inst.FPos, BurnSize, 0);
  Inst.FValidKey:= False;
end;

class function TAESStreamCipherInstance.Clone(Inst: PAESStreamCipherInstance;
                 var NewInst: PAESStreamCipherInstance): TF_RESULT;
var
  Tmp: PAESStreamCipherInstance;

begin
  try
    GetMem(Tmp, SizeOf(TAESStreamCipherInstance));
    Move(Inst^, Tmp^, SizeOf(TAESStreamCipherInstance));
    Tmp.FRefCount:= 1;

    TForgeHelper.Free(NewInst);
    NewInst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TAESStreamCipherInstance.DecryptBlock(
                 Inst: PAESStreamCipherInstance; Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.DecryptBlock(Data);
end;

class function TAESStreamCipherInstance.EncryptBlock(
                 Inst: PAESStreamCipherInstance; Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.EncryptBlock(Data);
end;

class function TAESStreamCipherInstance.ExpandKeyIV(
                 Inst: PAESStreamCipherInstance; Key: PByte; KeySize: Cardinal;
                 IV: PByte; IVSize: Cardinal): TF_RESULT;
begin
  Result:= Inst.FState.ExpandKey(Key, KeySize);
//todo:
  //  if Result = TF_S_OK then
//    Result:= TBlockCipherInstance.SetIV(Inst, IV, IVSize);
  Inst.FValidKey:= Result = TF_S_OK;
end;

end.
