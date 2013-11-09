{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ *********************************************************** }

unit tfLimbs;

{$I TFL.inc}
{$IFDEF TFL_POINTERMATH}
   {$POINTERMATH ON}      // PLimb is compiled with POINTERMATH ON
{$ENDIF}

interface

type
  PLimb = ^TLimb;
  PIntLimb = ^TIntLimb;
  PDblLimb = ^TDblLimb;
  PDblIntLimb = ^TDblIntLimb;

{$IFDEF TFL_LIMB32}
  TLimb = LongWord;
  TIntLimb = LongInt;
  TDblLimb = UInt64;
  TDblIntLimb = Int64;

  TLimbVector = record
    case Byte of
      0: (Value: UInt64);
      1: (Lo, Hi: LongWord);
  end;

  TLimbInfo = record
  public const
    BitSize = 32;
    BitShift = 5;
    BitShiftMask = $1F;
    MaxLimb = $FFFFFFFF;
    MaxIntLimb = $7FFFFFFF;
    MaxDblLimb = UInt64($FFFFFFFFFFFFFFFF);
    MaxDblIntLimb = Int64($7FFFFFFFFFFFFFFF);
                               // max number of limbs in big number
    MaxCapacity = $01000000 div SizeOf(TLimb);
  end;
{$ENDIF}

{$IFDEF TFL_LIMB16}
  TLimb = Word;
  TIntLimb = SmallInt;
  TDblLimb = LongWord;
  TDblIntLimb = LongInt;

  TLimbVector = record
    case Byte of
      0: (Value: LongWord);
      1: (Lo, Hi: Word);
  end;

  TLimbInfo = record
  const
    BitSize = 16;
    BitShift = 4;
    BitShiftMask = $0F;
    MaxLimb = $FFFF;
    MaxIntLimb = $7FFF;
    MaxCapacity = $01000000 div SizeOf(TLimb);
  end;
{$ENDIF}

{$IFDEF TFL_LIMB8}
  TLimb = Byte;
  TIntLimb = ShortInt;
  TDblLimb = Word;
  TDblIntLimb = SmallInt;

  TLimbVector = record
    case Byte of
      0: (Value: Word);
      1: (Lo, Hi: Byte);
  end;

  TLimbInfo = record
  public const
    BitSize = 8;
    BitShift = 3;
    BitShiftMask = $07;
    MaxLimb = $FF;
    MaxIntLimb = $7F;
    MaxCapacity = $01000000 div SizeOf(TLimb);
  end;
{$ENDIF}

implementation

end.
