program ChallengeKeys;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  KeyGens in '..\Source\KeyGens.pas',
  ChUtils in '..\Source\ChUtils.pas';

begin
  try
    TKeyGen.Execute('KeyTable.pas');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
