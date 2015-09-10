unit Demos;

{$ifdef fpc}
{$mode delphi}
{$endif}

interface

uses
  tfTypes,
  tfBytes,
  tfHashes,
  tfCiphers;

const
  HexKey = '2BD6459F82C5B300952C49104881FF48';
  HexIV = '6B1E2FFFE8A114009D8FE22F6DB5F876';

  PlainText1 = 'EA024714AD5C4D84EA024714AD5C4D84';
  CipherText1 = '13C2C18F15299BC26AEDADD118AE537D';

  PlainText2 = 'E99388EED41AD8058D6162B0CF4667E6';
  CipherText2 = 'EA024714AD5C4D84EA024714AD5C4D84';

procedure ECBTest;
procedure CBCTest;
procedure CTRTest;
procedure CBCDemo(const PlainText, IV, Key: ByteArray);
procedure CTRDemo(const PlainText, IV, Key: ByteArray);
procedure CBCFileDemo(const FileName: string; const IV, Key: ByteArray);
procedure CBCFileDemo2(const FileName: string; const IV, Key: ByteArray);
procedure BlockDemo(const Block, Key: ByteArray);
procedure RC5BlockDemo(const Block, Key: ByteArray);
procedure RandDemo(const Key: ByteArray);
procedure RC4FileDemo(const FileName: string; const Key: ByteArray);

implementation

procedure ECBTest;
var
  Key: ByteArray;
  PTextA, PTextB: ByteArray;
  CText: ByteArray;
  PText1, PText2: ByteArray;
  CText1, CText2: ByteArray;

begin
  Key:= ByteArray.ParseHex(HexKey);
  PTextA:= ByteArray.ParseHex(PlainText1 + PlainText2);

  Writeln('--- ECB mode test ---');
  Writeln(' Plaintext  : ', PTextA.ToHex);

  CText:= TCipher.AES.ExpandKey(Key, ECB_ENCRYPT).EncryptData(PTextA);
  Writeln(' Ciphertext : ', CText.ToHex);

  PTextB:= TCipher.AES.ExpandKey(Key, ECB_DECRYPT).DecryptData(CText);
  Writeln(' Decrypted  : ', PTextB.ToHex);

  Assert(PTextA = PTextB);

// 'manual' implementation of ECB encryption
  CText1:= TCipher.AES.EncryptBlock(ByteArray.ParseHex(PlainText1), Key);
  CText2:= TCipher.AES.EncryptBlock(ByteArray.ParseHex(PlainText2), Key);

  Assert(CText1 = ByteArray.ParseHex(CipherText1));
  Assert(CText2 = ByteArray.ParseHex(CipherText2));

// CText contains additional 3rd padding block,
//   we need only 2 first blocks to check
  Assert(CText.Copy(0, 32) = CText1 + CText2);

  PText1:= TCipher.AES.DecryptBlock(CText1, Key);
  PText2:= TCipher.AES.DecryptBlock(CText2, Key);

  Assert(PTextA = PText1 + PText2);
end;

procedure CBCTest;
var
  Key, IV: ByteArray;
  PTextA, PTextB: ByteArray;
  CText: ByteArray;
  PText1, PText2: ByteArray;
  CText1, CText2: ByteArray;

begin
  Key:= ByteArray.ParseHex(HexKey);
  IV:= ByteArray.ParseHex(HexIV);
  PTextA:= ByteArray.ParseHex(PlainText1 + PlainText2);

  CText:= TCipher.AES.ExpandKey(Key, CBC_ENCRYPT, IV).EncryptData(PTextA);
  PTextB:= TCipher.AES.ExpandKey(Key, CBC_DECRYPT, IV).DecryptData(CText);

  Writeln('--- CBC mode test ---');
  Writeln(' Plaintext  : ', PTextA.ToHex);
  Writeln(' Ciphertext : ', CText.ToHex);
  Writeln(' Decrypted  : ', PTextB.ToHex);

  Assert(PTextA = PTextB);

