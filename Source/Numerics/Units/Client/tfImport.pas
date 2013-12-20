{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ *********************************************************** }

unit tfImport;

{$I TFL.inc}

interface

uses
  tfLimbs, tfTypes, tfNumVer;

type
  TGetNumericsVersion = function(var Version: LongWord): TF_RESULT; stdcall;
  TBigNumberFromLimb = function(var A: IBigNumber; Value: TLimb): TF_RESULT; stdcall;
  TBigNumberFromDblLimb = function(var A: IBigNumber; Value: TDblLimb): TF_RESULT; stdcall;

  TBigNumberFromIntLimb = function(var A: IBigNumber; Value: TIntLimb): TF_RESULT; stdcall;
  TBigNumberFromDblIntLimb = function(var A: IBigNumber; Value: TDblIntLimb): TF_RESULT; stdcall;

  TBigNumberFromPChar = function(var A: IBigNumber; P: PByte; L: Integer;
           CharSize: Integer; AllowNegative: Boolean; TwoCompl: Boolean): TF_RESULT; stdcall;
  TBigNumberFromPByte = function(var A: IBigNumber;
    P: PByte; L: Integer; AllowNegative: Boolean): TF_RESULT; stdcall;

var
  GetNumericsVersion: TGetNumericsVersion;
  BigNumberFromLimb: TBigNumberFromLimb;
  BigNumberFromDblLimb: TBigNumberFromDblLimb;
  BigNumberFromIntLimb: TBigNumberFromIntLimb;
  BigNumberFromDblIntLimb: TBigNumberFromDblIntLimb;
  BigNumberFromPChar: TBigNumberFromPChar;
  BigNumberFromPByte: TBigNumberFromPByte;

function LoadNumerics(const Name: string = ''): TF_RESULT;

implementation

uses Windows;

const
{$IFDEF WIN64}
  LibName = 'numerics64.dll';
{$ELSE}
  LibName = 'numerics32.dll';
{$ENDIF}

function GetNumericsVersionError(var Version: LongWord): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function BigNumberFromLimbError(var A: IBigNumber; Value: TLimb): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function BigNumberFromDblLimbError(var A: IBigNumber; Value: TDblLimb): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function BigNumberFromPCharError(var A: IBigNumber; P: PByte; L: Integer;
           CharSize: Integer; AllowNegative: Boolean; TwoCompl: Boolean): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

function BigNumberFromPByteError(var A: IBigNumber;
           P: PByte; L: Cardinal; AllowNegative: Boolean): TF_RESULT; stdcall;
begin
  Result:= TF_E_LOADERROR;
end;

var
  LibLoaded: Boolean = False;

function LoadNumerics(const Name: string): TF_RESULT;
var
  LibHandle: THandle;
  Version: LongWord;

begin
  if LibLoaded then begin
    Result:= TF_S_FALSE;
    Exit;
  end;
  if Name = ''
    then LibHandle:= LoadLibrary(LibName)
    else LibHandle:= LoadLibrary(PChar(Name));
  if (LibHandle <> 0) then begin
    @GetNumericsVersion:= GetProcAddress(LibHandle, 'GetNumericsVersion');
    @BigNumberFromLimb:= GetProcAddress(LibHandle, 'BigNumberFromLimb');
    @BigNumberFromDblLimb:= GetProcAddress(LibHandle, 'BigNumberFromDblLimb');
    @BigNumberFromIntLimb:= GetProcAddress(LibHandle, 'BigNumberFromIntLimb');
    @BigNumberFromDblIntLimb:= GetProcAddress(LibHandle, 'BigNumberFromDblIntLimb');
    @BigNumberFromPChar:= GetProcAddress(LibHandle, 'BigNumberFromPChar');
    @BigNumberFromPByte:= GetProcAddress(LibHandle, 'BigNumberFromPByte');

    if (@GetNumericsVersion <> nil) and
       (@BigNumberFromLimb <> nil) and
       (@BigNumberFromDblLimb <> nil) and
       (@BigNumberFromIntLimb <> nil) and
       (@BigNumberFromDblIntLimb <> nil) and
       (@BigNumberFromPChar <> nil) and
       (@BigNumberFromPByte <> nil)
    then begin
      if (GetNumericsVersion(Version) = TF_S_OK) and
         (Version = NumericsVersion)
      then begin
        LibLoaded:= True;
        Result:= TF_S_OK;
        Exit;
      end;
    end;
    FreeLibrary(LibHandle);
  end;
  @GetNumericsVersion:= @GetNumericsVersionError;
  @BigNumberFromLimb:= @BigNumberFromLimbError;
  @BigNumberFromDblLimb:= @BigNumberFromDblLimbError;
  @BigNumberFromIntLimb:= @BigNumberFromLimbError;
  @BigNumberFromDblIntLimb:= @BigNumberFromDblLimbError;
  @BigNumberFromPChar:= @BigNumberFromPCharError;
  @BigNumberFromPByte:= @BigNumberFromPByteError;
  Result:= TF_E_LOADERROR;
end;


function BigNumberFromLimbStub(var A: IBigNumber; Value: TLimb): TF_RESULT; stdcall;
begin
  LoadNumerics(LibName);
  Result:= BigNumberFromLimb(A, Value);
end;

function BigNumberFromDblLimbStub(var A: IBigNumber; Value: TDblLimb): TF_RESULT; stdcall;
begin
  LoadNumerics(LibName);
  Result:= BigNumberFromDblLimb(A, Value);
end;

function BigNumberFromIntLimbStub(var A: IBigNumber; Value: TIntLimb): TF_RESULT; stdcall;
begin
  LoadNumerics(LibName);
  Result:= BigNumberFromIntLimb(A, Value);
end;

function BigNumberFromDblIntLimbStub(var A: IBigNumber; Value: TDblIntLimb): TF_RESULT; stdcall;
begin
  LoadNumerics(LibName);
  Result:= BigNumberFromDblIntLimb(A, Value);
end;

function BigNumberFromPCharStub(var A: IBigNumber; P: PByte; L: Integer;
           CharSize: Integer; AllowNegative: Boolean; TwoCompl: Boolean): TF_RESULT; stdcall;
begin
  LoadNumerics(LibName);
  Result:= BigNumberFromPCharStub(A, P, L, CharSize, AllowNegative, TwoCompl);
end;

function BigNumberFromPByteStub(var A: IBigNumber;
           P: PByte; L: Cardinal; AllowNegative: Boolean): TF_RESULT; stdcall;
begin
  LoadNumerics(LibName);
  Result:= BigNumberFromPByteStub(A, P, L, AllowNegative);
end;

//var
//  LibHandle: THandle = 0;

{
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
}
initialization
//  LoadLib;
  @BigNumberFromLimb:= @BigNumberFromLimbStub;
  @BigNumberFromDblLimb:= @BigNumberFromDblLimbStub;
  @BigNumberFromIntLimb:= @BigNumberFromIntLimbStub;
  @BigNumberFromDblIntLimb:= @BigNumberFromDblIntLimbStub;
  @BigNumberFromPChar:= @BigNumberFromPCharStub;
  @BigNumberFromPByte:= @BigNumberFromPByteStub;
end.
