{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
{ *********************************************************** }

unit tfSalsa20;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  PSalsa20 = ^TSalsa20;
  TSalsa20 = record
  private type
    PKey = ^TKey;
    TKey = array[0..7] of LongWord;    // 256-bit key

    PBlock = ^TBlock;
    TBlock = array[0..15] of LongWord;

    TNonce = record
      case Byte of
        0: (Value: UInt64);
        1: (Words: array[0..1] of LongWord);
    end;

  private
{$HINTS OFF}                    // -- inherited fields begin --
                                // from tfRecord
    FVTable:   Pointer;
    FRefCount: Integer;
                                // from tfStreamCipher
    FValidKey: LongBool;
                                // -- inherited fields end --
    FExpandedKey: TBlock;
    FRounds: Cardinal;            // 1..255
{$HINTS ON}
  public
    class function Release(Inst: PSalsa20): Integer; stdcall; static;
    class function ExpandKey(Inst: PSalsa20; Key: PByte; KeySize: LongWord): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize(Inst: PSalsa20): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DuplicateKey(Inst: PSalsa20; var Key: PSalsa20): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure DestroyKey(Inst: PSalsa20);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetKeyParam(Inst: PSalsa20; Param: LongWord; Data: Pointer;
          DataLen: LongWord): TF_RESULT;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function KeyBlock(Inst: PSalsa20; Data: TSalsa20.PBlock): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetSalsa20Algorithm(var A: PSalsa20): TF_RESULT;
function GetSalsa20AlgorithmEx(var A: PSalsa20; Rounds: Integer): TF_RESULT;

implementation

uses tfRecords, tfUtils, tfBaseCiphers;

const
  SALSA_BLOCK_SIZE = 64;

  Salsa20VTable: array[0..14] of Pointer = (
   @TtfRecord.QueryIntf,
   @TtfRecord.Addref,
   @TSalsa20.Release,

   @TSalsa20.SetKeyParam,
   @TSalsa20.ExpandKey,
   @TSalsa20.DestroyKey,
   @TSalsa20.DuplicateKey,
   @TSalsa20.GetBlockSize,
   @TStreamCipher.Encrypt,
   @TStreamCipher.Decrypt,
   @TStreamCipher.EncryptBlock,
   @TStreamCipher.EncryptBlock,
   @TStreamCipher.GetRand,
   @TSalsa20.KeyBlock,
   @TStreamCipher.RandCrypt
   );

function GetSalsa20Algorithm(var A: PSalsa20): TF_RESULT;
begin
  Result:= GetSalsa20AlgorithmEx(A, 20);
end;

function GetSalsa20AlgorithmEx(var A: PSalsa20; Rounds: Integer): TF_RESULT;
var
  Tmp: PSalsa20;

begin
  if (Rounds < 1) or (Rounds > 255) or Odd(Rounds) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  try
    Tmp:= AllocMem(SizeOf(TSalsa20));
    Tmp^.FVTable:= @Salsa20VTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FRounds:= Rounds shr 1;

    if A <> nil then TSalsa20.Release(A);
    A:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

{ TSalsa20 }

procedure BurnKey(Inst: PSalsa20); inline;
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TSalsa20)
             - Integer(@PSalsa20(nil)^.FValidKey);
  FillChar(Inst.FValidKey, BurnSize, 0);
end;

class function TSalsa20.Release(Inst: PSalsa20): Integer;
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

class procedure TSalsa20.DestroyKey(Inst: PSalsa20);
begin
  BurnKey(Inst);
end;
{
type
  PSalsaBlock = ^TSalsaBlock;
  TSalsaBlock = array[0..15] of LongWord;
}
procedure DoubleRound(x: TSalsa20.PBlock); //PSalsaBlock);
var
  y: LongWord;

