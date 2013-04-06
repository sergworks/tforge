{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ * ------------------------------------------------------- * }
{ *   # shared unit                                         * }
{ *********************************************************** }

unit tfTypes;

{$I TFL.inc}

interface

uses
  tfLimbs;
//  SysUtils;

// HRESULT codes returned by TFL functions; see also
//   http://msdn.microsoft.com/en-us/library/cc231198(v=prot.10).aspx
//   http://msdn.microsoft.com/en-us/library/windows/desktop/aa378137(v=vs.85).aspx
const
                                            // = common microsoft codes =
  TFL_S_OK          = HRESULT(0);           // Operation successful
  TFL_S_FALSE       = HRESULT(1);           // Operation successful
  TFL_E_FAIL        = HRESULT($80004005);   // Unspecified failure
  TFL_E_INVALIDARG  = HRESULT($80070057);   // One or more arguments are not valid
  TFL_E_NOINTERFACE = HRESULT($80004002);   // No such interface supported
  TFL_E_NOTIMPL     = HRESULT($80004001);   // Not implemented
  TFL_E_OUTOFMEMORY = HRESULT($8007000E);   // Failed to allocate necessary memory
  TFL_E_UNEXPECTED  = HRESULT($8000FFFF);   // Unexpected failure
                                            // = TFL specific codes =
  TFL_E_ZERODIVIDE  = HRESULT($A0000001);   // Division by zero
  TFL_E_INVALIDSUB  = HRESULT($A0000002);   // Unsigned subtract greater from lesser
  TFL_E_NOMEMORY    = HRESULT($A0000003);   // specific TFL memory error
  TFL_E_LOADERROR   = HRESULT($A0000004);   // Error loading tforge dll

{$IFDEF FPC}
type
  TBytes = array of Byte;
{$ENDIF}

type
  IBigNumber = interface

    function GetIsEven: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetIsOne: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetIsPowerOfTwo: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetIsZero: Boolean;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function GetSign: Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function CompareNumber(Num: IBigNumber): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareNumberU(Num: IBigNumber): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AddNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AddNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemNumber(Num: IBigNumber; var Q, R: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemNumberU(Num: IBigNumber; var Q, R: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AndNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AndNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function OrNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function OrNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function XorNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ShlNumber(Shift: Cardinal; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ShrNumber(Shift: Cardinal; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AbsNumber(var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Pow(Value: Cardinal; var IRes: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function PowU(Value: Cardinal; var IRes: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function PowerMod(IExp, IMod: IBigNumber; var IRes: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function ToWideString(var S: WideString): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function ToWideHexString(var S: WideString; Digits: Cardinal; TwoCompl: Boolean): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function CompareToLimb(Limb: TLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToLimbU(Limb: TLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToIntLimb(Limb: TIntLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function CompareToIntLimbU(Limb: TIntLimb): Integer;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function AddLimb(Limb: TLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AddLimbU(Limb: TLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AddIntLimb(Limb: TIntLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function AddIntLimbU(Limb: TIntLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function SubLimb(Limb: TLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubLimbU(Limb: TLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubIntLimb(Limb: TIntLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SubIntLimbU(Limb: TIntLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function MulLimb(Limb: TLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulLimbU(Limb: TLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulIntLimb(Limb: TIntLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function MulIntLimbU(Limb: TIntLimb; var Res: IBigNumber): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

    function DivRemLimbU(Limb: TLimb; var Q: IBigNumber; var R: TLimb): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DivRemIntLimb(Limb: TIntLimb; var Q: IBigNumber; var R: TIntLimb): HRESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
  end;

implementation

end.
