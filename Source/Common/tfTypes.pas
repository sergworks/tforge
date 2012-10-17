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

type
  IBigNumber = interface
    function GetSign: Integer; stdcall;

    function AddNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function AddNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function SubNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function SubNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function MulNumber(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function MulNumberU(Num: IBigNumber; var Res: IBigNumber): HRESULT; stdcall;
    function DivModNumber(Num: IBigNumber; var Q, R: IBigNumber): HRESULT; stdcall;
    function DivModNumberU(Num: IBigNumber; var Q, R: IBigNumber): HRESULT; stdcall;
    function Power(Value: Cardinal; var IRes: IBigNumber): HRESULT; stdcall;
    function PowerU(Value: Cardinal; var IRes: IBigNumber): HRESULT; stdcall;
    function PowerMod(IExp, IMod: IBigNumber; var IRes: IBigNumber): HRESULT; stdcall;

    function ToWideString(var S: WideString): HRESULT; stdcall;

    function AddLimb(Limb: TLimb; var Res: IBigNumber): HRESULT; stdcall;
    function AddLimbU(Limb: TLimb; var Res: IBigNumber): HRESULT; stdcall;
    function AddIntLimb(Limb: TIntLimb; var Res: IBigNumber): HRESULT; stdcall;
    function AddIntLimbU(Limb: TIntLimb; var Res: IBigNumber): HRESULT; stdcall;

    function SubLimb(Limb: TLimb; var Res: IBigNumber): HRESULT; stdcall;
    function SubLimbU(Limb: TLimb; var Res: IBigNumber): HRESULT; stdcall;
    function SubIntLimb(Limb: TIntLimb; var Res: IBigNumber): HRESULT; stdcall;
    function SubIntLimbU(Limb: TIntLimb; var Res: IBigNumber): HRESULT; stdcall;

    function MulLimb(Limb: TLimb; var Res: IBigNumber): HRESULT; stdcall;
    function MulLimbU(Limb: TLimb; var Res: IBigNumber): HRESULT; stdcall;
    function MulIntLimb(Limb: TIntLimb; var Res: IBigNumber): HRESULT; stdcall;
    function MulIntLimbU(Limb: TIntLimb; var Res: IBigNumber): HRESULT; stdcall;

  end;

implementation

end.
