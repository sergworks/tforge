{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # GHash for GCM mode of operation
}

unit tfGHash;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  PGHash = ^TGHash;
  TGHash = record
  private type
    TValue = array[0..3] of UInt32;
  private
    FH: TValue;
    FY: TValue;
    FPos: Cardinal;   // 0..15
  public
    procedure Init(HashKey: Pointer);
    procedure Update(Data: Pointer; DataSize: Cardinal);
    procedure Pad;
    procedure Done(Tag: Pointer; TagSize: Cardinal);
  end;

implementation

{ TGHash }

function Swap32(Value: UInt32): UInt32;
begin
  Result:= (Value and $000000FF) shl 24
        or (Value and $0000FF00) shl 8
        or (Value and $00FF0000) shr 8
        or (Value and $FF000000) shr 24;
end;

procedure GF128Mul(Y: PByte; const H: TGHash.TValue);
var
  Z, V: TGHash.TValue;
  I, Bit: Integer;
  Value: Byte;
  Mask: UInt32;

begin
  Z[0]:= 0;      // Z = 0
  Z[1]:= 0;
  Z[2]:= 0;
  Z[3]:= 0;
  V:= H;
//  V[0]:= H[0];     // V = H
//  V[1]:= H[1];
//  V[2]:= H[2];
//  V[3]:= H[3];

// Multiply Z by V for the set bits in Y, starting at the top.
// This is a very simple bit by bit version that may not be very
// fast but it should be resistant to cache timing attacks.
  for I:= 0 to 15 do begin
    Value:= Y[I];
    for Bit:= 0 to 7 do begin
      Value:= Value shl 1;
// Extract the high bit of "value" and turn it into a mask.
      Mask:= not UInt32(Value shr 7) + 1;

// XOR V with Z if the bit is 1.
      Z[0]:= Z[0] xor (V[0] and Mask);
      Z[1]:= Z[1] xor (V[1] and Mask);
      Z[2]:= Z[2] xor (V[2] and Mask);
      Z[3]:= Z[3] xor (V[3] and Mask);

// Rotate V right by 1 bit.
      Mask:= (not (V[3] and 1) + 1) and $E1000000;
      V[3]:= (V[3] shr 1) or (V[2] shl 31);
      V[2]:= (V[2] shr 1) or (V[1] shl 31);
      V[1]:= (V[1] shr 1) or (V[0] shl 31);
      V[0]:= (V[0] shr 1) xor Mask;
    end;
  end;
// We have finished the block so copy Z into Y and byte-swap.
  Y[0]:= Swap32(Z[0]);
  Y[1]:= Swap32(Z[1]);
  Y[2]:= Swap32(Z[2]);
  Y[3]:= Swap32(Z[3]);
end;

procedure TGHash.Init(HashKey: Pointer);
begin
//  Move(HashKey^, FH, SizeOf(FH));
  FH[0]:= Swap32(PUInt32(HashKey)[0]);
  FH[1]:= Swap32(PUInt32(HashKey)[1]);
  FH[2]:= Swap32(PUInt32(HashKey)[2]);
  FH[3]:= Swap32(PUInt32(HashKey)[3]);
  FillChar(FY, SizeOf(FY), 0);
  FPos:= 0;
end;

procedure TGHash.Done(Tag: Pointer; TagSize: Cardinal);
begin
  Pad;
  if TagSize > 16 then TagSize:= 16;
  Move(FY, Tag^, TagSize);
end;

procedure TGHash.Pad;
begin
  if FPos <> 0 then begin
// Padding involves XOR'ing the rest of FY with zeroes, which does nothing.
    GF128mul(@FY, FH);
    FPos:= 0;
  end;
end;

procedure TGHash.Update(Data: Pointer; DataSize: Cardinal);
var
  Size: Cardinal;
  P: PByte;
  I: Integer;

begin
  while DataSize > 0 do begin
    Size:= 16 - FPos;
    if Size > DataSize
      then Size:= DataSize;
    P:= PByte(@FY) + FPos;
    for I:= 0 to Size - 1 do
      P[I]:= P[I] xor PByte(Data)[I];

    Inc(FPos, Size);
    Dec(DataSize, Size);
    Inc(PByte(Data), Size);
    if FPos = 16 then begin
      GF128mul(@FY, FH);
      FPos:= 0;
    end;
  end;
end;

end.
