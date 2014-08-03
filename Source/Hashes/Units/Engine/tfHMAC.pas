{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ * ------------------------------------------------------- * }
{ *  documentation: RFC2104                                 * }
{ * ------------------------------------------------------- * }
{ *  !! warning:                                            * }
{ *    THMACAlg implements the same IHashAlgorithm          * }
{ *      interface as MD5, SHA256, etc,                     * }
{ *      but THMACAlg.Init method is just a stub,           * }
{ *      so you can't reinitialize a THMACAlg instance.     * }
{ *    That means for example that you should not pass      * }
{ *      a reference to THMACAlg instance                   * }
{ *      as a parameter to THash.HMAC(),                    * }
{ *        i.e. you should not generate HMAC                * }
{ *        using another HMAC as inner hash function.       * }
{ *********************************************************** }

unit tfHMAC;

{$I TFL.inc}

interface

uses tfTypes, tfByteVectors;

type
  PHMACAlg = ^THMACAlg;
  THMACAlg = record
  private const
    IPad = $36;
    OPad = $5C;

  private
    FVTable: Pointer;
    FRefCount: Integer;
    FHash: IHashAlgorithm;
    FKey: PByteVector;
  public
    class function Release(Inst: PHMACAlg): Integer; stdcall; static;
    class procedure Init(Inst: PHMACAlg);
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Update(Inst: PHMACAlg; Data: Pointer; DataSize: LongWord);
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Done(Inst: PHMACAlg; PDigest: Pointer);
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Purge(Inst: PHMACAlg);
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetDigestSize(Inst: PHMACAlg): LongInt;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize(Inst: PHMACAlg): LongInt;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Duplicate(Inst: PHMACAlg; var DupInst: PHMACAlg): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetHMACAlgorithm(var Inst: PHMACAlg; Key: Pointer; KeySize: Cardinal;
         const HashAlg: IHashAlgorithm): TF_RESULT;

implementation

uses tfRecords;

const
  HMACVTable: array[0..9] of Pointer = (
   @TtfRecord.QueryIntf,
   @TtfRecord.Addref,
   @THMACAlg.Release,

   @THMACAlg.Init,
   @THMACAlg.Update,
   @THMACAlg.Done,
   @THMACAlg.Purge,
   @THMACAlg.GetDigestSize,
   @THMACAlg.GetBlockSize,
   @THMACAlg.Duplicate
   );

function GetHMACAlgorithm(var Inst: PHMACAlg; Key: Pointer; KeySize: Cardinal;
                          const HashAlg: IHashAlgorithm): TF_RESULT;
var
  P: PHMACAlg;
  BlockSize, DigestSize: Integer;
  I: Integer;
  InnerP: PByte;

begin
  BlockSize:= HashAlg.GetBlockSize;
// protection against hashing algorithms which should not be used in HMAC
  if BlockSize = 0 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  try
    New(P);
    P^.FVTable:= @HMACVTable;
    P^.FRefCount:= 1;
    P^.FKey:= nil;
    P^.FHash:= HashAlg;

    DigestSize:= HashAlg.GetDigestSize;

    Result:= ByteVectorAlloc(P^.FKey, BlockSize);
    if Result <> TF_S_OK then Exit;

    FillChar(P^.FKey.FData, BlockSize, 0);
    if KeySize > BlockSize then begin
      HashAlg.Init;
      HashAlg.Update(Key, KeySize);
      HashAlg.Done(@Inst.FKey.FData);
      KeySize:= DigestSize;
    end
    else begin
      Move(Key^, P^.FKey.FData, KeySize);
    end;

    InnerP:= @P^.FKey.FData;
//    OuterP:= @P^.FOuterKey.FData;
//    Move(InnerP^, OuterP^, BlockSize);

    for I:= 0 to BlockSize - 1 do begin
      InnerP^:= InnerP^ xor THMACAlg.IPad;
//      OuterP^:= OuterP^ xor OPad;
      Inc(InnerP);
//      Inc(OuterP);
    end;

    HashAlg.Init;
    HashAlg.Update(@P^.FKey.FData, BlockSize);

    if Inst <> nil then THMACAlg.Release(Inst);
    Inst:= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;

end;

{ THMACAlg }

class function THMACAlg.Release(Inst: PHMACAlg): Integer;
begin
  if Inst.FHash <> nil
    then Inst.FHash._Release;
  if Inst.FKey <> nil
    then IBytes(Inst.FKey)._Release;
  Result:= TtfRecord.Release(Inst);
end;

class procedure THMACAlg.Init(Inst: PHMACAlg);
begin
// stub
end;

class procedure THMACAlg.Update(Inst: PHMACAlg; Data: Pointer; DataSize: LongWord);
begin
  Inst.FHash.Update(Data, DataSize);
end;

class procedure THMACAlg.Done(Inst: PHMACAlg; PDigest: Pointer);
var
  BlockSize, DigestSize, I: Integer;
  P: PByte;

begin
  BlockSize:= Inst.FHash.GetBlockSize;
  DigestSize:= Inst.FHash.GetDigestSize;
  Inst.FHash.Done(PDigest);
  Inst.FHash.Init;
  P:= @Inst.FKey.FData;
  for I:= 0 to BlockSize - 1 do begin
    P^:= P^ xor (IPad xor OPad);
    Inc(P);
  end;
  Inst.FHash.Update(@Inst.FKey.FData, BlockSize);
  Inst.FHash.Update(PDigest, DigestSize);
  Inst.FHash.Done(PDigest);
end;

class function THMACAlg.Duplicate(Inst: PHMACAlg; var DupInst: PHMACAlg): TF_RESULT;
var
  P: PHMACAlg;
  BlockSize, DigestSize: Integer;
  I: Integer;
  InnerP: PByte;

begin
  try
    New(P);
    P^.FVTable:= @HMACVTable;
    P^.FRefCount:= 1;
    P^.FKey:= nil;

    Result:= TByteVector.CopyBytes(Inst.FKey, P^.FKey);
    if Result <> TF_S_OK then Exit;

    Inst.FHash.Duplicate(P^.FHash);

    if DupInst <> nil then THMACAlg.Release(DupInst);
    DupInst:= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function THMACAlg.GetBlockSize(Inst: PHMACAlg): LongInt;
begin
  Result:= 0;
end;

class function THMACAlg.GetDigestSize(Inst: PHMACAlg): LongInt;
begin
  Result:= Inst.FHash.GetBlockSize;
end;

class procedure THMACAlg.Purge(Inst: PHMACAlg);
begin
  FillChar(Inst.FKey.FData, Inst.FKey.FUsed, 0);
  Inst.FHash.Purge;
end;

end.
