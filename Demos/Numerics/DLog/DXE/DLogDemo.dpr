{
  Calculation of discrete logarithm by meet-in-the-middle attack
}

program DLogDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  tfNumerics,
  UseDict in '..\Source\UseDict.pas',
  UseList in '..\Source\UseList.pas',
  DLogData in '..\Source\DLogData.pas';

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

  Writeln('Using Hash Table...');
  SaveTime:= Now;
  DL:= UseDict.DLog(Value, Base, Modulo);
  TimeElapsed:= Round((Now - SaveTime) * 24 * 60 * 60 * 1000);
  Writeln('DLog = ', DL, ', Time: ', TimeElapsed, ' ms');

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
  ReportMemoryLeaksOnShutdown:= True;
  try
    Solve;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
