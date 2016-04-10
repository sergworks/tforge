{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
{ *********************************************************** }

unit tfKeyStreams;

interface

{$I TFL.inc}

uses tfTypes, tfUtils{, tfCipherServ};

type
  PKeyStreamEngine = ^TKeyStreamEngine;
  TKeyStreamEngine = record
  private type
    TBlock = array[0..TF_MAX_CIPHER_BLOCK_SIZE - 1] of Byte;
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
{$HINTS ON}
    FCipher: ICipherAlgorithm;
    FBlockSize: LongWord;
// don't assume that FBlockNo is the rightmost 8 bytes of a block cipher's IV
//    FBlockNo: UInt64;
    FPos: LongWord;       // 0 .. FBlockSize - 1
    FBlock: TBlock;       // var len
  public
//    class function NewInstance(Alg: ICipherAlgorithm; BlockSize: Cardinal): PKeyStreamEngine;
    class function GetInstance(var Inst: PKeyStreamEngine; Alg: ICipherAlgorithm): TF_RESULT; static;
    class function Release(Inst: PKeyStreamEngine): Integer; stdcall; static;
    class procedure DestroyKey(Inst: PKeyStreamEngine);
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKey(Inst: PKeyStreamEngine;
      Key: PByte; KeySize: LongWord; Nonce: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class function SetKeyParam(Inst: PKeyStreamEngine; Param: LongWord;
//      Data: Pointer; DataLen: LongWord): TF_RESULT;
//      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Read(Inst: PKeyStreamEngine; Data: PByte; DataSize: LongWord): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Skip(Inst: PKeyStreamEngine; Dist: Int64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Crypt(Inst: PKeyStreamEngine; Data: PByte; DataSize: LongWord): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

//function GetKeyStreamByAlgID(AlgID: LongWord; var A: PKeyStreamEngine): TF_RESULT;

implementation

uses tfRecords;

const
  EngVTable: array[0..7] of Pointer = (
   @TtfRecord.QueryIntf,
   @TtfRecord.Addref,
   @TKeyStreamEngine.Release,

//   @TKeyStreamEngine.SetKeyParam,
   @TKeyStreamEngine.ExpandKey,
   @TKeyStreamEngine.DestroyKey,
   @TKeyStreamEngine.Read,
   @TKeyStreamEngine.Skip,
   @TKeyStreamEngine.Crypt
   );
(*
function GetKeyStreamByAlgID(AlgID: LongWord; var A: PKeyStreamEngine): TF_RESULT;
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

{ TKeyStreamEngine }
(*
procedure Burn(Inst: PKeyStreamEngine); inline;
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TKeyStreamEngine) - Integer(@PKeyStreamEngine(nil)^.FBlockNo);
  FillChar(Inst.FBlockNo, BurnSize, 0);
end;
*)

procedure Burn(Inst: PKeyStreamEngine); inline;
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TKeyStreamEngine) - Integer(@PKeyStreamEngine(nil)^.FPos)
                                      + Integer(Inst.FBlockSize);
  FillChar(Inst.FPos, BurnSize, 0);
end;

class procedure TKeyStreamEngine.DestroyKey(Inst: PKeyStreamEngine);
begin
  Inst.FCipher.BurnKey;
  Burn(Inst);
end;

class function TKeyStreamEngine.Release(Inst: PKeyStreamEngine): Integer;
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
    Result:= PtfRecord(Inst).FRefCount;
end;

class function TKeyStreamEngine.ExpandKey(Inst: PKeyStreamEngine;
                 Key: PByte; KeySize: LongWord; Nonce: UInt64): TF_RESULT;
var
  Flags: LongWord;

begin
// for block ciphers; stream ciphers will return error code which is ignored
  Flags:= CTR_ENCRYPT;
  Inst.FCipher.SetKeyParam(TF_KP_FLAGS, @Flags, SizeOf(Flags));

//  Inst.FBlockNo:= 0;
  Inst.FPos:= 0;
  Result:= Inst.FCipher.ExpandKey(Key, KeySize);
  if Result = TF_S_OK then
    Result:= Inst.FCipher.SetKeyParam(TF_KP_INCNO, @Nonce, SizeOf(Nonce));
end;

class function TKeyStreamEngine.GetInstance(var Inst: PKeyStreamEngine;
                 Alg: ICipherAlgorithm): TF_RESULT;
var
  BlockSize: Cardinal;
  Tmp: PKeyStreamEngine;

begin
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
//    Result^.FPos:= 0;
    if Inst <> nil then TKeyStreamEngine.Release(Inst);
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

class function TKeyStreamEngine.SetKeyParam(Inst: PKeyStreamEngine;
                 Param: LongWord; Data: Pointer; DataLen: LongWord): TF_RESULT;
begin
  Inst.FPos:= 0;
  Result:= Inst.FCipher.SetKeyParam(Param, Data, DataLen);
end;
*)
(*
class function TKeyStreamEngine.Read(Inst: PKeyStreamEngine; Data: PByte;
  DataSize: LongWord): TF_RESULT;
var
  LBlockSize: LongWord;
  LDataSize: LongWord;
  LPos: LongWord;
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


class function TKeyStreamEngine.Read(Inst: PKeyStreamEngine; Data: PByte;
  DataSize: LongWord): TF_RESULT;
var
  LDataSize: LongWord;

begin
// read current block's tail
  if Inst.FPos > 0 then begin
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

class function TKeyStreamEngine.Crypt(Inst: PKeyStreamEngine; Data: PByte;
  DataSize: LongWord): TF_RESULT;
var
  LDataSize: LongWord;

begin
// read current block's tail
  if Inst.FPos > 0 then begin
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
    Result:= Inst.FCipher.KeyCrypt(@Inst.FBlock, Inst.FBlockSize, False);
    if Result <> TF_S_OK then Exit;
    MoveXor(PByte(@Inst.FBlock)^, Data^, DataSize);
    Inst.FPos:= DataSize;
  end;

  Result:= TF_S_OK;
end;


class function TKeyStreamEngine.Skip(Inst: PKeyStreamEngine; Dist: Int64): TF_RESULT;
var
  NBlocks: UInt64;
  Tail: LongWord;

begin
  if Dist >= 0 then begin
    Tail:= Inst.FBlockSize - Inst.FPos;
    if Dist < Tail then begin
      Inst.FPos:= Inst.FPos + LongWord(Dist);
    end
    else begin
      NBlocks:= (UInt64(Dist) - Tail) div Inst.FBlockSize + 1;
      Result:= Inst.FCipher.SetKeyParam(TF_KP_INCNO, @NBlocks, SizeOf(NBlocks));
      if Result <> TF_S_OK then Exit;
      Inst.FPos:= Inst.FPos + LongWord(UInt64(Dist) mod Inst.FBlockSize);
      if Inst.FPos >= Inst.FBlockSize then
        Inst.FPos:= Inst.FPos - Inst.FBlockSize;
    end;
  end
  else begin
    Dist:= -Dist;
    if Dist <= Inst.FPos then begin
      Inst.FPos:= Inst.FPos - LongWord(Dist);
    end
    else begin
      NBlocks:= (UInt64(Dist) - Inst.FPos) div Inst.FBlockSize;
      Result:= Inst.FCipher.SetKeyParam(TF_KP_DECNO, @NBlocks, SizeOf(NBlocks));
      if Result <> TF_S_OK then Exit;
// Inst.FPos is unsigned
      Inst.FPos:= Inst.FPos - LongWord(UInt64(Dist) mod Inst.FBlockSize);
      if Inst.FPos >= Inst.FBlockSize then
        Inst.FPos:= Inst.FPos + Inst.FBlockSize;
    end;
  end;
  Result:= TF_S_OK;
end;

end.
