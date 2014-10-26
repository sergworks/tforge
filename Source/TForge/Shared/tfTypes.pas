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
//  TF_E_INVALIDKEY   = TF_RESULT($A0001001);   // Invalid crypto key

{$IFNDEF FPC}
const
  FPC_VERSION = 2;
  FPC_RELEASE = 6;
{$ELSE}
type
  TBytes = array of Byte;
  PUInt64 = ^UInt64;
{$IF FPC_VERSION = 2}
  {$IF FPC_RELEASE <= 6}
type
  RawByteString = AnsiString;
  {$IFEND}
{$IFEND}

{$ENDIF}

type
  IBytesEnumerator = interface(IInterface)
    function GetCurrent: Byte;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: Byte read GetCurrent;
  end;

  IBytes = interface(IInterface)
    function GetEnum(var R: IBytesEnumerator): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function GetHashCode: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetLen: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SetLen(Value: Integer): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetRawData: PByte;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AssignBytes(var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CopyBytes(var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CopyBytes1(var R: IBytes; I: Cardinal): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CopyBytes2(var R: IBytes; I, L: Cardinal): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function RemoveBytes1(var R: IBytes; I: Cardinal): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function RemoveBytes2(var R: IBytes; I, L: Cardinal): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ReverseBytes(var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ConcatBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function InsertBytes(Index: Cardinal; const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualBytes(const B: IBytes): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AddBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AndBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function OrBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function XorBytes(const B: IBytes; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AppendByte(B: Byte; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function InsertByte(Index: Cardinal; B: Byte; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualToByte(B: Byte): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AppendPByte(P: PByte; L: Cardinal; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function InsertPByte(Index: Cardinal; P: PByte; L: Cardinal; var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function EqualToPByte(P: PByte; L: Integer): Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ToDec(var R: IBytes): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

(*
  IBytesServer = interface(IInterface)
    function Allocate(var A: IBytes; ASize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ReAllocate(var A: IBytes; ASize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function FromPByte(var A: IBytes; P: PByte; L: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function FromPCharHex(var A: IBytes; P: PByte; L: Cardinal; CharSize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function FromByte(var A: IBytes; Value: Byte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;
*)

type
  IBigNumber = interface(IInterface)
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

const
                           // Cryptographic Hash Algorithms
  TF_ALG_MD5       = $1001;
  TF_ALG_SHA1      = $1002;
  TF_ALG_SHA256    = $1003;
  TF_ALG_SHA512    = $1004;
  TF_ALG_SHA224    = $1005;
  TF_ALG_SHA384    = $1006;
                           // Non-cryptographic Hash Algorithms
  TF_ALG_CRC32     = $1801;
  TF_ALG_JENKINS1  = $1802;

type
  IHashAlgorithm = interface(IInterface)
    procedure Init;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Update(Data: Pointer; DataSize: LongWord);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Done(PDigest: Pointer);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Burn;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetDigestSize: LongInt;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetBlockSize: LongInt;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Duplicate(var Inst: IHashAlgorithm): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

  THashGetter = function(var A: IHashAlgorithm): TF_RESULT;
                {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

  IHMACAlgorithm = interface(IInterface)
    procedure Init(Key: Pointer; KeySize: LongWord);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Update(Data: Pointer; DataSize: LongWord);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Done(PDigest: Pointer);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure Burn;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetDigestSize: LongInt;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
//    function GetBlockSize: LongInt;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Duplicate(var Inst: IHMACAlgorithm): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function PBKDF2(Password: Pointer; PassLen: LongWord;
          Salt: Pointer; SaltLen: LongWord;
          Rounds, DKLen: Integer; var Key: IBytes): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

  IHashServer = interface(IInterface)
    function GetByAlgID(AlgID: LongInt; var Alg: IHashAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetByName(Name: Pointer; CharSize: Integer; var Alg: IHashAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetByIndex(Index: Integer; var Alg: IHashAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetName(Index: Integer; var Name: IBytes): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetCount: Integer;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetHMAC(var HMACAlg: IHMACAlgorithm;
          const HashAlg: IHashAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function PBKDF1(HashAlg: IHashAlgorithm;
          Password: Pointer; PassLen: LongWord;
          Salt: Pointer; SaltLen: LongWord;
          Rounds, dkLen: LongWord; var Key: IBytes): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
//    function RegisterHash(Name: Pointer; CharSize: Integer; Getter: THashGetter;
//          var Index: Integer): TF_RESULT;
//          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

  IBlockCipherAlgorithm = interface(IInterface)
    function ImportKey(Key: PByte; Flags: LongWord): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DestroyKey;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure EncryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DecryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

  ICipherKey = interface(IInterface)
    function DuplicateKey(var Key: ICipherKey): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SetKeyParam(Param: LongWord; Data: PByte; DataLen: LongWord): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DestroyKey;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

  ICipher = interface(ICipherKey)
    function GetBlockSize: LongInt;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Encrypt(Data: PByte; var DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Decrypt(Data: PByte; var DataSize: LongWord;
             Last: Boolean): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure EncryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DecryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

const
// IBlockCipherAlgorithm.ImportKey Flags
  TF_KEY_ENCRYPT = $80000000;
  TF_KEY_DECRYPT = $00000000;

// ICipherKey.SetKeyParam Params
  TF_KP_KEY     = 1;
  TF_KP_IV      = 2;
  TF_KP_MODE    = 3;
  TF_KP_PADDING = 4;

// Cipher Key Mode
  TF_KEYMODE_ECB = 1;
  TF_KEYMODE_CBC = 2;
  TF_KEYMODE_CTR = 3;

  TF_KEYMODE_MIN = TF_KEYMODE_ECB;
  TF_KEYMODE_MAX = TF_KEYMODE_CTR;

// Cipher Key Padding
  TF_PADDING_DEFAULT  = 0;
  TF_PADDING_NONE     = 1;
  TF_PADDING_ZERO     = 2;    // XX 00 00 00 00
  TF_PADDING_ANSI     = 3;    // XX 00 00 00 04
  TF_PADDING_PKSC7    = 4;    // XX 04 04 04 04
  TF_PADDING_ISO10126 = 5;    // XX ?? ?? ?? 04
  TF_PADDING_ISOIEC   = 6;    // XX 80 00 00 00

  TF_PADDING_MIN = TF_PADDING_NONE;
  TF_PADDING_MAX = TF_PADDING_ISOIEC;

{ Hash digest helper types }
type
                                  // 128-bit MD5 digest
  PMD5Digest = ^TMD5Digest;
  TMD5Digest = array[0..3] of LongWord;
                                  // 160-bit SHA1 digest
  PSHA1Digest = ^TSHA1Digest;
  TSHA1Digest = array[0..4] of LongWord;
                                  // 256-bit SHA256 digest
  PSHA256Digest = ^TSHA256Digest;
  TSHA256Digest = array[0..7] of LongWord;
                                  // 512-bit SHA512 digest
  PSHA512Digest = ^TSHA512Digest;
  TSHA512Digest = array[0..7] of UInt64;
                                  // 224-bit SHA224 digest
  PSHA224Digest = ^TSHA224Digest;
  TSHA224Digest = array[0..6] of LongWord;
                                  // 384-bit SHA384 digest
  PSHA384Digest = ^TSHA384Digest;
  TSHA384Digest = array[0..5] of UInt64;

implementation

end.
