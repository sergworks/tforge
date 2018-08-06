{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # AES in block cipher mode (ECB, CBC)
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TBlockCipherInstance <--
         <-- TAESCipherInstance
}

unit tfAESCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfAlgAES;

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

    class function ExpandKeyIV(Inst: PAESCipherInstance; Key: PByte; KeySize: Cardinal;
                     IV: PByte; IVSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PAESCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptBlock(Inst: PAESCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetAESInstance(var A: PAESCipherInstance; AlgID: TAlgID): TF_RESULT;

implementation

uses
  tfRecords, tfHelpers, tfCipherInstances, tfStreamCiphers, tfBlockCiphers;
(*
function GetAESBlockSize(Inst: Pointer): Integer; {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
begin
  Result:= TAESAlgorithm.BLOCK_SIZE;
end;
*)
const
  ECBCipherVTable: array[0..24] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptECB,
    @TBlockCipherInstance.DecryptECB,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TCipherInstance.GetKeyBlockStub,
    @TCipherInstance.GetKeyStreamStub,
    @TCipherInstance.ApplyKeyStreamStub,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer
  );

  CBCCipherVTable: array[0..24] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptCBC,
    @TBlockCipherInstance.DecryptCBC,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TCipherInstance.GetKeyBlockStub,
    @TCipherInstance.GetKeyStreamStub,
    @TCipherInstance.ApplyKeyStreamStub,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer
  );

  CTRCipherVTable: array[0..24] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TStreamCipherInstance.Encrypt,
    @TStreamCipherInstance.Encrypt,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TBlockCipherInstance.GetKeyBlockCTR,
    @TStreamCipherInstance.GetKeyStream,
    @TStreamCipherInstance.ApplyKeyStream,
    @TCipherInstance.IsStreamCipher,
    @TBlockCipherInstance.IncBlockNoCTR,
    @TBlockCipherInstance.DecBlockNoCTR,
    @TBlockCipherInstance.SkipCTR,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer
  );

function GetVTable(AlgID: TAlgID): Pointer;
begin
  case AlgID and TF_KEYMODE_MASK of
    TF_KEYMODE_ECB: Result:= @ECBCipherVTable;
    TF_KEYMODE_CBC: Result:= @CBCCipherVTable;
    TF_KEYMODE_CTR: Result:= @CTRCipherVTable;
  else
    Result:= nil;
  end;
end;

function GetAESInstance(var A: PAESCipherInstance; AlgID: TAlgID): TF_RESULT;
var
  Tmp: PAESCipherInstance;
  LVTable: Pointer;

begin
  LVTable:= GetVTable(AlgID);
  if LVTable = nil then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  try
    Tmp:= AllocMem(SizeOf(TAESCipherInstance));
    Tmp.FVTable:= LVTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FAlgID:= AlgID;
//    if A <> nil then TForgeHelper.Release(A);
    TForgeHelper.Free(A);
    A:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

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

class function TAESCipherInstance.ExpandKeyIV(Inst: PAESCipherInstance;
                 Key: PByte; KeySize: Cardinal; IV: PByte; IVSize: Cardinal): TF_RESULT;
begin
  Result:= Inst.FState.ExpandKey(Key, KeySize);
  if Result = TF_S_OK then
    Result:= TBlockCipherInstance.SetIV(Inst, IV, IVSize);
  if Result = TF_S_OK then
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_KEY;
end;

class function TAESCipherInstance.DecryptBlock(
                 Inst: PAESCipherInstance; Data: PByte): TF_RESULT;
begin
  Result:= Inst.FState.DecryptBlock(Data);
end;

end.
