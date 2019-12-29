{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # DES block cipher algorithm
  # NB: the code follows original hardware implementation:
  #   - block encryption and decryption functions are identical;
  #   - key expansion depends on block operation (encryption or decryption).
  #   This is a little cumbersome for software implementation, because
  #     CFB, OFB and CTR modes of operation use block encryption
  #     for decryption operation, and the key is expanded for encryption;
  #     that is why ExpandKey method has additional boolean parameter.
}

unit tfAlgDES;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  PDESAlgorithm = ^TDESAlgorithm;
  TDESAlgorithm = record
  private type
    PDESBlock = ^TDESBlock;
    TDESBlock = record
      case Byte of
        0: (Bytes: array[0..7] of Byte);
        1: (LWords: array[0..1] of UInt32);
    end;

  public type
    PExpandedKey = ^TExpandedKey;
    TExpandedKey = array[0..31] of UInt32;

  public
    FSubKeys:  TExpandedKey;

//    class procedure DoExpandKey(Key: PByte; var SubKeys: TExpandedKey; Encryption: Boolean); static;
//    class procedure DoEncryptBlock(var SubKeys: TExpandedKey; Data: PByte); static;
    function ExpandKey(Key: PByte; KeySize: Cardinal; Encryption: Boolean): TF_RESULT;
//    function EncryptBlock(Data: PByte): TF_RESULT;
  end;

  PDES3Algorithm = ^TDES3Algorithm;
  TDES3Algorithm = record
  public
    FSubKeys:  array[0..2] of TDESAlgorithm.TExpandedKey;

    function ExpandKey(Key: PByte; KeySize: Cardinal; Encryption: Boolean): TF_RESULT;
//    function EncryptBlock(Data: PByte): TF_RESULT;
  end;

procedure DesEncryptBlock(CPtr: PUint32; Data: PByte);

implementation

procedure DesExpandKey(Key: PByte; var SubKeys: TDESAlgorithm.TExpandedKey;
            Encryption: Boolean);
const
  PC1        : array [0..55] of Byte =
    (56, 48, 40, 32, 24, 16, 8, 0, 57, 49, 41, 33, 25, 17, 9, 1, 58, 50, 42, 34, 26,
     18, 10, 2, 59, 51, 43, 35, 62, 54, 46, 38, 30, 22, 14, 6, 61, 53, 45, 37, 29, 21,
     13, 5, 60, 52, 44, 36, 28, 20, 12, 4, 27, 19, 11, 3);
  PC2        : array [0..47] of Byte =
    (13, 16, 10, 23, 0, 4, 2, 27, 14, 5, 20, 9, 22, 18, 11, 3, 25, 7,
     15, 6, 26, 19, 12, 1, 40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47,
     43, 48, 38, 55, 33, 52, 45, 41, 49, 35, 28, 31);
  CTotRot    : array [0..15] of Byte = (1, 2, 4, 6, 8, 10, 12, 14, 15, 17, 19, 21, 23, 25, 27, 28);
  CBitMask   : array [0..7] of Byte = (128, 64, 32, 16, 8, 4, 2, 1);

var
  PC1M       : array [0..55] of Byte;
  PC1R       : array [0..55] of Byte;
  KS         : array [0..7] of Byte;
  I, J, L, M : Int32;

begin
  {convert PC1 to bits of key}
  for J := 0 to 55 do begin
    L := PC1[J];
    M := L mod 8;
    PC1M[J] := Ord((Key[L div 8] and CBitMask[M]) <> 0);
  end;

  {key chunk for each iteration}
  for I := 0 to 15 do begin
    {rotate PC1 the right amount}
    for J := 0 to 27 do begin
      L := J + CTotRot[I];
      if (L < 28) then begin
        PC1R[J] := PC1M[L];
        PC1R[J + 28] := PC1M[L + 28];
      end else begin
        PC1R[J] := PC1M[L - 28];
        PC1R[J + 28] := PC1M[L];
      end;
    end;

    {select bits individually}
    FillChar(KS, SizeOf(KS), 0);
    for J := 0 to 47 do
      if Boolean(PC1R[PC2[J]]) then begin
        L := J div 6;
        KS[L] := KS[L] or CBitMask[J mod 6] shr 2;
      end;

    {now convert to odd/even interleaved form for use in F}
    if Encryption then begin
      SubKeys[I * 2] := (Int32(KS[0]) shl 24) or (Int32(KS[2]) shl 16) or
        (Int32(KS[4]) shl 8) or (Int32(KS[6]));
      SubKeys[I * 2 + 1] := (Int32(KS[1]) shl 24) or (Int32(KS[3]) shl 16) or
        (Int32(KS[5]) shl 8) or (Int32(KS[7]));
    end
    else begin
      SubKeys[31 - (I * 2 + 1)] := (Int32(KS[0]) shl 24) or (Int32(KS[2]) shl 16) or
        (Int32(KS[4]) shl 8) or (Int32(KS[6]));
      SubKeys[31 - (I * 2)] := (Int32(KS[1]) shl 24) or (Int32(KS[3]) shl 16) or
        (Int32(KS[5]) shl 8) or (Int32(KS[7]));
    end;
  end;
