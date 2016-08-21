unit Demos;

interface

uses SysUtils, Classes, tfTypes, tfBytes, tfCiphers;

implementation

procedure EncryptAES(const FileName: string; const Key: ByteArray; Nonce: UInt64);
var
  InStream, OutStream: TStream;

begin
  InStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create(FileName + '.aes', fmCreate);
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

procedure EncryptAES2(const FileName: string; const Key: ByteArray; Nonce: UInt64);
var
  KeyStream: TKeyStream;

begin

end;

end.
