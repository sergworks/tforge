program CipherDemo;

{$mode delphi}

uses
  SysUtils, tfBytes, Demos;

begin
  try
    ECBTest;
    CBCTest;
    CTRTest;
    CBCDemo(ByteArray.ParseHex(PlainText1),
            ByteArray.ParseHex(HexIV),
            ByteArray.ParseHex(HexKey));
    CTRDemo(ByteArray.ParseHex(PlainText1),
            ByteArray.ParseHex(HexIV),
            ByteArray.ParseHex(HexKey));
    CBCFileDemo(ParamStr(0),
            ByteArray.ParseHex(HexIV),
            ByteArray.ParseHex(HexKey));
    CBCFileDemo2(ParamStr(0),
            ByteArray.ParseHex(HexIV),
            ByteArray.ParseHex(HexKey));
    BlockDemo(ByteArray.ParseHex(PlainText1).Copy(1, 8),
              ByteArray.ParseHex(HexKey).Copy(1, 8));
    RC5BlockDemo(ByteArray.ParseHex(PlainText1),
                 ByteArray.ParseHex(HexKey));
    RandDemo(ByteArray.ParseHex(HexKey));
    RC4FileDemo(ParamStr(0),
                ByteArray.ParseHex(HexKey));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln;
  Write('Press Enter ..');
  Readln;
end.