end;

const
  SPBox: array[0..7,0..63] of UInt32 = ({$I DES_SPBoxes.inc});

procedure SplitBlock(Block: PByte; var L, R: UInt32);
{$IFDEF ASM86}
asm
        PUSH    EBX
        PUSH    EAX
        MOV     EAX,[EAX]
        MOV     BH,AL
        MOV     BL,AH
        ROL     EBX,16      // Block.Bytes[0] --> L.Bytes[3]
        SHR     EAX,16      // Block.Bytes[1] --> L.Bytes[2]
        MOV     BH,AL       // Block.Bytes[2] --> L.Bytes[1]
        MOV     BL,AH       // Block.Bytes[3] --> L.Bytes[0]
        MOV     [EDX],EBX
        POP     EAX
        MOV     EAX,[EAX+4]
        MOV     BH,AL
        MOV     BL,AH
        ROL     EBX,16      // Block.Bytes[4] --> R.Bytes[3]
        SHR     EAX,16      // Block.Bytes[5] --> R.Bytes[2]
        MOV     BH,AL       // Block.Bytes[6] --> R.Bytes[1]
        MOV     BL,AH       // Block.Bytes[7] --> R.Bytes[0]
        MOV     [ECX],EBX
        POP     EBX
end;
{$ELSE}
var
  P: PByte;

begin
  P:= PByte(@L) + 3;
  P^:= Block^; Inc(Block); Dec(P);
  P^:= Block^; Inc(Block); Dec(P);
  P^:= Block^; Inc(Block); Dec(P);
  P^:= Block^; Inc(Block);
  P:= PByte(@R) + 3;
  P^:= Block^; Inc(Block); Dec(P);
  P^:= Block^; Inc(Block); Dec(P);
  P^:= Block^; Inc(Block); Dec(P);
  P^:= Block^;
end;
{$ENDIF}

procedure JoinBlock(const L, R: UInt32; Block: PByte);
{$IFDEF ASM86}
asm
        PUSH    EBX
        MOV     BH,AL
        MOV     BL,AH
        ROL     EBX,16      // L.Bytes[0] --> Block.Bytes[7]
        SHR     EAX,16      // L.Bytes[1] --> Block.Bytes[6]
        MOV     BH,AL       // L.Bytes[2] --> Block.Bytes[5]
        MOV     BL,AH       // L.Bytes[3] --> Block.Bytes[4]
        MOV     [ECX+4],EBX
        MOV     BH,DL
        MOV     BL,DH
        ROL     EBX,16      // R.Bytes[0] --> Block.Bytes[3]
        SHR     EDX,16      // R.Bytes[1] --> Block.Bytes[2]
        MOV     BH,DL       // R.Bytes[2] --> Block.Bytes[1]
        MOV     BL,DH       // R.Bytes[3] --> Block.Bytes[0]
        MOV     [ECX],EBX
        POP     EBX
end;
{$ELSE}
var
  P: PByte;

begin
  P:= PByte(@R) + 3;
  Block^:= P^; Inc(Block); Dec(P);
  Block^:= P^; Inc(Block); Dec(P);
  Block^:= P^; Inc(Block); Dec(P);
  Block^:= P^; Inc(Block);
  P:= PByte(@L) + 3;
  Block^:= P^; Inc(Block); Dec(P);
  Block^:= P^; Inc(Block); Dec(P);
  Block^:= P^; Inc(Block); Dec(P);
  Block^:= P^;
end;
{$ENDIF}

procedure IPerm(var L, R : UInt32);
var
  Work : UInt32;
