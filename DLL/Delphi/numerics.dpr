library numerics;

{$DEFINE TFL_DLL}

{$I TFL.inc}

uses
  tfLimbs in '..\..\Source\Common\tfLimbs.pas',
  tfTypes in '..\..\Source\Common\tfTypes.pas',
  arrProcs in '..\..\Source\Engine\arrProcs.pas',
  tfNumbers in '..\..\Source\Engine\tfNumbers.pas';

exports
  BigNumberFromLimb,
  BigNumberFromIntLimb,
  BigNumberFromPWideChar,
  BigNumberFromPByte;

{$R *.res}

begin
end.
