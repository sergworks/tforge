{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tgBytes;

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
    class function EqualBytes(A, B: PByteVector): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ConcatBytes(A, B: PByteVector; var R: PByteVector): TF_RESULT;
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

    class function AssignBytes(A: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function ToDec(A: PByteVector; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;

    class function AppendByte(A: PByteVector; B: Byte; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function PrependByte(A: PByteVector; B: Byte; var R: PByteVector): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EqualToByte(A: PByteVector; B: Byte): Boolean;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function ByteVectorAlloc(var A: PByteVector; ASize: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorFromPByte(var A: PByteVector; P: PByte; L: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function ByteVectorFromByte(var A: PByteVector; Value: Byte): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

implementation

uses tfRecords, tfJenkinsOne;

const
  ByteVecVTable: array[0..15] of Pointer = (
   @TtfRecord.QueryIntf,
   @TtfRecord.Addref,
   @TtfRecord.Release,
   nil,

   @TByteVector.GetHashCode,
   @TByteVector.EqualBytes,
   @TByteVector.ConcatBytes,

   @TByteVector.AddBytes,
   @TByteVector.SubBytes,
   @TByteVector.AndBytes,
   @TByteVector.OrBytes,
   @TByteVector.XorBytes,

   @TByteVector.AssignBytes,

   @TByteVector.ToDec,

   @TByteVector.EqualToByte,
   @TByteVector.AppendByte
   );

(*
const
  ByteVecZero: TByteVector = (
    FVTable: @ByteVecVTable;
    FRefCount: -1;
    FCapacity: 0;
    FUsed: 1;
{$IFDEF DEBUG}
    FBytes: (0, 0, 0, 0, 0, 0, 0, 0);
{$ELSE}
    FBytes: (0);
{$ENDIF}
    );
*)

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
  BytesRequired:= NBytes + ByteVecPrefixSize;
  BytesRequired:= (BytesRequired + 7) and not 7;
  try
    GetMem(A, BytesRequired);
    A^.FVTable:= @ByteVecVTable;
    A^.FRefCount:= 1;
    A^.FCapacity:= BytesRequired - ByteVecPrefixSize;
    A^.FUsed:= 1;
    A^.FData[0]:= 0;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

class function TByteVector.GetHashCode(Inst: PByteVector): Integer;
begin
  Result:= JenkinsOneHash(Inst.FData, Inst.FUsed);
end;

class function TByteVector.EqualBytes(A, B: PByteVector): Boolean;
begin
  Result:= (A.FUsed = B.FUsed) and
    CompareMem(@A.FData, @B.FData, A.FUsed);
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

class function TByteVector.PrependByte(A: PByteVector; B: Byte;
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
  P^:= B;
  Inc(P);
  Move(A.FData, P^, UsedA);
  Tmp.FUsed:= UsedA + 1;

  if (R <> nil) then TtfRecord.Release(R);
  R:= Tmp;
end;

class function TByteVector.EqualToByte(A: PByteVector; B: Byte): Boolean;
begin
  Result:= (A.FUsed = 1) and (A.FData[0] = B);
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

(*
function ByteToDec(B: Byte; Target: PByte): Integer; inline;
var
  Tmp: Byte;

begin
  if B >= 100 then begin
    Tmp:= B div 100;
    B:= B mod 100;
    Target^:= Tmp + $30;
    Inc(Target);
    Tmp:= B div 10;
    B:= B mod 10;
    Target^:= Tmp + $30;
    Inc(Target);
    Target^:= B + $30;
    Result:= 3;
  end
  else if B >= 10 then begin
    Tmp:= B div 10;
    B:= B mod 10;
    Target^:= Tmp + $30;
    Inc(Target);
    Target^:= B + $30;
    Result:= 2;
  end
  else begin
    Target^:= B + $30;
    Result:= 1;
  end;
end;
*)

class function TByteVector.ToDec(A: PByteVector; var R: PByteVector): TF_RESULT;
var
  Tmp: PByteVector;
  PA, PTmp: PByte;
  I: Integer;
  B: Byte;

begin
  if (A = nil) or (A.FUsed = 0) then begin
    if R <> nil then TtfRecord.Release(R);
    R:= nil;
    Result:= TF_S_OK;
    Exit;
  end;

  Result:= AllocVector(Tmp, A.FUsed * 4);
  if Result <> TF_S_OK then Exit;

  PA:= @A.FData;
  PTmp:= @Tmp.FData;

  for I:= 1 to A.FUsed - 1 do begin
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
  end;
  Tmp.FUsed:= NativeInt(PTmp) - NativeInt(@Tmp.FData);

  if R <> nil then TtfRecord.Release(R);
  R:= Tmp;
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

function ByteVectorFromPByte(var A: PByteVector; P: PByte; L: Cardinal): TF_RESULT;
  {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
var
  Tmp: PByteVector;

begin
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
