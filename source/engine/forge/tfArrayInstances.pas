{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2019
}

unit tfArrayInstances;

{$I TFL.inc}

{$R-}   // range checking is not allowed

interface

uses tfTypes, SysUtils;

type
  PByteArrayEnum = ^TByteArrayEnum;

  PByteArrayInstance = ^TByteArrayInstance;
  PPByteArrayInstance = ^PByteArrayInstance;
  
  { TByteArrayInstance }

  TByteArrayInstance = record
//  private const
//    FUsedSize = SizeOf(Integer); // because SizeOf(FUsed) does not compile
  public type
{$IFDEF DEBUG}
    TData = array[0..7] of Byte;
{$ELSE}
    TData = array[0..0] of Byte;
{$ENDIF}

  public
    FVTable: Pointer;
    FRefCount: Integer;
    FCapacity: Integer;         // number of bytes allocated
    FUsed: Integer;             // number of bytes used
    FData: TData;

    class function Allocate(var A: PByteArrayInstance; NBytes: Cardinal): TF_RESULT; static;
    class function Alloc(var A: PByteArrayInstance; ASize: Cardinal): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function AllocEx(var A: PByteArrayInstance; ASize: Cardinal; Filler: Byte): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    class function ReAlloc(var A: PByteArrayInstance; ASize: Cardinal): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function SetInstanceLen(var A: PByteArrayInstance; L: Integer): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function FromPByte(var A: PByteArrayInstance; P: PByte; L: Cardinal): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function FromPByteEx(var A: PByteArrayInstance; P: PByte;
            L: Cardinal; Reversed: Boolean): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function FromPCharHex(var A: PByteArrayInstance; P: PByte;
            L: Cardinal; CharSize: Cardinal): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function Parse(var A: PByteArrayInstance; P: PByte;
            L: Cardinal; CharSize: Cardinal; Delimiter: Byte): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function ParseHex(var A: PByteArrayInstance; P: PByte;
            L: Cardinal; CharSize: Cardinal; Delimiter: Byte): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    class function FromByte(var A: PByteArrayInstance; Value: Byte): TF_RESULT; static;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    class function GetEnum(Inst: PByteArrayInstance; var AEnum: PByteArrayEnum): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetHashCode(Inst: PByteArrayInstance): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetLen(A: PByteArrayInstance): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SetLen(A: PByteArrayInstance; L: Integer): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetRawData(A: PByteArrayInstance): PByte;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AssignBytes(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function CopyBytes(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function CopyBytes1(A: PByteArrayInstance; var R: PByteArrayInstance; I: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function CopyBytes2(A: PByteArrayInstance; var R: PByteArrayInstance; I, L: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RemoveBytes1(A: PByteArrayInstance; var R: PByteArrayInstance; I: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RemoveBytes2(A: PByteArrayInstance; var R: PByteArrayInstance; I, L: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DeleteBytes(A: PByteArrayInstance; I, L: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ReverseBytes(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ConcatBytes(A, B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function InsertBytes(A: PByteArrayInstance; Index: Cardinal; B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EqualBytes(A, B: PByteArrayInstance): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AddBytes(A, B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SubBytes(A, B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function AndBytes(A, B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function OrBytes(A, B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function XorBytes(A, B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function NotBytes(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AppendByte(A: PByteArrayInstance; B: Byte; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function InsertByte(A: PByteArrayInstance; Index: Cardinal; B: Byte; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EqualToByte(A: PByteArrayInstance; B: Byte): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AppendPByte(A: PByteArrayInstance; P: PByte; L: Cardinal; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function InsertPByte(A: PByteArrayInstance; Index: Cardinal; P: PByte;
                               L: Cardinal; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EqualToPByte(A: PByteArrayInstance; P: PByte; L: Integer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ToDec(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function Incr(A: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Decr(A: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function IncrLE(A: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecrLE(A: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class procedure Burn(A: PByteArrayInstance);
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Fill(A: PByteArrayInstance; Value: Byte);
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ToData(A: PByteArrayInstance; Data: PByte; L: Cardinal; Reversed: Boolean): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ShiftLeft(A: PByteArrayInstance; Shift: Cardinal; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ShiftRight(A: PByteArrayInstance; Shift: Cardinal; var R: PByteArrayInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function TestBit(A: PByteArrayInstance; Shift: Cardinal): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetSeniorBit(A: PByteArrayInstance): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

// for .. in iteration support
  TByteArrayEnum = record
  private
    FVTable: Pointer;
    FRefCount: Integer;
    FVector: PByteArrayInstance;
    FIndex: Integer;
  public
    class function Release(Inst: PByteArrayEnum): Integer; stdcall; static;
    class function Init(var Inst: PByteArrayEnum; AVector: PByteArrayInstance): TF_RESULT; static;
    class function GetCurrent(Inst: PByteArrayEnum): Byte; static;
    class function MoveNext(Inst: PByteArrayEnum): Boolean; static;
    class procedure Reset(Inst: PByteArrayEnum); static;
  end;

(*
function ByteVectorFromPByte(var A: PByteArrayInstance; P: PByte; L: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorFromPByteEx(var A: PByteArrayInstance; P: PByte; L: Cardinal;
           Reversed: Boolean): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorParse(var A: PByteArrayInstance; P: PByte;
           L: Cardinal; CharSize: Cardinal; Delimiter: Byte): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorFromPCharHex(var A: PByteArrayInstance; P: PByte;
           L: Cardinal; CharSize: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorParseHex(var A: PByteArrayInstance; P: PByte;
           L: Cardinal; CharSize: Cardinal; Delimiter: Byte): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorFromByte(var A: PByteArrayInstance; Value: Byte): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
*)

implementation

uses tfInstances, tfHelpers, tfUtils;

const
  ByteVecVTable: array[0..3{40}] of Pointer = (
   @TForgeInstance.QueryIntf,
   @TForgeInstance.Addref,
   @TForgeInstance.SafeRelease,
   @TByteArrayInstance.Burn
{
   @TByteArrayInstance.GetEnum,

   @TByteArrayInstance.GetHashCode,
   @TByteArrayInstance.GetLen,
   @TByteArrayInstance.SetLen,
   @TByteArrayInstance.GetRawData,

   @TByteArrayInstance.AssignBytes,
   @TByteArrayInstance.CopyBytes,
   @TByteArrayInstance.CopyBytes1,
   @TByteArrayInstance.CopyBytes2,
   @TByteArrayInstance.RemoveBytes1,
   @TByteArrayInstance.RemoveBytes2,
   @TByteArrayInstance.ReverseBytes,
   @TByteArrayInstance.ConcatBytes,
   @TByteArrayInstance.InsertBytes,
   @TByteArrayInstance.EqualBytes,

   @TByteArrayInstance.AddBytes,
   @TByteArrayInstance.SubBytes,
   @TByteArrayInstance.AndBytes,
   @TByteArrayInstance.OrBytes,
   @TByteArrayInstance.XorBytes,

   @TByteArrayInstance.AppendByte,
   @TByteArrayInstance.InsertByte,
   @TByteArrayInstance.EqualToByte,

   @TByteArrayInstance.AppendPByte,
   @TByteArrayInstance.InsertPByte,
   @TByteArrayInstance.EqualToByte,

   @TByteArrayInstance.ToDec,

   @TByteArrayInstance.Incr,
   @TByteArrayInstance.Decr,

   @TByteArrayInstance.Fill,

   @TByteArrayInstance.ToInt,

   @TByteArrayInstance.IncrLE,
   @TByteArrayInstance.DecrLE,

   @TByteArrayInstance.ShiftLeft,
   @TByteArrayInstance.ShiftRight,

   @TByteArrayInstance.GetBitSet,
   @TByteArrayInstance.GetSeniorBit
   }
   );

const
  ByteVecEnumVTable: array[0..5] of Pointer = (
   @TForgeInstance.QueryIntf,
   @TForgeInstance.Addref,
   @TByteArrayEnum.Release,
   @TByteArrayEnum.GetCurrent,
   @TByteArrayEnum.MoveNext,
   @TByteArrayEnum.Reset
   );

const
  ZeroArray: TByteArrayInstance = (
    FVTable: @ByteVecVTable;
    FRefCount: -1;
    FCapacity: 0;
    FUsed: 0;
{$IFDEF DEBUG}
    FData: (0, 0, 0, 0, 0, 0, 0, 0);
{$ELSE}
    FData: (0);
{$ENDIF}
    );

{ TByteArrayInstance }

const
  ByteVecPrefixSize = SizeOf(TByteArrayInstance) - SizeOf(TByteArrayInstance.TData);
  MaxCapacity = $01000000;

class function TByteArrayInstance.Allocate(var A: PByteArrayInstance;
        NBytes: Cardinal): TF_RESULT;
var
  BytesRequired: Cardinal;

begin
  if NBytes >= MaxCapacity then begin
    Result:= TF_E_NOMEMORY;
    Exit;
  end;
  if NBytes = 0 then begin
    A:= @ZeroArray;
    Result:= TF_S_OK;
    Exit;
  end;
  BytesRequired:= NBytes + ByteVecPrefixSize;
  BytesRequired:= (BytesRequired + 7) and not 7;
{$IFDEF TFL_CATCH_MEMORY_ERRORS}
  try
{$ENDIF}
    GetMem(A, BytesRequired);
    A^.FVTable:= @ByteVecVTable;
    A^.FRefCount:= 1;
    A^.FCapacity:= BytesRequired - ByteVecPrefixSize;
    A^.FUsed:= NBytes;
    Result:= TF_S_OK;
{$IFDEF TFL_CATCH_MEMORY_ERRORS}
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
{$ENDIF}
end;

class function TByteArrayInstance.Alloc(var A: PByteArrayInstance; ASize: Cardinal): TF_RESULT;
var
  Tmp: PByteArrayInstance;

begin
  Result:= Allocate(Tmp, ASize);
  if Result = TF_S_OK then begin
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

class function TByteArrayInstance.AllocEx(var A: PByteArrayInstance; ASize: Cardinal; Filler: Byte): TF_RESULT;
var
  Tmp: PByteArrayInstance;

begin
  Result:= Allocate(Tmp, ASize);
  if Result = TF_S_OK then begin
    FillChar(Tmp.FData, ASize, Filler);
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

class function TByteArrayInstance.ReAlloc(var A: PByteArrayInstance; ASize: Cardinal): TF_RESULT;
var
  Tmp: PByteArrayInstance;
  L: Cardinal;

begin
  Result:= Allocate(Tmp, ASize);
  if Result = TF_S_OK then begin
    if A <> nil then begin
//      Tmp.FBigEndian:= A.FBigEndian;
      L:= A.FUsed;
      if L > ASize then L:= ASize;
      Move(A.FData, Tmp.FData, L);
      TForgeHelper.Release(A);
//      tfReleaseInstance(A); //TtfRecord.Release(A);
    end;
    A:= Tmp;
  end;
end;

class function TByteArrayInstance.SetInstanceLen(var A: PByteArrayInstance; L: Integer): TF_RESULT;
begin
  if (A.FRefCount = 1) and (Cardinal(L) <= Cardinal(A.FCapacity)) then begin
    A.FUsed:= L;
    Result:= TF_S_OK;
  end
  else
    Result:= TByteArrayInstance.ReAlloc(A, L);
end;

class function TByteArrayInstance.GetLen(A: PByteArrayInstance): Integer;
begin
  Result:= A.FUsed;
end;

class function TByteArrayInstance.SetLen(A: PByteArrayInstance; L: Integer): TF_RESULT;
begin
  if Cardinal(L) <= Cardinal(A.FCapacity) then begin
    A.FUsed:= L;
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;
end;

class function TByteArrayInstance.TestBit(A: PByteArrayInstance; Shift: Cardinal): Boolean;
var
  ByteShift: Cardinal;
  BitShift: Cardinal;
  UsedA: Cardinal;
  B: Byte;
  Mask: Byte;

begin
  UsedA:= A.FUsed;
  ByteShift:= Shift shr 3;
  if (ByteShift < UsedA) then begin
    BitShift:= Shift and 7;
    B:= A.FData[UsedA - ByteShift - 1];
    Mask:= 1 shl BitShift;
    Result:= B and Mask <> 0;
  end
  else
    Result:= False;
end;

class function TByteArrayInstance.GetSeniorBit(A: PByteArrayInstance): Integer;
var
  N: Integer;
  P: PByte;
  Mask: Byte;

begin
  N:= A.FUsed;
  P:= @A.FData;
  while (N > 0) do begin
    if (P^ = 0) then begin
      Dec(N);
      Inc(P);
    end
    else begin
      Mask:= $80;
      Result:= N shl 3 - 1;
      while Mask and P^ = 0 do begin
        Dec(Result);
        Mask:= Mask shr 1;
      end;
      Exit;
    end;
  end;
  Result:= -1;
end;

class function TByteArrayInstance.ShiftLeft(A: PByteArrayInstance; Shift: Cardinal;
  var R: PByteArrayInstance): TF_RESULT;
var
  ByteShift: Cardinal;
  BitShift: Cardinal;
  UsedA, N: Cardinal;
  Tmp: PByteArrayInstance;
  Carry: Byte;
  W: Word;
  Src, Tgt: PByte;

begin
  UsedA:= A.FUsed;
  Result:= Allocate(Tmp, UsedA);
  if Result <> TF_S_OK then Exit;

  FillChar(Tmp.FData, UsedA, 0);
  ByteShift:= Shift shr 3;
  if ByteShift < UsedA then begin
    BitShift:= Shift and 7;
    N:= UsedA - ByteShift;      // N > 0
    if BitShift = 0 then begin
      Move(A.FData[ByteShift], Tmp.FData, N);
    end
    else begin
      Src:= @A.FData[ByteShift];
      Tgt:= @Tmp.FData;
      Carry:= 0;
      repeat
        W:= Src^;
        W:= W shl BitShift;
        Tgt^:= WordRec(W).Lo or Carry;
        Carry:= WordRec(W).Hi;
        Dec(N);
        Inc(Src);
        Inc(Tgt);
      until N = 0;
    end;
  end;
  TForgeHelper.Free(R);
//  tfFreeInstance(R);  //  if R <> nil then TtfRecord.Release(R);
  R:= Tmp;
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.ShiftRight(A: PByteArrayInstance; Shift: Cardinal;
  var R: PByteArrayInstance): TF_RESULT;
var
  ByteShift: Cardinal;
  BitShift: Cardinal;
  UsedA, N: Cardinal;
  Tmp: PByteArrayInstance;
  Carry: Byte;
  W: Word;
  Src, Tgt: PByte;

begin
  UsedA:= A.FUsed;
  Result:= Allocate(Tmp, UsedA);
  if Result <> TF_S_OK then Exit;

  FillChar(Tmp.FData, UsedA, 0);
  ByteShift:= Shift shr 3;
  if ByteShift < UsedA then begin
    BitShift:= Shift and 7;
    N:= UsedA - ByteShift;      // N > 0
    if BitShift = 0 then begin
      Move(A.FData, Tmp.FData[ByteShift], N);
    end
    else begin
      Src:= @A.FData;
      Tgt:= @Tmp.FData[ByteShift];
      Carry:= 0;
      repeat
        W:= Src^;
        W:= W shl (8 - BitShift);
        Tgt^:= WordRec(W).Hi or Carry;
        Carry:= WordRec(W).Lo;
        Dec(N);
        Inc(Src);
        Inc(Tgt);
      until N = 0;
    end;
  end;
  TForgeHelper.Free(R);
//  tfFreeInstance(R); // if R <> nil then TtfRecord.Release(R);
  R:= Tmp;
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.GetEnum(Inst: PByteArrayInstance;
                                   var AEnum: PByteArrayEnum): TF_RESULT;
var
  Tmp: PByteArrayEnum;

begin
  Result:= TByteArrayEnum.Init(Tmp, Inst);
  if Result = TF_S_OK then begin
    TForgeHelper.Free(AEnum);
//    if AEnum <> nil then TByteArrayEnum.Release(AEnum);
    AEnum:= Tmp;
  end;
end;

class function TByteArrayInstance.GetHashCode(Inst: PByteArrayInstance): Integer;
begin
  Result:= TJenkins1.Hash(Inst.FData, Inst.FUsed);
end;

class function TByteArrayInstance.ConcatBytes(A, B: PByteArrayInstance;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA, UsedB: Cardinal;
  P: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;

  Result:= Allocate(Tmp, UsedA + UsedB);
  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;

  P:= @Tmp.FData;
  Move(A.FData, P^, UsedA);
  Inc(P, UsedA);
  Move(B.FData, P^, UsedB);
  Tmp.FUsed:= UsedA + UsedB;
  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.CopyBytes(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
begin
  Result:= FromPByte(R, @A.FData, A.FUsed);
end;

class function TByteArrayInstance.ReverseBytes(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
var
  LUsed: Integer;
  Tmp: PByteArrayInstance;
  PA, PTmp: PByte;

begin
  LUsed:= A.FUsed;
  Result:= Allocate(Tmp, LUsed);
  if Result = TF_S_OK then begin
//    Tmp.FBigEndian:= A.FBigEndian;
    PA:= @A.FData;
    PTmp:= @Tmp.FData;
    Inc(PA, LUsed);
    while LUsed > 0 do begin
      Dec(PA);
      PTmp^:= PA^;
      Inc(PTmp);
      Dec(LUsed);
    end;
    TForgeHelper.Free(R);
//    tfFreeInstance(R); //if R <> nil then TtfRecord.Release(R);
    R:= Tmp;
  end;
end;

class function TByteArrayInstance.CopyBytes1(A: PByteArrayInstance; var R: PByteArrayInstance;
                I: Cardinal): TF_RESULT;
var
  L: Cardinal;

begin
  L:= A.FUsed;
  if (I < L)
    then L:= L - I
    else L:= 0;

  Result:= FromPByte(R, @A.FData[I], L);
end;

class function TByteArrayInstance.CopyBytes2(A: PByteArrayInstance; var R: PByteArrayInstance;
               I, L: Cardinal): TF_RESULT;
var
  LL: Cardinal;

begin
  LL:= A.FUsed;
  if (I < LL) then begin
    if (LL - I < L)
      then L:= LL - I;
  end
  else
    L:= 0;

  Result:= FromPByte(R, @A.FData[I], L);
end;

class function TByteArrayInstance.RemoveBytes1(A: PByteArrayInstance; var R: PByteArrayInstance;
               I: Cardinal): TF_RESULT;
var
  L: Cardinal;

begin
  L:= A.FUsed;
  if (I < L)
    then L:= I;

  Result:= FromPByte(R, @A.FData, L);
end;

class function TByteArrayInstance.RemoveBytes2(A: PByteArrayInstance; var R: PByteArrayInstance;
               I, L: Cardinal): TF_RESULT;
var
  LL: Cardinal;
  UsedA: Cardinal;
  Tmp: PByteArrayInstance;
  PTmp: PByte;

begin
  UsedA:= A.FUsed;
  LL:= UsedA;
  if (I < UsedA)
    then LL:= I;

  if (L > UsedA - LL) then L:= UsedA - LL;

  Result:= Allocate(Tmp, UsedA - L);
  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;
  PTmp:= @Tmp.FData;

  if LL > 0 then begin
    Move(A.FData, PTmp^, LL);
    Inc(PTmp, LL);
  end;

  if UsedA - L > LL then
    Move(A.FData[UsedA - L], PTmp^, UsedA - L - LL);

  Tmp.FUsed:= UsedA - L;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.DeleteBytes(A: PByteArrayInstance; I,
  L: Cardinal): TF_RESULT;
var
  UsedA: Cardinal;

begin
  UsedA:= A.FUsed;
  if I < UsedA then begin
    if L >= UsedA - I then
      SetLen(A, I)
    else begin
      Move(A.FData[I + L], A.FData[I], UsedA - I - L);
      SetLen(A, UsedA - L);
    end;
  end;
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.EqualBytes(A, B: PByteArrayInstance): Boolean;
begin
  Result:= (A.FUsed = B.FUsed) and
    CompareMem(@A.FData, @B.FData, A.FUsed);
end;

class function TByteArrayInstance.AddBytes(A, B: PByteArrayInstance;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= Allocate(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;
//  Tmp.FUsed:= UsedR;

  PA:= @A.FData;
  PB:= @B.FData;
  PR:= @Tmp.FData;
  while UsedR > 0 do begin
    PR^:= PA^+PB^;
    Inc(PA);
    Inc(PB);
    Inc(PR);
    Dec(UsedR);
  end;
  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.SubBytes(A, B: PByteArrayInstance;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= Allocate(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;
//  Tmp.FBigEndian:= A.FBigEndian;
//  Tmp.FUsed:= UsedR;

  PA:= @A.FData;
  PB:= @B.FData;
  PR:= @Tmp.FData;
  while UsedR > 0 do begin
    PR^:= PA^ - PB^;
    Inc(PA);
    Inc(PB);
    Inc(PR);
    Dec(UsedR);
  end;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.AndBytes(A, B: PByteArrayInstance;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= Allocate(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;
//  Tmp.FUsed:= UsedR;

  PA:= @A.FData;
  PB:= @B.FData;
  PR:= @Tmp.FData;
  while UsedR > 0 do begin
    PR^:= PA^ and PB^;
    Inc(PA);
    Inc(PB);
    Inc(PR);
    Dec(UsedR);
  end;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.OrBytes(A, B: PByteArrayInstance;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= Allocate(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;
//  Tmp.FUsed:= UsedR;

  PA:= @A.FData;
  PB:= @B.FData;
  PR:= @Tmp.FData;
  while UsedR > 0 do begin
    PR^:= PA^ or PB^;
    Inc(PA);
    Inc(PB);
    Inc(PR);
    Dec(UsedR);
  end;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.XorBytes(A, B: PByteArrayInstance;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= Allocate(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;

//  Tmp.FUsed:= UsedR;

  PA:= @A.FData;
  PB:= @B.FData;
  PR:= @Tmp.FData;
  while UsedR > 0 do begin
    PR^:= PA^ xor PB^;
    Inc(PA);
    Inc(PB);
    Inc(PR);
    Dec(UsedR);
  end;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.NotBytes(A: PByteArrayInstance;
  var R: PByteArrayInstance): TF_RESULT;
var
  UsedA: Cardinal;
  PA, PR: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;

  Result:= Allocate(Tmp, UsedA);
  if Result <> TF_S_OK then Exit;

  PA:= @A.FData;
  PR:= @Tmp.FData;
  while UsedA > 0 do begin
    PR^:= not PA^;
    Inc(PA);
    Inc(PR);
    Dec(UsedA);
  end;

  TForgeHelper.Free(R);
  R:= Tmp;
end;

class function TByteArrayInstance.AssignBytes(A: PByteArrayInstance;
                           var R: PByteArrayInstance): TF_RESULT;
begin
  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if R <> nil then TtfRecord.Release(R);
  R:= A;
  TForgeHelper.Addref(R);
//  tfAddrefInstance(A); //if A <> nil then TtfRecord.AddRef(A);
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.ToData(A: PByteArrayInstance; Data: PByte; L: Cardinal;
                 Reversed: Boolean): TF_RESULT;
var
  LA, LL: Cardinal;
  P, Sent: PByte;

begin
  LA:= A.FUsed;
  if (L > LA) then begin
    FillChar((Data + (L - LA))^, L - LA, 0);
    LL:= LA;
  end
  else begin
    if (L < LA) then begin
      P:= @A.FData;
      if Reversed then begin
        Sent:= P + (LA - L);
      end
      else begin
        Sent:= P + LA;
        Inc(P, L);
      end;
      repeat
        if P^ <> 0 then begin
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
        Inc(P);
      until P = Sent;
    end;
    LL:= L;
  end;

  if LA > 0 then begin
    if Reversed
      then TBigEndian.ReverseCopy(PByte(@A.FData) + (LA - LL),
                                  PByte(@A.FData) + LA, Data)
      else Move(A.FData, Data^, LL);
  end;

  Result:= TF_S_OK;
end;

class function TByteArrayInstance.ToDec(A: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
var
  Tmp: PByteArrayInstance;
  PA, PTmp: PByte;
  B: Byte;
  UsedA: Integer;

begin
  UsedA:= A.FUsed;
  if (UsedA = 0) then begin
    TForgeHelper.Free(R);
//    tfFreeInstance(R); //if R <> nil then TtfRecord.Release(R);
    R:= @ZeroArray;
    Result:= TF_S_OK;
    Exit;
  end;

  Result:= Allocate(Tmp, A.FUsed * 4);
  if Result <> TF_S_OK then Exit;

  PA:= @A.FData;
  PTmp:= @Tmp.FData;

  repeat
    B:= PA^;
    if B >= 100 then begin
      PTmp^:= B div 100 + $30;
      B:= B mod 100;
      Inc(PTmp);
      PTmp^:= B div 10 + $30;
      Inc(PTmp);
      PTmp^:= B mod 10 + $30;
    end
    else if B >= 10 then begin
      PTmp^:= B div 10 + $30;
      Inc(PTmp);
      PTmp^:= B mod 10 + $30;
    end
    else begin
      PTmp^:= B + $30;
    end;
    Inc(PTmp);
    PTmp^:= 0;

    Inc(PA);
    Inc(PTmp);
    Dec(UsedA);
  until UsedA = 0;

// last #0 is not included in the length
  Tmp.FUsed:= NativeUInt(PTmp) - NativeUInt(@Tmp.FData) - 1;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if R <> nil then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.AppendByte(A: PByteArrayInstance; B: Byte;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA: Cardinal;
  P: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;

  Result:= Allocate(Tmp, UsedA + 1);
  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;

  P:= @Tmp.FData;
  Move(A.FData, P^, UsedA);
  Inc(P, UsedA);
  P^:= B;
  Tmp.FUsed:= UsedA + 1;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class procedure TByteArrayInstance.Burn(A: PByteArrayInstance);
begin
//  FillChar(A.FData, A.FUsed, 0);
  FillChar(A.FData, A.FCapacity, 0);
  A.FUsed:= 1;
end;

class procedure TByteArrayInstance.Fill(A: PByteArrayInstance; Value: Byte);
begin
  FillChar(A.FData, A.FUsed, Value);
end;

class function TByteArrayInstance.Incr(A: PByteArrayInstance): TF_RESULT;
var
  N: Integer;

begin
  N:= A.FUsed;
  while N > 0 do begin
    Dec(N);
    Inc(A.FData[N]);
    if A.FData[N] <> 0 then Break;
  end;
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.IncrLE(A: PByteArrayInstance): TF_RESULT;
var
  N: Integer;
  P: PByte;

begin
  N:= A.FUsed;
  P:= @A.FData;
  while N > 0 do begin
    Inc(P^);
    if P^ <> 0 then Break;
    Inc(P);
    Dec(N);
  end;
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.Decr(A: PByteArrayInstance): TF_RESULT;
var
  N: Integer;
//  P: PByte;

begin
  N:= A.FUsed;
  while N > 0 do begin
    Dec(N);
    Dec(A.FData[N]);
    if A.FData[N] <> $FF then Break;
  end;
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.DecrLE(A: PByteArrayInstance): TF_RESULT;
var
  N: Integer;
  P: PByte;

begin
  N:= A.FUsed;
  P:= @A.FData;
  while N > 0 do begin
    Dec(P^);
    if P^ <> $FF then Break;
    Inc(P);
    Dec(N);
  end;
  Result:= TF_S_OK;
end;

class function TByteArrayInstance.InsertByte(A: PByteArrayInstance; Index: Cardinal;
               B: Byte; var R: PByteArrayInstance): TF_RESULT;
var
  UsedA: Cardinal;
  PTmp: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;

  Result:= Allocate(Tmp, UsedA + 1);
  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;

  if Index > UsedA then Index:= UsedA;
  PTmp:= @Tmp.FData;
  if Index > 0 then begin
    Move(A.FData, PTmp^, Index);
    Inc(PTmp, Index);
  end;
  PTmp^:= B;
  Inc(PTmp);
  Move(A.FData[Index], PTmp^, UsedA - Index);

  Tmp.FUsed:= UsedA + 1;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.EqualToByte(A: PByteArrayInstance; B: Byte): Boolean;
begin
  Result:= (A.FUsed = 1) and (A.FData[0] = B);
end;

class function TByteArrayInstance.AppendPByte(A: PByteArrayInstance; P: PByte; L: Cardinal;
                           var R: PByteArrayInstance): TF_RESULT;
var
  UsedA: Cardinal;
  PA: PByte;
  Tmp: PByteArrayInstance;

begin
  UsedA:= A.FUsed;

  if L >= MaxCapacity then
    Result:= TF_E_NOMEMORY
  else
    Result:= Allocate(Tmp, UsedA + L);

  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;

  PA:= @Tmp.FData;
  Move(A.FData, PA^, UsedA);
  Inc(PA, UsedA);
  Move(P^, PA^, L);
  Tmp.FUsed:= UsedA + L;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.InsertPByte(A: PByteArrayInstance; Index: Cardinal;
               P: PByte; L: Cardinal; var R: PByteArrayInstance): TF_RESULT;
var
  UsedA: Cardinal;
  Tmp: PByteArrayInstance;
  PTmp: PByte;

begin
  UsedA:= A.FUsed;

  if L >= MaxCapacity then
    Result:= TF_E_NOMEMORY
  else
    Result:= Allocate(Tmp, UsedA + L);

  if Result <> TF_S_OK then Exit;

//  Tmp.FBigEndian:= A.FBigEndian;

  if Index > UsedA then Index:= UsedA;

  PTmp:= @Tmp.FData;

  if Index > 0 then begin
    Move(A.FData, PTmp^, Index);
    Inc(PTmp, Index);
  end;

  Move(P^, PTmp^, L);
  Inc(PTmp, L);

  Move(A.FData[Index], PTmp^, UsedA - Index);
  Tmp.FUsed:= UsedA + L;

  TForgeHelper.Free(R);
//  tfFreeInstance(R); //if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteArrayInstance.InsertBytes(A: PByteArrayInstance; Index: Cardinal;
               B: PByteArrayInstance; var R: PByteArrayInstance): TF_RESULT;
begin
  Result:= InsertPByte(A, Index, @B.FData, B.FUsed, R);
end;

class function TByteArrayInstance.GetRawData(A: PByteArrayInstance): PByte;
begin
  Result:= @A.FData;
end;

class function TByteArrayInstance.EqualToPByte(A: PByteArrayInstance; P: PByte;
                           L: Integer): Boolean;
begin
  Result:= (A.FUsed = L) and
    CompareMem(@A.FData, P, L);
end;


class function TByteArrayInstance.FromPByte(var A: PByteArrayInstance; P: PByte;
           L: Cardinal): TF_RESULT;
var
  Tmp: PByteArrayInstance;

begin
// not needed now after TByteArrayInstance.Allocate(Tmp, 0) sets Tmp:= @ZeroArray;
//  if L = 0 then begin
//    if A <> nil then TtfRecord.Release(A);
//    A:= @ZeroArray;
//    Result:= TF_S_OK;
//    Exit;
//  end;
  Result:= Allocate(Tmp, L);
  if Result = TF_S_OK then begin
    Move(P^, Tmp.FData, L);
//    Tmp.FUsed:= L;
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

class function TByteArrayInstance.FromPByteEx(var A: PByteArrayInstance; P: PByte;
           L: Cardinal; Reversed: Boolean): TF_RESULT;
var
  Tmp: PByteArrayInstance;

begin
  Result:= Allocate(Tmp, L);
  if (Result = TF_S_OK) then begin
//    Tmp.FBigEndian:= Reversed;
    if (L > 0) then begin
      if Reversed then TBigEndian.ReverseCopy(P, P + L, @Tmp.FData)
      else Move(P^, Tmp.FData, L);
    end;
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

function GetNibble(var B: Byte): Boolean;
const
  ASCII_0 = Ord('0');
  ASCII_9 = Ord('9');
  ASCII_A = Ord('A');
  ASCII_F = Ord('F');

var
  LB: Byte;

begin
  LB:= B;
  if LB < ASCII_0 then begin
    Result:= False;
    Exit;
  end;
  if LB <= ASCII_9 then begin
    B:= LB - ASCII_0;
    Result:= True;
    Exit;
  end;
  LB:= LB and not $20;  // UpCase
  if (LB < ASCII_A) or (LB > ASCII_F) then begin
    Result:= False;
    Exit;
  end;
  B:= LB + 10 - ASCII_A;
  Result:= True;
end;

class function TByteArrayInstance.FromPCharHex(var A: PByteArrayInstance; P: PByte;
         L: Cardinal; CharSize: Cardinal): TF_RESULT;
var
  Tmp: PByteArrayInstance;
  B, Nibble: Byte;
  PA: PByte;

begin
  if Odd(L) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  if L = 0 then begin
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= @ZeroArray;
    Result:= TF_S_OK;
    Exit;
  end;
  L:= L shr 1;
  Result:= Allocate(Tmp, L);
  if Result = TF_S_OK then begin
    Tmp.FUsed:= L;
    PA:= @Tmp.FData;
    repeat
      B:= P^;
      if not GetNibble(B) then begin
        TForgeHelper.Release(Tmp);
//        tfReleaseInstance(Tmp); // TtfRecord.Release(Tmp);
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      Inc(P, CharSize);
      Nibble:= P^;
      if not GetNibble(Nibble) then begin
        TForgeHelper.Release(Tmp);
//        tfReleaseInstance(Tmp); // TtfRecord.Release(Tmp);
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      PA^:= B shl 4 + Nibble;
      Inc(PA);
      Inc(P, CharSize);
      Dec(L);
    until L = 0;
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

class function TByteArrayInstance.Parse(var A: PByteArrayInstance; P: PByte;
         L: Cardinal; CharSize: Cardinal; Delimiter: Byte): TF_RESULT;
const
  ASCII_ZERO: Cardinal = Ord('0');
  ASCII_NINE: Cardinal = Ord('9');
  ASCII_SPACE: Cardinal = Ord(' ');

var
  Buffer: array[0..4095] of Byte;
  BufCount: Cardinal;
  Tmp: PByteArrayInstance;
  TmpP: PByte;
  Value: Cardinal;
  ValueExists: Boolean;
  TmpSize: Cardinal;
  B, Nibble: Byte;
  IsHex: Boolean;

begin

// skip leading spaces
  while (L > 0) and (P^ <= ASCII_SPACE) do begin
    Inc(P, CharSize);
    Dec(L);
  end;

  Tmp:= nil;
  TmpSize:= 0;
  BufCount:= 0;

  while (L > 0) do begin
    Value:= 0;
//    State:= 0;
    ValueExists:= False;
    IsHex:= False;
// 3 chars required for a valid $.. hex byte
    if (L > 2) and (P^ = Byte('$')) then begin
      Inc(P, CharSize);
      Dec(L);
      IsHex:= True;
    end;
// 4 chars required for a valid 0x.. hex byte
    if (L > 3) and (P^ = ASCII_ZERO)  and ((P + CharSize)^ = Byte('x')) then begin
      Inc(P, 2 * CharSize);
      Dec(L, 2);
      IsHex:= True;
    end;

    if IsHex then begin
      B:= P^;
      if not GetNibble(B) then begin
        TForgeHelper.Free(Tmp);
//        tfFreeInstance(Tmp); //if Tmp <> nil then TtfRecord.Release(Tmp);
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      Inc(P, CharSize);
      Dec(L);
      Nibble:= P^;
      if not GetNibble(Nibble) then begin
        TForgeHelper.Free(Tmp);
//        tfFreeInstance(Tmp); //if Tmp <> nil then TtfRecord.Release(Tmp);
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
      Inc(P, CharSize);
      Dec(L);

      ValueExists:= True;
      Value:= B * 16 + Nibble;

// next byte should not be a valid hex digit
      if (L > 0) and GetNibble(Nibble) then begin
        TForgeHelper.Free(Tmp);
//        tfFreeInstance(Tmp); //if Tmp <> nil then TtfRecord.Release(Tmp);
        Result:= TF_E_INVALIDARG;
        Exit;
      end;
    end
    else begin
      repeat
        B:= P^;
//        Inc(P, CharSize);
//        Dec(L);
        if (B >= ASCII_ZERO) and (B <= ASCII_NINE) then begin
          ValueExists:= True;
          Value:= Value * 10 + (B - ASCII_ZERO);
          if Value > 255 then begin
            TForgeHelper.Free(Tmp);
//            tfFreeInstance(Tmp); //if Tmp <> nil then TtfRecord.Release(Tmp);
            Result:= TF_E_INVALIDARG;
            Exit;
          end;
          Inc(P, CharSize);
          Dec(L);
        end
        else Break;
      until L = 0;
    end;
    if ValueExists then begin
      if BufCount = SizeOf(Buffer) then begin
        Inc(TmpSize, SizeOf(Buffer));
        Result:= TByteArrayInstance.ReAlloc(Tmp, TmpSize);
        if Result <> TF_S_OK then begin
          TForgeHelper.Free(Tmp);
//          tfFreeInstance(Tmp); //if Tmp <> nil then TtfRecord.Release(Tmp);
          Exit;
        end;
        TmpP:= PByte(@Tmp.FData) + TmpSize - SizeOf(Buffer);
        Move(Buffer, TmpP^, SizeOf(Buffer));
        BufCount:= 0;
      end;
      Buffer[BufCount]:= Value;
      Inc(BufCount);
//       Inc(State);
    end
    else begin
      TForgeHelper.Free(Tmp);
//      tfFreeInstance(Tmp); //if Tmp <> nil then TtfRecord.Release(Tmp);
      Result:= TF_E_INVALIDARG;
      Exit;
    end;
        // skip spaces
    while (L > 0) and (P^ <= ASCII_SPACE) do begin
      Inc(P, CharSize);
      Dec(L);
    end;
       // skip delimiter
    if (Delimiter > 0) and (L > 0) and (P^ = Delimiter) then begin
      Inc(P, CharSize);
      Dec(L);
    end;
       // skip spaces
    while (L > 0) and (P^ <= ASCII_SPACE) do begin
      Inc(P, CharSize);
      Dec(L);
    end;
  end;

  if BufCount > 0 then begin
    Inc(TmpSize, BufCount);
    Result:= TByteArrayInstance.ReAlloc(Tmp, TmpSize);
    if Result <> TF_S_OK then begin
      TForgeHelper.Free(Tmp);
//      tfFreeInstance(Tmp); //if Tmp <> nil then TtfRecord.Release(Tmp);
      Exit;
    end;
    TmpP:= PByte(@Tmp.FData) + TmpSize - BufCount;
    Move(Buffer, TmpP^, BufCount);
//    BufCount:= 0;
  end;

  TForgeHelper.Free(A);
//  tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
  if Tmp = nil then begin
    A:= @ZeroArray;
  end
  else A:= Tmp;
  Result:= TF_S_OK;
end;

  (*
      case State of
        0: if (B >= ASCII_ZERO) and (B <= ASCII_NINE) then begin
             ValueExists:= True;
             Value:= Value * 10 + (B - ASCII_ZERO);
             if Value > 255 then begin
               if Tmp <> nil then TtfRecord.Release(Tmp);
               Result:= TF_E_INVALIDARG;
               Exit;
             end;
             Inc(P, CharSize);
             Dec(L);
           end
           else Inc(State);
        1: if ValueExists then begin
// todo:
             if BufCount = SizeOf(Buffer) then begin
               Inc(TmpSize, SizeOf(Buffer));
               Result:= ByteVectorRealloc(Tmp, TmpSize);
               if Result <> TF_S_OK then begin
                 if Tmp <> nil then TtfRecord.Release(Tmp);
                 Exit;
               end;
               TmpP:= PByte(@Tmp.FData) + TmpSize - SizeOf(Buffer);
               Move(Buffer, TmpP^, SizeOf(Buffer));
               BufCount:= 0;
             end;
             Buffer[BufCount]:= Value;
             Inc(BufCount);
             Inc(State);
           end
           else begin
             if Tmp <> nil then TtfRecord.Release(Tmp);
             Result:= TF_E_INVALIDARG;
             Exit;
           end;
        2: begin       // skip spaces
             while (L > 0) and (P^ <= ASCII_SPACE) do begin
               Inc(P, CharSize);
               Dec(L);
             end;
             Inc(State);
           end;
        3: begin       // skip delimiter
             if (Delimiter > 0) and (L > 0) and (P^ = Delimiter) then begin
               Inc(P, CharSize);
               Dec(L);
             end;
             Inc(State);
           end;
        4: begin       // skip spaces
             while (L > 0) and (P^ <= ASCII_SPACE) do begin
               Inc(P, CharSize);
               Dec(L);
             end;
             State:= 0;
           end;
      end {case};
    until (L = 0); // or (PBuffer = Sentinel);
        else begin
          if Tmp <> nil then TtfRecord.Release(Tmp);
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
    until (L = 0) or (PBuffer = Sentinel);
  until L = 0; *)


class function TByteArrayInstance.ParseHex(var A: PByteArrayInstance; P: PByte;
         L: Cardinal; CharSize: Cardinal; Delimiter: Byte): TF_RESULT;
var
  Tmp: PByteArrayInstance;
  B, Nibble: Byte;
  PA: PByte;
  Cnt: Integer;

begin
  if L = 0 then begin
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= @ZeroArray;
    Result:= TF_S_OK;
    Exit;
  end;

//  L:= L shr 1;
  Result:= Allocate(Tmp, L shr 1);

  if Result = TF_S_OK then begin
//    Tmp.FUsed:= L;
    PA:= @Tmp.FData;
    Cnt:= 0;
    repeat
      while ((P^ = $20) or (P^ = Delimiter)) and (L > 0) do begin
        Inc(P, CharSize);
        Dec(L);
      end;
      if L > 0 then begin
        B:= P^;
        if not GetNibble(B) then begin
          TForgeHelper.Release(Tmp);
//          tfReleaseInstance(Tmp); //TtfRecord.Release(Tmp);
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
        Inc(P, CharSize);
        Dec(L);
        if L = 0 then begin
          TForgeHelper.Release(Tmp);
//          tfReleaseInstance(Tmp); //TtfRecord.Release(Tmp);
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
        Nibble:= P^;
        if not GetNibble(Nibble) then begin
          TForgeHelper.Release(Tmp);
//          tfReleaseInstance(Tmp); //TtfRecord.Release(Tmp);
          Result:= TF_E_INVALIDARG;
          Exit;
        end;
        PA^:= B shl 4 + Nibble;
        Inc(Cnt);
        Inc(PA);
        Inc(P, CharSize);
        Dec(L);
      end;
    until L = 0;
    Tmp.FUsed:= Cnt;
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

class function TByteArrayInstance.FromByte(var A: PByteArrayInstance; Value: Byte): TF_RESULT;
var
  Tmp: PByteArrayInstance;

begin
  Result:= Allocate(Tmp, 1);
  if Result = TF_S_OK then begin
    Tmp.FData[0]:= Value;
    TForgeHelper.Free(A);
//    tfFreeInstance(A); //if (A <> nil) then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

{ TByteArrayEnum }

class function TByteArrayEnum.Release(Inst: PByteArrayEnum): Integer;
begin
// we need this check because FRefCount = -1 is allowed
  if Inst.FRefCount > 0 then begin
    Result:= tfDecrement(Inst.FRefCount);
    if Result = 0 then begin
      IBytes(Inst.FVector)._Release;
      FreeMem(Inst);
    end;
  end
  else
    Result:= Inst.FRefCount;
end;

class function TByteArrayEnum.Init(var Inst: PByteArrayEnum;
  AVector: PByteArrayInstance): TF_RESULT;
var
  BytesRequired: Cardinal;

begin
  BytesRequired:= (SizeOf(TByteArrayEnum) + 7) and not 7;
  try
    GetMem(Inst, BytesRequired);
    Inst^.FVTable:= @ByteVecEnumVTable;
    Inst^.FRefCount:= 1;
    IBytes(AVector)._Addref;
    Inst^.FVector:= AVector;
    Inst^.FIndex:= -1;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TByteArrayEnum.GetCurrent(Inst: PByteArrayEnum): Byte;
begin
  Result:= Inst.FVector.FData[Inst.FIndex];
end;

class function TByteArrayEnum.MoveNext(Inst: PByteArrayEnum): Boolean;
begin
  Result:= Inst.FIndex + 1 < Inst.FVector.FUsed;
  if Result then
    Inc(Inst.FIndex);
end;

class procedure TByteArrayEnum.Reset(Inst: PByteArrayEnum);
begin
  Inst.FIndex:= -1;
end;

end.
