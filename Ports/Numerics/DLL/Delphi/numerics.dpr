library numerics;

{$DEFINE TFL_DLL}

{$I TFL.inc}

uses
  tfLimbs in '..\..\..\..\Source\Shared\Units\Shared\tfLimbs.pas',
  tfTypes in '..\..\..\..\Source\Shared\Units\Shared\tfTypes.pas',
  tfRecords in '..\..\..\..\Source\Shared\Units\Engine\tfRecords.pas',
  arrProcs in '..\..\..\..\Source\Numerics\Units\Engine\arrProcs.pas',
  tfNumbers in '..\..\..\..\Source\Numerics\Units\Engine\tfNumbers.pas';

exports
  BigNumberFromLimb,
  BigNumberFromIntLimb,
  BigNumberFromDblLimb,
  BigNumberFromDblIntLimb,
  BigNumberFromPChar,
  BigNumberFromPByte;

{$R *.res}

{$LIBSUFFIX '32'}

begin
end.