// 'manual' implementation of CBC encryption
  CText1:= TCipher.AES.EncryptBlock(ByteArray.ParseHex(PlainText1) xor IV, Key);
  CText2:= TCipher.AES.EncryptBlock(ByteArray.ParseHex(PlainText2) xor CText1, Key);

// CText contains additional 3rd padding block,
//   we need only 2 first blocks to check
  Assert(CText.Copy(0, 32) = CText1 + CText2);

  PText1:= TCipher.AES.DecryptBlock(CText1, Key) xor IV;
  PText2:= TCipher.AES.DecryptBlock(CText2, Key) xor CText1;

  Assert(PTextA = PText1 + PText2);
end;

procedure CTRTest;
var
  Key, IV, TmpIV: ByteArray;
  PTextA, PTextB: ByteArray;
  CText: ByteArray;
  PText1, PText2: ByteArray;
  CText1, CText2: ByteArray;

begin
  Key:= ByteArray.ParseHex(HexKey);
  IV:= ByteArray.ParseHex(HexIV);
  PTextA:= ByteArray.ParseHex(PlainText1 + PlainText2);

  CText:= TCipher.AES.ExpandKey(Key, CTR_ENCRYPT, IV).EncryptData(PTextA);
  PTextB:= TCipher.AES.ExpandKey(Key, CTR_DECRYPT, IV).DecryptData(CText);

  Writeln('--- CTR mode test ---');
  Writeln(' Plaintext  : ', PTextA.ToHex);
  Writeln(' Ciphertext : ', CText.ToHex);
  Writeln(' Decrypted  : ', PTextB.ToHex);

  Assert(PTextA = PTextB);

// 'manual' implementation of CTR encryption
  Writeln(' IV  : ', IV.ToHex);
  TmpIV:= IV.Copy();
  Writeln(' IV  : ', TmpIV.ToHex);

  CText1:= TCipher.AES.EncryptBlock(TmpIV, Key) xor ByteArray.ParseHex(PlainText1);
  TmpIV.Incr();
  Writeln(' IV  : ', TmpIV.ToHex);
  CText2:= TCipher.AES.EncryptBlock(TmpIV, Key) xor ByteArray.ParseHex(PlainText2);

  Writeln(' Ciphertext : ', (CText1 + CText2).ToHex);
  Assert(CText.Copy(0, 32) = CText1 + CText2);

  TmpIV:= IV.Copy();
  PText1:= TCipher.AES.EncryptBlock(TmpIV, Key) xor CText1;
  TmpIV.Incr();
  PText2:= TCipher.AES.EncryptBlock(TmpIV, Key) xor CText2;

  Writeln(' Plaintext  : ', (PText1 + PText2).ToHex);
  Assert(PTextA = PText1 + PText2);
end;

procedure CBCDemo(const PlainText, IV, Key: ByteArray);
var
  CipherText, Plaintext2: ByteArray;

begin
  Writeln;
  Writeln('-- Running CBCDemo --');
  Writeln('PlainText:  ', PlainText.ToHex);
  CipherText:= TCipher.AES.ExpandKey(Key, CBC_ENCRYPT, IV).EncryptData(PlainText);
  Writeln('CipherText: ', CipherText.ToHex);
  PlainText2:= TCipher.AES.ExpandKey(Key, CBC_DECRYPT, IV).DecryptData(CipherText);
  Writeln('PlainText:  ', PlainText2.ToHex);
  Assert(PlainText = PlainText2);
  Writeln('-- Done CBCDemo --');
end;

procedure CTRDemo(const PlainText, IV, Key: ByteArray);
var
  CipherText, Plaintext2: ByteArray;

begin
  Writeln;
  Writeln('-- Running CTRDemo --');
  Writeln('PlainText:  ', PlainText.ToHex);
  CipherText:= TCipher.AES.ExpandKey(Key, CTR_ENCRYPT, IV).EncryptData(PlainText);
  Writeln('CipherText: ', CipherText.ToHex);
  PlainText2:= TCipher.AES.ExpandKey(Key, CTR_DECRYPT, IV).DecryptData(CipherText);
  Writeln('PlainText:  ', PlainText2.ToHex);
  Assert(PlainText = PlainText2);
  Writeln('-- Done CTRDemo --');
