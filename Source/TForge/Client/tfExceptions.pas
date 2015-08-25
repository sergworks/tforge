{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
{ *********************************************************** }

unit tfExceptions;

interface

uses SysUtils, tfTypes;

type
  EForgeError = class(Exception)
  private
    FCode: TF_RESULT;
  public
    constructor Create(ACode: TF_RESULT; const Msg: string = '');
    function CodeInfo: string;
    property Code: TF_RESULT read FCode;
  end;

procedure ForgeError(ACode: TF_RESULT; const Msg: string = '');

implementation

{ EForgeError }

function EForgeError.CodeInfo: string;
begin
  case FCode of
    TF_S_FALSE: Result:= 'TF_S_FALSE';
    TF_E_FAIL: Result:= 'TF_E_FAIL';
    TF_E_INVALIDARG: Result:= 'TF_E_INVALIDARG';
    TF_E_NOINTERFACE: Result:= 'TF_E_NOINTERFACE';
    TF_E_NOTIMPL: Result:= 'TF_E_NOTIMPL';
    TF_E_OUTOFMEMORY: Result:= 'TF_E_OUTOFMEMORY';
    TF_E_UNEXPECTED: Result:= 'TF_E_UNEXPECTED';

    TF_E_NOMEMORY: Result:= 'TF_E_NOMEMORY';
    TF_E_LOADERROR: Result:= 'TF_E_LOADERROR';
  else
    Result:= 'Unknown';
  end;
end;

constructor EForgeError.Create(ACode: TF_RESULT; const Msg: string);
begin
  if Msg = '' then
    inherited Create(Format('Forge Error 0x%.8x', [ACode]))
  else
    inherited Create(Msg);
  FCode:= ACode;
end;

procedure ForgeError(ACode: TF_RESULT; const Msg: string);
begin
  raise EForgeError.Create(ACode, Msg);
end;

end.
