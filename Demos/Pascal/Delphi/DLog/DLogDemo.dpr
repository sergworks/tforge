program DLogDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  tfNumerics,
  UseDict in 'UseDict.pas',
  UseList in 'UseList.pas';

const
  ModuloStr = '134078079299425970995740249982058461274793658205923933' +
              '77723561443721764030073546976801874298166903427690031' +
              '858186486050853753882811946569946433649006084171';

  BaseStr =   '11717829880366207009516117596335367088558084999998952205' +
              '59997945906392949973658374667057217647146031292859482967' +
              '5428279466566527115212748467589894601965568';

  ValueStr =  '323947510405045044356526437872806578864909752095244' +
              '952783479245297198197614329255807385693795855318053' +
              '2878928001494706097394108577585732452307673444020333';

procedure Solve;
var
  SaveTime: TDateTime;
  Value, Base, Modulo: BigInteger;
  DL: Int64;
  TimeElapsed: Integer;

begin
// 375374217830
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
end;

begin
//  ReportMemoryLeaksOnShutdown:= True;
  try
    Solve;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
