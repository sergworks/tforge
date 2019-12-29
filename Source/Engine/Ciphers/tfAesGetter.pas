{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-------------------------------------------------------------------------

  # exports:
      ValidAesAlgID, GetAesInstance
}

unit tfAesGetter;

{$I TFL.inc}

interface

uses
  tfTypes, tfCipherInstances, tfBlockCiphers, tfGcmCiphers, tfAesCiphers;

function ValidAesAlgID(AlgID: TAlgID): Boolean;
function GetAesInstance(var A: Pointer; AlgID: TAlgID): TF_RESULT;

implementation

uses
  tfRecords, tfHelpers, tfCipherHelpers;

const
  AesEcbVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TAesCipherInstance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
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

  AesCbcVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TAesCipherInstance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
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

  AesCfbVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TAesCipherInstance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
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

  AesOfbVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TAesCipherInstance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
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

  AesCtrVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESCipherInstance.Burn,
    @TAESCipherInstance.Clone,
    @TAesCipherInstance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
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

  AesGcmVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAesGcmCipherInstance.Burn,
    @TAesGcmCipherInstance.Clone,
    @TAesGcmCipherInstance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,     // todo: this is probably wrong
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
    @TGcmCipherInstance.SetNonce,
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
    TF_KEYMODE_ECB: Result:= @AesEcbVTable;
    TF_KEYMODE_CBC: Result:= @AesCbcVTable;
    TF_KEYMODE_CFB: Result:= @AesCfbVTable;
    TF_KEYMODE_OFB: Result:= @AesOfbVTable;
    TF_KEYMODE_CTR: Result:= @AesCtrVTable;
    TF_KEYMODE_GCM: Result:= @AesGcmVTable;
  else
    Result:= nil;
  end;
end;

function ValidAesAlgID(AlgID: TAlgID): Boolean;
begin
  Result:= False;
  case AlgID and TF_KEYMODE_MASK of
    TF_KEYMODE_ECB,
    TF_KEYMODE_CBC:
      case AlgID and TF_PADDING_MASK of
        TF_PADDING_DEFAULT,
        TF_PADDING_NONE,
        TF_PADDING_ZERO,
        TF_PADDING_ANSI,
        TF_PADDING_PKCS,
        TF_PADDING_ISO: Result:= True;
      end;
    TF_KEYMODE_CFB,
    TF_KEYMODE_OFB,
    TF_KEYMODE_CTR,
    TF_KEYMODE_GCM:
      case AlgID and TF_PADDING_MASK of
        TF_PADDING_DEFAULT,
        TF_PADDING_NONE: Result:= True;
      end;
  end;
end;

function GetAesInstance(var A: Pointer; AlgID: TAlgID): TF_RESULT;
var
  Tmp: PCipherInstance;
  LVTable: Pointer;

begin
  if not ValidAesAlgID(AlgID) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  LVTable:= GetVTable(AlgID);

  try
    if LVTable = @AesGcmVTable then
      Tmp:= AllocMem(SizeOf(TAesGcmCipherInstance))
    else
      Tmp:= AllocMem(SizeOf(TAESCipherInstance));
    Tmp.FVTable:= LVTable;
    Tmp.FRefCount:= 1;
    Tmp.FAlgID:= AlgID;

    TForgeHelper.Free(A);
    A:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

end.
