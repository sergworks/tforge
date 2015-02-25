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
    property Code: TF_RESULT read FCode;
  end;

procedure ForgeError(ACode: TF_RESULT; const Msg: string = '');

implementation

{ EForgeError }

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
