program SSLEncrypt;

{$APPTYPE CONSOLE}

uses
  SysUtils, tfBytes, tfWindows, tfOpenSSL, tfEngines;

procedure Test;
var
  Ctx: PEVP_CIPHER_CTX;
  Key, IV: ByteArray;
  Plaintext: ByteArray;
  Decryptedtext: ByteArray;
  OutBuf: array[0..1023] of Byte;
  OutPtr: PByte;
  OutBufLen: Integer;
  BufLen: Integer;
//  InBuf: array[0..1023] of Byte;
  InPtr: PByte;
  InBufLen: Integer;

begin
// create encryption key and IV
  Key:= ByteArray.FromText('01234567890123456789012345678901'); // 256 bits
  IV:= ByteArray.FromText('01234567890123456');  // 128 bits

// create encryption context
  Ctx:= EVP_CIPHER_CTX_new();
  if Ctx = nil then begin
    Writeln('EVP_CIPHER_CTX_new Error');
    Exit;
  end;

// initialize encryption context with AES cipher, 256 bit key and 128 bit IV
  if EVP_EncryptInit_ex(Ctx, EVP_aes_256_cbc(), nil, Key.RawData, IV.RawData) <> 1 then begin
    Writeln('EVP_EncryptInit_ex Error');
    Exit;
  end;

// create plaintext
  Plaintext:= ByteArray.FromText('The quick brown fox jumps over the lazy dog 123 456');

// encrypt plaintext
  OutBufLen:= SizeOf(OutBuf);
  OutPtr:= @OutBuf;
  if EVP_EncryptUpdate(Ctx, OutPtr, OutBufLen, PlainText.RawData, PlainText.Len) <> 1 then begin
    Writeln('EVP_EncryptUpdate Error');
    Exit;
  end;

  Writeln('Encrypted after Update: ', OutBufLen);

  Inc(OutPtr, OutBufLen);
  BufLen:= OutBufLen;
  OutBufLen:= SizeOf(OutBuf) - BufLen;
  if EVP_EncryptFinal_ex(Ctx, OutPtr, OutBufLen) <> 1 then begin
    Writeln('EVP_EncryptFinal_ex Error');
    Exit;
  end;

  Inc(BufLen, OutBufLen);
  Writeln('Encrypted after Final: ', BufLen);

// release encryption context
  EVP_CIPHER_CTX_free(Ctx);

// create decryption context
  Ctx:= EVP_CIPHER_CTX_new();
  if Ctx = nil then begin
    Writeln('EVP_CIPHER_CTX_new Error');
    Exit;
  end;

// initialize decryption context with AES cipher, 256 bit key and 128 bit IV
  if EVP_DecryptInit_ex(Ctx, EVP_aes_256_cbc(), nil, Key.RawData, IV.RawData) <> 1 then begin
    Writeln('EVP_EncryptInit_ex Error');
    Exit;
  end;

// decrypt ciphertext
  InBufLen:= BufLen;
  InPtr:= @OutBuf;
  OutPtr:= @OutBuf;
  OutBufLen:= SizeOf(OutBuf);
  if EVP_DecryptUpdate(Ctx, OutPtr, OutBufLen, InPtr, InBufLen) <> 1 then begin
    Writeln('EVP_DecryptUpdate Error');
    Exit;
  end;

  Writeln('Decrypted after Update: ', OutBufLen);

  Inc(OutPtr, OutBufLen);
  BufLen:= OutBufLen;
  OutBufLen:= SizeOf(OutBuf) - BufLen;
  if EVP_DecryptFinal_ex(Ctx, OutPtr, OutBufLen) <> 1 then begin
    Writeln('EVP_EncryptFinal_ex Error');
    Exit;
  end;

  Inc(BufLen, OutBufLen);
  Writeln('Decrypted after Final: ', BufLen);

// release encryption context
  EVP_CIPHER_CTX_free(Ctx);

  DecryptedText:= ByteArray.FromMem(@OutBuf, BufLen);
  Writeln(DecryptedText.ToString);
  Writeln(DecryptedText.ToText);
end;


begin
  try
    ReportMemoryLeaksOnShutdown:= True;
    LoadLibCrypto();
    Test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('Press Enter ... ');
  Readln;
end.
