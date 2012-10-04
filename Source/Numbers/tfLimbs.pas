{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ *********************************************************** }

unit tfLimbs;

{$I TFL.inc}
{$IFDEF TFL_POINTERMATH}
   {$POINTERMATH ON}      // PLimb is compiled with POINTERMATH ON
{$ENDIF}

interface

type
  PLimb = ^TLimb;

{$IFDEF TFL_LIMB32}
  TLimb = LongWord;
  TIntLimb = LongInt;

  TLimbVector = record
    case Byte of
      0: (Value: UInt64);
      1: (Lo, Hi: LongWord);
  end;

  TLimbInfo = record
  public const
    BitSize = 32;
    MaxLimb = $FFFFFFFF;
                               // max number of limbs in big number
    MaxCapacity = $01000000 div SizeOf(TLimb);
  end;
{$ENDIF}

{$IFDEF TFL_LIMB16}
  TLimb = Word;
  TIntLimb = SmallInt;

  TLimbVector = record
    case Byte of
      0: (Value: LongWord);
      1: (Lo, Hi: Word);
  end;

  TLimbInfo = record
  const
    BitSize = 16;
    MaxLimb = $FFFF;
    MaxCapacity = $01000000 div SizeOf(TLimb);
  end;
{$ENDIF}

{$IFDEF TFL_LIMB8}
  TLimb = Byte;
  TIntLimb = ShortInt;

  TLimbVector = record
    case Byte of
      0: (Value: Word);
      1: (Lo, Hi: Byte);
  end;

  TLimbInfo = record
  public const
    BitSize = 8;
    MaxLimb = $FF;
    MaxCapacity = $01000000 div SizeOf(TLimb);
  end;
{$ENDIF}

implementation

end.
