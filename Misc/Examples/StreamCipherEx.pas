unit StreamCipherEx;

interface

uses
  SysUtils, Classes, tfTypes, tfBytes, tfCiphers, tfHashes;

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

procedure ApplyToExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';

var
  Key: ByteArray;
  PlainText, PlainText2: ByteArray;
  CipherText, CipherText2: ByteArray;
  L: Integer;

begin
// 16-byte key;
  Key:= ByteArray.ParseHex(HexKey);
  PlainText:= ByteArray.FromText('The quick brown fox jumps over the lazy dog');
  Writeln('PlainText: ', PlainText.ToHex);

// encrypt using TStreamCipher
  L:= PlainText.Len;
  CipherText:= ByteArray.Allocate(L);
  TStreamCipher.AES.ExpandKey(Key)
               .ApplyTo(PlainText.RawData^, CipherText.RawData^, L);
  Writeln('CipherText: ', CipherText.ToHex);

// encrypt using TCipher
  CipherText2:= TCipher.AES.ExpandKey(Key, CTR_ENCRYPT).EncryptByteArray(PlainText);
  Assert(CipherText = CipherText2);

// decrypt
  PlainText2:= ByteArray.Allocate(L);
  TStreamCipher.AES.ExpandKey(Key)
               .ApplyTo(CipherText.RawData^, PlainText2.RawData^, L);
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
  FileName, NameAES, NameBAK: string;
  Key: ByteArray;
  FileDigest, DigestAES: ByteArray;

begin
  FileName:= ParamStr(0);
  NameAES:= FileName + '.aes';
  NameBAK:= FileName + '.bak';
  Key:= ByteArray.ParseHex(HexKey);
  FileDigest:= THash.SHA256.UpdateFile(FileName).Digest;
  Writeln('SHA256(', FileName, '): ', FileDigest.ToHex);

// encryption
  TStreamCipher.AES.ExpandKey(Key, Nonce).ApplyToFile(FileName, NameAES);

// decryption
  TStreamCipher.AES.ExpandKey(Key, Nonce).ApplyToFile(NameAES, NameBAK);

  DigestAES:= THash.SHA256.UpdateFile(NameAES).Digest;
  Writeln('SHA256(', NameAES, '): ', DigestAES.ToHex);
  Assert(THash.SHA256.UpdateFile(NameBAK).Digest = FileDigest);

// same using TCipher
  TCipher.AES.ExpandKey(Key, CTR_ENCRYPT, Nonce).EncryptFile(FileName, NameAES);
  TCipher.AES.ExpandKey(Key, CTR_DECRYPT, Nonce).DecryptFile(NameAES, NameBAK);

  Assert(THash.SHA256.UpdateFile(NameAES).Digest = DigestAES);
  Assert(THash.SHA256.UpdateFile(NameBAK).Digest = FileDigest);
  Writeln;
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

procedure CopyExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  PlainText1, PlainText2: ByteArray;
  CipherText1, CipherText2: ByteArray;
  AES1, AES2: TStreamCipher;

begin
// allocate 2 chunks of random data
  PlainText1:= ByteArray.AllocateRand(20);
  PlainText2:= ByteArray.AllocateRand(20);
  Writeln('PlainText1: ', PlainText1.ToHex);
  Writeln('PlainText2: ', PlainText2.ToHex);

// encrypt the 1st chunk
  AES1:= TStreamCipher.AES.ExpandKey(ByteArray.ParseHex(HexKey), Nonce);
  CipherText1:= AES1.ApplyToByteArray(PlainText1);
  Writeln('CipherText1: ', CipherText1.ToHex);

// duplicate TStreamCipher instance
  AES2:= AES1.Copy();

// encrypt the 2nd chunk using the 1st instance
  CipherText2:= AES1.ApplyToByteArray(PlainText2);
  Writeln('CipherText2: ', CipherText2.ToHex);

// encrypt the 2nd chunk using the 2nd instance
  Assert(AES2.ApplyToByteArray(PlainText2) = CipherText2);
end;

procedure KeyStreamExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  KeyStream1, KeyStream2: ByteArray;
  Key: ByteArray;


begin
  Writeln;
  Writeln('=== TStreamCipher.KeyStream example ===');
  Key:= ByteArray.ParseHex(HexKey);

// generate 20 bytes of keystream using TStreamCipher instance
  KeyStream1:= TStreamCipher.AES.ExpandKey(Key, Nonce)
                            .KeyStream(20);
// generate 20 bytes of keystream using TCipher instance
  KeyStream2:= TCipher.AES.ExpandKey(Key, CTR_ENCRYPT, Nonce)
                          .KeyStream(20);
  Writeln('KeyStream: ', KeyStream1.ToHex);
  Assert(KeyStream1 = KeyStream2);
end;

procedure GetKeyStreamExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  I: Integer;
  Buffer1, Buffer2: array[0..19] of Byte;
  Key: ByteArray;


begin
  Writeln;
  Writeln('=== TStreamCipher.GetKeyStream example ===');
  Key:= ByteArray.ParseHex(HexKey);

// generate 20 bytes of keystream using TStreamCipher instance
  TStreamCipher.AES.ExpandKey(Key, Nonce)
               .GetKeyStream(Buffer1, SizeOf(Buffer1));

// generate 20 bytes of keystream using TCipher instance
  TCipher.AES.ExpandKey(Key, CTR_ENCRYPT, Nonce)
             .GetKeyStream(Buffer2, SizeOf(Buffer2));
  for I:= 0 to SizeOf(Buffer1) - 1 do
    Assert(Buffer1[I] = Buffer2[I]);
end;

procedure StreamCipherExamples;
begin
  ApplyExample;
  ApplyToExample;
  ApplyToByteArrayExample;
  ApplyToFileExample;
  ApplyToStreamExample;
  BurnExample;
  CopyExample;
  KeyStreamExample;
  GetKeyStreamExample;
end;

end.
