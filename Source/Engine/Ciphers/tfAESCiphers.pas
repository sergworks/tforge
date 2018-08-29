{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # AES cipher instance
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TBlockCipherInstance <--
         <-- TAESCipherInstance
}

unit tfAESCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfAlgAES, tfGHash, tfCipherInstances, //tfStreamCiphers,
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

    class function ExpandKeyIV(Inst: PAESCipherInstance; Key: PByte; KeySize: Cardinal;
                     IV: PByte; IVSize: Cardinal): TF_RESULT;
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

    class function ExpandKeyIV(Inst: PAesGcmCipherInstance; Key: PByte; KeySize: Cardinal;
                     IV: PByte; IVSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PAesGcmCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptBlock(Inst: PAesGcmCipherInstance; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetAESInstance(var A: Pointer; AlgID: TAlgID): TF_RESULT;

implementation

uses
  tfRecords, tfHelpers;

const
  ECBCipherVTable: array[0..29] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptUpdateECB,
    @TBlockCipherInstance.DecryptUpdateECB,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.DataMethodStub,
    @TBlockCipherInstance.EncryptECB,
    @TBlockCipherInstance.DecryptECB,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer,
    @TCipherInstance.SetKeyDir,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub
  );

  CBCCipherVTable: array[0..29] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptUpdateCBC,
    @TBlockCipherInstance.DecryptUpdateCBC,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.DataMethodStub,
    @TBlockCipherInstance.EncryptCBC,
    @TBlockCipherInstance.DecryptCBC,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer,
    @TCipherInstance.SetKeyDir,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub
  );

  CFBCipherVTable: array[0..29] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptUpdateCFB,
    @TBlockCipherInstance.DecryptUpdateCFB,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.DataMethodStub,
    @TBlockCipherInstance.EncryptCFB,
    @TBlockCipherInstance.DecryptCFB,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer,
    @TCipherInstance.SetKeyDir,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub
  );

  OFBCipherVTable: array[0..29] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptUpdateOFB,
    @TBlockCipherInstance.EncryptUpdateOFB,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.DataMethodStub,
    @TBlockCipherInstance.EncryptOFB,
    @TBlockCipherInstance.EncryptOFB,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer,
    @TCipherInstance.SetKeyDir,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub
  );

  CTRCipherVTable: array[0..29] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptUpdateCTR,
    @TBlockCipherInstance.EncryptUpdateCTR,
    @TAESCipherInstance.EncryptBlock,
    @TAESCipherInstance.DecryptBlock,
    @TBlockCipherInstance.GetKeyBlockCTR,
    @TBlockCipherInstance.GetKeyStreamCTR,
    @TBlockCipherInstance.EncryptCTR,
    @TBlockCipherInstance.EncryptCTR,
    @TCipherInstance.IsBlockCipher,
    @TBlockCipherInstance.IncBlockNoCTR,
    @TBlockCipherInstance.DecBlockNoCTR,
    @TBlockCipherInstance.SkipCTR,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce,
    @TBlockCipherInstance.GetIVPointer,
    @TCipherInstance.SetKeyDir,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.DataMethodStub
  );

  GcmCipherVTable: array[0..29] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAesGcmCipherInstance.Burn,
    @TAesGcmCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,          // todo: this is wrong
    @TAesGcmCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,     // todo: this is probably wrong
    @TCipherInstance.GetBlockSize128,
    @TBlockCipherInstance.EncryptUpdateECB,   // todo: this is wrong
    @TBlockCipherInstance.DecryptUpdateECB,   // todo: this is wrong
    @TAesGcmCipherInstance.EncryptBlock,
    @TAesGcmCipherInstance.DecryptBlock,
    @TCipherInstance.BlockMethodStub,
    @TCipherInstance.DataMethodStub,
    @TGcmCipherInstance.Encrypt,
    @TGcmCipherInstance.Decrypt,
    @TCipherInstance.IsBlockCipher,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TGcmCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,            // todo: this is wrong
    @TCipherInstance.DataMethodStub,
    @TCipherInstance.GetNonceStub,
    @TCipherInstance.GetIVPointerStub,
    @TCipherInstance.SetKeyDir,
    @TGcmCipherInstance.AddAuthData,
    @TGcmCipherInstance.ComputeTag,
    @TGcmCipherInstance.CheckTag
  );

function GetVTable(AlgID: TAlgID): Pointer;
begin
  case AlgID and TF_KEYMODE_MASK of
    TF_KEYMODE_ECB: Result:= @ECBCipherVTable;
    TF_KEYMODE_CBC: Result:= @CBCCipherVTable;
    TF_KEYMODE_CFB: Result:= @CFBCipherVTable;
    TF_KEYMODE_OFB: Result:= @OFBCipherVTable;
    TF_KEYMODE_CTR: Result:= @CTRCipherVTable;
    TF_KEYMODE_GCM: Result:= @GCMCipherVTable;
  else
    Result:= nil;
  end;
end;


function GetAESInstance(var A: Pointer; AlgID: TAlgID): TF_RESULT;
var
  Tmp: PAESCipherInstance;   // todo: should be PCipherInstance
  LVTable: Pointer;

begin
  LVTable:= GetVTable(AlgID);
  if LVTable = nil then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  try
    if LVTable = @GCMCipherVTable then
      Tmp:= AllocMem(SizeOf(TAesGcmCipherInstance))
    else
      Tmp:= AllocMem(SizeOf(TAESCipherInstance));
    Tmp.FVTable:= LVTable;
    Tmp.FRefCount:= 1;
    Tmp.FAlgID:= AlgID;

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
// direction (encryption/decryption) must be set
//   for all modes of operation except OFB and CTR
  if Inst.FAlgID and TF_KEYDIR_ENABLED = 0 then begin
    case Inst.FAlgID and TF_KEYMODE_MASK of
      TF_KEYMODE_OFB, TF_KEYMODE_CTR: ;
    else
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
  end;

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

class function TAesGcmCipherInstance.ExpandKeyIV(Inst: PAesGcmCipherInstance;
  Key: PByte; KeySize: Cardinal; IV: PByte; IVSize: Cardinal): TF_RESULT;
begin
// direction (encryption/decryption) must be set
//   for all modes of operation except OFB and CTR
  if Inst.FAlgID and TF_KEYDIR_ENABLED = 0 then begin
    case Inst.FAlgID and TF_KEYMODE_MASK of
      TF_KEYMODE_OFB, TF_KEYMODE_CTR: ;
    else
      Result:= TF_E_UNEXPECTED;
      Exit;
    end;
  end;

  Result:= Inst.FState.ExpandKey(Key, KeySize);
  if Result = TF_S_OK then
    Result:= TGcmCipherInstance.SetIV(PGcmCipherInstance(Inst), IV, IVSize);
  if Result = TF_S_OK then
    Inst.FKeyFlags:= Inst.FKeyFlags or TF_KEYFLAG_KEY;
end;

end.
