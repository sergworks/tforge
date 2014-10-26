{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfSHA256;

{$I TFL.inc}

{$IFDEF TFL_CPUX86_WIN32}
  {$DEFINE CPUX86_WIN32}
{$ENDIF}

{$IFDEF TFL_CPUX64_WIN64}
  {$DEFINE CPUX64_WIN64}
{$ENDIF}

interface

uses tfTypes;

type
  PSHA256Alg = ^TSHA256Alg;
  TSHA256Alg = record
  private type
    TData = record
      Digest: TSHA256Digest;
      Block: array[0..63] of Byte;
      Count: UInt64;                 // number of bytes processed
    end;
  private
    FVTable: Pointer;
    FRefCount: Integer;
    FData: TData;

    procedure Compress;
  public
    class procedure Init(Inst: PSHA256Alg);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Update(Inst: PSHA256Alg; Data: PByte; DataSize: LongWord);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Done(Inst: PSHA256Alg; PDigest: PSHA256Digest);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetDigestSize(Inst: PSHA256Alg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize(Inst: PSHA256Alg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Duplicate(Inst: PSHA256Alg; var DupInst: PSHA256Alg): TF_RESULT;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
end;

type
  PSHA224Alg = ^TSHA224Alg;
  TSHA224Alg = record
  private type
    TData = record
      Digest: TSHA256Digest;         // !! 256 bits
      Block: array[0..63] of Byte;
      Count: UInt64;                 // number of bytes processed
    end;
  private
    FVTable: Pointer;
    FRefCount: Integer;
    FData: TData;

  public
    class procedure Init(Inst: PSHA224Alg);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Done(Inst: PSHA224Alg; PDigest: PSHA224Digest);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetDigestSize(Inst: PSHA256Alg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
end;

function GetSHA256Algorithm(var Inst: PSHA256Alg): TF_RESULT;
function GetSHA224Algorithm(var Inst: PSHA224Alg): TF_RESULT;

implementation

uses tfRecords;

const
  SHA256VTable: array[0..9] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfRecord.Addref,
    @HashAlgRelease,

    @TSHA256Alg.Init,
    @TSHA256Alg.Update,
    @TSHA256Alg.Done,
    @TSHA256Alg.Init,
    @TSHA256Alg.GetDigestSize,
    @TSHA256Alg.GetBlockSize,
    @TSHA256Alg.Duplicate
  );

const
  SHA224VTable: array[0..9] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfRecord.Addref,
    @HashAlgRelease,

    @TSHA224Alg.Init,
    @TSHA256Alg.Update,
    @TSHA224Alg.Done,
    @TSHA224Alg.Init,
    @TSHA224Alg.GetDigestSize,
    @TSHA256Alg.GetBlockSize,
    @TSHA256Alg.Duplicate
  );

function GetSHA256Algorithm(var Inst: PSHA256Alg): TF_RESULT;
var
  P: PSHA256Alg;

begin
  try
    New(P);
    P^.FVTable:= @SHA256VTable;
    P^.FRefCount:= 1;
    TSHA256Alg.Init(P);
    if Inst <> nil then HashAlgRelease(Inst);
    Inst:= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

function GetSHA224Algorithm(var Inst: PSHA224Alg): TF_RESULT;
var
  P: PSHA224Alg;

begin
  try
    New(P);
    P^.FVTable:= @SHA224VTable;
    P^.FRefCount:= 1;
    TSHA224Alg.Init(P);
    if Inst <> nil then HashAlgRelease(Inst);
    Inst:= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

{ TSHA256Algorithm }

function Swap32(Value: LongWord): LongWord;
begin
  Result:= ((Value and $FF) shl 24) or ((Value and $FF00) shl 8) or
           ((Value and $FF0000) shr 8) or ((Value and $FF000000) shr 24);
end;

procedure TSHA256Alg.Compress;
type
  PLongArray = ^TLongArray;
  TLongArray = array[0..15] of LongWord;

var
  W: PLongArray;
//  W: array[0..63] of LongWord;
  a, b, c, d, e, f, g, h, t1, t2: LongWord;
  I: LongWord;

begin
  W:= @FData.Block;

  a:= FData.Digest[0];
  b:= FData.Digest[1];
  c:= FData.Digest[2];
  d:= FData.Digest[3];
  e:= FData.Digest[4];
  f:= FData.Digest[5];
  g:= FData.Digest[6];
  h:= FData.Digest[7];
//  Move(FData.Block, W, SizeOf(FData.Block));

{  for I:= 0 to 15 do
    W[I]:= Swap32(W[I]);

  for I:= 16 to 63 do
    W[I]:= (((W[I-2] shr 17) or (W[I-2] shl 15)) xor
            ((W[I-2] shr 19) or (W[I-2] shl 13)) xor (W[I-2] shr 10)) + W[I-7] +
           (((W[I-15] shr 7) or (W[I-15] shl 25)) xor
            ((W[I-15] shr 18) or (W[I-15] shl 14)) xor (W[I-15] shr 3)) + W[I-16];
}
  W[0]:= Swap32(W[0]);
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $428a2f98 + W[0];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[1]:= Swap32(W[1]);
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $71374491 + W[1];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[2]:= Swap32(W[2]);
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $b5c0fbcf + W[2];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[3]:= Swap32(W[3]);
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $e9b5dba5 + W[3];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[4]:= Swap32(W[4]);
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $3956c25b + W[4];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[5]:= Swap32(W[5]);
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $59f111f1 + W[5];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[6]:= Swap32(W[6]);
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $923f82a4 + W[6];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[7]:= Swap32(W[7]);
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $ab1c5ed5 + W[7];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  W[8]:= Swap32(W[8]);
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $d807aa98 + W[8];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[9]:= Swap32(W[9]);
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $12835b01 + W[9];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[10]:= Swap32(W[10]);
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $243185be + W[10];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[11]:= Swap32(W[11]);
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $550c7dc3 + W[11];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[12]:= Swap32(W[12]);
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $72be5d74 + W[12];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[13]:= Swap32(W[13]);
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $80deb1fe + W[13];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[14]:= Swap32(W[14]);
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $9bdc06a7 + W[14];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[15]:= Swap32(W[15]);
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $c19bf174 + W[15];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;


  W[0]:= (((W[14] shr 17) or (W[14] shl 15)) xor
          ((W[14] shr 19) or (W[14] shl 13)) xor (W[14] shr 10)) + W[9] +
         (((W[1] shr 7) or (W[1] shl 25)) xor
          ((W[1] shr 18) or (W[1] shl 14)) xor (W[1] shr 3)) + W[0];
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $e49b69c1 + W[0];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[1]:= (((W[15] shr 17) or (W[15] shl 15)) xor
          ((W[15] shr 19) or (W[15] shl 13)) xor (W[15] shr 10)) + W[10] +
         (((W[2] shr 7) or (W[2] shl 25)) xor
          ((W[2] shr 18) or (W[2] shl 14)) xor (W[2] shr 3)) + W[1];
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $efbe4786 + W[1];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[2]:= (((W[0] shr 17) or (W[0] shl 15)) xor
          ((W[0] shr 19) or (W[0] shl 13)) xor (W[0] shr 10)) + W[11] +
         (((W[3] shr 7) or (W[3] shl 25)) xor
          ((W[3] shr 18) or (W[3] shl 14)) xor (W[3] shr 3)) + W[2];
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $0fc19dc6 + W[2];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[3]:= (((W[1] shr 17) or (W[1] shl 15)) xor
          ((W[1] shr 19) or (W[1] shl 13)) xor (W[1] shr 10)) + W[12] +
         (((W[4] shr 7) or (W[4] shl 25)) xor
          ((W[4] shr 18) or (W[4] shl 14)) xor (W[4] shr 3)) + W[3];
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $240ca1cc + W[3];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[4]:= (((W[2] shr 17) or (W[2] shl 15)) xor
          ((W[2] shr 19) or (W[2] shl 13)) xor (W[2] shr 10)) + W[13] +
         (((W[5] shr 7) or (W[5] shl 25)) xor
          ((W[5] shr 18) or (W[5] shl 14)) xor (W[5] shr 3)) + W[4];
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $2de92c6f + W[4];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[5]:= (((W[3] shr 17) or (W[3] shl 15)) xor
          ((W[3] shr 19) or (W[3] shl 13)) xor (W[3] shr 10)) + W[14] +
         (((W[6] shr 7) or (W[6] shl 25)) xor
          ((W[6] shr 18) or (W[6] shl 14)) xor (W[6] shr 3)) + W[5];
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $4a7484aa + W[5];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[6]:= (((W[4] shr 17) or (W[4] shl 15)) xor
          ((W[4] shr 19) or (W[4] shl 13)) xor (W[4] shr 10)) + W[15] +
         (((W[7] shr 7) or (W[7] shl 25)) xor
          ((W[7] shr 18) or (W[7] shl 14)) xor (W[7] shr 3)) + W[6];
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $5cb0a9dc + W[6];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[7]:= (((W[5] shr 17) or (W[5] shl 15)) xor
          ((W[5] shr 19) or (W[5] shl 13)) xor (W[5] shr 10)) + W[0] +
         (((W[8] shr 7) or (W[8] shl 25)) xor
          ((W[8] shr 18) or (W[8] shl 14)) xor (W[8] shr 3)) + W[7];
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $76f988da + W[7];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  W[8]:= (((W[6] shr 17) or (W[6] shl 15)) xor
          ((W[6] shr 19) or (W[6] shl 13)) xor (W[6] shr 10)) + W[1] +
         (((W[9] shr 7) or (W[9] shl 25)) xor
          ((W[9] shr 18) or (W[9] shl 14)) xor (W[9] shr 3)) + W[8];
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $983e5152 + W[8];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[9]:= (((W[7] shr 17) or (W[7] shl 15)) xor
          ((W[7] shr 19) or (W[7] shl 13)) xor (W[7] shr 10)) + W[2] +
         (((W[10] shr 7) or (W[10] shl 25)) xor
          ((W[10] shr 18) or (W[10] shl 14)) xor (W[10] shr 3)) + W[9];
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $a831c66d + W[9];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[10]:= (((W[8] shr 17) or (W[8] shl 15)) xor
           ((W[8] shr 19) or (W[8] shl 13)) xor (W[8] shr 10)) + W[3] +
          (((W[11] shr 7) or (W[11] shl 25)) xor
           ((W[11] shr 18) or (W[11] shl 14)) xor (W[11] shr 3)) + W[10];
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $b00327c8 + W[10];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[11]:= (((W[9] shr 17) or (W[9] shl 15)) xor
           ((W[9] shr 19) or (W[9] shl 13)) xor (W[9] shr 10)) + W[4] +
          (((W[12] shr 7) or (W[12] shl 25)) xor
           ((W[12] shr 18) or (W[12] shl 14)) xor (W[12] shr 3)) + W[11];
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $bf597fc7 + W[11];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[12]:= (((W[10] shr 17) or (W[10] shl 15)) xor
           ((W[10] shr 19) or (W[10] shl 13)) xor (W[10] shr 10)) + W[5] +
          (((W[13] shr 7) or (W[13] shl 25)) xor
           ((W[13] shr 18) or (W[13] shl 14)) xor (W[13] shr 3)) + W[12];
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $c6e00bf3 + W[12];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[13]:= (((W[11] shr 17) or (W[11] shl 15)) xor
           ((W[11] shr 19) or (W[11] shl 13)) xor (W[11] shr 10)) + W[6] +
          (((W[14] shr 7) or (W[14] shl 25)) xor
           ((W[14] shr 18) or (W[14] shl 14)) xor (W[14] shr 3)) + W[13];
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $d5a79147 + W[13];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[14]:= (((W[12] shr 17) or (W[12] shl 15)) xor
           ((W[12] shr 19) or (W[12] shl 13)) xor (W[12] shr 10)) + W[7] +
          (((W[15] shr 7) or (W[15] shl 25)) xor
           ((W[15] shr 18) or (W[15] shl 14)) xor (W[15] shr 3)) + W[14];
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $06ca6351 + W[14];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[15]:= (((W[13] shr 17) or (W[13] shl 15)) xor
           ((W[13] shr 19) or (W[13] shl 13)) xor (W[13] shr 10)) + W[8] +
          (((W[0] shr 7) or (W[0] shl 25)) xor
           ((W[0] shr 18) or (W[0] shl 14)) xor (W[0] shr 3)) + W[15];
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $14292967 + W[15];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  W[0]:= (((W[14] shr 17) or (W[14] shl 15)) xor
          ((W[14] shr 19) or (W[14] shl 13)) xor (W[14] shr 10)) + W[9] +
         (((W[1] shr 7) or (W[1] shl 25)) xor
          ((W[1] shr 18) or (W[1] shl 14)) xor (W[1] shr 3)) + W[0];
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $27b70a85 + W[0];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[1]:= (((W[15] shr 17) or (W[15] shl 15)) xor
          ((W[15] shr 19) or (W[15] shl 13)) xor (W[15] shr 10)) + W[10] +
         (((W[2] shr 7) or (W[2] shl 25)) xor
          ((W[2] shr 18) or (W[2] shl 14)) xor (W[2] shr 3)) + W[1];
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $2e1b2138 + W[1];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[2]:= (((W[0] shr 17) or (W[0] shl 15)) xor
          ((W[0] shr 19) or (W[0] shl 13)) xor (W[0] shr 10)) + W[11] +
         (((W[3] shr 7) or (W[3] shl 25)) xor
          ((W[3] shr 18) or (W[3] shl 14)) xor (W[3] shr 3)) + W[2];
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $4d2c6dfc + W[2];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[3]:= (((W[1] shr 17) or (W[1] shl 15)) xor
          ((W[1] shr 19) or (W[1] shl 13)) xor (W[1] shr 10)) + W[12] +
         (((W[4] shr 7) or (W[4] shl 25)) xor
          ((W[4] shr 18) or (W[4] shl 14)) xor (W[4] shr 3)) + W[3];
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $53380d13 + W[3];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[4]:= (((W[2] shr 17) or (W[2] shl 15)) xor
          ((W[2] shr 19) or (W[2] shl 13)) xor (W[2] shr 10)) + W[13] +
         (((W[5] shr 7) or (W[5] shl 25)) xor
          ((W[5] shr 18) or (W[5] shl 14)) xor (W[5] shr 3)) + W[4];
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $650a7354 + W[4];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[5]:= (((W[3] shr 17) or (W[3] shl 15)) xor
          ((W[3] shr 19) or (W[3] shl 13)) xor (W[3] shr 10)) + W[14] +
         (((W[6] shr 7) or (W[6] shl 25)) xor
          ((W[6] shr 18) or (W[6] shl 14)) xor (W[6] shr 3)) + W[5];
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $766a0abb + W[5];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[6]:= (((W[4] shr 17) or (W[4] shl 15)) xor
          ((W[4] shr 19) or (W[4] shl 13)) xor (W[4] shr 10)) + W[15] +
         (((W[7] shr 7) or (W[7] shl 25)) xor
          ((W[7] shr 18) or (W[7] shl 14)) xor (W[7] shr 3)) + W[6];
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $81c2c92e + W[6];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[7]:= (((W[5] shr 17) or (W[5] shl 15)) xor
          ((W[5] shr 19) or (W[5] shl 13)) xor (W[5] shr 10)) + W[0] +
         (((W[8] shr 7) or (W[8] shl 25)) xor
          ((W[8] shr 18) or (W[8] shl 14)) xor (W[8] shr 3)) + W[7];
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $92722c85 + W[7];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  W[8]:= (((W[6] shr 17) or (W[6] shl 15)) xor
          ((W[6] shr 19) or (W[6] shl 13)) xor (W[6] shr 10)) + W[1] +
         (((W[9] shr 7) or (W[9] shl 25)) xor
          ((W[9] shr 18) or (W[9] shl 14)) xor (W[9] shr 3)) + W[8];
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $a2bfe8a1 + W[8];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[9]:= (((W[7] shr 17) or (W[7] shl 15)) xor
          ((W[7] shr 19) or (W[7] shl 13)) xor (W[7] shr 10)) + W[2] +
         (((W[10] shr 7) or (W[10] shl 25)) xor
          ((W[10] shr 18) or (W[10] shl 14)) xor (W[10] shr 3)) + W[9];
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $a81a664b + W[9];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[10]:= (((W[8] shr 17) or (W[8] shl 15)) xor
           ((W[8] shr 19) or (W[8] shl 13)) xor (W[8] shr 10)) + W[3] +
          (((W[11] shr 7) or (W[11] shl 25)) xor
           ((W[11] shr 18) or (W[11] shl 14)) xor (W[11] shr 3)) + W[10];
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $c24b8b70 + W[10];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[11]:= (((W[9] shr 17) or (W[9] shl 15)) xor
           ((W[9] shr 19) or (W[9] shl 13)) xor (W[9] shr 10)) + W[4] +
          (((W[12] shr 7) or (W[12] shl 25)) xor
           ((W[12] shr 18) or (W[12] shl 14)) xor (W[12] shr 3)) + W[11];
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $c76c51a3 + W[11];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[12]:= (((W[10] shr 17) or (W[10] shl 15)) xor
           ((W[10] shr 19) or (W[10] shl 13)) xor (W[10] shr 10)) + W[5] +
          (((W[13] shr 7) or (W[13] shl 25)) xor
           ((W[13] shr 18) or (W[13] shl 14)) xor (W[13] shr 3)) + W[12];
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $d192e819 + W[12];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[13]:= (((W[11] shr 17) or (W[11] shl 15)) xor
           ((W[11] shr 19) or (W[11] shl 13)) xor (W[11] shr 10)) + W[6] +
          (((W[14] shr 7) or (W[14] shl 25)) xor
           ((W[14] shr 18) or (W[14] shl 14)) xor (W[14] shr 3)) + W[13];
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $d6990624 + W[13];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[14]:= (((W[12] shr 17) or (W[12] shl 15)) xor
           ((W[12] shr 19) or (W[12] shl 13)) xor (W[12] shr 10)) + W[7] +
          (((W[15] shr 7) or (W[15] shl 25)) xor
           ((W[15] shr 18) or (W[15] shl 14)) xor (W[15] shr 3)) + W[14];
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $f40e3585 + W[14];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[15]:= (((W[13] shr 17) or (W[13] shl 15)) xor
           ((W[13] shr 19) or (W[13] shl 13)) xor (W[13] shr 10)) + W[8] +
          (((W[0] shr 7) or (W[0] shl 25)) xor
           ((W[0] shr 18) or (W[0] shl 14)) xor (W[0] shr 3)) + W[15];
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $106aa070 + W[15];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  W[0]:= (((W[14] shr 17) or (W[14] shl 15)) xor
           ((W[14] shr 19) or (W[14] shl 13)) xor (W[14] shr 10)) + W[9] +
         (((W[1] shr 7) or (W[1] shl 25)) xor
          ((W[1] shr 18) or (W[1] shl 14)) xor (W[1] shr 3)) + W[0];
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $19a4c116 + W[0];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[1]:= (((W[15] shr 17) or (W[15] shl 15)) xor
          ((W[15] shr 19) or (W[15] shl 13)) xor (W[15] shr 10)) + W[10] +
         (((W[2] shr 7) or (W[2] shl 25)) xor
          ((W[2] shr 18) or (W[2] shl 14)) xor (W[2] shr 3)) + W[1];
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $1e376c08 + W[1];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[2]:= (((W[0] shr 17) or (W[0] shl 15)) xor
          ((W[0] shr 19) or (W[0] shl 13)) xor (W[0] shr 10)) + W[11] +
         (((W[3] shr 7) or (W[3] shl 25)) xor
          ((W[3] shr 18) or (W[3] shl 14)) xor (W[3] shr 3)) + W[2];
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $2748774c + W[2];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[3]:= (((W[1] shr 17) or (W[1] shl 15)) xor
          ((W[1] shr 19) or (W[1] shl 13)) xor (W[1] shr 10)) + W[12] +
         (((W[4] shr 7) or (W[4] shl 25)) xor
          ((W[4] shr 18) or (W[4] shl 14)) xor (W[4] shr 3)) + W[3];
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $34b0bcb5 + W[3];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[4]:= (((W[2] shr 17) or (W[2] shl 15)) xor
          ((W[2] shr 19) or (W[2] shl 13)) xor (W[2] shr 10)) + W[13] +
         (((W[5] shr 7) or (W[5] shl 25)) xor
          ((W[5] shr 18) or (W[5] shl 14)) xor (W[5] shr 3)) + W[4];
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $391c0cb3 + W[4];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[5]:= (((W[3] shr 17) or (W[3] shl 15)) xor
          ((W[3] shr 19) or (W[3] shl 13)) xor (W[3] shr 10)) + W[14] +
         (((W[6] shr 7) or (W[6] shl 25)) xor
          ((W[6] shr 18) or (W[6] shl 14)) xor (W[6] shr 3)) + W[5];
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $4ed8aa4a + W[5];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[6]:= (((W[4] shr 17) or (W[4] shl 15)) xor
          ((W[4] shr 19) or (W[4] shl 13)) xor (W[4] shr 10)) + W[15] +
         (((W[7] shr 7) or (W[7] shl 25)) xor
          ((W[7] shr 18) or (W[7] shl 14)) xor (W[7] shr 3)) + W[6];
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $5b9cca4f + W[6];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[7]:= (((W[5] shr 17) or (W[5] shl 15)) xor
          ((W[5] shr 19) or (W[5] shl 13)) xor (W[5] shr 10)) + W[0] +
         (((W[8] shr 7) or (W[8] shl 25)) xor
          ((W[8] shr 18) or (W[8] shl 14)) xor (W[8] shr 3)) + W[7];
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $682e6ff3 + W[7];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  W[8]:= (((W[6] shr 17) or (W[6] shl 15)) xor
          ((W[6] shr 19) or (W[6] shl 13)) xor (W[6] shr 10)) + W[1] +
         (((W[9] shr 7) or (W[9] shl 25)) xor
          ((W[9] shr 18) or (W[9] shl 14)) xor (W[9] shr 3)) + W[8];
  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $748f82ee + W[8];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  W[9]:= (((W[7] shr 17) or (W[7] shl 15)) xor
          ((W[7] shr 19) or (W[7] shl 13)) xor (W[7] shr 10)) + W[2] +
         (((W[10] shr 7) or (W[10] shl 25)) xor
          ((W[10] shr 18) or (W[10] shl 14)) xor (W[10] shr 3)) + W[9];
  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $78a5636f + W[9];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  W[10]:= (((W[8] shr 17) or (W[8] shl 15)) xor
           ((W[8] shr 19) or (W[8] shl 13)) xor (W[8] shr 10)) + W[3] +
          (((W[11] shr 7) or (W[11] shl 25)) xor
           ((W[11] shr 18) or (W[11] shl 14)) xor (W[11] shr 3)) + W[10];
  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $84c87814 + W[10];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  W[11]:= (((W[9] shr 17) or (W[9] shl 15)) xor
           ((W[9] shr 19) or (W[9] shl 13)) xor (W[9] shr 10)) + W[4] +
          (((W[12] shr 7) or (W[12] shl 25)) xor
           ((W[12] shr 18) or (W[12] shl 14)) xor (W[12] shr 3)) + W[11];
  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $8cc70208 + W[11];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  W[12]:= (((W[10] shr 17) or (W[10] shl 15)) xor
           ((W[10] shr 19) or (W[10] shl 13)) xor (W[10] shr 10)) + W[5] +
          (((W[13] shr 7) or (W[13] shl 25)) xor
           ((W[13] shr 18) or (W[13] shl 14)) xor (W[13] shr 3)) + W[12];
  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $90befffa + W[12];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  W[13]:= (((W[11] shr 17) or (W[11] shl 15)) xor
           ((W[11] shr 19) or (W[11] shl 13)) xor (W[11] shr 10)) + W[6] +
          (((W[14] shr 7) or (W[14] shl 25)) xor
           ((W[14] shr 18) or (W[14] shl 14)) xor (W[14] shr 3)) + W[13];
  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $a4506ceb + W[13];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  W[14]:= (((W[12] shr 17) or (W[12] shl 15)) xor
           ((W[12] shr 19) or (W[12] shl 13)) xor (W[12] shr 10)) + W[7] +
          (((W[15] shr 7) or (W[15] shl 25)) xor
           ((W[15] shr 18) or (W[15] shl 14)) xor (W[15] shr 3)) + W[14];
  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $bef9a3f7 + W[14];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  W[15]:= (((W[13] shr 17) or (W[13] shl 15)) xor
           ((W[13] shr 19) or (W[13] shl 13)) xor (W[13] shr 10)) + W[8] +
          (((W[0] shr 7) or (W[0] shl 25)) xor
           ((W[0] shr 18) or (W[0] shl 14)) xor (W[0] shr 3)) + W[15];
  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $c67178f2 + W[15];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  FData.Digest[0]:= FData.Digest[0] + a;
  FData.Digest[1]:= FData.Digest[1] + b;
  FData.Digest[2]:= FData.Digest[2] + c;
  FData.Digest[3]:= FData.Digest[3] + d;
  FData.Digest[4]:= FData.Digest[4] + e;
  FData.Digest[5]:= FData.Digest[5] + f;
  FData.Digest[6]:= FData.Digest[6] + g;
  FData.Digest[7]:= FData.Digest[7] + h;

//  FillChar(W, SizeOf(W), 0);
  FillChar(FData.Block, SizeOf(FData.Block), 0);
end;

class procedure TSHA256Alg.Init(Inst: PSHA256Alg);
begin
  Inst.FData.Digest[0]:= $6a09e667;
  Inst.FData.Digest[1]:= $bb67ae85;
  Inst.FData.Digest[2]:= $3c6ef372;
  Inst.FData.Digest[3]:= $a54ff53a;
  Inst.FData.Digest[4]:= $510e527f;
  Inst.FData.Digest[5]:= $9b05688c;
  Inst.FData.Digest[6]:= $1f83d9ab;
  Inst.FData.Digest[7]:= $5be0cd19;

  FillChar(Inst.FData.Block, SizeOf(Inst.FData.Block), 0);
  Inst.FData.Count:= 0;
end;

class procedure TSHA256Alg.Update(Inst: PSHA256Alg; Data: PByte; DataSize: LongWord);
var
  Cnt, Ofs: LongWord;

begin
  while DataSize > 0 do begin
    Ofs:= LongWord(Inst.FData.Count) and $3F;
    Cnt:= $40 - Ofs;
    if Cnt > DataSize then Cnt:= DataSize;
    Move(Data^, PByte(@Inst.FData.Block)[Ofs], Cnt);
    if (Cnt + Ofs = $40) then Inst.Compress;
    Inc(Inst.FData.Count, Cnt);
    Dec(DataSize, Cnt);
    Inc(Data, Cnt);
  end;
end;

class procedure TSHA256Alg.Done(Inst: PSHA256Alg; PDigest: PSHA256Digest);
var
  Ofs: LongWord;

begin
  Ofs:= LongWord(Inst.FData.Count) and $3F;
  Inst.FData.Block[Ofs]:= $80;
  if Ofs >= 56 then
    Inst.Compress;

  Inst.FData.Count:= Inst.FData.Count shl 3;
  PLongWord(@Inst.FData.Block[56])^:= Swap32(LongWord(Inst.FData.Count shr 32));
  PLongWord(@Inst.FData.Block[60])^:= Swap32(LongWord(Inst.FData.Count));
  Inst.Compress;

  Inst.FData.Digest[0]:= Swap32(Inst.FData.Digest[0]);
  Inst.FData.Digest[1]:= Swap32(Inst.FData.Digest[1]);
  Inst.FData.Digest[2]:= Swap32(Inst.FData.Digest[2]);
  Inst.FData.Digest[3]:= Swap32(Inst.FData.Digest[3]);
  Inst.FData.Digest[4]:= Swap32(Inst.FData.Digest[4]);
  Inst.FData.Digest[5]:= Swap32(Inst.FData.Digest[5]);
  Inst.FData.Digest[6]:= Swap32(Inst.FData.Digest[6]);
  Inst.FData.Digest[7]:= Swap32(Inst.FData.Digest[7]);

  Move(Inst.FData.Digest, PDigest^, SizeOf(TSHA256Digest));

  Init(Inst);
end;

class function TSHA256Alg.GetDigestSize(Inst: PSHA256Alg): LongInt;
begin
  Result:= SizeOf(TSHA256Digest);
end;

class function TSHA256Alg.GetBlockSize(Inst: PSHA256Alg): LongInt;
begin
  Result:= 64;
end;

class function TSHA256Alg.Duplicate(Inst: PSHA256Alg; var DupInst: PSHA256Alg): TF_RESULT;
begin
  Result:= GetSHA256Algorithm(DupInst);
  if Result = TF_S_OK then
    DupInst.FData:= Inst.FData;
end;

{ TSHA224Alg }

class procedure TSHA224Alg.Init(Inst: PSHA224Alg);
begin
  Inst.FData.Digest[0]:= $c1059ed8;
  Inst.FData.Digest[1]:= $367cd507;
  Inst.FData.Digest[2]:= $3070dd17;
  Inst.FData.Digest[3]:= $f70e5939;
  Inst.FData.Digest[4]:= $ffc00b31;
  Inst.FData.Digest[5]:= $68581511;
  Inst.FData.Digest[6]:= $64f98fa7;
  Inst.FData.Digest[7]:= $befa4fa4;

  FillChar(Inst.FData.Block, SizeOf(Inst.FData.Block), 0);
  Inst.FData.Count:= 0;
end;

class procedure TSHA224Alg.Done(Inst: PSHA224Alg; PDigest: PSHA224Digest);
var
  Ofs: LongWord;

begin
  Ofs:= LongWord(Inst.FData.Count) and $3F;
  Inst.FData.Block[Ofs]:= $80;
  if Ofs >= 56 then
    PSHA256Alg(Inst).Compress;

  Inst.FData.Count:= Inst.FData.Count shl 3;
  PLongWord(@Inst.FData.Block[56])^:= Swap32(LongWord(Inst.FData.Count shr 32));
  PLongWord(@Inst.FData.Block[60])^:= Swap32(LongWord(Inst.FData.Count));
  PSHA256Alg(Inst).Compress;

  Inst.FData.Digest[0]:= Swap32(Inst.FData.Digest[0]);
  Inst.FData.Digest[1]:= Swap32(Inst.FData.Digest[1]);
  Inst.FData.Digest[2]:= Swap32(Inst.FData.Digest[2]);
  Inst.FData.Digest[3]:= Swap32(Inst.FData.Digest[3]);
  Inst.FData.Digest[4]:= Swap32(Inst.FData.Digest[4]);
  Inst.FData.Digest[5]:= Swap32(Inst.FData.Digest[5]);
  Inst.FData.Digest[6]:= Swap32(Inst.FData.Digest[6]);

  Move(Inst.FData.Digest, PDigest^, SizeOf(TSHA224Digest));

  Init(Inst);
end;

class function TSHA224Alg.GetDigestSize(Inst: PSHA256Alg): LongInt;
begin
  Result:= SizeOf(TSHA224Digest);
end;

end.
