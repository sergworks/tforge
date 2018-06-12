unit Demos;

interface

uses SysUtils, Classes, tfTypes, tfBytes, tfHashes, tfCiphers, EncryptedStreams;

procedure TestAll;

implementation

// Encrypts file using TCipher
procedure EncryptAES1(const FileName: string; const Key: ByteArray; Nonce: UInt64);
var
  InStream, OutStream: TStream;

begin
  InStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create(FileName + '1.aes', fmCreate);
    try
      OutStream.WriteBuffer(Nonce, SizeOf(Nonce));
      TCipher.AES.ExpandKey(Key, CTR_ENCRYPT, Nonce)
                 .EncryptStream(InStream, OutStream);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;
end;

// Encrypts file using TStreamCipher
procedure EncryptAES2(const FileName: string; const Key: ByteArray; Nonce: UInt64);
var
  InStream, OutStream: TStream;
//  StreamCipher: TStreamCipher;

begin
  InStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create(FileName + '2.aes', fmCreate);
    try
      OutStream.WriteBuffer(Nonce, SizeOf(Nonce));
      TStreamCipher.AES.ExpandKey(Key, Nonce)
                   .ApplyToStream(InStream, OutStream);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;
end;

// Encrypts file using TEncryptedStream
procedure EncryptAES3(const FileName: string; const Key: ByteArray; Nonce: UInt64);
var
  InStream, OutStream: TStream;
//  StreamCipher: TStreamCipher;

begin
  InStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TEncryptedFileStream.Create(FileName + '3.aes', fmCreate,
                                     TStreamCipher.AES.ExpandKey(Key, Nonce));
    try
      OutStream.CopyFrom(InStream, 0);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;
end;

// Check all 3 encrypted files are identical
procedure CheckEncrypted(const FileName: string);
var
  Digest1, Digest2, Digest3: ByteArray;

begin
  Digest1:= THash.SHA256.UpdateFile(FileName+'1.aes').Digest;
  Digest2:= THash.SHA256.UpdateFile(FileName+'2.aes').Digest;
  Digest3:= THash.SHA256.UpdateFile(FileName+'3.aes').Digest;
  Assert(Digest1 = Digest2);
  Assert(Digest1 = Digest3);
end;

procedure TestRead(const FileName: string; const Key: ByteArray; Nonce: UInt64);
const
  BUF_SIZE = 999;

var
  Stream1, Stream2: TStream;
  Buffer1, Buffer2: array[0..BUF_SIZE-1] of Byte;
  I: Integer;

begin
  Stream1:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Stream2:= TEncryptedFileStream.Create(FileName + '3.aes',
                                          fmOpenRead or fmShareDenyWrite,
                                          TStreamCipher.AES.ExpandKey(Key, Nonce));
    try
      Stream1.ReadBuffer(Buffer1, BUF_SIZE);
      Stream2.ReadBuffer(Buffer2, BUF_SIZE);
      Assert(CompareMem(@Buffer1, @Buffer2, BUF_SIZE));

      Stream1.Position:= 333;
      Stream2.Position:= 333;
      Stream1.ReadBuffer(Buffer1, BUF_SIZE);
      Stream2.ReadBuffer(Buffer2, BUF_SIZE);
      Assert(CompareMem(@Buffer1, @Buffer2, BUF_SIZE));

      Stream1.Position:= 4000;
      Stream2.Position:= 4000;
      Stream1.ReadBuffer(Buffer1, BUF_SIZE);
      Stream2.ReadBuffer(Buffer2, BUF_SIZE);
      Assert(CompareMem(@Buffer1, @Buffer2, BUF_SIZE));

      Stream1.Position:= 4000 - BUF_SIZE;
      Stream2.Position:= 4000 - BUF_SIZE;
      Stream1.ReadBuffer(Buffer1, BUF_SIZE);
      Stream2.ReadBuffer(Buffer2, BUF_SIZE);
      Assert(CompareMem(@Buffer1, @Buffer2, BUF_SIZE));

    finally
      Stream2.Free;
    end;
  finally
    Stream1.Free;
  end;
end;

procedure TestAll;
const
  HexKey = '000102030405060708090A0B0C0D0E0F';
  Nonce = 42;

var
  Name: string;
  Key: ByteArray;

begin
  Name:= ParamStr(0);
  Key:= ByteArray.ParseHex(HexKey);
  EncryptAES1(Name, Key, Nonce);
  EncryptAES2(Name, Key, Nonce);
  EncryptAES3(Name, Key, Nonce);
  CheckEncrypted(Name);
  TestRead(Name, Key, Nonce);
end;

end.
