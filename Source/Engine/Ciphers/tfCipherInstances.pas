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
    FKeyFlags: TKeyFlags;
//    FPos:      Integer;
{$HINTS ON}
   public
     class function ValidKey(Inst: Pointer): Boolean; static; inline;
     class function ValidEncryptionKey(Inst: Pointer): Boolean; static; inline;
     class function ValidDecryptionKey(Inst: Pointer): Boolean; static; inline;


(*    class function GetAlgID(Inst: PCipherInstance): TAlgID;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
    class function SetKeyDir(Inst: PCipherInstance; KeyDir: TAlgID): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ExpandKey(Inst: Pointer; Key: PByte; KeySize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKeyNonce(Inst: Pointer; Key: PByte; KeySize: Cardinal; Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function IsBlockCipher(Inst: Pointer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function IsStreamCipher(Inst: Pointer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize64(Inst: Pointer): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize128(Inst: Pointer): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

// not implemented stubs
    class function CloneStub(Inst: Pointer; var NewInst: Pointer): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function BlockMethodStub(Inst: Pointer; Data: PByte): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function EncryptBlockStub(Inst: Pointer; Data: PByte): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DataMethodStub(Inst: Pointer; Data: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptStub(Inst: Pointer; Data, OutData: PByte;
                     DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function IncBlockNoStub(Inst: Pointer; Count: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function SetIVStub(Inst: Pointer; IV: Pointer; IVLen: Cardinal): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetNonceStub(Inst: Pointer; Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function GetIVStub(Inst: Pointer; Data: Pointer; DataLen: Cardinal): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetNonceStub(Inst: Pointer; var Nonce: TNonce): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIVPointerStub(Inst: Pointer): Pointer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

uses
  tfCipherHelpers;

{ TCipherInstance }
(*
class function TCipherInstance.GetAlgID(Inst: PCipherInstance): TAlgID;
begin
  Result:= Inst.FAlgID;
end;
*)

// I assume here that derived class implements ExpandKeyIV
//   and inherits ExpandKey and ExpandKeyNonce implementations
//   from TCipherInstance
class function TCipherInstance.ExpandKey(Inst: Pointer; Key: PByte;
  KeySize: Cardinal): TF_RESULT;
begin
  Result:= TCipherHelper.ExpandKeyIV(Inst, Key, KeySize, nil, 0);
end;

class function TCipherInstance.ExpandKeyNonce(Inst: Pointer; Key: PByte;
  KeySize: Cardinal; Nonce: TNonce): TF_RESULT;
begin
//  Result:= TCipherHelper.ExpandKeyIV(Inst, Key, KeySize, nil, 0);
  Result:= TCipherHelper.ExpandKey(Inst, Key, KeySize);
  if Result = TF_S_OK then
    Result:= TCipherHelper.SetNonce(Inst, Nonce);
end;

{
class function TCipherInstance.GetIVStub(Inst, Data: Pointer; DataLen: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;
}
class function TCipherInstance.GetBlockSize128(Inst: Pointer): Integer;
begin
  Result:= 16;
end;

class function TCipherInstance.GetBlockSize64(Inst: Pointer): Integer;
begin
  Result:= 8;
end;

class function TCipherInstance.GetIVPointerStub(Inst: Pointer): Pointer;
begin
  Result:= nil;
end;

class function TCipherInstance.BlockMethodStub(Inst: Pointer;
                 Data: PByte): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TCipherInstance.DataMethodStub(Inst: Pointer;
                 Data: PByte; DataSize: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TCipherInstance.GetNonceStub(Inst: Pointer; var Nonce: TNonce): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TCipherInstance.EncryptStub(Inst: Pointer; Data, OutData: PByte;
                 DataSize: Cardinal; Last: Boolean): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

// IncBlocNo/DecBlockNo stub
class function TCipherInstance.IncBlockNoStub(Inst: Pointer;
  Count: UInt64): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TCipherInstance.IsBlockCipher(Inst: Pointer): Boolean;
begin
  Result:= True;
end;

class function TCipherInstance.IsStreamCipher(Inst: Pointer): Boolean;
begin
  Result:= False;
end;

{
class function TCipherInstance.SetIVStub(Inst, IV: Pointer; IVLen: Cardinal): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;
}
// SetKeyDir call must be followed by ExpandKey... call
class function TCipherInstance.SetKeyDir(Inst: PCipherInstance; KeyDir: TAlgID): TF_RESULT;
begin
  if KeyDir and not TF_KEYDIR_MASK <> 0 then
    Result:= TF_E_INVALIDARG
  else begin
    Inst.FAlgID:= Inst.FAlgID and not TF_KEYDIR_MASK;
    Inst.FAlgID:= Inst.FAlgID or KeyDir;
    Result:= TF_S_OK;
  end;
end;

class function TCipherInstance.SetNonceStub(Inst: Pointer; Nonce: TNonce): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

class function TCipherInstance.ValidDecryptionKey(Inst: Pointer): Boolean;
begin
  Result:= (PCipherInstance(Inst).FKeyFlags and TF_KEYFLAG_KEY <> 0) and
           ((PCipherInstance(Inst).FAlgID and TF_KEYDIR_ENABLED = 0) or
            (PCipherInstance(Inst).FAlgID and TF_KEYDIR_ENC = 0));
end;

class function TCipherInstance.ValidEncryptionKey(Inst: Pointer): Boolean;
begin
  Result:= (PCipherInstance(Inst).FKeyFlags and TF_KEYFLAG_KEY <> 0) and
           ((PCipherInstance(Inst).FAlgID and TF_KEYDIR_ENABLED = 0) or
            (PCipherInstance(Inst).FAlgID and TF_KEYDIR_ENC <> 0));
end;

class function TCipherInstance.ValidKey(Inst: Pointer): Boolean;
begin
  Result:= (PCipherInstance(Inst).FKeyFlags and TF_KEYFLAG_KEY <> 0);
end;

class function TCipherInstance.CloneStub(Inst: Pointer;
  var NewInst: Pointer): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;

// EncryptBlock/DecryptBlock stub
(*
class function TCipherInstance.EncryptBlockStub(Inst: Pointer;
  Data: PByte): TF_RESULT;
begin
  Result:= TF_E_NOTIMPL;
end;
*)
end.
