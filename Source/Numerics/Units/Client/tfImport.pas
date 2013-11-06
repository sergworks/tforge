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
  TBigNumberFromLimb = function(var A: IBigNumber; Value: TLimb): TF_RESULT; stdcall;
  TBigNumberFromDblLimb = function(var A: IBigNumber; Value: TDblLimb): TF_RESULT; stdcall;

  TBigNumberFromIntLimb = function(var A: IBigNumber; Value: TIntLimb): TF_RESULT; stdcall;
  TBigNumberFromDblIntLimb = function(var A: IBigNumber; Value: TDblIntLimb): TF_RESULT; stdcall;

//  TBigNumberFromPWideChar = function(var A: IBigNumber;
//    P: PWideChar; L: Cardinal; AllowNegative: Boolean): HResult; stdcall;
  TBigNumberFromPChar = function(var A: IBigNumber; P: PByte; L: Integer;
           CharSize: Integer; AllowNegative: Boolean; TwoCompl: Boolean): TF_RESULT; stdcall;
  TBigNumberFromPByte = function(var A: IBigNumber;
    P: PByte; L: Cardinal; AllowNegative: Boolean): TF_RESULT; stdcall;

var
  BigNumberFromLimb: TBigNumberFromLimb;
  BigNumberFromDblLimb: TBigNumberFromDblLimb;
  BigNumberFromIntLimb: TBigNumberFromIntLimb;
  BigNumberFromDblIntLimb: TBigNumberFromDblIntLimb;
//  BigNumberFromPWideChar: TBigNumberFromPWideChar;
  BigNumberFromPChar: TBigNumberFromPChar;
  BigNumberFromPByte: TBigNumberFromPByte;

implementation

uses Windows;

const
  LibName = 'numerics32.dll';

var
  LibHandle: THandle = 0;

function BigNumberFromLimbStub(var A: IBigNumber; Value: TLimb): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function BigNumberFromDblLimbStub(var A: IBigNumber; Value: TDblLimb): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function BigNumberFromPCharStub(var A: IBigNumber; P: PByte; L: Integer;
           CharSize: Integer; AllowNegative: Boolean; TwoCompl: Boolean): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function BigNumberFromPByteStub(var A: IBigNumber;
           P: PByte; L: Cardinal; AllowNegative: Boolean): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function LoadLib: Boolean;
begin
  if LibHandle <> 0 then begin
    Result:= True;
    Exit;
  end;
  Result:= False;
  LibHandle:= LoadLibrary(LibName);
  if LibHandle <> 0 then begin
    @BigNumberFromLimb:= GetProcAddress(LibHandle, 'BigNumberFromLimb');
    @BigNumberFromDblLimb:= GetProcAddress(LibHandle, 'BigNumberFromDblLimb');
    @BigNumberFromIntLimb:= GetProcAddress(LibHandle, 'BigNumberFromIntLimb');
    @BigNumberFromDblIntLimb:= GetProcAddress(LibHandle, 'BigNumberFromDblIntLimb');
//    @BigNumberFromPWideChar:= GetProcAddress(LibHandle, 'BigNumberFromPWideChar');
    @BigNumberFromPChar:= GetProcAddress(LibHandle, 'BigNumberFromPChar');
    @BigNumberFromPByte:= GetProcAddress(LibHandle, 'BigNumberFromPByte');
    Result:= (@BigNumberFromLimb <> nil)
             and (@BigNumberFromDblLimb <> nil)
             and (@BigNumberFromIntLimb <> nil)
             and (@BigNumberFromDblIntLimb <> nil)
//             and (@BigNumberFromPWideChar <> nil)
             and (@BigNumberFromPChar <> nil)
             and (@BigNumberFromPByte <> nil)
  end;
  if not Result then begin
    @BigNumberFromLimb:= @BigNumberFromLimbStub;
    @BigNumberFromDblLimb:= @BigNumberFromDblLimbStub;
    @BigNumberFromIntLimb:= @BigNumberFromLimbStub;
    @BigNumberFromDblIntLimb:= @BigNumberFromDblLimbStub;
//    @BigNumberFromPWideChar:= @BigNumberFromPByteStub;
    @BigNumberFromPChar:= @BigNumberFromPCharStub;
    @BigNumberFromPByte:= @BigNumberFromPByteStub;
  end;
end;

initialization
  LoadLib;

end.
