{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfKeyStreams;

interface

{$I TFL.inc}

uses tfTypes, tfUtils, tfAES, tfDES, tfRC5, tfRC4, tfSalsa20;

type
  PStreamCipherInstance = ^TStreamCipherInstance;
  TStreamCipherInstance = record
  private type
    TBlock = array[0..TF_MAX_CIPHER_BLOCK_SIZE - 1] of Byte;
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
{$HINTS ON}
    FCipher: ICipher;
    FBlockSize: Cardinal;
// don't assume that FBlockNo is the rightmost 8 bytes of a block cipher's IV
//    FBlockNo: UInt64;
    FPos: Cardinal;       // 0 .. FBlockSize - 1
    FBlock: TBlock;       // var len
  public
    class function GetInstance(var Inst: PStreamCipherInstance; Alg: ICipher): TF_RESULT; static;
    class procedure Burn(Inst: PStreamCipherInstance);
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Duplicate(Inst: PStreamCipherInstance; var NewInst: PStreamCipherInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKey(Inst: PStreamCipherInstance;
      Key: PByte; KeySize: Cardinal; Nonce: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Read(Inst: PStreamCipherInstance; Data: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Skip(Inst: PStreamCipherInstance; Dist: Int64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Crypt(Inst: PStreamCipherInstance; Data: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetNonce(Inst: PStreamCipherInstance; Nonce: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetNonce(Inst: PStreamCipherInstance; var Nonce: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetAESStreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
function GetDESStreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
function Get3DESStreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
function GetRC5StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
function GetRC5StreamCipherInstanceEx(var Inst: IStreamCipher;
           BlockSize, Rounds: Integer): TF_RESULT;

function GetRC4StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
function GetSalsa20StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
function GetSalsa20StreamCipherInstanceEx(var Inst: IStreamCipher; Rounds: Integer): TF_RESULT;
function GetChacha20StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
function GetChacha20StreamCipherInstanceEx(var Inst: IStreamCipher; Rounds: Integer): TF_RESULT;

implementation

uses tfRecords;

const
  VTable: array[0..10] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,
    @TStreamCipherInstance.Burn,
    @TStreamCipherInstance.Duplicate,
    @TStreamCipherInstance.ExpandKey,
    @TStreamCipherInstance.SetNonce,
    @TStreamCipherInstance.GetNonce,
    @TStreamCipherInstance.Skip,
    @TStreamCipherInstance.Read,
    @TStreamCipherInstance.Crypt
  );

function GetAESStreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetAESInstance(PAESInstance(Cipher), TF_CTR_DECRYPT);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetDESStreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetDESInstance(PDESInstance(Cipher), TF_CTR_DECRYPT);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function Get3DESStreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= Get3DESInstance(P3DESInstance(Cipher), TF_CTR_DECRYPT);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetRC5StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetRC5Instance(PRC5Instance(Cipher), TF_CTR_DECRYPT);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetRC5StreamCipherInstanceEx(var Inst: IStreamCipher;
           BlockSize, Rounds: Integer): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetRC5InstanceEx(PRC5Instance(Cipher), TF_CTR_DECRYPT, BlockSize, Rounds);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetRC4StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetRC4Instance(PRC4Instance(Cipher));
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetSalsa20StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetSalsa20Instance(PSalsa20Instance(Cipher));
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetSalsa20StreamCipherInstanceEx(var Inst: IStreamCipher; Rounds: Integer): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetSalsa20InstanceEx(PSalsa20Instance(Cipher), Rounds);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetChacha20StreamCipherInstance(var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetChacha20Instance(PSalsa20Instance(Cipher));
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

function GetChacha20StreamCipherInstanceEx(var Inst: IStreamCipher; Rounds: Integer): TF_RESULT;
var
  Cipher: ICipher;

begin
  Result:= GetChacha20InstanceEx(PSalsa20Instance(Cipher), Rounds);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
end;

(*
function GetKeyStreamByAlgID(AlgID: UInt32; var A: PKeyStreamEngine): TF_RESULT;
var
  Server: ICipherServer;
  Alg: ICipherAlgorithm;
  BlockSize: Cardinal;
  Tmp: PKeyStreamEngine;


begin
  Result:= GetCipherServer(Server);
  if Result <> TF_S_OK then Exit;
  Result:= Server.GetByAlgID(AlgID, Alg);
  if Result <> TF_S_OK then Exit;
  BlockSize:= Alg.GetBlockSize;
  if (BlockSize = 0) or (BlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
  try
    Tmp:= AllocMem(SizeOf(TKeyStreamEngine) + BlockSize);
    Tmp^.FVTable:= @EngVTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FCipher:= Alg;
    Tmp^.FBlockSize:= BlockSize;

    if A <> nil then TKeyStreamEngine.Release(A);
    A:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;
*)

{ TStreamCipherInstance }

procedure BurnMem(Inst: PStreamCipherInstance); inline;
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TStreamCipherInstance) - SizeOf(TStreamCipherInstance.TBlock)
             + Integer(Inst.FBlockSize) - Integer(@PStreamCipherInstance(nil)^.FCipher);

  FillChar(Inst.FCipher, BurnSize, 0);
end;

class procedure TStreamCipherInstance.Burn(Inst: PStreamCipherInstance);
begin
//  Inst.FCipher.BurnKey;
//  tfFreeInstance(Inst.FCipher);
  Inst.FCipher:= nil;
  BurnMem(Inst);
end;

{
class function TKeyStreamInstance.Release(Inst: PKeyStreamInstance): Integer;
begin
  if Inst.FRefCount > 0 then begin
    Result:= tfDecrement(Inst.FRefCount);
    if Result = 0 then begin
      Inst.FCipher.BurnKey;
      Inst.FCipher:= nil;
      Burn(Inst);
      FreeMem(Inst);
    end;
  end
  else
    Result:= Inst.FRefCount;
end;
}

class function TStreamCipherInstance.ExpandKey(Inst: PStreamCipherInstance;
                 Key: PByte; KeySize: Cardinal; Nonce: UInt64): TF_RESULT;
var
  Flags: UInt32;
  BlockSize: Cardinal;
  Block: array[0..TF_MAX_CIPHER_BLOCK_SIZE - 1] of Byte;

begin
// for block ciphers; stream ciphers will return error code which is ignored
//  Flags:= TF_CTR_ENCRYPT;
//  Inst.FCipher.SetKeyParam(TF_KP_FLAGS, @Flags, SizeOf(Flags));

//  Inst.FBlockNo:= 0;
  Inst.FPos:= 0;
{
  BlockSize:= Inst.FCipher.GetBlockSize;
  if BlockSize < SizeOf(Nonce) then begin
    if Nonce = 0 then
      Result:= Inst.FCipher.ExpandKeyIV(Key, KeySize, nil, 0)
    else
      Result:= TF_E_INVALIDARG;
  end
  else if BlockSize = SizeOf(Nonce) then begin
    Result:= Inst.FCipher.ExpandKeyIV(Key, KeySize, @Nonce, BlockSize);
  end
  else if BlockSize <= TF_MAX_CIPHER_BLOCK_SIZE then begin
    FillChar(Block, TF_MAX_CIPHER_BLOCK_SIZE, 0);
    Move(Nonce, Block, SizeOf(Nonce));
    Result:= Inst.FCipher.ExpandKeyIV(Key, KeySize, @Block, BlockSize);
    FillChar(Block, TF_MAX_CIPHER_BLOCK_SIZE, 0);
  end
  else
    Result:= TF_E_UNEXPECTED;
}
  Result:= Inst.FCipher.ExpandKeyNonce(Key, KeySize, Nonce);
end;

class function TStreamCipherInstance.GetInstance(var Inst: PStreamCipherInstance;
                 Alg: ICipher): TF_RESULT;
var
  BlockSize: Cardinal;
  Tmp: PStreamCipherInstance;

begin
  BlockSize:= Alg.GetBlockSize;
  if (BlockSize = 0) or (BlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;
  try
    Tmp:= AllocMem(SizeOf(TStreamCipherInstance) + BlockSize);
    Tmp^.FVTable:= @VTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FCipher:= Alg;
    Tmp^.FBlockSize:= BlockSize;
//    Result^.FPos:= 0;
    tfFreeInstance(Inst);   // if Inst <> nil then TKeyStreamInstance.Release(Inst);
    Inst:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

(*
class function TKeyStreamEngine.NewInstance(Alg: ICipherAlgorithm;
  BlockSize: Cardinal): PKeyStreamEngine;
begin
  Result:= AllocMem(SizeOf(TKeyStreamEngine) + BlockSize);
  Result^.FVTable:= @EngVTable;
  Result^.FRefCount:= 1;
  Result^.FCipher:= Alg;
  Result^.FBlockSize:= BlockSize;
//  Result^.FPos:= 0;
end;

*)
(*
class function TKeyStreamEngine.Read(Inst: PKeyStreamEngine; Data: PByte;
  DataSize: Cardinal): TF_RESULT;
var
  LBlockSize: Cardinal;
  LDataSize: Cardinal;
  LPos: Cardinal;
  LBlockNo: UInt64;

begin
// check arguments
  LBlockSize:= Inst.FBlockSize;
  LBlockNo:= Inst.FBlockNo + DataSize div LBlockSize + 1;
  if LBlockNo < Inst.FBlockNo then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

// read current block's tail
  if Inst.FPos > 0 then begin
    LDataSize:= Inst.FBlockSize - Inst.FPos;
    if LDataSize > DataSize
      then LDataSize:= DataSize;
    LPos:= Inst.FPos + LDataSize;

    if LPos = Inst.FBlockSize then begin
      LPos:= 0;
      LBlockNo:= Inst.FBlockNo + 1;
      if LBlockNo = 0 then begin
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
    end;

    Move(PByte(@Inst.FBlock)[Inst.FPos], Data^, LDataSize);
    Inst.FPos:= LPos;
    Inst.FBlockNo:= LBlockNo;

    if LDataSize = DataSize then begin
      Result:= TF_S_OK;
      Exit;
    end;
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// read full blocks
  if DataSize >= Inst.FBlockSize then begin
    LDataSize:= DataSize and not (Inst.FBlockSize - 1);
    Result:= Inst.FCipher.GetKeyStream(Data, LDataSize);
    if Result <> TF_S_OK then Exit;
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
//    Inst.FBlockNo:= Inst.FBlockNo + LDataSize div Inst.FBlockSize;
  end;
  if DataSize > 0 then begin
    Result:= Inst.FCipher.GetKeyStream(@Inst.FBlock, Inst.FBlockSize);
    if Result <> TF_S_OK then Exit;
    Move(PByte(@Inst.FBlock)^, Data^, DataSize);
    Inst.FPos:= DataSize;
//    Inst.FBlockNo:= Inst.FBlockNo + 1;
  end;
end;
*)


class function TStreamCipherInstance.Read(Inst: PStreamCipherInstance; Data: PByte;
  DataSize: Cardinal): TF_RESULT;
var
  LDataSize: Cardinal;
  NBlocks: Cardinal;

begin
// read current block's tail
  if Inst.FPos > 0 then begin
    NBlocks:= 1;
    Result:= Inst.FCipher.SetKeyParam(TF_KP_DECNO, @NBlocks, SizeOf(NBlocks));
    if Result <> TF_S_OK then Exit;
    Result:= Inst.FCipher.GetKeyStream(@Inst.FBlock, Inst.FBlockSize);
    if Result <> TF_S_OK then Exit;

    LDataSize:= Inst.FBlockSize - Inst.FPos;
    if LDataSize > DataSize
      then LDataSize:= DataSize;
    Move(PByte(@Inst.FBlock)[Inst.FPos], Data^, LDataSize);
    Inst.FPos:= Inst.FPos + LDataSize;
    if Inst.FPos = Inst.FBlockSize then Inst.FPos:= 0;
    if LDataSize = DataSize then begin
      Result:= TF_S_OK;
      Exit;
    end;
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// read full blocks
  if DataSize >= Inst.FBlockSize then begin
    LDataSize:= DataSize and not (Inst.FBlockSize - 1);
    Result:= Inst.FCipher.GetKeyStream(Data, LDataSize);
    if Result <> TF_S_OK then Exit;
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// read last incomplete block
  if DataSize > 0 then begin
    Result:= Inst.FCipher.GetKeyStream(@Inst.FBlock, Inst.FBlockSize);
    if Result <> TF_S_OK then Exit;
    Move(PByte(@Inst.FBlock)^, Data^, DataSize);
    Inst.FPos:= DataSize;
  end;

  Result:= TF_S_OK;
end;

class function TStreamCipherInstance.Crypt(Inst: PStreamCipherInstance; Data: PByte;
  DataSize: Cardinal): TF_RESULT;
var
  LDataSize: Cardinal;
  NBlocks: Cardinal;

begin
// read current block's tail
  if Inst.FPos > 0 then begin
    NBlocks:= 1;
    Result:= Inst.FCipher.SetKeyParam(TF_KP_DECNO, @NBlocks, SizeOf(NBlocks));
    if Result <> TF_S_OK then Exit;
    Result:= Inst.FCipher.GetKeyStream(@Inst.FBlock, Inst.FBlockSize);
    if Result <> TF_S_OK then Exit;

    LDataSize:= Inst.FBlockSize - Inst.FPos;
    if LDataSize > DataSize
      then LDataSize:= DataSize;

    MoveXor(PByte(@Inst.FBlock)[Inst.FPos], Data^, LDataSize);
    Inst.FPos:= Inst.FPos + LDataSize;
    if Inst.FPos = Inst.FBlockSize then Inst.FPos:= 0;
    if LDataSize = DataSize then begin
      Result:= TF_S_OK;
      Exit;
    end;
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// read full blocks
  if DataSize >= Inst.FBlockSize then begin
    LDataSize:= DataSize and not (Inst.FBlockSize - 1);
    Result:= Inst.FCipher.KeyCrypt(Data, LDataSize, False);
    if Result <> TF_S_OK then Exit;
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// read last incomplete block
  if DataSize > 0 then begin
//    Result:= Inst.FCipher.KeyCrypt(@Inst.FBlock, Inst.FBlockSize, False);
    Result:= Inst.FCipher.GetKeyStream(@Inst.FBlock, Inst.FBlockSize);
    if Result <> TF_S_OK then Exit;
    MoveXor(PByte(@Inst.FBlock)^, Data^, DataSize);
    Inst.FPos:= DataSize;
  end;

  Result:= TF_S_OK;
end;

class function TStreamCipherInstance.Duplicate(Inst: PStreamCipherInstance;
               var NewInst: PStreamCipherInstance): TF_RESULT;
var
  CipherInst: ICipher;
  TmpInst: PStreamCipherInstance;

begin
  Result:= Inst.FCipher.Duplicate(CipherInst);
  if Result = TF_S_OK then begin
    TmpInst:= nil;
    Result:= GetInstance(TmpInst, CipherInst);
    if Result = TF_S_OK then begin
      TmpInst.FBlockSize:= Inst.FBlockSize;
      TmpInst.FPos:= Inst.FPos;
      Move(Inst.FBlock, TmpInst.FBlock, Inst.FBlockSize);
      tfFreeInstance(NewInst);
      NewInst:= TmpInst;
    end
    else
      CipherInst:= nil;
  end;
end;

class function TStreamCipherInstance.SetNonce(Inst: PStreamCipherInstance;
  Nonce: UInt64): TF_RESULT;
begin
  Result:= Inst.FCipher.SetKeyParam(TF_KP_NONCE, @Nonce, SizeOf(Nonce));
end;

class function TStreamCipherInstance.GetNonce(Inst: PStreamCipherInstance;
  var Nonce: UInt64): TF_RESULT;
var
  L: Cardinal;

begin
  L:= SizeOf(Nonce);
  Result:= Inst.FCipher.GetKeyParam(TF_KP_NONCE, @Nonce, L);
end;

class function TStreamCipherInstance.Skip(Inst: PStreamCipherInstance; Dist: Int64): TF_RESULT;
var
  NBlocks: UInt64;
  NBytes: Cardinal;
  Tail: Cardinal;
  ZeroIn, ZeroOut: Boolean;

begin
  if Dist >= 0 then begin
    Tail:= Inst.FBlockSize - Inst.FPos;
    NBlocks:= UInt64(Dist) div Inst.FBlockSize;
    NBytes:= UInt64(Dist) mod Inst.FBlockSize;
    ZeroIn:= Inst.FPos = 0;
    Inc(Inst.FPos, NBytes);
    if Inst.FPos >= Inst.FBlockSize then begin
      Inc(NBlocks);
      Dec(Inst.FPos, Inst.FBlockSize);
    end;
    ZeroOut:= Inst.FPos = 0;
    if ZeroIn <> ZeroOut then begin
      if ZeroIn then Inc(NBlocks)
      else Dec(NBlocks);
    end;
    if NBlocks = 0 then Result:= TF_S_OK
    else
      Result:= Inst.FCipher.SetKeyParam(TF_KP_INCNO, @NBlocks, SizeOf(NBlocks));
  end
  else begin
    Dist:= -Dist;
    NBlocks:= UInt64(Dist) div Inst.FBlockSize;
    NBytes:= UInt64(Dist) mod Inst.FBlockSize;
    ZeroIn:= Inst.FPos = 0;
    if NBytes > Inst.FPos then begin
      Inc(NBlocks);
      Inst.FPos:= Inst.FPos + Inst.FBlockSize;
    end;
    Dec(Inst.FPos, NBytes);
    ZeroOut:= Inst.FPos = 0;
    if ZeroIn <> ZeroOut then begin
      if ZeroIn then Dec(NBlocks)
      else Inc(NBlocks);
    end;
    if NBlocks = 0 then Result:= TF_S_OK
    else
      Result:= Inst.FCipher.SetKeyParam(TF_KP_DECNO, @NBlocks, SizeOf(NBlocks));
  end;
end;

end.
