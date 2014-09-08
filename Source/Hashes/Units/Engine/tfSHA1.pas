{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfSHA1;

{$I TFL.inc}

interface

uses tfTypes;

type
  PSHA1Alg = ^TSHA1Alg;
  TSHA1Alg = record
  private type
    TData = record
      Digest: TSHA1Digest;
      Block: array[0..63] of Byte;   // 512-bit message block
      Count: UInt64;                 // number of bytes processed
    end;
  private
    FVTable: Pointer;
    FRefCount: Integer;
    FData: TData;

    procedure Compress;
  public
    class function Release(Inst: PSHA1Alg): Integer; stdcall; static;
    class procedure Init(Inst: PSHA1Alg);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Update(Inst: PSHA1Alg; Data: PByte; DataSize: LongWord);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure Done(Inst: PSHA1Alg; PDigest: PSHA1Digest);
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
//    class procedure Purge(Inst: PSHA1Alg);  -- redirected to Init
//         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetDigestSize(Inst: PSHA1Alg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetBlockSize(Inst: PSHA1Alg): LongInt;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function Duplicate(Inst: PSHA1Alg; var DupInst: PSHA1Alg): TF_RESULT;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetSHA1Algorithm(var Inst: PSHA1Alg): TF_RESULT;

implementation

uses tfRecords;

const
  SHA1VTable: array[0..9] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfRecord.Addref,
    @TSHA1Alg.Release,

    @TSHA1Alg.Init,
    @TSHA1Alg.Update,
    @TSHA1Alg.Done,
    @TSHA1Alg.Init,
    @TSHA1Alg.GetDigestSize,
    @TSHA1Alg.GetBlockSize,
    @TSHA1Alg.Duplicate
  );

function GetSHA1Algorithm(var Inst: PSHA1Alg): TF_RESULT;
var
  P: PSHA1Alg;

begin
  try
    New(P);
    P^.FVTable:= @SHA1VTable;
    P^.FRefCount:= 1;
    TSHA1Alg.Init(P);
    if Inst <> nil then TSHA1Alg.Release(Inst);
    Inst:= P;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;


{ TSHA1Alg }

function Swap32(Value: LongWord): LongWord;
begin
  Result:= ((Value and $FF) shl 24) or ((Value and $FF00) shl 8) or
           ((Value and $FF0000) shr 8) or ((Value and $FF000000) shr 24);
end;

procedure TSHA1Alg.Compress;
var
  A, B, C, D, E: LongWord;
  W: array[0..79] of LongWord;
  I: LongWord;

begin
//  Index:= 0;
//  dcpFillChar(W, SizeOf(W), 0);

  Move(FData.Block, W, SizeOf(FData.Block));
