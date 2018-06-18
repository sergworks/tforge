program Check;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils, tfBytes, tfCiphers;

procedure Test;
var
  Key, Data: ByteArray;
  I: Integer;

begin
  Key:= ByteArray.Allocate(16);
  for I:= 0 to 15 do
    Key[I]:= I + 1;
  Data:= ByteArray.Allocate(16);
  for I:= 0 to 15 do
    Data[I]:= I + 16;
  Writeln(TCipher.DecryptBlock(ALG_AES, Data, Key).ToHex);
end;

begin
  try
    Test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
