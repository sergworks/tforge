{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # generic stream cipher
  # inheritance:
      TForgeInstance <-- TCipherInstance <-- TStreamCipherInstance
}

unit tfStreamCiphers;

{$I TFL.inc}

interface

uses
  tfTypes, tfUtils;

type
  PStreamCipherInstance = ^TStreamCipherInstance;
  TStreamCipherInstance = record
  private
{$HINTS OFF}
    FVTable:   Pointer;
    FRefCount: Integer;
    FAlgID:    TAlgID;
    FKeyFlags: UInt32;
{$HINTS ON}
    FPos:      Cardinal;    // 0 .. BlockSize - 1

  public
    class function IncBlockNo(Inst: PStreamCipherInstance; Count: UInt64): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Encrypt(Inst: Pointer; OutData: PByte; OutSize: Cardinal;
      Data: PByte; var DataSize: Cardinal; Last: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKeyStream(Inst: PStreamCipherInstance; Data: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ApplyKeyStream(Inst: PStreamCipherInstance; InData, OutData: PByte; DataSize: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIsBlockCipher(Inst: Pointer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

uses tfCipherHelpers;

{ TStreamCipherInstance }

class function TStreamCipherInstance.ApplyKeyStream(Inst: PStreamCipherInstance;
                 InData, OutData: PByte; DataSize: Cardinal): TF_RESULT;
var
  LBlockSize: Cardinal;
  LGetKeyBlock: TCipherHelper.TBlockFunc;
  LDataSize: Cardinal;
//  NBlocks: Cardinal;
  LBlock: TCipherHelper.TBlock;

begin
  if Inst.FKeyFlags and TF_KEYFLAG_KEY <> 0 then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  @LGetKeyBlock:= TCipherHelper.GetKeyBlockFunc(Inst);

// process current block's tail (if exists)
  if Inst.FPos > 0 then begin
//    NBlocks:= 1;
//    Result:= TCipherHelper.SetKeyParam(Inst, TF_KP_DECNO, @NBlocks, SizeOf(NBlocks));
    Result:= TCipherHelper.DecBlockNo(Inst, 1);
    if Result <> TF_S_OK then Exit;
    Result:= LGetKeyBlock(Inst, @LBlock);
    if Result <> TF_S_OK then Exit;

    LDataSize:= LBlockSize - Inst.FPos;
    if LDataSize > DataSize
      then LDataSize:= DataSize;

    Move(InData^, OutData^, LDataSize);
    MoveXor(LBlock[Inst.FPos], OutData^, LDataSize);
    Inst.FPos:= Inst.FPos + LDataSize;
    if Inst.FPos = LBlockSize then Inst.FPos:= 0;
    Inc(OutData, LDataSize);
    Inc(InData, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// process full blocks
  while DataSize >= LBlockSize do begin
    LDataSize:= DataSize and not (LBlockSize - 1);
    Result:= LGetKeyBlock(Inst, @LBlock);
    if Result <> TF_S_OK then Exit;
    Move(InData^, OutData^, LDataSize);
    MoveXor(LBlock, OutData^, LDataSize);
    Inc(OutData, LDataSize);
    Inc(InData, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// process last incomplete block (if exists)
  if DataSize > 0 then begin
    Result:= LGetKeyBlock(Inst, @LBlock);
    if Result <> TF_S_OK then Exit;
    Move(InData^, OutData^, DataSize);
    MoveXor(LBlock, OutData^, DataSize);
    Inst.FPos:= DataSize;
  end;

  FillChar(LBlock, LBlockSize, 0);
  Result:= TF_S_OK;
end;

class function TStreamCipherInstance.Encrypt(Inst: Pointer; OutData: PByte;
  OutSize: Cardinal; Data: PByte; var DataSize: Cardinal;
  Last: Boolean): TF_RESULT;
begin
  Result:= ApplyKeyStream(Inst, Data, OutData, DataSize);
end;

// CTR-mode block algorithms can override it
class function TStreamCipherInstance.GetIsBlockCipher(Inst: Pointer): Boolean;
begin
  Result:= False;
end;

class function TStreamCipherInstance.GetKeyStream(Inst: PStreamCipherInstance;
                 Data: PByte; DataSize: Cardinal): TF_RESULT;
var
  LBlockSize: Cardinal;
  LGetKeyBlock: TCipherHelper.TBlockFunc;
  LDataSize: Cardinal;
//  NBlocks: Cardinal;
  LBlock: TCipherHelper.TBlock;

begin
  if Inst.FKeyFlags and TF_KEYFLAG_KEY <> 0 then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  LBlockSize:= TCipherHelper.GetBlockSize(Inst);
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  @LGetKeyBlock:= TCipherHelper.GetKeyBlockFunc(Inst);

// process current block's tail (if exists)
  if Inst.FPos > 0 then begin
//    NBlocks:= 1;
//    Result:= TCipherHelper.SetKeyParam(Inst, TF_KP_DECNO, @NBlocks, SizeOf(NBlocks));
    Result:= TCipherHelper.DecBlockNo(Inst, 1);
    if Result <> TF_S_OK then Exit;
    Result:= LGetKeyBlock(Inst, @LBlock);
    if Result <> TF_S_OK then Exit;

    LDataSize:= LBlockSize - Inst.FPos;
    if LDataSize > DataSize
      then LDataSize:= DataSize;

    Move(LBlock[Inst.FPos], Data^, LDataSize);
    Inst.FPos:= Inst.FPos + LDataSize;
    if Inst.FPos = LBlockSize then Inst.FPos:= 0;
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// process full blocks
  while DataSize >= LBlockSize do begin
    LDataSize:= DataSize and not (LBlockSize - 1);
    Result:= LGetKeyBlock(Inst, @LBlock);
    if Result <> TF_S_OK then Exit;
    Move(LBlock, Data^, LDataSize);
    Inc(Data, LDataSize);
    Dec(DataSize, LDataSize);
  end;

// process last incomplete block (if exists)
  if DataSize > 0 then begin
    Result:= LGetKeyBlock(Inst, @LBlock);
    if Result <> TF_S_OK then Exit;
    Move(LBlock, Data^, DataSize);
    Inst.FPos:= DataSize;
  end;

  FillChar(LBlock, LBlockSize, 0);
  Result:= TF_S_OK;
end;

class function TStreamCipherInstance.IncBlockNo(Inst: PStreamCipherInstance;
                 Count: UInt64): TF_RESULT;
var
  LBlockSize: Cardinal;
  LGetKeyBlock: TCipherHelper.TBlockFunc;
  LBlock: TCipherHelper.TBlock;

begin
  LBlockSize:= TCipherHelper.GetBlockSize(Inst);
  if (LBlockSize <= 0) or (LBlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then begin
    Result:= TF_E_UNEXPECTED;
    Exit;
  end;

  @LGetKeyBlock:= TCipherHelper.GetKeyBlockFunc(Inst);
  while Count > 0 do begin
    LGetKeyBlock(Inst, @LBlock);
    Dec(Count);
  end;
  FillChar(LBlock, LBlockSize, 0);
  Result:= TF_S_OK;
end;

end.
