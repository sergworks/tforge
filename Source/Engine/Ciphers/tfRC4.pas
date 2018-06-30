{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfRC4;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  PRC4Instance = ^TRC4Instance;
  TRC4Instance = record
  private type
    PState = ^TState;
    TState = record
      S: array[0..255] of Byte;
      I, J: Byte;
    end;

  private
{$HINTS OFF}                    // -- inherited fields begin --
                                // from tfRecord
    FVTable:   Pointer;
    FRefCount: Integer;
                                // from tfBaseStreamCipher
    FValidKey: Boolean;
    FAlgID:    UInt32;
                                // -- inherited fields end --
    FState:    TState;
{$HINTS ON}
  public
    class function Release(Inst: PRC4Instance): Integer; stdcall; static;
    class function ExpandKey(Inst: PRC4Instance; Key: PByte; KeySize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize(Inst: PRC4Instance): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DuplicateKey(Inst: PRC4Instance; var Key: PRC4Instance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure DestroyKey(Inst: PRC4Instance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RandBlock(Inst: PRC4Instance; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKeyIV(Inst: PRC4Instance; Key: PByte; KeySize: Cardinal;
          IV: Pointer; IVSize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKeyNonce(Inst: PRC4Instance; Key: PByte; KeySize: Cardinal;
          Nonce: UInt64): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetRC4Instance(var A: PRC4Instance): TF_RESULT;

implementation

uses tfRecords, tfBaseCiphers;

const
  RC4VTable: array[0..18] of Pointer = (
   @TForgeInstance.QueryIntf,
   @TForgeInstance.Addref,
   @TRC4Instance.Release,

   @TRC4Instance.DestroyKey,
   @TRC4Instance.DuplicateKey,
   @TRC4Instance.ExpandKey,
   @TBaseStreamCipher.SetKeyParam,
   @TBaseStreamCipher.GetKeyParam,
   @TRC4Instance.GetBlockSize,
   @TBaseStreamCipher.Encrypt,
//   @TBaseStreamCipher.Decrypt,
   @TBaseStreamCipher.Encrypt,
   @TBaseStreamCipher.EncryptBlock,
   @TBaseStreamCipher.EncryptBlock,
   @TBaseStreamCipher.GetRand,
   @TRC4Instance.RandBlock,
   @TBaseStreamCipher.RandCrypt,
   @TBaseStreamCipher.GetIsBlockCipher,
   @TRC4Instance.ExpandKeyIV,
   @TRC4Instance.ExpandKeyNonce
   );

function GetRC4Instance(var A: PRC4Instance): TF_RESULT;
var
  Tmp: PRC4Instance;

begin
  try
    Tmp:= AllocMem(SizeOf(TRC4Instance));
    Tmp^.FVTable:= @RC4VTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FAlgID:= TF_ALG_RC4;
    if A <> nil then TRC4Instance.Release(A);
    A:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

{ TRC4Algorithm }

procedure BurnKey(Inst: PRC4Instance); inline;
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TRC4Instance)
             - Integer(@PRC4Instance(nil)^.FValidKey);
  FillChar(Inst.FValidKey, BurnSize, 0);
end;

class function TRC4Instance.Release(Inst: PRC4Instance): Integer;
begin
  if Inst.FRefCount > 0 then begin
    Result:= tfDecrement(Inst.FRefCount);
    if Result = 0 then begin
      BurnKey(Inst);
      FreeMem(Inst);
    end;
  end
  else
    Result:= Inst.FRefCount;
end;

class procedure TRC4Instance.DestroyKey(Inst: PRC4Instance);
begin
  BurnKey(Inst);
end;

class function TRC4Instance.DuplicateKey(Inst: PRC4Instance;
  var Key: PRC4Instance): TF_RESULT;
begin
  Result:= GetRC4Instance(Key);
  if Result = TF_S_OK then begin
    Key.FValidKey:= Inst.FValidKey;
    Key.FState:= Inst.FState;
  end;
end;

class function TRC4Instance.ExpandKey(Inst: PRC4Instance; Key: PByte;
  KeySize: Cardinal): TF_RESULT;
var
  I: Cardinal;
  J, Tmp: Byte;

begin
  I:= 0;
  repeat
    Inst.FState.S[I]:= I;
    Inc(I);
  until I = 256;
  I:= 0;
  J:= 0;
  repeat
    J:= J + Inst.FState.S[I] + Key[I mod KeySize];
    Tmp:= Inst.FState.S[I];
    Inst.FState.S[I]:= Inst.FState.S[J];
    Inst.FState.S[J]:= Tmp;
    Inc(I);
  until I = 256;
  Inst.FState.I:= 0;
  Inst.FState.J:= 0;

  Inst.FValidKey:= True;
  Result:= TF_S_OK;
end;

class function TRC4Instance.ExpandKeyIV(Inst: PRC4Instance; Key: PByte;
  KeySize: Cardinal; IV: Pointer; IVSize: Cardinal): TF_RESULT;
begin
  if (IV <> nil) or (IVSize <> 0) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  Result:= ExpandKey(Inst, Key, KeySize);
end;

class function TRC4Instance.ExpandKeyNonce(Inst: PRC4Instance; Key: PByte;
  KeySize: Cardinal; Nonce: UInt64): TF_RESULT;
begin
  if (Nonce <> 0) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  Result:= ExpandKey(Inst, Key, KeySize);
end;

class function TRC4Instance.GetBlockSize(Inst: PRC4Instance): Integer;
begin
  Result:= 1;
end;

class function TRC4Instance.RandBlock(Inst: PRC4Instance; Data: PByte): TF_RESULT;
var
  Tmp: Byte;
  State: PState;

begin
  State:= @Inst.FState;
  Inc(State.I);
  Tmp:= State.S[State.I];
  State.J:= State.J + Tmp;
  State.S[State.I]:= State.S[State.J];
  State.S[State.J]:= Tmp;
  Tmp:= Tmp + State.S[State.I];
  Data^:= State.S[Tmp];
  Result:= TF_S_OK;
end;

end.
