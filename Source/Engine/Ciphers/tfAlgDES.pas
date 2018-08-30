{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # DES block cipher algorithm
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

    PExpandedKey = ^TExpandedKey;
    TExpandedKey = array[0..31] of UInt32;

  private
    FSubKeys:  TExpandedKey;

    class procedure DoExpandKey(Key: PByte; var SubKeys: TExpandedKey; Encryption: Boolean); static;
    class procedure DoEncryptBlock(var SubKeys: TExpandedKey; Data: PByte); static;
  public
    function ExpandKey(Key: PByte; KeySize: Cardinal): TF_RESULT;
    function EncryptBlock(Data: PByte): TF_RESULT;
  end;

  PDES3Algorithm = ^TDES3Algorithm;
  TDES3Algorithm = record
  private
    FSubKeys:  array[0..2] of TDESAlgorithm.TExpandedKey;

  public
    function ExpandKey(Key: PByte; KeySize: Cardinal): TF_RESULT;
    function EncryptBlock(Data: PByte): TF_RESULT;
  end;

implementation

{ TDESAlgorithm }

class procedure TDESAlgorithm.DoEncryptBlock(var SubKeys: TExpandedKey; Data: PByte);
begin
end;

class procedure TDESAlgorithm.DoExpandKey(Key: PByte; var SubKeys: TExpandedKey;
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

function TDESAlgorithm.EncryptBlock(Data: PByte): TF_RESULT;
begin

end;

function TDESAlgorithm.ExpandKey(Key: PByte; KeySize: Cardinal): TF_RESULT;
begin

end;

{ TDES3Algorithm }

function TDES3Algorithm.EncryptBlock(Data: PByte): TF_RESULT;
begin

end;

function TDES3Algorithm.ExpandKey(Key: PByte; KeySize: Cardinal): TF_RESULT;
begin

end;

end.