//  Move(HashBuffer,W,Sizeof(HashBuffer));

  for I:= 0 to 15 do
    W[I]:= Swap32(W[I]);
  for I:= 16 to 79 do
    W[I]:= ((W[I-3] xor W[I-8] xor W[I-14] xor W[I-16]) shl 1) or
           ((W[I-3] xor W[I-8] xor W[I-14] xor W[I-16]) shr 31);

  A:= FData.Digest[0];
  B:= FData.Digest[1];
  C:= FData.Digest[2];
  D:= FData.Digest[3];
  E:= FData.Digest[4];

  Inc(E,((A shl 5) or (A shr 27)) + (D xor (B and (C xor D))) + $5A827999 + W[ 0]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (C xor (A and (B xor C))) + $5A827999 + W[ 1]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (B xor (E and (A xor B))) + $5A827999 + W[ 2]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (A xor (D and (E xor A))) + $5A827999 + W[ 3]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (E xor (C and (D xor E))) + $5A827999 + W[ 4]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (D xor (B and (C xor D))) + $5A827999 + W[ 5]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (C xor (A and (B xor C))) + $5A827999 + W[ 6]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (B xor (E and (A xor B))) + $5A827999 + W[ 7]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (A xor (D and (E xor A))) + $5A827999 + W[ 8]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (E xor (C and (D xor E))) + $5A827999 + W[ 9]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (D xor (B and (C xor D))) + $5A827999 + W[10]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (C xor (A and (B xor C))) + $5A827999 + W[11]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (B xor (E and (A xor B))) + $5A827999 + W[12]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (A xor (D and (E xor A))) + $5A827999 + W[13]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (E xor (C and (D xor E))) + $5A827999 + W[14]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (D xor (B and (C xor D))) + $5A827999 + W[15]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (C xor (A and (B xor C))) + $5A827999 + W[16]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (B xor (E and (A xor B))) + $5A827999 + W[17]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (A xor (D and (E xor A))) + $5A827999 + W[18]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (E xor (C and (D xor E))) + $5A827999 + W[19]);
  C:= (C shl 30) or (C shr 2);

  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $6ED9EBA1 + W[20]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $6ED9EBA1 + W[21]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $6ED9EBA1 + W[22]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $6ED9EBA1 + W[23]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $6ED9EBA1 + W[24]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $6ED9EBA1 + W[25]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $6ED9EBA1 + W[26]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $6ED9EBA1 + W[27]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $6ED9EBA1 + W[28]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $6ED9EBA1 + W[29]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $6ED9EBA1 + W[30]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $6ED9EBA1 + W[31]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $6ED9EBA1 + W[32]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $6ED9EBA1 + W[33]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $6ED9EBA1 + W[34]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $6ED9EBA1 + W[35]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $6ED9EBA1 + W[36]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $6ED9EBA1 + W[37]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $6ED9EBA1 + W[38]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $6ED9EBA1 + W[39]);
  C:= (C shl 30) or (C shr 2);

  Inc(E,((A shl 5) or (A shr 27)) + ((B and C) or (D and (B or C))) + $8F1BBCDC + W[40]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + ((A and B) or (C and (A or B))) + $8F1BBCDC + W[41]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + ((E and A) or (B and (E or A))) + $8F1BBCDC + W[42]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + ((D and E) or (A and (D or E))) + $8F1BBCDC + W[43]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + ((C and D) or (E and (C or D))) + $8F1BBCDC + W[44]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + ((B and C) or (D and (B or C))) + $8F1BBCDC + W[45]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + ((A and B) or (C and (A or B))) + $8F1BBCDC + W[46]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + ((E and A) or (B and (E or A))) + $8F1BBCDC + W[47]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + ((D and E) or (A and (D or E))) + $8F1BBCDC + W[48]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + ((C and D) or (E and (C or D))) + $8F1BBCDC + W[49]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + ((B and C) or (D and (B or C))) + $8F1BBCDC + W[50]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + ((A and B) or (C and (A or B))) + $8F1BBCDC + W[51]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + ((E and A) or (B and (E or A))) + $8F1BBCDC + W[52]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + ((D and E) or (A and (D or E))) + $8F1BBCDC + W[53]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + ((C and D) or (E and (C or D))) + $8F1BBCDC + W[54]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + ((B and C) or (D and (B or C))) + $8F1BBCDC + W[55]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + ((A and B) or (C and (A or B))) + $8F1BBCDC + W[56]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + ((E and A) or (B and (E or A))) + $8F1BBCDC + W[57]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + ((D and E) or (A and (D or E))) + $8F1BBCDC + W[58]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + ((C and D) or (E and (C or D))) + $8F1BBCDC + W[59]);
  C:= (C shl 30) or (C shr 2);

  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $CA62C1D6 + W[60]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $CA62C1D6 + W[61]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $CA62C1D6 + W[62]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $CA62C1D6 + W[63]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $CA62C1D6 + W[64]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $CA62C1D6 + W[65]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $CA62C1D6 + W[66]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $CA62C1D6 + W[67]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $CA62C1D6 + W[68]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $CA62C1D6 + W[69]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $CA62C1D6 + W[70]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $CA62C1D6 + W[71]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $CA62C1D6 + W[72]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $CA62C1D6 + W[73]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $CA62C1D6 + W[74]);
  C:= (C shl 30) or (C shr 2);
  Inc(E,((A shl 5) or (A shr 27)) + (B xor C xor D) + $CA62C1D6 + W[75]);
  B:= (B shl 30) or (B shr 2);
  Inc(D,((E shl 5) or (E shr 27)) + (A xor B xor C) + $CA62C1D6 + W[76]);
  A:= (A shl 30) or (A shr 2);
  Inc(C,((D shl 5) or (D shr 27)) + (E xor A xor B) + $CA62C1D6 + W[77]);
  E:= (E shl 30) or (E shr 2);
  Inc(B,((C shl 5) or (C shr 27)) + (D xor E xor A) + $CA62C1D6 + W[78]);
  D:= (D shl 30) or (D shr 2);
  Inc(A,((B shl 5) or (B shr 27)) + (C xor D xor E) + $CA62C1D6 + W[79]);
  C:= (C shl 30) or (C shr 2);

  FData.Digest[0]:= FData.Digest[0] + A;
  FData.Digest[1]:= FData.Digest[1] + B;
  FData.Digest[2]:= FData.Digest[2] + C;
  FData.Digest[3]:= FData.Digest[3] + D;
  FData.Digest[4]:= FData.Digest[4] + E;
  FillChar(W, SizeOf(W), 0);
  FillChar(FData.Block, SizeOf(FData.Block), 0);
end;

class function TSHA1Alg.Release(Inst: PSHA1Alg): Integer;
begin
//  Init(Inst);
//  Result:= TtfRecord.Release(Inst);

  if Inst.FRefCount > 0 then begin
    Result:= tfDecrement(Inst.FRefCount);
    if Result = 0 then begin
      Init(Inst);
      FreeMem(Inst);
    end;
  end
  else
    Result:= Inst.FRefCount;

end;

class procedure TSHA1Alg.Init(Inst: PSHA1Alg);
begin
  Inst.FData.Digest[0]:= $67452301;
  Inst.FData.Digest[1]:= $EFCDAB89;
  Inst.FData.Digest[2]:= $98BADCFE;
  Inst.FData.Digest[3]:= $10325476;
  Inst.FData.Digest[4]:= $C3D2E1F0;

  FillChar(Inst.FData.Block, SizeOf(Inst.FData.Block), 0);
  Inst.FData.Count:= 0;
end;

class procedure TSHA1Alg.Update(Inst: PSHA1Alg; Data: PByte;
                                DataSize: LongWord);
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

class procedure TSHA1Alg.Done(Inst: PSHA1Alg; PDigest: PSHA1Digest);
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

  Move(Inst.FData.Digest, PDigest^, SizeOf(TSHA1Digest));

  Init(Inst);
end;

class function TSHA1Alg.Duplicate(Inst: PSHA1Alg;
                                  var DupInst: PSHA1Alg): TF_RESULT;
begin
  Result:= GetSHA1Algorithm(DupInst);
  if Result = TF_S_OK then
    DupInst.FData:= Inst.FData;
end;

class function TSHA1Alg.GetBlockSize(Inst: PSHA1Alg): LongInt;
begin
  Result:= 64;
end;

class function TSHA1Alg.GetDigestSize(Inst: PSHA1Alg): LongInt;
begin
  Result:= SizeOf(TSHA1Digest);
end;

end.
