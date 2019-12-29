{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # DES cipher instance
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TBlockCipherInstance <--
         <-- TDesInstance
}

unit tfDesCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfAlgDES, tfCipherInstances, tfBlockCiphers;

type
  PDesInstance = ^TDesInstance;
  TDesInstance = record
  private
{$HINTS OFF}                    // -- inherited fields begin --
                                // from TForgeInstance
    FVTable:   Pointer;
    FRefCount: Integer;
                                // from TCipherInstance
    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
                                // from TBlockCipherInstance
    FPos:      Integer;
    FCache:    array[0..7] of Byte;
    FIVector:  array[0..7] of Byte;
{$HINTS ON}

    FState:    TDesAlgorithm;

  public
    class function ExpandKey(Inst: PDESInstance; Key: PByte; KeySize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Clone(Inst: PDesInstance; var NewInst: PDesInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Burn(Inst: PDESInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PDESInstance; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

//    class function DecryptBlock(Inst: PDESAlgorithm; Data: PByte);
//          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

  PDes3Instance = ^TDes3Instance;
  TDes3Instance = record
  private
{$HINTS OFF}                    // -- inherited fields begin --
                                // from tfRecord
    FVTable:   Pointer;
    FRefCount: Integer;
                                // from TCipherInstance
    FAlgID:    TAlgID;
    FKeyFlags: TKeyFlags;
                                // from TBlockCipherInstance
    FPos:      Integer;
    FCache:    array[0..7] of Byte;
    FIVector:  array[0..7] of Byte;
{$HINTS ON}

    FState:    TDes3Algorithm;

  public
    class function ExpandKey(Inst: PDes3Instance;
          Key: PByte; KeySize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Clone(Inst: PDes3Instance; var NewInst: PDes3Instance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Burn(Inst: PDes3Instance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PDes3Instance; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

uses
  tfHelpers;

function GetEncryption(AlgID: TAlgID; out Encryption: Boolean): Boolean;
var
  LMode: TAlgID;
  LEncryption: Boolean;

begin
  LMode:= AlgID and TF_KEYMODE_MASK;

// for CFB, OFB and CTR modes the key is always expanded for encryption
//   (for GCM too, but GCM is not implemented for DES)
  LEncryption:= (LMode = TF_KEYMODE_CFB) or
                (LMode = TF_KEYMODE_OFB) or
                (LMode = TF_KEYMODE_CTR);

// for ECB and CBC modes we check encryption flag in FAlgID
  if not LEncryption then begin
    if AlgID and TF_KEYDIR_ENABLED = 0 then begin
      Result:= False;
      Exit;
    end;
    LEncryption:= AlgID and TF_KEYDIR_ENC <> 0;
  end;
  Encryption:= LEncryption;
  Result:= True;
end;

{ TDesInstance }

class procedure TDesInstance.Burn(Inst: PDESInstance);
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TDesInstance) - Integer(@PDesInstance(nil)^.FKeyFlags);
  FillChar(Inst.FKeyFlags, BurnSize, 0);
end;

class function TDesInstance.Clone(Inst: PDesInstance; var NewInst: PDESInstance): TF_RESULT;
var
  Tmp: PDesInstance;

begin
  try
    GetMem(Tmp, SizeOf(TDesInstance));
    Move(Inst^, Tmp^, SizeOf(TDesInstance));
    Tmp.FRefCount:= 1;

    TForgeHelper.Free(NewInst);
    NewInst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TDesInstance.EncryptBlock(Inst: PDESInstance; Data: PByte): TF_RESULT;
begin
  DesEncryptBlock(@Inst.FState.FSubKeys, Data);
  Result:= TF_S_OK;
end;

class function TDesInstance.ExpandKey(Inst: PDesInstance; Key: PByte;
                 KeySize: Cardinal): TF_RESULT;
var
  Encryption: Boolean;

begin
  if not GetEncryption(Inst.FAlgID, Encryption) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  Result:= Inst.FState.ExpandKey(Key, KeySize, Encryption);

  if Result = TF_S_OK then
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_KEY;
end;

{ TDes3Instance }

class procedure TDes3Instance.Burn(Inst: PDes3Instance);
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TDes3Instance) - Integer(@PDes3Instance(nil)^.FKeyFlags);
  FillChar(Inst.FKeyFlags, BurnSize, 0);
end;

class function TDes3Instance.Clone(Inst: PDes3Instance; var NewInst: PDes3Instance): TF_RESULT;
var
  Tmp: PDes3Instance;

begin
  try
    GetMem(Tmp, SizeOf(TDes3Instance));
    Move(Inst^, Tmp^, SizeOf(TDes3Instance));
    Tmp.FRefCount:= 1;

    TForgeHelper.Free(NewInst);
    NewInst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TDes3Instance.EncryptBlock(Inst: PDes3Instance; Data: PByte): TF_RESULT;
begin
  DesEncryptBlock(@Inst.FState.FSubKeys[0], Data);
  DesEncryptBlock(@Inst.FState.FSubKeys[1], Data);
  DesEncryptBlock(@Inst.FState.FSubKeys[2], Data);
  Result:= TF_S_OK;
end;

class function TDes3Instance.ExpandKey(Inst: PDes3Instance; Key: PByte;
                 KeySize: Cardinal): TF_RESULT;
var
  Encryption: Boolean;

begin
  if not GetEncryption(Inst.FAlgID, Encryption) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  Result:= Inst.FState.ExpandKey(Key, KeySize, Encryption);

  if Result = TF_S_OK then
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_KEY;
end;

end.
