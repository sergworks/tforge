program HashDemo;

{$mode delphi}

uses
  SysUtils, tfBytes, CalcDemos;

begin
  try
    if ParamCount = 1 then begin
      Writeln('File: ', ParamStr(1));
      Writeln;
//      FluentCalcHash(ParamStr(1));
      CalcHash(ParamStr(1));
      SHA1_HMAC_File(ParamStr(1), ByteArray.FromText('Secret Key'));
    end
    else begin
      Writeln('Usage: > HashDemo filename');
      Writeln('File: ', ExtractFileName(ParamStr(0)));
      Writeln;
      CalcHash(ParamStr(0));
      SHA1_HMAC_File(ParamStr(0), ByteArray.FromText('Secret Key'));
    end;
    DeriveKeys(ByteArray.FromText('User Password'),
               ByteArray.FromText('Salt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln;
  Write('Press <Enter> ..');
  Readln;
end.

