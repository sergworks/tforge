{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2012         * }
{ * ------------------------------------------------------- * }
{ *   # client unit                                         * }
{ *   # loads TForge dll                                    * }
{ *********************************************************** }

unit tfImport;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  TWideStringToBigNumber = function(var A: IBigNumber; const S: WideString): HResult; stdcall;
  TCardinalToBigNumber = function(var A: IBigNumber; Value: Cardinal): HResult; stdcall;
  TIntegerToBigNumber = function(var A: IBigNumber; Value: Integer): HResult; stdcall;

var
  WideStringToBigNumber: TWideStringToBigNumber;
  WideStringToBigNumberU: TWideStringToBigNumber;
  CardinalToBigNumber: TCardinalToBigNumber;
  IntegerToBigNumber: TIntegerToBigNumber;

function LoadForge: Boolean;

implementation

uses Windows;

const
  LibName = 'TForge.dll';

var
  LibHandle: THandle = 0;

function LoadForge: Boolean;
begin
  if LibHandle <> 0 then begin
    Result:= True;
    Exit;
  end;
  Result:= False;
  LibHandle:= LoadLibrary(LibName);
  if LibHandle <> 0 then begin
    @WideStringToBigNumber:= GetProcAddress(LibHandle, 'WideStringToBigNumber');
    @WideStringToBigNumberU:= GetProcAddress(LibHandle, 'WideStringToBigNumberU');
    @CardinalToBigNumber:= GetProcAddress(LibHandle, 'CardinalToBigNumber');
    @IntegerToBigNumber:= GetProcAddress(LibHandle, 'IntegerToBigNumber');
    Result:= True;
  end;
end;

end.
