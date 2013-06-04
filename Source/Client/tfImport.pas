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
  tfLimbs, tfTypes;

type
  TBigNumberFromLimb = function(var A: IBigNumber; Value: TLimb): HResult; stdcall;
  TBigNumberFromIntLimb = function(var A: IBigNumber; Value: TIntLimb): HResult; stdcall;
  TBigNumberFromPWideChar = function(var A: IBigNumber;
    P: PWideChar; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;
  TBigNumberFromPByte = function(var A: IBigNumber;
    P: PByte; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;

var
  BigNumberFromLimb: TBigNumberFromLimb;
  BigNumberFromIntLimb: TBigNumberFromIntLimb;
  BigNumberFromPWideChar: TBigNumberFromPWideChar;
  BigNumberFromPByte: TBigNumberFromPByte;

implementation

uses Windows;

const
  LibName = 'tforge32.dll';

var
  LibHandle: THandle = 0;

function BigNumberFromLimbStub(var A: IBigNumber; Value: TLimb): HResult; stdcall;
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
    @BigNumberFromLimb:= GetProcAddress(LibHandle, 'BigNumberFromLimb');
    @BigNumberFromIntLimb:= GetProcAddress(LibHandle, 'BigNumberFromIntLimb');
    @BigNumberFromPWideChar:= GetProcAddress(LibHandle, 'BigNumberFromPWideChar');
    @BigNumberFromPByte:= GetProcAddress(LibHandle, 'BigNumberFromPByte');
    Result:= (@BigNumberFromLimb <> nil)
             and (@BigNumberFromIntLimb <> nil)
             and (@BigNumberFromPWideChar <> nil)
             and (@BigNumberFromPByte <> nil)
  end;
  if not Result then begin
    @BigNumberFromLimb:= @BigNumberFromLimbStub;
    @BigNumberFromIntLimb:= @BigNumberFromLimbStub;
    @BigNumberFromPWideChar:= @BigNumberFromPByteStub;
    @BigNumberFromPByte:= @BigNumberFromPByteStub;
  end;
end;

initialization
  LoadForge;

end.
