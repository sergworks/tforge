unit CipherTestClasses;

interface

uses
  Classes, SysUtils;

TBaseCipherTest = class(TTestObject)
private
  FAlgID: TAlgID;
  FKey: ByteArray;
  FPlainText: ByteArray;
  FCipherText: ByteArray;
public
  constructor Create(ALogger: TLogger; AAlgID: TAlgID; AName: string = '');
  property Key: ByteArray read FKey write FKey;
  property PlainText: ByteArray read FPlainText write FPlainText;
  property CipherText: ByteArray read FCipherText write FCipherText;
end;

TBaseModeCipherTest = class(TBaseCipherTest)
private
  FIV: ByteArray;
public
  property IV: ByteArray read FIV write FIV;
end;

TCipherTest = class(TBaseModeCipherTest)
public
  procedure Execute; override;
end;

TGCMModeCipherTest = class(TBaseModeCipherTest)
private
  FAuthData: ByteArray;
  FAuthTag: ByteArray;
public
  procedure Execute; override;
end;

TBlockCipherTest = class(TBaseCipherTest)
private
  FCount: Integer;
public
  procedure Execute; override;
  property Count: Integer read FCount write FCount;
end;

TBaseCipherRunner = class(TFileRunner)
private
  FAlgID: TAlgID;
protected
  property AlgID: TAlgID read FAlgID write FAlgID;
public
  procedure Run; override;
end;

TCipherRunner = class(TBaseCipherRunner)
private
  FKey: ByteArray;
  FIV: ByteArray;
  FPlainText: ByteArray;
  FCipherText: ByteArray;
protected
//    procedure GetIsValidLine(var IsValid: Boolean); override;
  function GetTest: TTestObject; override;
end;

TNessieBlockCipherRunner = class(TBaseCipherRunner)
private
  FState: Integer;
  FMaxState: Integer;
  FKey: ByteArray;
  FPlainText: ByteArray;
  FCipherText: ByteArray;
  FCipherText100: ByteArray;
  FCipherText1000: ByteArray;
protected
//    procedure GetIsValidLine(var IsValid: Boolean); override;
  function GetTest: TTestObject; override;
end;

TKeyStreamTest = class(TTestObject)
private
  FAlgID: TAlgID;
  FKey: ByteArray;
  FKeyStream: ByteArray;
  FActual: ByteArray;
  FPosition: Integer;
public
  constructor Create(ALogger: TLogger; AAlgID: TAlgID; AName: string = '');
  procedure Execute; override;
  property Key: ByteArray read FKey write FKey;
  property KeyStream: ByteArray read FKeyStream write FKeyStream;
  property Position: Integer read FPosition write FPosition;
end;

implementation

{ TBlockCipherTest }

procedure TBlockCipherTest.Execute;
var
  Cipher: TCipher;
  N: Integer;
  Block: ByteArray;
  BlockSize: Cardinal;

begin
  Logger.WriteLn('Key = ' + Key.ToHex, LOG_DETAILED);
  Logger.WriteLn('PlainText = ' + FPlainText.ToHex, LOG_DETAILED);
  if FCount <= 1 then
    Logger.WriteLn(Format('CipherText = %s', [FCipherText.ToHex]), LOG_DETAILED)
  else
    Logger.WriteLn(Format('CipherText%d = %s', [FCount, FCipherText.ToHex]), LOG_DETAILED);

  Cipher:= TCipher.GetInstance(FAlgID or ECB_ENCRYPT or PADDING_NONE);
  BlockSize:= Cipher.GetBlockSize;
  Check(BlockSize = Cardinal(PlainText.Len));
  Check(BlockSize = Cardinal(CipherText.Len));

// encryption
//  CheckOK(ICipher(Cipher).ExpandKeyIV(Key.RawData, Key.Len, nil, 0));
  Cipher.Init(Key);

  Block:= PlainText.Copy();

  N:= FCount;

//Logger.WriteLn('Block: ' + Block.ToHex);
//Logger.WriteLn('N: ' + IntToStr(N));
  repeat
//    ICipher(Cipher).EncryptBlock(Block.RawData);
//    Cipher.Encrypt(Block.RawData^, BlockSize, BlockSize, False);
    Cipher.EncryptUpdate(Block.RawData, Block.RawData, BlockSize, BlockSize, False);
    Dec(N);
  until N <= 0;

  CheckEquals(CipherText, Block);


