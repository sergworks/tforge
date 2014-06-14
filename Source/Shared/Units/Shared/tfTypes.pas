{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfTypes;

{$I TFL.inc}

interface

uses
  tfLimbs;

type
  TF_RESULT = LongInt;

// Codes returned by TF functions; see also
//   http://msdn.microsoft.com/en-us/library/cc231198(v=prot.10).aspx
//   http://msdn.microsoft.com/en-us/library/windows/desktop/aa378137(v=vs.85).aspx
const
                                              // = common microsoft codes =
  TF_S_OK           = TF_RESULT(0);           // Operation successful
  TF_S_FALSE        = TF_RESULT(1);           // Operation successful
  TF_E_FAIL         = TF_RESULT($80004005);   // Unspecified failure
  TF_E_INVALIDARG   = TF_RESULT($80070057);   // One or more arguments are not valid
  TF_E_NOINTERFACE  = TF_RESULT($80004002);   // No such interface supported
  TF_E_NOTIMPL      = TF_RESULT($80004001);   // Not implemented
  TF_E_OUTOFMEMORY  = TF_RESULT($8007000E);   // Failed to allocate necessary memory
  TF_E_UNEXPECTED   = TF_RESULT($8000FFFF);   // Unexpected failure
                                              // = Numerics codes =
  TF_E_NOMEMORY     = TF_RESULT($A0000003);   // specific TFL memory error
  TF_E_LOADERROR    = TF_RESULT($A0000004);   // Error loading tforge dll
                                              // = Crypto codes =
  TF_E_INVALIDKEY   = TF_RESULT($A0001001);   // Invalid crypto key

{$IFDEF FPC}
type
  TBytes = array of Byte;
{$ENDIF}

type
  TClearMemProc = function(Inst: Pointer): TF_RESULT; stdcall;

  IForge = interface
    function ClearMem: TF_RESULT; stdcall;
  end;

type
  IBytes = interface(IForge)
    function GetHashCode: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetLen: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetRawData: PByte;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AssignBytes(var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ConcatBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualBytes(const B: IBytes): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AddBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AndBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function OrBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function XorBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AppendByte(B: Byte; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function PrependByte(B: Byte; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualToByte(B: Byte): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AppendPByte(P: PByte; L: Cardinal; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function PrependPByte(P: PByte; L: Cardinal; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualToPByte(P: PByte; L: Integer): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ToDec(var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

type
  IBigNumber = interface(IForge)
    function GetHashCode: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetLen: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetRawData: PByte;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function GetIsEven: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetIsOne: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetIsPowerOfTwo: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetIsZero: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetSign: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetSize: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function CompareNumber(const Num: IBigNumber): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareNumberU(const Num: IBigNumber): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualsNumber(const Num: IBigNumber): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualsNumberU(const Num: IBigNumber): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AddNumber(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AddNumberU(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubNumber(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubNumberU(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulNumber(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulNumberU(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemNumber(const Num: IBigNumber; var Q, R: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemNumberU(const Num: IBigNumber; var Q, R: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AndNumber(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AndNumberU(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function OrNumber(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function OrNumberU(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function XorNumber(const Num: IBigNumber; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ShlNumber(Shift: Cardinal; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ShrNumber(Shift: Cardinal; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AssignNumber(var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AbsNumber(var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function NegateNumber(var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Pow(Value: Cardinal; var IRes: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function PowU(Value: Cardinal; var IRes: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function SqrtNumber(var IRes: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GCD(const B: IBigNumber; var G: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EGCD(const B: IBigNumber; var G, X, Y: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ModPow(const IExp, IMod: IBigNumber; var IRes: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ModInverse(const M: IBigNumber; var R: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ToLimb(var Value: TLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ToIntLimb(var Value: TIntLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ToDec(P: PByte; var L: Integer): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ToHex(P: PByte; var L: Integer; TwoCompl: Boolean): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ToPByte(P: PByte; var L: Cardinal): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function CompareToLimb(Limb: TLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToLimbU(Limb: TLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToIntLimb(Limb: TIntLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToIntLimbU(Limb: TIntLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AddLimb(Limb: TLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AddLimbU(Limb: TLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AddIntLimb(Limb: TIntLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function SubLimb(Limb: TLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubLimb2(Limb: TLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubLimbU(Limb: TLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubLimbU2(Limb: TLimb; var Res: TLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubIntLimb(Limb: TIntLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubIntLimb2(Limb: TIntLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function MulLimb(Limb: TLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulLimbU(Limb: TLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulIntLimb(Limb: TIntLimb; var Res: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function DivRemLimb(Limb: TLimb; var Q: IBigNumber; var R: IBigNumber): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemLimb2(Limb: TLimb; var Q: IBigNumber; var R: TLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemLimbU(Limb: TLimb; var Q: IBigNumber; var R: TLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemLimbU2(Limb: TLimb; var Q: TLimb; var R: TLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemIntLimb(Limb: TIntLimb; var Q: IBigNumber; var R: TIntLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemIntLimb2(Limb: TIntLimb; var Q: TIntLimb; var R: TIntLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ToDblLimb(var Value: TDblLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ToDblIntLimb(var Value: TDblIntLimb): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToDblLimb(B: TDblLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToDblLimbU(B: TDblLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToDblIntLimb(B: TDblIntLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToDblIntLimbU(B: TDblIntLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

  IHashAlgorithm = interface(IForge)
    procedure Init;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Update(Data: Pointer; DataSize: LongWord);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Done(PDigest: Pointer);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetHashSize: LongInt;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Purge;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

  IBlockCipherAlgorithm = interface(IForge)
    function ImportKey(Key: PByte; KeySize: LongWord; AlgID: Integer): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure ExpandKey(Encryption: Boolean);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DeleteKey;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure EncryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DecryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

{ Hash helper types }
type
  PSHA256Digest = ^TSHA256Digest;
  TSHA256Digest = array[0..7] of LongWord;

  PMD5Digest = ^TMD5Digest;
  TMD5Digest = record
    A, B, C, D: LongWord;
  end;

implementation

end.
