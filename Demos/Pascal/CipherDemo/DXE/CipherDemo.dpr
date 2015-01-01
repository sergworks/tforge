program CipherDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfTypes, tfBytes, tfCiphers;

const
  HexKey = '2BD6459F82C5B300952C49104881FF48';
  HexIV = '6B1E2FFFE8A114009D8FE22F6DB5F876';

  PlainText1 = 'EA024714AD5C4D84EA024714AD5C4D84';
  CipherText1 = '13C2C18F15299BC26AEDADD118AE537D';

  PlainText2 = 'E99388EED41AD8058D6162B0CF4667E6';
  CipherText2 = 'EA024714AD5C4D84EA024714AD5C4D84';

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

begin
  try
    ECBTest;
    CBCTest;
    CTRTest;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