// decryption
  Cipher:= TCipher.GetInstance(FAlgID or ECB_DECRYPT or PADDING_NONE);
//  CheckOK(ICipher(Cipher).ExpandKeyIV(Key.RawData, Key.Len, nil, 0));
  Cipher.Init(Key);

  N:= FCount;
  repeat
//    ICipher(Cipher).DecryptBlock(Block.RawData);
    Cipher.DecryptUpdate(Block.RawData, Block.RawData, BlockSize, BlockSize, False);
    Dec(N);
  until N <= 0;

  CheckEquals(PlainText, Block);
end;

{ TCipherRunner }

procedure TBaseCipherRunner.Run;
begin
  Logger.WriteLn;
  Logger.WriteLn('Running ' + FTestName, LOG_NORMAL);
  Logger.WriteLn('Test Vectors: ' + FFileName, LOG_NORMAL);
  Logger.WriteLn;

  inherited Run;

  Logger.WriteLn(FTestName + ' Statistics', LOG_NORMAL);
  LogCounts;
end;

{ TCipherRunner }

function TCipherRunner.GetTest: TTestObject;
const
  keyLiteral = 'Key';
  ivLiteral = 'IV';
  plainLiteral = 'Plaintext';
  cipherLiteral = 'Ciphertext';

var
  N: Integer;
  S: string;
  hasIV: Boolean;

begin
  repeat
    if not TryGetLine then begin
// no more test vectors
      Result:= nil;
      Exit;
    end;
    N:= Pos(keyLiteral, FLine);
  until N > 0;
// get key
  N:= Pos(':', FLine);
  S:= Trim(Copy(FLine, N + 1, Length(FLine)));
  FKey:= ByteArray.ParseHex(S);

// get IV
  if not TryGetLine then ParseError();
  N:= Pos(ivLiteral, FLine);
  hasIV:= N > 0;
  if HasIV then begin
    N:= Pos(':', FLine);
    S:= Trim(Copy(FLine, N + 1, Length(FLine)));
    FIV:= ByteArray.ParseHex(S);
    if not TryGetLine then ParseError();
  end;

// get plaintext
  N:= Pos(plainLiteral, FLine);
  if N <= 0 then ParseError();
  N:= Pos(':', FLine);
  S:= Trim(Copy(FLine, N + 1, Length(FLine)));
  FPlainText:= ByteArray.ParseHex(S);

// get ciphertext
  if not TryGetLine then ParseError();
  N:= Pos(cipherLiteral, FLine);
  if N <= 0 then ParseError();
  N:= Pos(':', FLine);
  S:= Trim(Copy(FLine, N + 1, Length(FLine)));
  FCipherText:= ByteArray.ParseHex(S);

  Result:= TCipherTest.Create(Logger, AlgID, FTestName);
  TCipherTest(Result).FKey:= FKey;
  if hasIV then
    TCipherTest(Result).FIV:= FIV;
  TCipherTest(Result).FPlainText:= FPlainText;
  TCipherTest(Result).FCipherText:= FCipherText;
end;

{ TNessieBlockCipherRunner }

function TNessieBlockCipherRunner.GetTest: TTestObject;
const
  keyLiteral = 'key=';
  plainLiteral = 'plain=';
  cipherLiteral = 'cipher=';
  decryptedLiteral = 'decrypted=';
  encryptedLiteral = 'encrypted=';
  Iter100Literal = 'Iterated 100 times=';
  Iter1000Literal = 'Iterated 1000 times=';

var
  N: Integer;
  S: string;

begin
  if FState = 0 then begin
    repeat
      if not TryGetLine then begin
  // no more test vectors
        Result:= nil;
        Exit;
      end;
      N:= Pos(keyLiteral, FLine);
    until N > 0;
  // get key
    S:= Trim(Copy(FLine, N + Length(keyLiteral), Length(FLine)));
    if not TryGetLine then ParseError();
    if (Pos(plainLiteral, FLine) <=0) and (Pos(cipherLiteral, FLine) <= 0) then begin
