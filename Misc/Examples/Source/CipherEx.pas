unit CipherEx;

interface

uses
  SysUtils, Classes, tfTypes, tfBytes, tfCiphers, tfHashes;

procedure CipherExamples;

implementation

procedure CopyExample;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  PlainText1, PlainText2: ByteArray;
  CipherText1, CipherText21, CipherText22: ByteArray;
  AES1, AES2: TCipher;

begin
// allocate 2 chunks of random data
  PlainText1:= ByteArray.AllocateRand(16);
  PlainText2:= ByteArray.AllocateRand(16);
  Writeln('PlainText1: ', PlainText1.ToHex);
  Writeln('PlainText2: ', PlainText2.ToHex);

// encrypt the 1st plaintext
  AES1:= TCipher.AES(CTR_ENCRYPT).ExpandKey(ByteArray.ParseHex(HexKey), Nonce);
  CipherText1:= AES1.EncryptByteArray(PlainText1);
  Writeln('CipherText1: ', CipherText1.ToHex);

// duplicate TCipher instance
  AES2:= AES1.Clone();

// encrypt the 2nd plaintext using the 1st instance
  CipherText21:= AES1.EncryptByteArray(PlainText2);
  Writeln('CipherText2: ', CipherText21.ToHex);

// encrypt the 2nd plaintext using the 2nd instance
  CipherText22:= AES2.EncryptByteArray(PlainText2);
  Writeln('CipherText2: ', CipherText22.ToHex);

  Assert(CipherText22 = CipherText21);
end;

procedure DecryptExample;
// TCipher.Decrypt is a low-level function
//   used internally by TCipher.DecryptXXX functions;
// the example shows how TCipher.Decrypt works
const
  BufSize = 1024;
  PlainTextSize = 4000;
  Nonce = 42;

var
  Buffer: array[0..BufSize - 1] of Byte;
  Key: ByteArray;
  PlainText, DecryptedText: ByteArray;
  CipherText: ByteArray;
  Cipher: TCipher;
  P: PByte;
  L, Count: Cardinal;
  Last: Boolean;

begin
// generate 16-byte AES key
  Key:= ByteArray.AllocateRand(16);

// generate random plaintext
  PlainText:= ByteArray.AllocateRand(PlainTextSize);

// encrypt using TCipher.EncryptByteArray
  CipherText:= TCipher.AES(CBC_ENCRYPT).ExpandKey(Key, Nonce)
                          .EncryptByteArray(PlainText);

// decrypt by BufSize chuncks using TCipher.Decrypt
  P:= CipherText.RawData;
  L:= CipherText.Len;
  Cipher:= TCipher.AES(CBC_DECRYPT).ExpandKey(Key, Nonce);
// required to correctly process the last padded block
  Assert(BufSize mod Cipher.GetBlockSize = 0);

  while L > 0 do begin
    Last:= L <= BufSize;
    if Last then Count:= L
    else Count:= BufSize;
    Move(P^, Buffer, Count);
    Inc(P, Count);
    Dec(L, Count);
    Cipher.Decrypt(Buffer, Count, Last);    // can modify Count
    if DecryptedText.IsAssigned then
      DecryptedText:= DecryptedText + ByteArray.FromMem(@Buffer, Count)
    else
      DecryptedText:= ByteArray.FromMem(@Buffer, Count);
  end;
  Writeln('Plain:     ', THash.SHA1.UpdateByteArray(PlainText).Digest.ToHex);
  Writeln('Decrypted: ', THash.SHA1.UpdateByteArray(DecryptedText).Digest.ToHex);
  Assert(PlainText = DecryptedText);
end;

procedure DecryptBlockExample;
const
  AESBlockSize = 16;

var
  Key: ByteArray;
  PlainText, DecryptedText: ByteArray;
  CipherText: ByteArray;

begin
// generate 16-byte AES key
  Key:= ByteArray.AllocateRand(16);

// generate block of plaintext
  PlainText:= ByteArray.AllocateRand(AESBlockSize);

// encrypt block
  CipherText:= TCipher.EncryptBlock(ALG_AES, PlainText, Key);

// decrypt block
  DecryptedText:= TCipher.DecryptBlock(ALG_AES, CipherText, Key);

  Assert(PlainText = DecryptedText);
end;

procedure DecryptByteArrayExample;
const
  Nonce = 42;

var
  Key: ByteArray;
  PlainText, DecryptedText: ByteArray;
  CipherText: ByteArray;

begin
// generate 16-byte AES key
  Key:= ByteArray.AllocateRand(16);

// generate 20-byte plaintext
  PlainText:= ByteArray.AllocateRand(20);

// encrypt plaintext
  CipherText:= TCipher.AES(CBC_ENCRYPT).ExpandKey(Key, Nonce)
                          .EncryptByteArray(PlainText);