begin
  y := x[ 0] + x[12]; x[ 4] := x[ 4] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 4] + x[ 0]; x[ 8] := x[ 8] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 8] + x[ 4]; x[12] := x[12] xor ((y shl 13) or (y shr (32-13)));
  y := x[12] + x[ 8]; x[ 0] := x[ 0] xor ((y shl 18) or (y shr (32-18)));
  y := x[ 5] + x[ 1]; x[ 9] := x[ 9] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 9] + x[ 5]; x[13] := x[13] xor ((y shl 09) or (y shr (32-09)));
  y := x[13] + x[ 9]; x[ 1] := x[ 1] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 1] + x[13]; x[ 5] := x[ 5] xor ((y shl 18) or (y shr (32-18)));
  y := x[10] + x[ 6]; x[14] := x[14] xor ((y shl 07) or (y shr (32-07)));
  y := x[14] + x[10]; x[ 2] := x[ 2] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 2] + x[14]; x[ 6] := x[ 6] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 6] + x[ 2]; x[10] := x[10] xor ((y shl 18) or (y shr (32-18)));
  y := x[15] + x[11]; x[ 3] := x[ 3] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 3] + x[15]; x[ 7] := x[ 7] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 7] + x[ 3]; x[11] := x[11] xor ((y shl 13) or (y shr (32-13)));
  y := x[11] + x[ 7]; x[15] := x[15] xor ((y shl 18) or (y shr (32-18)));
  y := x[ 0] + x[ 3]; x[ 1] := x[ 1] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 1] + x[ 0]; x[ 2] := x[ 2] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 2] + x[ 1]; x[ 3] := x[ 3] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 3] + x[ 2]; x[ 0] := x[ 0] xor ((y shl 18) or (y shr (32-18)));
  y := x[ 5] + x[ 4]; x[ 6] := x[ 6] xor ((y shl 07) or (y shr (32-07)));
  y := x[ 6] + x[ 5]; x[ 7] := x[ 7] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 7] + x[ 6]; x[ 4] := x[ 4] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 4] + x[ 7]; x[ 5] := x[ 5] xor ((y shl 18) or (y shr (32-18)));
  y := x[10] + x[ 9]; x[11] := x[11] xor ((y shl 07) or (y shr (32-07)));
  y := x[11] + x[10]; x[ 8] := x[ 8] xor ((y shl 09) or (y shr (32-09)));
  y := x[ 8] + x[11]; x[ 9] := x[ 9] xor ((y shl 13) or (y shr (32-13)));
  y := x[ 9] + x[ 8]; x[10] := x[10] xor ((y shl 18) or (y shr (32-18)));
  y := x[15] + x[14]; x[12] := x[12] xor ((y shl 07) or (y shr (32-07)));
  y := x[12] + x[15]; x[13] := x[13] xor ((y shl 09) or (y shr (32-09)));
  y := x[13] + x[12]; x[14] := x[14] xor ((y shl 13) or (y shr (32-13)));
  y := x[14] + x[13]; x[15] := x[15] xor ((y shl 18) or (y shr (32-18)));
end;

class function TSalsa20.GetBlockSize(Inst: PSalsa20): Integer;
begin
  Result:= SALSA_BLOCK_SIZE;
end;

class function TSalsa20.KeyBlock(Inst: PSalsa20; Data: TSalsa20.PBlock): TF_RESULT;
var
  N: Cardinal;

begin
  Move(Inst.FExpandedKey, Data^, SizeOf(TBlock));
  N:= Inst.FRounds;
  repeat
    DoubleRound(Data);
    Dec(N);
  until N = 0;
  repeat
    Data[N]:= Data[N] + Inst.FExpandedKey[N];
    Inc(N);
  until N = 16;
  Inc(Inst.FExpandedKey[8]);
  if (Inst.FExpandedKey[8] = 0)
    then Inc(Inst.FExpandedKey[9]);
  Result:= TF_S_OK;
end;

class function TSalsa20.DuplicateKey(Inst: PSalsa20; var Key: PSalsa20): TF_RESULT;
begin
  Result:= GetSalsa20Algorithm(Key);
  if Result = TF_S_OK then begin
    Key.FValidKey:= Inst.FValidKey;
    Key.FExpandedKey:= Inst.FExpandedKey;
    Key.FRounds:= Inst.FRounds;
  end;
end;

class function TSalsa20.ExpandKey(Inst: PSalsa20; Key: PByte;
  KeySize: LongWord): TF_RESULT;
const
                        // Sigma = 'expand 32-byte k'
  Sigma0 = $61707865;
  Sigma1 = $3320646e;
  Sigma2 = $79622d32;
  Sigma3 = $6b206574;
                        // Tau = 'expand 16-byte k'
  Tau0   = $61707865;
  Tau1   = $3120646e;
  Tau2   = $79622d36;
  Tau3   = $6b206574;

begin
  if (KeySize <> 16) and (KeySize <> 32) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  Move(Key^, Inst.FExpandedKey[1], 16);
  if KeySize = 16 then begin        // 128-bit key
    Inst.FExpandedKey[0]:= Tau0;
    Inst.FExpandedKey[5]:= Tau1;
    Inst.FExpandedKey[10]:= Tau2;
    Inst.FExpandedKey[15]:= Tau3;
    Move(Key^, Inst.FExpandedKey[11], 16);
  end
  else begin                        // 256-bit key
    Inst.FExpandedKey[0]:= Sigma0;
    Inst.FExpandedKey[5]:= Sigma1;
    Inst.FExpandedKey[10]:= Sigma2;
    Inst.FExpandedKey[15]:= Sigma3;
    Move(PByte(Key)[16], Inst.FExpandedKey[11], 16);
  end;
                                    // 64-bit block number
  Inst.FExpandedKey[8]:= 0;
  Inst.FExpandedKey[9]:= 0;
  Inst.FValidKey:= True;