// key is continued on the next line
      S:= S + Trim(Copy(FLine, 1, Length(FLine)));
      if not TryGetLine then ParseError();
    end;

    FKey:= ByteArray.ParseHex(S);

    N:= Pos(plainLiteral, FLine);
    FMaxState:= 0;

  // get plain
    if N > 0 then begin
      S:= Trim(Copy(FLine, N + Length(plainLiteral), Length(FLine)));
      FPlainText:= ByteArray.ParseHex(S);

    // get cipher
      if not TryGetLine then ParseError();
      N:= Pos(cipherLiteral, FLine);
      if N <= 0 then ParseError();
      S:= Trim(Copy(FLine, N + Length(cipherLiteral), Length(FLine)));
      FCipherText:= ByteArray.ParseHex(S);

  // get decrypted
      if not TryGetLine then ParseError();
      N:= Pos(decryptedLiteral, FLine);
      if N <= 0 then ParseError();

      N:= 0;
      if TryGetLine then N:= Pos(Iter100Literal, FLine);
      if N > 0 then begin
        S:= Trim(Copy(FLine, N + Length(Iter100Literal), Length(FLine)));
        FCipherText100:= ByteArray.ParseHex(S);
        Inc(FMaxState);
        N:= 0;
        if TryGetLine then N:= Pos(Iter1000Literal, FLine);
        if N > 0 then begin
          S:= Trim(Copy(FLine, N + Length(Iter1000Literal), Length(FLine)));
          FCipherText1000:= ByteArray.ParseHex(S);
          Inc(FMaxState);
        end;
      end;
    end
    else begin
// get cipher
      N:= Pos(cipherLiteral, FLine);
      if N <= 0 then ParseError();
      S:= Trim(Copy(FLine, N + Length(cipherLiteral), Length(FLine)));
      FCipherText:= ByteArray.ParseHex(S);

  // get plain
      if not TryGetLine then ParseError();
      N:= Pos(plainLiteral, FLine);
      S:= Trim(Copy(FLine, N + Length(plainLiteral), Length(FLine)));
      FPlainText:= ByteArray.ParseHex(S);

  // get encrypted
      if not TryGetLine then ParseError();
      N:= Pos(encryptedLiteral, FLine);
      if N <= 0 then ParseError();
    end;

    Result:= TBlockCipherTest.Create(Logger, AlgID, FTestName);
    TBlockCipherTest(Result).FKey:= FKey;
    TBlockCipherTest(Result).FPlainText:= FPlainText;
    TBlockCipherTest(Result).FCipherText:= FCipherText;
    TBlockCipherTest(Result).FCount:= 1;

    if FState < FMaxState then Inc(FState);
  end
  else if FState = 1 then begin

    Result:= TBlockCipherTest.Create(Logger, AlgID, FTestName);
    TBlockCipherTest(Result).FKey:= FKey;
    TBlockCipherTest(Result).FPlainText:= FPlainText;
    TBlockCipherTest(Result).FCipherText:= FCipherText100;
    TBlockCipherTest(Result).FCount:= 100;

    if FState < FMaxState
      then Inc(FState)
      else FState:= 0;
  end
  else {if FState = 2 then} begin

    Result:= TBlockCipherTest.Create(Logger, AlgID);
    TBlockCipherTest(Result).FKey:= FKey;
    TBlockCipherTest(Result).FPlainText:= FPlainText;
    TBlockCipherTest(Result).FCipherText:= FCipherText1000;
    TBlockCipherTest(Result).FCount:= 1000;

    FState:= 0;
  end;
end;

{ TKeyStreamTest }

constructor TKeyStreamTest.Create(ALogger: TLogger; AAlgID: TAlgID;
  AName: string);
begin
  inherited Create(ALogger, AName);
  FAlgID:= AAlgID;
end;

procedure TKeyStreamTest.Execute;
var
  Cipher: TCipher;
  Cipher1, Cipher2, Cipher3, Cipher4: TCipher;
  DataSize: Cardinal;

begin
  Logger.WriteLn();
  Logger.WriteLn('Key      = ' + FKey.ToHex);
  Logger.WriteLn('Position = ' + IntToHex(FPosition, 0));
  Logger.WriteLn('Stream   = ' + FKeyStream.ToHex);

  Cipher:= TCipher.GetInstance(FAlgID);
  Cipher.Init(FKey);
  Cipher.Skip(FPosition);

  Cipher1:= Cipher.Clone;
  Cipher2:= Cipher.Clone;
  Cipher3:= Cipher.Clone;
  Cipher4:= Cipher.Clone;

