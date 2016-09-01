unit EncryptedStreams;

interface

uses SysUtils, Classes, tfCiphers;

type
  TEncryptedStream = class(TStream)
  protected
    FStream: TStream;
    FKeyStream: TStreamCipher;
    function NonceSize: Integer; virtual;
  public
    function Read(var Buffer; Count: Int32): Int32; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Write(const Buffer; Count: Int32): Int32; override;
  end;

  TEncryptedFileStream = class(TEncryptedStream)
  public
    constructor Create(const AFileName: string; Mode: Word; AStreamCipher: TStreamCipher);
    destructor Destroy; override;
  end;

implementation

{ TEncryptedStream }

function TEncryptedStream.NonceSize: Integer;
begin
  Result:= SizeOf(UInt64);
end;

function TEncryptedStream.Read(var Buffer; Count: Int32): Int32;
begin
  FStream.Read(Buffer, Count);
  FKeyStream.Apply(Buffer, Count);
end;

function TEncryptedStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  LSkip: Int64;
  OldPos: Int64;

begin
  OldPos:= FStream.Position;
  if Origin = soBeginning then
    Result:= FStream.Seek(Offset + NonceSize, soBeginning)
  else
    Result:= FStream.Seek(Offset, Origin);

  if Result < NonceSize then
    raise EStreamError.Create('Seek Error');

  Result:= Result - NonceSize;
  FKeyStream.Skip(Result - OldPos);
end;

function TEncryptedStream.Write(const Buffer; Count: Int32): Int32;
var
  Buf: Pointer;

begin
  if Count <= 0 then Exit;
  GetMem(Buf, Count);
  try
    Move(Buffer, Buf^, Count);
    FKeyStream.Apply(Buf^, Count);
    FStream.Write(Buf^, Count);
  finally
    FillChar(Buf^, Count, 0);
    FreeMem(Buf);
  end;
end;

{ TEncryptedFileStream }

constructor TEncryptedFileStream.Create(const AFileName: string; Mode: Word;
  AStreamCipher: TStreamCipher);
var
  LNonceSize: Integer;
  LNonce: UInt64;

begin
  FStream:= TFileStream.Create(AFileName, Mode);
  FKeyStream:= AStreamCipher;
  LNonceSize:= NonceSize;
  if LNonceSize > SizeOf(UInt64) then
    raise EStreamError.Create('Invalid Nonce Size');

  if (Mode and fmCreate) = fmCreate then begin
    LNonce:= FKeyStream.Nonce;
    FStream.WriteBuffer(LNonce, LNonceSize);
  end
  else begin
    LNonce:= 0;
    FStream.ReadBuffer(LNonce, LNonceSize);
    FKeyStream.Nonce:= LNonce;
  end;
end;

destructor TEncryptedFileStream.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

end.
