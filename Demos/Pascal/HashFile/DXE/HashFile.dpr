program HashFile;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  tfTypes,
  tfBytes,
  tfHashes;

procedure FluentCalcHash(const FileName: string);
begin
  Writeln('MD5:  ', THash.MD5.UpdateFile(FileName).Digest.ToHex);
  Writeln('SHA1: ', THash.SHA1.UpdateFile(FileName).Digest.ToHex);
  Writeln('CRC32: ', IntToHex(LongWord(THash.CRC32.UpdateFile(FileName).Digest), 8));
  Writeln('CRC32: ', THash.CRC32.UpdateFile(FileName).Digest.ToHex);
end;



procedure CalcHash(const FileName: string);
const
  BufSize = 16 * 1024;

var
  MD5, SHA1: THash;
  Stream: TStream;
  Buffer: array[0 .. BufSize - 1] of Byte;
  N: Integer;

begin
  MD5:= THash.MD5;
  SHA1:= THash.SHA1;
//  try
    Stream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      repeat
        N:= Stream.Read(Buffer, BufSize);
        if N <= 0 then Break
        else begin
          MD5.Update(Buffer, N);
          SHA1.Update(Buffer, N);
        end;
      until False;
    finally
      Stream.Free;
    end;
    Writeln('MD5:  ', MD5.Digest.ToHex);
    Writeln('SHA1: ', SHA1.Digest.ToHex);
//  finally
//    MD5.Burn;
//    SHA1.Burn;
//  end;
end;

procedure SHA1_HMAC_File(const FileName: string; const Key: ByteArray);
begin
  Writeln('SHA1-HMAC: ',
    THMAC.SHA1.ExpandKey(Key).UpdateFile(FileName).Digest.ToHex);
end;

procedure DeriveKeys(const Password, Salt: ByteArray);
begin
  Writeln('PBKDF1 Key: ',
    THash.SHA1.DeriveKey(Password, Salt,
                         10000,   // number of rounds
                         16       // key length in bytes
                         ).ToHex);
  Writeln('PBKDF2 Key: ',
    THMAC.SHA1.DeriveKey(Password, Salt,
                         10000,   // number of rounds
                         32       // key length in bytes
                         ).ToHex);
end;

begin
  ReportMemoryLeaksOnShutdown:= True;
  try
    if ParamCount = 1 then begin
//      FluentCalcHash(ParamStr(1));
      CalcHash(ParamStr(1));
      SHA1_HMAC_File(ParamStr(1), ByteArray.FromText('Secret Key'));
      DeriveKeys(ByteArray.FromText('User Password'),
                 ByteArray.FromText('Salt'));
    end
    else
      Writeln('Usage: > HashFile filename');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('Press <Enter> ..');
  Readln;
end.
