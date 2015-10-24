{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
{ *********************************************************** }

unit tfUtils;

{$I TFL.inc}

interface

//uses tfLimbs;

const CRC32Table: array[0..255] of LongWord = (
  $00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535,
  $9e6495a3, $0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd,
  $e7b82d07, $90bf1d91, $1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d,
  $6ddde4eb, $f4d4b551, $83d385c7, $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec,
  $14015c4f, $63066cd9, $fa0f3d63, $8d080df5, $3b6e20c8, $4c69105e, $d56041e4,
  $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b, $35b5a8fa, $42b2986c,
  $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59, $26d930ac,
  $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
  $2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab,
  $b6662d3d, $76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f,
  $9fbfe4a5, $e8b8d433, $7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb,
  $086d3d2d, $91646c97, $e6635c01, $6b6b51f4, $1c6c6162, $856530d8, $f262004e,
  $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457, $65b0d9c6, $12b7e950, $8bbeb8ea,
  $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65, $4db26158, $3ab551ce,
  $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb, $4369e96a,
  $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
  $5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409,
  $ce61e49f, $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81,
  $b7bd5c3b, $c0ba6cad, $edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739,
  $9dd277af, $04db2615, $73dc1683, $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8,
  $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1, $f00f9344, $8708a3d2, $1e01f268,
  $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7, $fed41b76, $89d32be0,
  $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5, $d6d6a3e8,
  $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
  $d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef,
  $4669be79, $cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703,
  $220216b9, $5505262f, $c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7,
  $b5d0cf31, $2cd99e8b, $5bdeae1d, $9b64c2b0, $ec63f226, $756aa39c, $026d930a,
  $9c0906a9, $eb0e363f, $72076785, $05005713, $95bf4a82, $e2b87a14, $7bb12bae,
  $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21, $86d3d2d4, $f1d4e242,
  $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777, $88085ae6,
  $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
  $a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d,
  $3e6e77db, $aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5,
  $47b2cf7f, $30b5ffe9, $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605,
  $cdd70693, $54de5729, $23d967bf, $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94,
  $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
  );

type
  TCRC32 = record
    class function Init: LongWord; inline; static;
    class function Update(const Data; DataSize: Cardinal; State: LongWord): LongWord; static;
    class function Done(State: LongWord): LongWord; inline; static;
    class function Hash(const Data; DataSize: Cardinal): LongWord; static;
  end;

type
  TJenkins1 = record
    class function Init: LongWord; inline; static;
    class function Update(const Data; DataSize: Cardinal; State: LongWord): LongWord; static;
    class function Done(State: LongWord): LongWord; inline; static;
    class function Hash(const Data; DataSize: Cardinal): LongWord; static;
  end;

type
  TBigEndian = record
    class function Incr(First, Last: Pointer): Boolean; overload; static;
    class function Incr(First: Pointer; Count: Cardinal): Boolean; overload; static;
    class function Incr(First, Last: Pointer; Value: Byte): Boolean; overload; static;
    class function Incr(First: Pointer; Count: Cardinal; Value: Byte): Boolean; overload; static;
    class function Decr(First, Last: Pointer): Boolean; overload; static;
    class function Decr(First: Pointer; Count: Cardinal): Boolean; overload; static;
    class function Decr(First, Last: Pointer; Value: Byte): Boolean; overload; static;
    class function Decr(First: Pointer; Count: Cardinal; Value: Byte): Boolean; overload; static;
    class function Add(A: Pointer; LA: Cardinal; B: Pointer; LB: Cardinal): Boolean; overload; static;
    class function Sub(A: Pointer; LA: Cardinal; B: Pointer; LB: Cardinal): Boolean; overload; static;

    class procedure ShiftRight(First, Last: Pointer); overload; static;
    class procedure ShiftRight(First: Pointer; Count: Cardinal); overload; static;
    class procedure ShiftRight(First, Last: Pointer; Shift: Cardinal); overload; static;
    class procedure ShiftRight(First: Pointer; Count, Shift: Cardinal); overload; static;

    class procedure Reverse(First, Last: Pointer); overload; static;
    class procedure Reverse(First: Pointer; Count: Cardinal); overload; static;
    class procedure ReverseCopy(First, Last, Output: Pointer); overload; static;
    class procedure ReverseCopy(First: Pointer; Count: Cardinal; Output: Pointer); overload; static;
  end;

type
  TMoveProc = procedure(const Source; var Dest; Count: LongWord);

procedure MoveMem(const Source; var Dest; Count: LongWord);
procedure MoveXor(const Source; var Dest; Count: LongWord);

{
type
  TLittleEndian = record
    class function Incr(A: Pointer; L: Cardinal): Boolean; overload; static;
    class function Incr(A: Pointer; L: Cardinal; Value: TLimb): Boolean; overload; static;
    class function Add(A: Pointer; LA: Cardinal; B: Pointer; LB: Cardinal): Boolean; overload; static;
  end;
}
{
procedure ReverseCopy(First, Last, Output: Pointer); overload;
procedure ReverseCopy(First: Pointer; Count: Cardinal; Output: Pointer); overload;
procedure ReverseBytes(First, Last: Pointer); overload;
procedure ReverseBytes(First: Pointer; Count: Cardinal); overload;
}
implementation

procedure MoveMem(const Source; var Dest; Count: LongWord);
var
  S, D: PByte;
  Cnt1, Cnt2: LongWord;

begin
  S:= @Source;
  D:= @Dest;
  Cnt1:= Count shr 2;
  Cnt2:= Count and 3;

  if NativeUInt(D) > NativeUInt(S) then begin
    if Cnt1 > 0 then begin
      Inc(PLongWord(S), Cnt1);
      Inc(PLongWord(D), Cnt1);
      repeat
        Dec(PLongWord(S));
        Dec(PLongWord(D));
        Dec(Cnt1);
        PLongWord(D)^:= PLongWord(S)^;
      until Cnt1 = 0;
    end;
    while Cnt2 > 0 do begin
      Dec(S);
      Dec(D);
      Dec(Cnt2);
      D^:= S^;
    end;
  end
  else begin
    while Cnt1 > 0 do begin
      PLongWord(D)^:= PLongWord(S)^;
      Dec(Cnt1);
      Inc(PLongWord(S));
      Inc(PLongWord(D));
    end;
    while Cnt2 > 0 do begin
      D^:= S^;
      Dec(Cnt2);
      Inc(S);
      Inc(D);
    end;
  end;
end;

procedure MoveXor(const Source; var Dest; Count: LongWord);
var
  S, D: PByte;
  Cnt1, Cnt2: LongWord;

begin
  S:= @Source;
  D:= @Dest;
  Cnt1:= Count shr 2;
  Cnt2:= Count and 3;

  if NativeUInt(D) > NativeUInt(S) then begin
    if Cnt1 > 0 then begin
      Inc(PLongWord(S), Cnt1);
      Inc(PLongWord(D), Cnt1);
      repeat
        Dec(PLongWord(S));
        Dec(PLongWord(D));
        Dec(Cnt1);
        PLongWord(D)^:= PLongWord(D)^ xor PLongWord(S)^;
      until Cnt1 = 0;
    end;
    while Cnt2 > 0 do begin
      Dec(S);
      Dec(D);
      Dec(Cnt2);
      D^:= D^ xor S^;
    end;
  end
  else begin
    while Cnt1 > 0 do begin
      PLongWord(D)^:= PLongWord(D)^ xor PLongWord(S)^;
      Dec(Cnt1);
      Inc(PLongWord(S));
      Inc(PLongWord(D));
    end;
    while Cnt2 > 0 do begin
      D^:= D^ xor S^;
      Dec(Cnt2);
      Inc(S);
      Inc(D);
    end;
  end;
end;

{
procedure ReverseCopy(First, Last, Output: Pointer);
begin
  while First <> Last do begin
    Dec(PByte(Last));
    PByte(Output)^:= PByte(Last)^;
    Inc(PByte(Output));
  end;
end;

procedure ReverseCopy(First: Pointer; Count: Cardinal; Output: Pointer);
begin
  ReverseCopy(First, PByte(First) + Count, Output);
end;

procedure ReverseBytes(First, Last: Pointer);
var
  Tmp: Byte;

begin
  while First <> Last do begin
    Dec(PByte(Last));
    if First = Last then Break;
    Tmp:= PByte(Last)^;
    PByte(Last)^:= PByte(First)^;
    PByte(First)^:= Tmp;
    Inc(PByte(First));
  end;
end;

procedure ReverseBytes(First: Pointer; Count: Cardinal);
begin
  ReverseBytes(First, PByte(First) + Count);
end;
}
{ TCRC32 }

class function TCRC32.Init: LongWord;
begin
  Result:= $FFFFFFFF;
end;

class function TCRC32.Update(const Data; DataSize: Cardinal; State: LongWord): LongWord;
var
  P: PByte;

begin
  P:= @Data;
  while DataSize > 0 do begin
    State:= Crc32Table[Byte(State xor P^)] xor LongWord(State shr 8);
    Dec(DataSize);
    Inc(P);
  end;
  Result:= State;
end;

class function TCRC32.Done(State: LongWord): LongWord;
begin
  Result:= not State;
end;

class function TCRC32.Hash(const Data; DataSize: Cardinal): LongWord;
var
  P: PByte;

begin
  P:= @Data;
  Result:= $FFFFFFFF;
  while DataSize > 0 do begin
    Result:= Crc32Table[Byte(Result xor P^)] xor LongWord(Result shr 8);
    Dec(DataSize);
    Inc(P);
  end;
  Result:= not Result;
end;

{ TJenkinsOne }

class function TJenkins1.Init: LongWord;
begin
  Result:= 0;
end;

class function TJenkins1.Update(const Data; DataSize: Cardinal;
                                  State: LongWord): LongWord;
var
  PData: PByte;

begin
  PData:= @Data;
  while DataSize > 0 do begin
    State:= State + PData^;
    State:= State + (State shl 10);
    State:= State xor (State shr 6);
    Inc(PData);
    Dec(DataSize);
  end;
  Result:= State;
end;

class function TJenkins1.Done(State: LongWord): LongWord;
begin
  State:= State + (State shl 3);
  State:= State xor (State shr 11);
  State:= State + (State shl 15);
  Result:= State;
end;

class function TJenkins1.Hash(const Data; DataSize: Cardinal): LongWord;
var
  PData: PByte;

begin
  Result:= 0;
  PData:= @Data;
  while DataSize > 0 do begin
    Result:= Result + PData^;
    Result:= Result + (Result shl 10);
    Result:= Result xor (Result shr 6);
    Inc(PData);
    Dec(DataSize);
  end;
  Result:= Result + (Result shl 3);
  Result:= Result xor (Result shr 11);
  Result:= Result + (Result shl 15);
end;

(*
function JenkinsOneHash(const Data; Len: Cardinal): Integer;
var
  PData: PByte;

begin
  Result:= 0;
  PData:= @Data;
  while Len > 0 do begin
    Result:= Result + PData^;
    Result:= Result + (Result shl 10);
    Result:= Result xor (Result shr 6);
    Inc(PData);
    Dec(Len);
  end;
  Result:= Result + (Result shl 3);
  Result:= Result xor (Result shr 11);
  Result:= Result + (Result shl 15);
end;
*)

{ TBigEndian }

class function TBigEndian.Incr(First, Last: Pointer): Boolean;
begin
  while First <> Last do begin
    Dec(PByte(Last));
    Inc(PByte(Last)^);
    if PByte(Last)^ <> 0 then begin
      Result:= False;
      Exit;
    end;
  end;
  Result:= True;
end;

class function TBigEndian.Incr(First: Pointer; Count: Cardinal): Boolean;
begin
  Result:= Incr(First, PByte(First) + Count);
end;

class function TBigEndian.Incr(First, Last: Pointer; Value: Byte): Boolean;
var
  Tmp: Byte;

begin
  while First <> Last do begin
    Dec(PByte(Last));
    Tmp:= PByte(Last)^;
    PByte(Last)^:= Tmp + Value;
    if PByte(Last)^ >= Tmp then begin
      Result:= False;
      Exit;
    end;
  end;
  Result:= True;
end;

class function TBigEndian.Incr(First: Pointer; Count: Cardinal; Value: Byte): Boolean;
begin
  Result:= Incr(First, PByte(First) + Count, Value);
end;

class function TBigEndian.Decr(First, Last: Pointer): Boolean;
begin
  while First <> Last do begin
    Dec(PByte(Last));
    Dec(PByte(Last)^);
    if PByte(Last)^ <> $FF then begin
      Result:= False;
      Exit;
    end;
  end;
  Result:= True;
end;

class function TBigEndian.Decr(First: Pointer; Count: Cardinal): Boolean;
begin
  Result:= Decr(First, PByte(First) + Count);
end;

class function TBigEndian.Decr(First, Last: Pointer; Value: Byte): Boolean;
var
  Tmp: Byte;

begin
  while First <> Last do begin
    Dec(PByte(Last));
    Tmp:= PByte(Last)^;
    PByte(Last)^:= Tmp - Value;
    if PByte(Last)^ <= Tmp then begin
      Result:= False;
      Exit;
    end;
  end;
  Result:= True;
end;

class function TBigEndian.Decr(First: Pointer; Count: Cardinal; Value: Byte): Boolean;
begin
  Result:= Decr(First, PByte(First) + Count, Value);
end;

class function TBigEndian.Add(A: Pointer; LA: Cardinal; B: Pointer; LB: Cardinal): Boolean;
var
  CarryOut, CarryIn: Boolean;
  Tmp: Byte;

begin
  if LB > LA then begin
    Inc(PByte(B), LB - LA);
    LB:= LA;
  end;
  Inc(PByte(A), LA);
  Inc(PByte(B), LB);
  Dec(LA, LB);
  CarryIn:= False;
  while LB > 0 do begin
    Dec(PByte(B));
    Dec(PByte(A));
    Tmp:= PByte(A)^ + PByte(B)^;
    CarryOut:= Tmp < PByte(A)^;
    if CarryIn then begin
      Inc(Tmp);
      CarryOut:= CarryOut or (Tmp = 0);
    end;
    CarryIn:= CarryOut;
    PByte(A)^:= Tmp;
    Dec(LB);
  end;
  while (LA > 0) and CarryIn do begin
    Dec(PByte(A));
    Tmp:= PByte(A)^ + 1;
    CarryIn:= Tmp = 0;
    PByte(A)^:= Tmp;
    Dec(LA);
  end;
  Result:= CarryIn;
end;

class function TBigEndian.Sub(A: Pointer; LA: Cardinal; B: Pointer; LB: Cardinal): Boolean;
var
  BorrowOut, BorrowIn: Boolean;
  Tmp: Byte;

begin
  if LB > LA then begin
    Inc(PByte(B), LB - LA);
    LB:= LA;
  end;
  Inc(PByte(A), LA);
  Inc(PByte(B), LB);
  Dec(LA, LB);
  BorrowIn:= False;
  while LB > 0 do begin
    Dec(PByte(B));
    Dec(PByte(A));
    Tmp:= PByte(A)^ - PByte(B)^;
    BorrowOut:= Tmp > PByte(A)^;
    if BorrowIn then begin
      BorrowOut:= BorrowOut or (Tmp = 0);
      Dec(Tmp);
    end;
    BorrowIn:= BorrowOut;
    PByte(A)^:= Tmp;
    Dec(LB);
  end;
  while (LA > 0) and BorrowIn do begin
    Dec(PByte(A));
    Tmp:= PByte(A)^;
    BorrowIn:= Tmp = 0;
    PByte(A)^:= Tmp - 1;
    Dec(LA);
  end;
  Result:= BorrowIn;
end;

class procedure TBigEndian.Reverse(First, Last: Pointer);
var
  Tmp: Byte;

begin
  while First <> Last do begin
    Dec(PByte(Last));
    if First = Last then Break;
    Tmp:= PByte(Last)^;
    PByte(Last)^:= PByte(First)^;
    PByte(First)^:= Tmp;
    Inc(PByte(First));
  end;
end;

class procedure TBigEndian.Reverse(First: Pointer; Count: Cardinal);
begin
  Reverse(First, PByte(First) + Count);
end;

class procedure TBigEndian.ReverseCopy(First, Last, Output: Pointer);
begin
  while First <> Last do begin
    Dec(PByte(Last));
    PByte(Output)^:= PByte(Last)^;
    Inc(PByte(Output));
  end;
end;

class procedure TBigEndian.ReverseCopy(First: Pointer; Count: Cardinal; Output: Pointer);
begin
  ReverseCopy(First, PByte(First) + Count, Output);
end;

class procedure TBigEndian.ShiftRight(First, Last: Pointer);
var
  Carry, Tmp: Byte;

begin
  if First <> Last then begin
    Carry:= PByte(First)^;
    PByte(First)^:= Carry shr 1;
    Carry:= Carry shl 7;
    Dec(PByte(Last));
    while First <> Last do begin
      Inc(PByte(First));
      Tmp:= PByte(First)^;
      PByte(First)^:= (Tmp shr 1) or Carry;
      Carry:= Tmp shl 7;
    end;
  end;
end;

class procedure TBigEndian.ShiftRight(First: Pointer; Count: Cardinal);
begin
  ShiftRight(First, PByte(First) + Count);
end;

class procedure TBigEndian.ShiftRight(First, Last: Pointer; Shift: Cardinal);
begin
// todo:
  while Shift > 0 do begin
    ShiftRight(First, Last);
    Dec(Shift);
  end;
end;

class procedure TBigEndian.ShiftRight(First: Pointer; Count, Shift: Cardinal);
begin
// todo:
  while Shift > 0 do begin
    ShiftRight(First, PByte(First) + Count);
    Dec(Shift);
  end;
end;

{ TLittleEndian

class function TLittleEndian.Incr(A: Pointer; L: Cardinal): Boolean;
var
  Tmp: TLimb;

begin
                          // !! Assert(Count > 0);
  Tmp:= PLimb(A)^ + 1;
  PLimb(A)^:= Tmp;
                          //  while we have carry from prev limb ..
  while (Tmp = 0) do begin
    Dec(L);
    Inc(PLimb(A));
    if L = 0 then begin
      Result:= True;
      Exit;
    end;
    Tmp:= PLimb(A)^ + 1;
    PLimb(A)^:= Tmp;
  end;
  Result:= False;
end;

class function TLittleEndian.Add(A: Pointer; LA: Cardinal;
                                 B: Pointer; LB: Cardinal): Boolean;
var
  CarryOut, CarryIn: Boolean;
  Tmp: TLimb;

begin
  if LB > LA then LB:= LA;
  Dec(LA, LB);
  CarryIn:= False;
  while LB > 0 do begin
    Tmp:= PLimb(A)^ + PLimb(B)^;
    CarryOut:= Tmp < PLimb(A)^;
    Inc(PLimb(B));
    if CarryIn then begin
      Inc(Tmp);
      CarryOut:= CarryOut or (Tmp = 0);
    end;
    CarryIn:= CarryOut;
    PLimb(A)^:= Tmp;
    Inc(PLimb(A));
    Dec(LB);
  end;
  while (LA > 0) and CarryIn do begin
    Tmp:= PLimb(A)^ + 1;
    CarryIn:= Tmp = 0;
    PLimb(A)^:= Tmp;
    Inc(PLimb(A));
    Dec(LA);
  end;
  Result:= CarryIn;
end;

class function TLittleEndian.Incr(A: Pointer; L: Cardinal; Value: TLimb): Boolean;
var
  Tmp: TLimb;

begin
  Tmp:= PLimb(A)^ + Value;
  PLimb(A)^:= Tmp;
  if Tmp < Value then repeat
    Dec(L);
    Inc(PLimb(A));
    if L = 0 then begin
      Result:= True;
      Exit;
    end;
    Tmp:= PLimb(A)^ + 1;
    PLimb(A)^:= Tmp;
  until Tmp <> 0;
  Result:= False;
end;
}

end.