//FillChar(Inst.FExpandedKey, SizeOf(Inst.FExpandedKey), 0);
//Inst.FExpandedKey[0]:= 1;

  Result:= TF_S_OK;
end;

class function TSalsa20.SetKeyParam(Inst: PSalsa20; Param: LongWord;
  Data: Pointer; DataLen: LongWord): TF_RESULT;

type
  TUInt64Rec = record
    Lo, Hi: LongWord;
  end;

var
  Tmp, Tmp1: UInt64;

begin
  if (Param = TF_KP_IV) then begin
    if (DataLen <> 2 * SizeOf(UInt64)) then begin
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
//    TBigEndian.ReverseCopy(Data, PByte(Data) + 2 * SizeOf(UInt64), @Inst.FExpandedKey[6]);
    Move(Data^, Inst.FExpandedKey[6], 2 * SizeOf(UInt64));
    Result:= TF_S_OK;
    Exit;
  end;
  if (Param = TF_KP_NONCE) then begin
    if (DataLen > 0) and (DataLen <= SizeOf(UInt64)) then begin
      Inst.FExpandedKey[6]:= 0;
      Inst.FExpandedKey[7]:= 0;
      if (Data <> nil) then begin
        Move(Data^, Inst.FExpandedKey, DataLen);
      end;
                                      // 64-byte block number
      Inst.FExpandedKey[8]:= 0;
      Inst.FExpandedKey[9]:= 0;
      Result:= TF_S_OK;
    end
    else
      Result:= TF_E_INVALIDARG;
  end
  else if (Param = TF_KP_NONCE_LE) then begin
    if (DataLen > 0) and (DataLen <= SizeOf(UInt64)) then begin
      Inst.FExpandedKey[6]:= 0;
      Inst.FExpandedKey[7]:= 0;
      if (Data <> nil) then begin
        Move(Data^, Inst.FExpandedKey, DataLen);
                                      // convert data to big-endian
//        TBigEndian.ReverseCopy(Data, PByte(Data) + DataLen, @Inst.FExpandedKey[6]);
      end;
                                      // 64-byte block number
      Inst.FExpandedKey[8]:= 0;
      Inst.FExpandedKey[9]:= 0;
      Result:= TF_S_OK;
    end
    else
      Result:= TF_E_INVALIDARG;
  end
  else if (Param = TF_KP_INCNO) then begin
    if (DataLen > 0) and (DataLen <= SizeOf(UInt64)) then begin
//      if (Data <> nil) then begin
// Salsa20 uses little-endian block numbers
        Tmp:= 0;
        TUInt64Rec(Tmp1).Lo:= Inst.FExpandedKey[8];
        TUInt64Rec(Tmp1).Hi:= Inst.FExpandedKey[9];

        TBigEndian.ReverseCopy(Data, PByte(Data) + DataLen, @Tmp);

        Tmp:= Tmp + Tmp1;

        Inst.FExpandedKey[8]:= TUInt64Rec(Tmp).Lo;
        Inst.FExpandedKey[9]:= TUInt64Rec(Tmp).Hi;
//      end
(*
      else begin
                                        // 64-byte block number
        Inst.FExpandedKey[8]:= 0;
        Inst.FExpandedKey[9]:= 0;
//        Inst.FPos:= 0;
      end;
*)
      Result:= TF_S_OK;
    end
    else
      Result:= TF_E_INVALIDARG;
  end
  else if (Param = TF_KP_INCNO_LE) then begin
    if (DataLen > 0) and (DataLen <= SizeOf(UInt64)) then begin
//      if (Data <> nil) then begin
        Tmp:= 0;
        TUInt64Rec(Tmp1).Lo:= Inst.FExpandedKey[8];
        TUInt64Rec(Tmp1).Hi:= Inst.FExpandedKey[9];

        Move(Data^, Tmp, DataLen);

        Tmp:= Tmp + Tmp1;

        Inst.FExpandedKey[8]:= TUInt64Rec(Tmp).Lo;
        Inst.FExpandedKey[9]:= TUInt64Rec(Tmp).Hi;
{      end
      else begin
                                        // 64-byte block number
        Inst.FExpandedKey[8]:= 0;
        Inst.FExpandedKey[9]:= 0;
//        Inst.FPos:= 0;
      end;}
      Result:= TF_S_OK;
    end
    else
      Result:= TF_E_INVALIDARG;
  end
  else
    Result:= TF_E_NOTIMPL;
end;

end.
