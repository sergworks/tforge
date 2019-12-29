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
      Valid3DesAlgID, Get3DesInstance
}

unit tf3DesGetter;

{$I TFL.inc}

interface

uses
  tfTypes, tfCipherInstances, tfBlockCiphers, tfDesCiphers;

function Valid3DesAlgID(AlgID: TAlgID): Boolean;
function Get3DesInstance(var A: Pointer; AlgID: TAlgID): TF_RESULT;

implementation

uses
  tfRecords, tfHelpers, tfCipherHelpers;

const
  Des3EcbVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TDes3Instance.Burn,
    @TDes3Instance.Clone,
    @TDes3Instance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize64,
    @TBlockCipherInstance.EncryptUpdateECB,
    @TBlockCipherInstance.DecryptUpdateECB,
    @TDes3Instance.EncryptBlock,
    @TDes3Instance.EncryptBlock,
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

  Des3CbcVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TDes3Instance.Burn,
    @TDes3Instance.Clone,
    @TDes3Instance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize64,
    @TBlockCipherInstance.EncryptUpdateCBC,
    @TBlockCipherInstance.DecryptUpdateCBC,
    @TDes3Instance.EncryptBlock,
    @TDes3Instance.EncryptBlock,
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

  Des3CfbVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TDes3Instance.Burn,
    @TDes3Instance.Clone,
    @TDes3Instance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize64,
    @TBlockCipherInstance.EncryptUpdateCFB,
    @TBlockCipherInstance.DecryptUpdateCFB,
    @TDes3Instance.EncryptBlock,
    @TDes3Instance.EncryptBlock,
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

  Des3OfbVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TDes3Instance.Burn,
    @TDes3Instance.Clone,
    @TDes3Instance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize64,
    @TBlockCipherInstance.EncryptUpdateOFB,
    @TBlockCipherInstance.EncryptUpdateOFB,
    @TDes3Instance.EncryptBlock,
    @TDes3Instance.EncryptBlock,
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

  Des3CtrVTable: TCipherHelper.TVTable = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TDes3Instance.Burn,
    @TDes3Instance.Clone,
    @TDes3Instance.ExpandKey,
    @TCipherInstance.ExpandKeyIV,
    @TCipherInstance.ExpandKeyNonce,
    @TCipherInstance.GetBlockSize64,
    @TBlockCipherInstance.EncryptUpdateCTR,
    @TBlockCipherInstance.EncryptUpdateCTR,
    @TDes3Instance.EncryptBlock,
    @TDes3Instance.EncryptBlock,
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


function Valid3DesAlgID(AlgID: TAlgID): Boolean;
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
    TF_KEYMODE_CTR:
      case AlgID and TF_PADDING_MASK of
        TF_PADDING_DEFAULT,
        TF_PADDING_NONE: Result:= True;
      end;
  end;
end;

function GetVTable(AlgID: TAlgID): Pointer;
begin
  case AlgID and TF_KEYMODE_MASK of
    TF_KEYMODE_ECB: Result:= @Des3EcbVTable;
    TF_KEYMODE_CBC: Result:= @Des3CbcVTable;
    TF_KEYMODE_CFB: Result:= @Des3CfbVTable;
    TF_KEYMODE_OFB: Result:= @Des3OfbVTable;
    TF_KEYMODE_CTR: Result:= @Des3CtrVTable;
  else
    Result:= nil;
  end;
end;

function Get3DesInstance(var A: Pointer; AlgID: TAlgID): TF_RESULT;
var
  Tmp: PCipherInstance;
  LVTable: Pointer;

begin
  if not Valid3DesAlgID(AlgID) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  LVTable:= GetVTable(AlgID);

  try
    Tmp:= AllocMem(SizeOf(TDes3Instance));
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
