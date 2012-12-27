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
  TBigNumberFromCardinal = function(var A: IBigNumber; Value: Cardinal): HResult; stdcall;
  TBigNumberFromInteger = function(var A: IBigNumber; Value: Integer): HResult; stdcall;
  TBigNumberFromPWideChar = function(var A: IBigNumber;
    P: PWideChar; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;
  TBigNumberFromPByte = function(var A: IBigNumber;
    P: PByte; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;

var
  BigNumberFromCardinal: TBigNumberFromCardinal;
  BigNumberFromInteger: TBigNumberFromInteger;
  BigNumberFromPWideChar: TBigNumberFromPWideChar;
  BigNumberFromPByte: TBigNumberFromPByte;

implementation

uses Windows;

const
  LibName = 'tforge32.dll';

var
  LibHandle: THandle = 0;

function BigNumberFromCardinalStub(var A: IBigNumber; Value: Cardinal): HResult; stdcall;
begin
  Result:= TFL_E_LOADERROR;
end;

function BigNumberFromPByteStub(var A: IBigNumber;
           P: PByte; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;
begin
  Result:= TFL_E_LOADERROR;
end;

function LoadForge: Boolean;
begin
  if LibHandle <> 0 then begin
    Result:= True;
    Exit;
  end;
  Result:= False;
  LibHandle:= LoadLibrary(LibName);
  if LibHandle <> 0 then begin
    @BigNumberFromCardinal:= GetProcAddress(LibHandle, 'BigNumberFromCardinal');
    @BigNumberFromInteger:= GetProcAddress(LibHandle, 'BigNumberFromInteger');
    @BigNumberFromPWideChar:= GetProcAddress(LibHandle, 'BigNumberFromPWideChar');
    @BigNumberFromPByte:= GetProcAddress(LibHandle, 'BigNumberFromPByte');
    Result:= (@BigNumberFromCardinal <> nil)
             and (@BigNumberFromInteger <> nil)
             and (@BigNumberFromPWideChar <> nil)
             and (@BigNumberFromPByte <> nil)
  end;
  if not Result then begin
    @BigNumberFromCardinal:= @BigNumberFromCardinalStub;
    @BigNumberFromInteger:= @BigNumberFromCardinalStub;
    @BigNumberFromPWideChar:= @BigNumberFromPByteStub;
    @BigNumberFromPByte:= @BigNumberFromPByteStub;
  end;
end;

initialization
  LoadForge;

end.
