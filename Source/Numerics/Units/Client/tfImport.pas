{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
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

  TBigNumberFromPChar = function(var A: IBigNumber; P: PByte; L: Integer;
           CharSize: Integer; AllowNegative: Boolean; TwoCompl: Boolean): TF_RESULT; stdcall;
  TBigNumberFromPByte = function(var A: IBigNumber;
    P: PByte; L: Integer; AllowNegative: Boolean): TF_RESULT; stdcall;

var
  BigNumberFromLimb: TBigNumberFromLimb;
  BigNumberFromDblLimb: TBigNumberFromDblLimb;
  BigNumberFromIntLimb: TBigNumberFromIntLimb;
  BigNumberFromDblIntLimb: TBigNumberFromDblIntLimb;
  BigNumberFromPChar: TBigNumberFromPChar;
  BigNumberFromPByte: TBigNumberFromPByte;

implementation

uses Windows;

const
{$IFDEF WIN64}
  LibName = 'numerics64.dll';
{$ELSE}
  LibName = 'numerics32.dll';
{$ENDIF}

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
    @BigNumberFromPChar:= GetProcAddress(LibHandle, 'BigNumberFromPChar');
    @BigNumberFromPByte:= GetProcAddress(LibHandle, 'BigNumberFromPByte');
    Result:= (@BigNumberFromLimb <> nil)
             and (@BigNumberFromDblLimb <> nil)
             and (@BigNumberFromIntLimb <> nil)
             and (@BigNumberFromDblIntLimb <> nil)
             and (@BigNumberFromPChar <> nil)
             and (@BigNumberFromPByte <> nil)
  end;
  if not Result then begin
    @BigNumberFromLimb:= @BigNumberFromLimbStub;
    @BigNumberFromDblLimb:= @BigNumberFromDblLimbStub;
    @BigNumberFromIntLimb:= @BigNumberFromLimbStub;
    @BigNumberFromDblIntLimb:= @BigNumberFromDblLimbStub;
    @BigNumberFromPChar:= @BigNumberFromPCharStub;
    @BigNumberFromPByte:= @BigNumberFromPByteStub;
  end;
end;

initialization
  LoadLib;

end.
