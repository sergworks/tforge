{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfSHA256;

{$I TFL.inc}

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
//    class procedure Purge(Inst: PCRC32Alg);  -- redirected to Init
//         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetDigestSize(Inst: PSHA256Alg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize(Inst: PSHA256Alg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Duplicate(Inst: PSHA256Alg; var DupInst: PSHA256Alg): TF_RESULT;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
end;

function GetSHA256Algorithm(var Inst: PSHA256Alg): TF_RESULT;

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
//    if Inst <> nil then TSHA256Alg.Release(Inst);
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
var
  a, b, c, d, e, f, g, h, t1, t2: LongWord;
  W: array[0..63] of LongWord;
  I: LongWord;

begin
  a:= FData.Digest[0]; b:= FData.Digest[1]; c:= FData.Digest[2]; d:= FData.Digest[3];
  e:= FData.Digest[4]; f:= FData.Digest[5]; g:= FData.Digest[6]; h:= FData.Digest[7];
  Move(FData.Block, W, SizeOf(FData.Block));

  for I:= 0 to 15 do
    W[I]:= Swap32(W[I]);

  for I:= 16 to 63 do
    W[I]:= (((W[I-2] shr 17) or (W[I-2] shl 15)) xor
            ((W[I-2] shr 19) or (W[I-2] shl 13)) xor (W[I-2] shr 10)) + W[I-7] +
           (((W[I-15] shr 7) or (W[I-15] shl 25)) xor
            ((W[I-15] shr 18) or (W[I-15] shl 14)) xor (W[I-15] shr 3)) + W[I-16];

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $428a2f98 + W[0];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $71374491 + W[1];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $b5c0fbcf + W[2];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $e9b5dba5 + W[3];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $3956c25b + W[4];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $59f111f1 + W[5];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $923f82a4 + W[6];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $ab1c5ed5 + W[7];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $d807aa98 + W[8];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $12835b01 + W[9];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $243185be + W[10];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $550c7dc3 + W[11];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $72be5d74 + W[12];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $80deb1fe + W[13];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $9bdc06a7 + W[14];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $c19bf174 + W[15];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $e49b69c1 + W[16];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $efbe4786 + W[17];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $0fc19dc6 + W[18];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $240ca1cc + W[19];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $2de92c6f + W[20];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $4a7484aa + W[21];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $5cb0a9dc + W[22];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $76f988da + W[23];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $983e5152 + W[24];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $a831c66d + W[25];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $b00327c8 + W[26];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $bf597fc7 + W[27];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $c6e00bf3 + W[28];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $d5a79147 + W[29];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $06ca6351 + W[30];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $14292967 + W[31];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $27b70a85 + W[32];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $2e1b2138 + W[33];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $4d2c6dfc + W[34];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $53380d13 + W[35];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $650a7354 + W[36];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $766a0abb + W[37];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $81c2c92e + W[38];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $92722c85 + W[39];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $a2bfe8a1 + W[40];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $a81a664b + W[41];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $c24b8b70 + W[42];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $c76c51a3 + W[43];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $d192e819 + W[44];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $d6990624 + W[45];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $f40e3585 + W[46];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $106aa070 + W[47];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $19a4c116 + W[48];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $1e376c08 + W[49];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $2748774c + W[50];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $34b0bcb5 + W[51];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $391c0cb3 + W[52];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $4ed8aa4a + W[53];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $5b9cca4f + W[54];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $682e6ff3 + W[55];
  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor
      ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d));
  a:= t1 + t2;
  e:= e + t1;

  t1:= h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor
      ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $748f82ee + W[56];
  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor
      ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c));
  h:= t1 + t2;
  d:= d + t1;

  t1:= g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor
      ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $78a5636f + W[57];
  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor
      ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b));
  g:= t1 + t2;
  c:= c + t1;

  t1:= f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor
      ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $84c87814 + W[58];
  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor
      ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a));
  f:= t1 + t2;
  b:= b + t1;

  t1:= e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor
      ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $8cc70208 + W[59];
  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor
      ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h));
  e:= t1 + t2;
  a:= a + t1;

  t1:= d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor
      ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $90befffa + W[60];
  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor
      ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g));
  d:= t1 + t2;
  h:= h + t1;

  t1:= c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor
      ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $a4506ceb + W[61];
  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor
      ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f));
  c:= t1 + t2;
  g:= g + t1;

  t1:= b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor
      ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $bef9a3f7 + W[62];
  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor
      ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e));
  b:= t1 + t2;
  f:= f + t1;

  t1:= a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor
      ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $c67178f2 + W[63];
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

  FillChar(W, SizeOf(W), 0);
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

end.