end;

procedure CBCFileDemo(const FileName: string; const IV, Key: ByteArray);
begin
  Writeln;
  Writeln('-- Running CBCFileDemo --');
  TCipher.AES.ExpandKey(Key, CBC_ENCRYPT, IV)
             .EncryptFile(FileName, FileName + '.aes');
  TCipher.AES.ExpandKey(Key, CBC_DECRYPT, IV)
             .DecryptFile(FileName + '.aes', FileName + '.bak');
  Writeln('-- Done CBCFileDemo --');
end;

procedure CBCFileDemo2(const FileName: string; const IV, Key: ByteArray);
var
  Cipher: TCipher;

begin
  Writeln;
  Writeln('-- Running CBCFileDemo 2 --');
  Cipher:= TCipher.AES.ExpandKey(Key, CBC_ENCRYPT, IV);
  try
    Cipher.EncryptFile(FileName, FileName + '.aes');
  finally
    Cipher.Burn;
  end;
  Cipher:= TCipher.AES.ExpandKey(Key, CBC_DECRYPT, IV);
  try
    Cipher.DecryptFile(FileName + '.aes', FileName + '.bak');
  finally
    Cipher.Burn;
  end;
  Writeln('-- Done CBCFileDemo 2 --');
end;

procedure BlockDemo(const Block, Key: ByteArray);
var
  CipherText, PlainText: ByteArray;

begin
  Writeln;
  Writeln('-- Running BlockDemo --');
  Writeln('Block:     ', Block.ToHex);
  Writeln('Key:       ', Key.ToHex);
  CipherText:= TCipher.DES.EncryptBlock(Block, Key);
  Writeln('Encrypted: ', CipherText.ToHex);
  PlainText:= TCipher.DES.DecryptBlock(CipherText, Key);
  Writeln('Decrypted: ', PlainText.ToHex);
  Assert(PlainText = Block);
  Writeln('-- Done BlockDemo --');
end;

procedure RC5BlockDemo(const Block, Key: ByteArray);
var
  CipherText, PlainText: ByteArray;

begin
  Writeln;
  Writeln('-- Running RC5BlockDemo --');
  Writeln('Block:     ', Block.ToHex);
  Writeln('Key:       ', Key.ToHex);
  CipherText:= TCipher.RC5(Block.Len, 20).EncryptBlock(Block, Key);
  Writeln('Encrypted: ', CipherText.ToHex);
  PlainText:= TCipher.RC5(Block.Len, 20).DecryptBlock(CipherText, Key);
  Writeln('Decrypted: ', PlainText.ToHex);
  Assert(PlainText = Block);
  Writeln('-- Done RC5BlockDemo --');
end;

// Shows how to use AES as pseudorandom generator
procedure RandDemo(const Key: ByteArray);
var
  Cipher: TCipher;
  I: Integer;
  Rand: LongWord;

begin
  Writeln;
  Writeln('-- Running RandDemo --');
  Cipher:= TCipher.AES.ExpandKey(Key, CTR_ENCRYPT);
  for I:= 0 to 9 do begin
    Rand:= LongWord(Cipher.KeyStream(SizeOf(Rand)));
    Writeln(I:3, ': ', Rand);
  end;
  Writeln('-- Done RandDemo --');
end;

// discards the first 1536 bytes of RC4 keystream [RFC4345]
procedure RC4FileDemo(const FileName: string; const Key: ByteArray);
begin
  Writeln;
  Writeln('-- Running RC4FileDemo --');
  TCipher.RC4.ExpandKey(Key)
{$ifdef fpc}
             .Skip(LongWord(1536))
{$else}
             .Skip(1536)
{$endif}
             .EncryptFile(FileName, FileName + '.rc4');
  TCipher.RC4.ExpandKey(Key)
{$ifdef fpc}
             .Skip(LongWord(1536))
{$else}
             .Skip(1536)
{$endif}
             .DecryptFile(FileName + '.rc4', FileName + '.bak');
  Writeln('-- Done RC4FileDemo --');
end;

end.
