program Challenge;

{$mode delphi}

uses
  SysUtils, ChUtils, KeyTable;

var
  Code: Integer;
  HashedKey: THashedKey;
  I: Integer;

begin
  try
    if ParamCount <> 1 then begin
      Writeln('Usage: >> ' + ExtractFileName(ParamStr(0)) +
                             '  XXXX-XXXX-XXXX-XXXX-XXXX');
      Code:= 3;
    end
    else begin
      Code:= 2;
      HashedKey:= TSerialKey.FromString(ParamStr(1)).ToHash;
      for I:= 0 to 99 do begin
        if CompareMem(@HashedKey, @HashedKeys[I], SizeOf(THashedKey)) then begin
          Writeln('Congratulations, valid serial number!');
          Code:= 0;
          Break;
        end;
      end;
      if Code <> 0 then
        Writeln('Sorry, wrong serial number');
    end;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
      Code:= 1;
    end;
  end;
  Write('Press <Enter> .. ');
  Readln;
  Halt(Code);
end.