begin
  Work := ((L shr 4) xor R) and $0F0F0F0F;
  R := R xor Work;
  L := L xor Work shl 4;

  Work := ((L shr 16) xor R) and $0000FFFF;
  R := R xor Work;
  L := L xor Work shl 16;

  Work := ((R shr 2) xor L) and $33333333;
  L := L xor Work;
  R := R xor Work shl 2;

  Work := ((R shr 8) xor L) and $00FF00FF;
  L := L xor Work;
  R := R xor Work shl 8;

  R := (R shl 1) or (R shr 31);
  Work := (L xor R) and $AAAAAAAA;
  L := L xor Work;
  R := R xor Work;
  L := (L shl 1) or (L shr 31);
end;

procedure FPerm(var L, R : UInt32);
var
  Work : UInt32;
begin
  L := L;

  R := (R shl 31) or (R shr 1);
  Work := (L xor R) and $AAAAAAAA;
  L := L xor Work;
  R := R xor Work;
  L := (L shr 1) or (L shl 31);

  Work := ((L shr 8) xor R) and $00FF00FF;
  R := R xor Work;
  L := L xor Work shl 8;

  Work := ((L shr 2) xor R) and $33333333;
  R := R xor Work;
  L := L xor Work shl 2;

  Work := ((R shr 16) xor L) and $0000FFFF;
  L := L xor Work;
  R := R xor Work shl 16;

  Work := ((R shr 4) xor L) and $0F0F0F0F;
  L := L xor Work;
  R := R xor Work shl 4;
end;

procedure DesEncryptBlock(CPtr: PUint32; //var SubKeys: TDesAlgorithm.TExpandedKey;
                  Data: PByte);
var
  I, L, R, Work : UInt32;
//  CPtr          : PUInt32;

begin
  SplitBlock(Data, L, R);
  IPerm(L, R);

//  CPtr := @SubKeys;
  for I := 0 to 7 do begin
    Work := (((R shr 4) or (R shl 28)) xor CPtr^);
    Inc(CPtr);
    L := L xor SPBox[6, Work and $3F];
    L := L xor SPBox[4, Work shr 8 and $3F];
    L := L xor SPBox[2, Work shr 16 and $3F];
    L := L xor SPBox[0, Work shr 24 and $3F];

    Work := (R xor CPtr^);
    Inc(CPtr);
    L := L xor SPBox[7, Work and $3F];
    L := L xor SPBox[5, Work shr 8 and $3F];
    L := L xor SPBox[3, Work shr 16 and $3F];
    L := L xor SPBox[1, Work shr 24 and $3F];

    Work := (((L shr 4) or (L shl 28)) xor CPtr^);
    Inc(CPtr);
    R := R xor SPBox[6, Work and $3F];
    R := R xor SPBox[4, Work shr 8 and $3F];
    R := R xor SPBox[2, Work shr 16 and $3F];
    R := R xor SPBox[0, Work shr 24 and $3F];

    Work := (L xor CPtr^);
    Inc(CPtr);
    R := R xor SPBox[7, Work and $3F];
    R := R xor SPBox[5, Work shr 8 and $3F];
    R := R xor SPBox[3, Work shr 16 and $3F];
    R := R xor SPBox[1, Work shr 24 and $3F];
  end;

  FPerm(L, R);
  JoinBlock(L, R, Data);
end;

{ TDESAlgorithm }

function TDesAlgorithm.ExpandKey(Key: PByte; KeySize: Cardinal;
           Encryption: Boolean): TF_RESULT;
begin
  if KeySize <> 8 then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  DesExpandKey(Key, FSubKeys, Encryption);
  Result:= TF_S_OK;
end;


{ TDES3Algorithm }

function TDES3Algorithm.ExpandKey(Key: PByte; KeySize: Cardinal;
           Encryption: Boolean): TF_RESULT;
begin
  if (KeySize <> 8) and (KeySize <> 16) and (KeySize <> 24) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;

  if Encryption then begin
    DesExpandKey(Key, FSubKeys[0], True);

    if KeySize > 8 then
      DesExpandKey(Key + 8, FSubKeys[1], False)
    else
      DesExpandKey(Key, FSubKeys[1], False);

    if KeySize > 16 then
      DesExpandKey(Key + 16, FSubKeys[2], True)
    else
      DesExpandKey(Key, FSubKeys[2], True);
  end
  else begin
    if KeySize > 16 then
      DesExpandKey(Key + 16, FSubKeys[0], False)
    else
      DesExpandKey(Key, FSubKeys[0], False);

    if KeySize > 8 then
      DesExpandKey(Key + 8, FSubKeys[1], True)
    else
      DesExpandKey(Key, FSubKeys[1], True);

    DesExpandKey(Key, FSubKeys[2], False);
  end;
  Result:= TF_S_OK;
end;

end.
