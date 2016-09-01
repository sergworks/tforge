unit Demos;

interface

uses SysUtils, Classes, tfTypes, tfBytes, tfCiphers, EncryptedStreams;

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
  StreamCipher: TStreamCipher;

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
  StreamCipher: TStreamCipher;

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

end.