// testing TCipher.KeyStream
  DataSize:= FKeyStream.Len;
  FActual:= Cipher.KeyStream(DataSize);
  CheckEquals(FKeyStream, FActual);

// testing TCipher.GetKeyStream
  FillChar(FActual.RawData^, DataSize, 0);
  Cipher1.GetKeyStream(FActual.RawData^, DataSize);
  CheckEquals(FKeyStream, FActual);

// additional tests: TCipher.Encrypt, TCipher.Decrypt, TCipher.Apply
  Cipher2.EncryptUpdate(FActual.RawData, FActual.RawData, DataSize, DataSize, True);
  CheckEquals(ByteArray.Allocate(DataSize, 0), FActual);
  Cipher3.DecryptUpdate(FActual.RawData, FActual.RawData, DataSize, DataSize, True);
  CheckEquals(FKeyStream, FActual);
  FillChar(FActual.RawData^, DataSize, 0);
  Cipher4.Encrypt(FActual.RawData, FActual.RawData, DataSize);
  CheckEquals(FKeyStream, FActual);
end;

{ TCipherTest }

constructor TBaseCipherTest.Create(ALogger: TLogger; AAlgID: TAlgID; AName: string);
begin
  inherited Create(ALogger, AName);
  FAlgID:= AAlgID;
end;

procedure TCipherTest.Execute;
var
  Cipher: TCipher;
  Tmp: ByteArray;

begin
  Logger.WriteLn('Key = ' + Key.ToHex, LOG_DETAILED);
  Logger.WriteLn('PlainText = ' + FPlainText.ToHex, LOG_DETAILED);
  Logger.WriteLn(Format('CipherText = %s', [FCipherText.ToHex]), LOG_DETAILED);

  Cipher:= TCipher.GetInstance(FAlgID);

  if IV.IsAssigned then
    Cipher.EncryptInit(Key, IV)
  else
    Cipher.EncryptInit(Key);

  Tmp:= Cipher.EncryptByteArray(FPlainText);
  CheckEquals(CipherText, Tmp);

//  Cipher:= TCipher.GetInstance(ALG_AES or MODE_ECB or PADDING_NONE);

  if IV.IsAssigned then
    Cipher.DecryptInit(Key, IV)
  else
    Cipher.DecryptInit(Key);

  Tmp:= Cipher.DecryptByteArray(FCipherText);
  if FAlgID and TF_PADDING_MASK = TF_PADDING_ZERO then
    Tmp:= Tmp.Remove(PlainText.Len);
  CheckEquals(PlainText, Tmp);
end;

{ TGCMModeCipherTest }

procedure TGCMModeCipherTest.Execute;
var
  Cipher: TCipher;
  Tmp: ByteArray;

begin
  Logger.WriteLn('Key = ' + FKey.ToHex, LOG_DETAILED);
  Logger.WriteLn('IV = ' + FIV.ToHex, LOG_DETAILED);
  Logger.WriteLn('PlainText = ' + FPlainText.ToHex, LOG_DETAILED);
  Logger.WriteLn(Format('CipherText = %s', [FCipherText.ToHex]), LOG_DETAILED);
  Logger.WriteLn('AuthData = ' + FAuthData.ToHex, LOG_DETAILED);
  Logger.WriteLn('AuthTag = ' + FAuthTag.ToHex, LOG_DETAILED);

  Cipher:= TCipher.GetInstance(FAlgID);
  Cipher.EncryptInit(FKey, FIV);
  Cipher.AddAuthData(FAuthData);

  Tmp:= Cipher.EncryptByteArray(FPlainText);
  CheckEquals(CipherText, Tmp);

  Cipher.GetAuthTag(Tmp);
  CheckEquals(FAuthTag, Tmp);

  Cipher.DecryptInit(Key, IV);
  Cipher.AddAuthData(FAuthData);

  Tmp:= Cipher.DecryptByteArray(FCipherText);
  CheckEquals(PlainText, Tmp);

  Cipher.CheckAuthTag(FAuthTag);
end;


end.

