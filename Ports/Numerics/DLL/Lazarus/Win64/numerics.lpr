library numerics;

{$I TFL.inc}

uses tfLimbs, tfTypes, tfUtils, tfRecords, arrProcs, tfNumbers, tfNumVer;

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

begin
end.
