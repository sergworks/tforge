program DLogDemo;

{$mode delphi}

uses
  SysUtils, tfNumerics,
  DLogData, UseList
  { you can add units after this };

procedure Solve;
var
  SaveTime: TDateTime;
  Value, Base, Modulo: BigInteger;
  DL: Int64;
  TimeElapsed: Integer;

begin
// 375374217830
  Writeln('Long calc (about 1 min), please wait...');

  Value:= BigInteger(ValueStr);
  Base:= BigInteger(BaseStr);
  Modulo:= BigInteger(ModuloStr);

// Hash Table (Generic Dict) is not implemented in FPC

  Writeln;
  Writeln('Using Sorted List...');
  SaveTime:= Now;
  DL:= UseList.DLog(Value, Base, Modulo);
  TimeElapsed:= Round((Now - SaveTime) * 24 * 60 * 60 * 1000);
  Writeln('DLog = ', DL, ', Time: ', TimeElapsed, ' ms');

  Writeln;
  Write('Done. Press <Enter> to exit...');
end;

begin
  try
    Solve;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

