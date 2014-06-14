{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ *********************************************************** }

library numerics;

{$I TFL.inc}

uses
  tfLimbs in '..\..\..\..\Source\Shared\Units\Shared\tfLimbs.pas',
  tfTypes in '..\..\..\..\Source\Shared\Units\Shared\tfTypes.pas',
  tfRecords in '..\..\..\..\Source\Shared\Units\Engine\tfRecords.pas',
  arrProcs in '..\..\..\..\Source\Numerics\Units\Engine\arrProcs.pas',
  tfNumbers in '..\..\..\..\Source\Numerics\Units\Engine\tfNumbers.pas',
  tfNumVer in '..\..\..\..\Source\Numerics\Units\Shared\tfNumVer.pas',
  tfUtils in '..\..\..\..\Source\Shared\Units\Shared\tfUtils.pas';

function GetNumericsVersion(var Version: LongWord): TF_RESULT;
         {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
begin
  Version:= NumericsVersion;
  Result:= TF_S_OK;
end;

exports
  GetNumericsVersion,
  BigNumberFromLimb,
  BigNumberFromIntLimb,
  BigNumberFromDblLimb,
  BigNumberFromDblIntLimb,
  BigNumberFromPChar,
  BigNumberFromPByte,
  BigNumberAlloc;

{$R *.res}

{$LIBSUFFIX '32'}

begin
end.
