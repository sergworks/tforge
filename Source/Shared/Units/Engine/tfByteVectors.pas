{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfByteVectors;

{$I TFL.inc}

{$R-}   // range checking is not allowed

interface

uses tfTypes, SysUtils;

// called ByteVector to avoid name conflict with SysUtils.TByteArray
type
  PByteVector = ^TByteVector;
  PPByteVector = ^PByteVector;
  TByteVector = record
  private const
    FUsedSize = SizeOf(Integer); // because SizeOf(FUsed) does not compile
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

    class function AllocVector(var A: PByteVector; NBytes: Cardinal): TF_RESULT; static;

    class function GetHashCode(Inst: PByteVector): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetLen(A: PByteVector): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetRawData(A: PByteVector): PByte;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AssignBytes(A: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function CopyBytes(A: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function CopyBytes1(A: PByteVector; var R: PByteVector; I: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function CopyBytes2(A: PByteVector; var R: PByteVector; I, L: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RemoveBytes1(A: PByteVector; var R: PByteVector; I: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RemoveBytes2(A: PByteVector; var R: PByteVector; I, L: Cardinal): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ConcatBytes(A, B: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function InsertBytes(A: PByteVector; Index: Cardinal; B: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EqualBytes(A, B: PByteVector): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AddBytes(A, B: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function SubBytes(A, B: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function AndBytes(A, B: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function OrBytes(A, B: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function XorBytes(A, B: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AppendByte(A: PByteVector; B: Byte; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function InsertByte(A: PByteVector; Index: Cardinal; B: Byte; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EqualToByte(A: PByteVector; B: Byte): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AppendPByte(A: PByteVector; P: PByte; L: Cardinal; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function InsertPByte(A: PByteVector; Index: Cardinal; P: PByte;
                               L: Cardinal; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EqualToPByte(A: PByteVector; P: PByte; L: Integer): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ToDec(A: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function ByteVectorAlloc(var A: PByteVector; ASize: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorFromPByte(var A: PByteVector; P: PByte; L: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorFromByte(var A: PByteVector; Value: Byte): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

implementation

uses tfRecords, tfUtils;

const
  ByteVecVTable: array[0..27] of Pointer = (
   @TtfRecord.QueryIntf,
   @TtfRecord.Addref,
   @TtfRecord.Release,
   nil,

   @TByteVector.GetHashCode,
   @TByteVector.GetLen,
   @TByteVector.GetRawData,

   @TByteVector.AssignBytes,
   @TByteVector.CopyBytes,
   @TByteVector.CopyBytes1,
   @TByteVector.CopyBytes2,
   @TByteVector.RemoveBytes1,
   @TByteVector.RemoveBytes2,
   @TByteVector.ConcatBytes,
   @TByteVector.InsertBytes,
   @TByteVector.EqualBytes,

   @TByteVector.AddBytes,
   @TByteVector.SubBytes,
   @TByteVector.AndBytes,
   @TByteVector.OrBytes,
   @TByteVector.XorBytes,

   @TByteVector.AppendByte,
   @TByteVector.InsertByte,
   @TByteVector.EqualToByte,

   @TByteVector.AppendPByte,
   @TByteVector.InsertPByte,
   @TByteVector.EqualToByte,

   @TByteVector.ToDec
   );

const
  ZeroVector: TByteVector = (
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

{ TByteVector }

const
  ByteVecPrefixSize = SizeOf(TByteVector) - SizeOf(TByteVector.TData);
  MaxCapacity = $01000000;

class function TByteVector.AllocVector(var A: PByteVector;
                                       NBytes: Cardinal): TF_RESULT;
var
  BytesRequired: Cardinal;

begin
  if NBytes >= MaxCapacity then begin
    Result:= TF_E_NOMEMORY;
    Exit;
  end;
{  if NBytes = 0 then begin
    A:= @ByteVecEmpty;
    Result:= TF_S_OK;
    Exit;
  end; }
  BytesRequired:= NBytes + ByteVecPrefixSize;
  BytesRequired:= (BytesRequired + 7) and not 7;
  try
    GetMem(A, BytesRequired);
    A^.FVTable:= @ByteVecVTable;
    A^.FRefCount:= 1;
    A^.FCapacity:= BytesRequired - ByteVecPrefixSize;
    A^.FUsed:= NBytes;
//    A^.FData[0]:= 0;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TByteVector.GetLen(A: PByteVector): Integer;
begin
  Result:= A.FUsed;
end;

class function TByteVector.GetHashCode(Inst: PByteVector): Integer;
begin
  Result:= JenkinsOneHash(Inst.FData, Inst.FUsed);
end;

class function TByteVector.ConcatBytes(A, B: PByteVector;
                           var R: PByteVector): TF_RESULT;
var
  UsedA, UsedB: Cardinal;
  P: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;

  Result:= AllocVector(Tmp, UsedA + UsedB);
  if Result <> TF_S_OK then Exit;

  P:= @Tmp.FData;
  Move(A.FData, P^, UsedA);
  Inc(P, UsedA);
  Move(B.FData, P^, UsedB);
  Tmp.FUsed:= UsedA + UsedB;

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.CopyBytes(A: PByteVector; var R: PByteVector): TF_RESULT;
begin
  Result:= ByteVectorFromPByte(R, @A.FData, A.FUsed);
end;

class function TByteVector.CopyBytes1(A: PByteVector; var R: PByteVector;
                I: Cardinal): TF_RESULT;
var
  L: Cardinal;

begin
  L:= A.FUsed;
  if (I < L)
    then L:= L - I
    else L:= 0;

  Result:= ByteVectorFromPByte(R, @A.FData[I], L);
end;

class function TByteVector.CopyBytes2(A: PByteVector; var R: PByteVector;
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

  Result:= ByteVectorFromPByte(R, @A.FData[I], L);
end;

class function TByteVector.RemoveBytes1(A: PByteVector; var R: PByteVector;
               I: Cardinal): TF_RESULT;
var
  L: Cardinal;

begin
  L:= A.FUsed;
  if (I < L)
    then L:= I;

  Result:= ByteVectorFromPByte(R, @A.FData, L);
end;

class function TByteVector.RemoveBytes2(A: PByteVector; var R: PByteVector;
               I, L: Cardinal): TF_RESULT;
var
  LL: Cardinal;
  UsedA: Cardinal;
  Tmp: PByteVector;
  PTmp: PByte;

begin
  UsedA:= A.FUsed;
  LL:= UsedA;
  if (I < UsedA)
    then LL:= I;

  if (L > UsedA - LL) then L:= UsedA - LL;

  Result:= AllocVector(Tmp, UsedA - L);
  if Result <> TF_S_OK then Exit;

  PTmp:= @Tmp.FData;

  if LL > 0 then begin
    Move(A.FData, PTmp^, LL);
    Inc(PTmp, LL);
  end;

  if UsedA - L > LL then
    Move(A.FData[UsedA - L], PTmp^, UsedA - L - LL);

  Tmp.FUsed:= UsedA - L;

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.EqualBytes(A, B: PByteVector): Boolean;
begin
  Result:= (A.FUsed = B.FUsed) and
    CompareMem(@A.FData, @B.FData, A.FUsed);
end;

class function TByteVector.AddBytes(A, B: PByteVector;
                           var R: PByteVector): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= AllocVector(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;
  Tmp.FUsed:= UsedR;

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

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.SubBytes(A, B: PByteVector;
                           var R: PByteVector): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= AllocVector(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;
  Tmp.FUsed:= UsedR;

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

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.AndBytes(A, B: PByteVector;
                           var R: PByteVector): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= AllocVector(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;
  Tmp.FUsed:= UsedR;

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

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.OrBytes(A, B: PByteVector;
                           var R: PByteVector): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= AllocVector(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;
  Tmp.FUsed:= UsedR;

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

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.XorBytes(A, B: PByteVector;
                           var R: PByteVector): TF_RESULT;
var
  UsedA, UsedB, UsedR: Cardinal;
  PA, PB, PR: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;
  UsedB:= B.FUsed;
  UsedR:= UsedA;
  if UsedR > UsedB then UsedR:= UsedB;

  Result:= AllocVector(Tmp, UsedR);
  if Result <> TF_S_OK then Exit;
  Tmp.FUsed:= UsedR;

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

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.AssignBytes(A: PByteVector;
                           var R: PByteVector): TF_RESULT;
begin
  if R <> nil then TtfRecord.Release(R);
  R:= A;
  if A <> nil then TtfRecord.AddRef(A);
  Result:= TF_S_OK;
end;

class function TByteVector.ToDec(A: PByteVector; var R: PByteVector): TF_RESULT;
var
  Tmp: PByteVector;
  PA, PTmp: PByte;
  B: Byte;
  UsedA: Integer;

begin
  UsedA:= A.FUsed;
  if (UsedA = 0) then begin
    if R <> nil then TtfRecord.Release(R);
    R:= @ZeroVector;
    Result:= TF_S_OK;
    Exit;
  end;

  Result:= AllocVector(Tmp, A.FUsed * 4);
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
  Tmp.FUsed:= NativeInt(PTmp) - NativeInt(@Tmp.FData) - 1;

  if R <> nil then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.AppendByte(A: PByteVector; B: Byte;
                           var R: PByteVector): TF_RESULT;
var
  UsedA: Cardinal;
  P: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;

  Result:= AllocVector(Tmp, UsedA + 1);
  if Result <> TF_S_OK then Exit;

  P:= @Tmp.FData;
  Move(A.FData, P^, UsedA);
  Inc(P, UsedA);
  P^:= B;
  Tmp.FUsed:= UsedA + 1;

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.InsertByte(A: PByteVector; Index: Cardinal;
               B: Byte; var R: PByteVector): TF_RESULT;
var
  UsedA: Cardinal;
  PTmp: PByte;
  Tmp: PByteVector;

begin
  UsedA:= A.FUsed;

  Result:= AllocVector(Tmp, UsedA + 1);
  if Result <> TF_S_OK then Exit;

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

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.EqualToByte(A: PByteVector; B: Byte): Boolean;
begin
  Result:= (A.FUsed = 1) and (A.FData[0] = B);
end;

class function TByteVector.AppendPByte(A: PByteVector; P: PByte; L: Cardinal;
                           var R: PByteVector): TF_RESULT;
var
  UsedA: Cardinal;
  PA: PByte;
  Tmp: PByteVector;

begin
  if L >= MaxCapacity then
    Result:= TF_E_NOMEMORY
  else begin
    UsedA:= A.FUsed;
    Result:= AllocVector(Tmp, UsedA + L);
  end;
  if Result <> TF_S_OK then Exit;

  PA:= @Tmp.FData;
  Move(A.FData, PA^, UsedA);
  Inc(PA, UsedA);
  Move(P^, PA^, L);
  Tmp.FUsed:= UsedA + L;

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.InsertPByte(A: PByteVector; Index: Cardinal;
               P: PByte; L: Cardinal; var R: PByteVector): TF_RESULT;
var
  UsedA: Cardinal;
  Tmp: PByteVector;
  PTmp: PByte;

begin
  if L >= MaxCapacity then
    Result:= TF_E_NOMEMORY
  else begin
    UsedA:= A.FUsed;
    Result:= AllocVector(Tmp, UsedA + L);
  end;
  if Result <> TF_S_OK then Exit;

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

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.InsertBytes(A: PByteVector; Index: Cardinal;
               B: PByteVector; var R: PByteVector): TF_RESULT;
begin
  Result:= InsertPByte(A, Index, @B.FData, B.FUsed, R);
end;

class function TByteVector.GetRawData(A: PByteVector): PByte;
begin
  Result:= @A.FData;
end;

class function TByteVector.EqualToPByte(A: PByteVector; P: PByte;
                           L: Integer): Boolean;
begin
  Result:= (A.FUsed = L) and
    CompareMem(@A.FData, P, L);
end;

function ByteVectorAlloc(var A: PByteVector; ASize: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
var
  Tmp: PByteVector;

begin
  Result:= TByteVector.AllocVector(Tmp, ASize);
  if Result = TF_S_OK then begin
    if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

function ByteVectorFromPByte(var A: PByteVector; P: PByte;
           L: Cardinal): TF_RESULT; {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
var
  Tmp: PByteVector;

begin
  if L = 0 then begin
    if A <> nil then TtfRecord.Release(A);
    A:= @ZeroVector;
    Result:= TF_S_OK;
    Exit;
  end;
  Result:= TByteVector.AllocVector(Tmp, L);
  if Result = TF_S_OK then begin
    Move(P^, Tmp.FData, L);
    Tmp.FUsed:= L;
    if A <> nil then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

function ByteVectorFromByte(var A: PByteVector; Value: Byte): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
var
  Tmp: PByteVector;

begin
  Result:= TByteVector.AllocVector(Tmp, 1);
  if Result = TF_S_OK then begin
    Tmp.FData[0]:= Value;
    if (A <> nil) then TtfRecord.Release(A);
    A:= Tmp;
  end;
end;

end.
