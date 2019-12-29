program ThreadDemo;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  tfTypes,
  tfBytes,
  tfCiphers,
  CipherThreads in '..\Source\CipherThreads.pas';

procedure TestCipher(Cipher: TCipher);
const
  DATA_SIZE = 1024 * 1024;
  NThreads = 4;

type
  PData = ^TData;
  TData = array[0 .. DATA_SIZE - 1] of LongWord;

var
  Data: PData;

var
  I: Integer;
  DataSize: Cardinal;
  BlockSize: Cardinal;
  Origin: PByte;
  Chunk, Size: Cardinal;
  Events: array[0 .. NThreads - 1] of THandle;

begin
  GetMem(Data, SizeOf(TData));
  try
// fill the data with some known values
    for I:= 0 to DATA_SIZE - 1 do
      Data[I]:= I;
    BlockSize:= Cipher.BlockSize;
    Origin:= PByte(Data);
    Chunk:= SizeOf(TData) div (NThreads * BlockSize);

// encrypt the data using multiple threads
    for I:= 0 to NThreads - 1 do begin
      if I = NThreads - 1 then
        Size:= SizeOf(TData) - (NThreads - 1) * Chunk * BlockSize
      else
        Size:= Chunk * BlockSize;
      Events[I]:= CreateEvent(nil, False, False, nil);
      TCipherThread.Create(Cipher.Copy.Skip(Chunk * LongWord(I)),
        Origin, Size, I = NThreads - 1, Events[I]);
      Inc(Origin, Chunk * BlockSize);
    end;

    try
      WaitForMultipleObjects(NThreads, @Events, True, INFINITE);
    finally
      for I:= 0 to NThreads - 1 do
        CloseHandle(Events[I]);
    end;

// check the result by decryption
    DataSize:= SizeOf(TData);
    Cipher.KeyCrypt(Data^, DataSize, True);
    for I:= 0 to DATA_SIZE - 1 do
      if Data[I] <> LongWord(I) then
        raise Exception.Create('!! Error -- decryption failed');

  finally
    FreeMem(Data);
  end;
end;

const
  HexKey = '2BD6459F82C5B300952C49104881FF48';
  HexIV  = '6B1E2FFFE8A114009D8FE22F6DB5F876';

begin
  try
    Writeln('=== Running AES Test ..');
    TestCipher(TCipher.AES.ExpandKey(ByteArray.ParseHex(HexKey),
                                     CTR_ENCRYPT or PADDING_NONE,
                                     ByteArray.ParseHex(HexIV))
               );

    Writeln('=== Running Salsa20 Test ..');
    TestCipher(TCipher.Salsa20
                      .SetNonce($123456789ABCDEF0)
                      .ExpandKey(ByteArray.ParseHex(HexKey))
               );
    Writeln('=== Done ! ===');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