// decrypt ciphertext
  DecryptedText:= TCipher.AES(CBC_DECRYPT).ExpandKey(Key, Nonce)
                             .DecryptByteArray(CipherText);

// Check encryption/decryption is correct:
  Assert(PlainText = DecryptedText);
end;

procedure DecryptStreamExample;
const
  Nonce = 42;

var
  FileName: string;
  InStream, OutStream: TStream;
  Key: ByteArray;
  Digest1, Digest2: ByteArray;

begin
  FileName:= ParamStr(0);

// generate random key
  Key:= ByteArray.AllocateRand(16);

// encryption
  InStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create('Encrypted.aes', fmCreate);
    try
      TCipher.AES(CBC_ENCRYPT).ExpandKey(Key, Nonce)
                 .EncryptStream(InStream, OutStream);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;

// decryption
  InStream:= TFileStream.Create('Encrypted.aes', fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create('Decrypted.aes', fmCreate);
    try
      TCipher.AES(CBC_DECRYPT).ExpandKey(Key, Nonce)
                 .DecryptStream(InStream, OutStream);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;

// Check encryption/decryption is correct:
  Digest1:= THash.SHA256.UpdateFile(FileName).Digest;
  Digest2:= THash.SHA256.UpdateFile('Decrypted.aes').Digest;
  Assert(Digest1 = Digest2);
end;

procedure DecryptFileExample;
const
  Nonce = 42;

var
  FileName: string;
  Key: ByteArray;
  Digest1, Digest2: ByteArray;

begin
  FileName:= ParamStr(0);

// generate random key
  Key:= ByteArray.AllocateRand(16);

// encryption
  TCipher.AES(CBC_ENCRYPT).ExpandKey(Key, Nonce)
             .EncryptFile(FileName, 'Encrypted.aes');

// decryption
  TCipher.AES(CBC_DECRYPT).ExpandKey(Key, Nonce)
             .DecryptFile('Encrypted.aes', 'Decrypted.aes');

// Check encryption/decryption is correct:
  Digest1:= THash.SHA256.UpdateFile(FileName).Digest;
  Digest2:= THash.SHA256.UpdateFile('Decrypted.aes').Digest;
  Assert(Digest1 = Digest2);
end;

procedure EncryptExample;
// TCipher.Encrypt is a low-level function
//   used internally by TCipher.EncryptXXX functions;
// the example shows how TCipher.Encrypt works
const
  BufSize = 1024;
  PlainTextSize = 4000;
  Nonce = 42;

var
  Buffer: array[0..BufSize - 1 + TF_MAX_CIPHER_BLOCK_SIZE] of Byte;
  Key: ByteArray;
  PlainText, EncryptedText: ByteArray;
  CipherText: ByteArray;
  Cipher: TCipher;
  P: PByte;
  L, Count: Cardinal;
  Last: Boolean;

begin
// generate 16-byte AES key
  Key:= ByteArray.AllocateRand(16);

// generate random plaintext
  PlainText:= ByteArray.AllocateRand(PlainTextSize);

// encrypt by BufSize chuncks using TCipher.Encrypt
  P:= PlainText.RawData;
  L:= PlainText.Len;
  Cipher:= TCipher.AES(CBC_ENCRYPT).ExpandKey(Key, Nonce);

  while L > 0 do begin
    Last:= L <= BufSize;
    if Last then Count:= L
    else Count:= BufSize;
    Move(P^, Buffer, Count);
    Inc(P, Count);
    Dec(L, Count);
    Cipher.Encrypt(Buffer, Count, SizeOf(Buffer), Last);    // can modify Count
    if EncryptedText.IsAssigned then
      EncryptedText:= EncryptedText + ByteArray.FromMem(@Buffer, Count)
    else
      EncryptedText:= ByteArray.FromMem(@Buffer, Count);
  end;
  Writeln('Plain:        ', THash.SHA1.UpdateByteArray(PlainText).Digest.ToHex);
  Writeln('Encrypted 1 : ', THash.SHA1.UpdateByteArray(EncryptedText).Digest.ToHex);

// Encrypt using TCipher.EncryptByteArray
  CipherText:= TCipher.AES(CBC_ENCRYPT).ExpandKey(Key, Nonce)
                          .EncryptByteArray(PlainText);

  Writeln('Encrypted 2 : ', THash.SHA1.UpdateByteArray(CipherText).Digest.ToHex);

  Assert(CipherText = EncryptedText);

end;

procedure CipherExamples;
begin
  CopyExample;
  DecryptExample;
  DecryptBlockExample;
  DecryptByteArrayExample;
  DecryptStreamExample;
  DecryptFileExample;
  EncryptExample;
end;

end.
