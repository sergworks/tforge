unit StreamCipherEx;

interface

uses
  SysUtils, Classes, tfTypes, tfBytes, tfCiphers;

procedure StreamCipherExamples;

implementation

procedure ApplyExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';

var
  Key: ByteArray;
  PlainText, PlainText2: ByteArray;
  CipherText, CipherText2: ByteArray;

begin
// 16-byte key;
  Key:= ByteArray.ParseHex(HexKey);
  PlainText:= ByteArray.FromText('The quick brown fox jumps over the lazy dog');
  Writeln('PlainText: ', PlainText.ToHex);

// encrypt using TStreamCipher
  CipherText:= PlainText.Copy();
  TStreamCipher.AES.ExpandKey(Key).Apply(CipherText.RawData^, CipherText.Len);
  Writeln('CipherText: ', CipherText.ToHex);

// encrypt using TCipher
  CipherText2:= TCipher.AES.ExpandKey(Key, CTR_ENCRYPT).EncryptByteArray(PlainText);
  Writeln('CipherText: ', CipherText2.ToHex);

  Assert(CipherText = CipherText2);

// decrypt
  PlainText2:= CipherText.Copy();
  TStreamCipher.AES.ExpandKey(Key).Apply(PlainText2.RawData^, PlainText2.Len);
  Writeln('PlainText: ', PlainText2.ToHex);

  Assert(PlainText = PlainText2);
end;

procedure ApplyToByteArrayExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';

var
  Key: ByteArray;
  PlainText, PlainText2: ByteArray;
  CipherText, CipherText2: ByteArray;

begin
// 16-byte key;
  Key:= ByteArray.ParseHex(HexKey);
  PlainText:= ByteArray.FromText('The quick brown fox jumps over the lazy dog');
  Writeln('PlainText: ', PlainText.ToHex);

// encrypt using TStreamCipher
  CipherText:= TStreamCipher.AES.ExpandKey(Key).ApplyToByteArray(PlainText);
  Writeln('CipherText: ', CipherText.ToHex);

// encrypt using TCipher
  CipherText2:= TCipher.AES.ExpandKey(Key, CTR_ENCRYPT).EncryptByteArray(PlainText);
  Writeln('CipherText: ', CipherText2.ToHex);

  Assert(CipherText = CipherText2);

// decrypt
  PlainText2:= TStreamCipher.AES.ExpandKey(Key).ApplyToByteArray(CipherText);
  Writeln('PlainText: ', PlainText2.ToHex);

  Assert(PlainText = PlainText2);
end;

procedure ApplyToFileExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  FileName: string;
  Key: ByteArray;

begin
  FileName:= ParamStr(0);
  Key:= ByteArray.ParseHex(HexKey);
// encryption
  TStreamCipher.AES.ExpandKey(Key, Nonce)
               .ApplyToFile(FileName, 'ApplyToFileExample.aes');
// decryption
  TStreamCipher.AES.ExpandKey(Key, Nonce)
               .ApplyToFile('ApplyToFileExample.aes', 'ApplyToFileExample.bak');

// same using TCipher
  TCipher.AES.ExpandKey(Key, CTR_ENCRYPT, Nonce)
             .EncryptFile(FileName, 'ApplyToFileExample1.aes');
  TCipher.AES.ExpandKey(Key, CTR_DECRYPT, Nonce)
             .DecryptFile('ApplyToFileExample1.aes', 'ApplyToFileExample1.bak');
end;

procedure ApplyToStreamExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  FileName: string;
  InStream, OutStream: TStream;
  Key: ByteArray;

begin
  FileName:= ParamStr(0);
  Key:= ByteArray.ParseHex(HexKey);

// encryption
  InStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create('ApplyToStreamExample.aes', fmCreate);
    try
      TStreamCipher.AES.ExpandKey(Key, Nonce)
                   .ApplyToStream(InStream, OutStream);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;

// decryption
  InStream:= TFileStream.Create('ApplyToStreamExample.aes', fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create('ApplyToStreamExample.bak', fmCreate);
    try
      TStreamCipher.AES.ExpandKey(Key, Nonce)
                   .ApplyToStream(InStream, OutStream);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;
end;

procedure BurnExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  StreamCipher: TStreamCipher;

begin
  StreamCipher:= TStreamCipher.AES.ExpandKey(ByteArray.ParseHex(HexKey), Nonce);
  try
// print 22 bytes of the keystream
    Writeln(StreamCipher.KeyStream(22).ToHex);
  finally
// erase key data from StreamCipher instance
    StreamCipher.Burn;
  end;
end;

procedure StreamCipherExamples;
begin
  ApplyExample;
  ApplyToByteArrayExample;
  ApplyToFileExample;
  ApplyToStreamExample;
  BurnExample;
end;

end.
