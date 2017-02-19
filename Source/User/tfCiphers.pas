{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfCiphers;

interface

{$I TFL.inc}

uses
  SysUtils, Classes, tfTypes, tfBytes, tfConsts, tfExceptions,
  {$IFDEF TFL_DLL}
    tfImport
  {$ELSE}
    tfAES, tfDES, tfRC4, tfRC5, tfSalsa20, tfCipherServ, tfKeyStreams
  {$ENDIF};

const
  ECB_ENCRYPT = TF_ECB_ENCRYPT;
  ECB_DECRYPT = TF_ECB_DECRYPT;

  CBC_ENCRYPT = TF_CBC_ENCRYPT;
  CBC_DECRYPT = TF_CBC_DECRYPT;

  CTR_ENCRYPT = TF_CTR_ENCRYPT;
  CTR_DECRYPT = TF_CTR_DECRYPT;

  PADDING_DEFAULT  = TF_PADDING_DEFAULT;
  PADDING_NONE     = TF_PADDING_NONE;
  PADDING_ZERO     = TF_PADDING_ZERO;
  PADDING_ANSI     = TF_PADDING_ANSI;
  PADDING_PKCS     = TF_PADDING_PKCS;
  PADDING_ISO10126 = TF_PADDING_ISO10126;
  PADDING_ISOIEC   = TF_PADDING_ISOIEC;

  ALG_AES      = TF_ALG_AES;
  ALG_DES      = TF_ALG_DES;
  ALG_RC5      = TF_ALG_RC5;
  ALG_3DES     = TF_ALG_3DES;

  ALG_RC4      = TF_ALG_RC4;
  ALG_SALSA20  = TF_ALG_SALSA20;
  ALG_CHACHA20 = TF_ALG_CHACHA20;

  ALG_AES_ECB_ENCRYPT = TF_ALG_AES or TF_ECB_ENCRYPT;
  ALG_AES_ECB_DECRYPT = TF_ALG_AES or TF_ECB_DECRYPT;
  ALG_AES_CBC_ENCRYPT = TF_ALG_AES or TF_CBC_ENCRYPT;
  ALG_AES_CBC_DECRYPT = TF_ALG_AES or TF_CBC_DECRYPT;
  ALG_AES_CTR_ENCRYPT = TF_ALG_AES or TF_CTR_ENCRYPT;
  ALG_AES_CTR_DECRYPT = TF_ALG_AES or TF_CTR_DECRYPT;

  ALG_DES_ECB_ENCRYPT = TF_ALG_DES or TF_ECB_ENCRYPT;
  ALG_DES_ECB_DECRYPT = TF_ALG_DES or TF_ECB_DECRYPT;
  ALG_DES_CBC_ENCRYPT = TF_ALG_DES or TF_CBC_ENCRYPT;
  ALG_DES_CBC_DECRYPT = TF_ALG_DES or TF_CBC_DECRYPT;
  ALG_DES_CTR_ENCRYPT = TF_ALG_DES or TF_CTR_ENCRYPT;
  ALG_DES_CTR_DECRYPT = TF_ALG_DES or TF_CTR_DECRYPT;

  ALG_3DES_ECB_ENCRYPT = TF_ALG_3DES or TF_ECB_ENCRYPT;
  ALG_3DES_ECB_DECRYPT = TF_ALG_3DES or TF_ECB_DECRYPT;
  ALG_3DES_CBC_ENCRYPT = TF_ALG_3DES or TF_CBC_ENCRYPT;
  ALG_3DES_CBC_DECRYPT = TF_ALG_3DES or TF_CBC_DECRYPT;
  ALG_3DES_CTR_ENCRYPT = TF_ALG_3DES or TF_CTR_ENCRYPT;
  ALG_3DES_CTR_DECRYPT = TF_ALG_3DES or TF_CTR_DECRYPT;

  ALG_RC5_ECB_ENCRYPT = TF_ALG_RC5 or TF_ECB_ENCRYPT;
  ALG_RC5_ECB_DECRYPT = TF_ALG_RC5 or TF_ECB_DECRYPT;
  ALG_RC5_CBC_ENCRYPT = TF_ALG_RC5 or TF_CBC_ENCRYPT;
  ALG_RC5_CBC_DECRYPT = TF_ALG_RC5 or TF_CBC_DECRYPT;
  ALG_RC5_CTR_ENCRYPT = TF_ALG_RC5 or TF_CTR_ENCRYPT;
  ALG_RC5_CTR_DECRYPT = TF_ALG_RC5 or TF_CTR_DECRYPT;

type
  TCipher = record
  private
    FInstance: ICipher;
  public
    procedure Free;
    function IsAssigned: Boolean;
    procedure Burn;
    function Clone: TCipher;

    function IsBlockCipher: Boolean;
    function GetBlockSize: Cardinal;

    function GetNonce: UInt64;
    procedure SetNonce(const Value: UInt64);

    procedure SetIV(AIV: Pointer; AIVLen: Cardinal); overload;
    procedure SetIV(const AIV: ByteArray); overload;
    function GetIV: ByteArray;

// key + IV
    function ExpandKey(AKey: PByte; AKeyLen: Cardinal;
                       AIV: Pointer; AIVLen: Cardinal): TCipher; overload;
    function ExpandKey(const AKey: ByteArray;
                       const AIV: ByteArray): TCipher; overload;
// key + Nonce
    function ExpandKey(AKey: PByte; AKeyLen: Cardinal;
                       const ANonce: UInt64): TCipher; overload;
    function ExpandKey(const AKey: ByteArray;
                       const ANonce: UInt64): TCipher; overload;
// key only (zeroed IV)
    function ExpandKey(AKey: PByte; AKeyLen: Cardinal): TCipher; overload;
    function ExpandKey(const AKey: ByteArray): TCipher; overload;

    procedure Encrypt(var Data; var DataSize: Cardinal;
                      BufSize: Cardinal; Last: Boolean);
    procedure Decrypt(var Data; var DataSize: Cardinal;
                      Last: Boolean);
    procedure Apply(var Data; DataSize: Cardinal;
                        Last: Boolean);

    procedure GetKeyStream(var Data; DataSize: Cardinal);
    function KeyStream(DataSize: Cardinal): ByteArray;

    class function EncryptBlock(AlgID: TAlgID; const Data, Key: ByteArray): ByteArray; static;
    class function DecryptBlock(AlgID: TAlgID; const Data, Key: ByteArray): ByteArray; static;

    function EncryptByteArray(const Data: ByteArray): ByteArray;
    function DecryptByteArray(const Data: ByteArray): ByteArray;

    procedure EncryptStream(InStream, OutStream: TStream; BufSize: Cardinal = 0);
    procedure DecryptStream(InStream, OutStream: TStream; BufSize: Cardinal = 0);

    procedure EncryptFile(const InName, OutName: string; BufSize: Cardinal = 0);
    procedure DecryptFile(const InName, OutName: string; BufSize: Cardinal = 0);

//    function Skip(Value: UInt32): TCipher; overload;
    function Skip(Value: UInt64): TCipher; overload;

    class function GetInstance(AlgID: TAlgID): TCipher; static;

    class function AES(AFlags: UInt32): TCipher; static;
    class function DES(AFlags: UInt32): TCipher; static;
    class function TripleDES(AFlags: UInt32): TCipher; static;
    class function RC5(AFlags: UInt32): TCipher; overload; static;
    class function RC5(AFlags: UInt32; BlockSize, Rounds: Cardinal): TCipher; overload; static;
    class function RC4: TCipher; static;
    class function Salsa20: TCipher; overload; static;
    class function Salsa20(Rounds: Cardinal): TCipher; overload; static;
    class function ChaCha20: TCipher; overload; static;
    class function ChaCha20(Rounds: Cardinal): TCipher; overload; static;

//    class operator Explicit(const Name: string): TCipher;
//    class operator Explicit(AlgID: Integer): TCipher;

    class function GetCount: Integer; static;
    class function GetID(Index: Cardinal): TAlgID; static;
    class function GetName(Index: Cardinal): string; static;
    class function GetIDByName(const Name: string): TAlgID; static;
    class function GetNameByID(AlgID: TAlgID): string; static;
  end;

  TStreamCipher = record
  private
    FInstance: IStreamCipher;
  public
    procedure Free;
    function IsAssigned: Boolean;
    procedure Burn;
    function Clone: TStreamCipher;

    function ExpandKey(const AKey: ByteArray; ANonce: UInt64 = 0): TStreamCipher; overload;
    function ExpandKey(AKey: PByte; AKeyLen: Cardinal; ANonce: UInt64): TStreamCipher; overload;

    function GetNonce: UInt64;
    procedure SetNonce(const Nonce: UInt64);

    function Skip(const AValue: Int64): TStreamCipher;

    procedure GetKeyStream(var Data; DataSize: Cardinal);
    function KeyStream(ASize: Cardinal): ByteArray;

    procedure Apply(var Data; DataLen: Cardinal);
    procedure ApplyTo(const InData; var OutData; DataLen: Cardinal);

    function ApplyToByteArray(const Data: ByteArray): ByteArray;
    procedure ApplyToStream(InStream, OutStream: TStream; BufSize: Cardinal = 0);
    procedure ApplyToFile(const InName, OutName: string; BufSize: Cardinal = 0);

    class function GetInstance(AlgID: TAlgID): TStreamCipher; static;
//    class function GetInstance(const Name: string): TStreamCipher; static;

    class function AES: TStreamCipher; static;
    class function DES: TStreamCipher; static;
    class function TripleDES: TStreamCipher; static;
    class function RC5: TStreamCipher; overload; static;
    class function RC5(BlockSize, Rounds: Cardinal): TStreamCipher; overload; static;
    class function RC4: TStreamCipher; static;
    class function Salsa20: TStreamCipher; overload; static;
    class function Salsa20(Rounds: Cardinal): TStreamCipher; overload; static;
    class function ChaCha20: TStreamCipher; overload; static;
    class function ChaCha20(Rounds: Cardinal): TStreamCipher; overload; static;

//    class operator Explicit(const Name: string): TStreamCipher;

//    property Nonce: UInt64 read GetNonce write SetNonceProc;
  end;

type
  ECipherError = class(EForgeError);

implementation

procedure CipherError(ACode: TF_RESULT; const Msg: string = '');
begin
  raise ECipherError.Create(ACode, Msg);
end;

procedure HResCheck(Value: TF_RESULT); inline;
begin
  if Value <> TF_S_OK then
    CipherError(Value);
end;



// FServer is a singleton, no memory leak because of global intf ref
var
  FServer: ICipherServer;

function GetServer: ICipherServer;
begin
  if FServer = nil then
    HResCheck(GetCipherServerInstance(FServer));
  Result:= FServer;
end;

{ TCipher }
(*
class function TCipher.Create(const Alg: ICipherAlgorithm): TCipher;
begin
  Result.FInstance:= Alg;
end;
*)

procedure TCipher.Free;
begin
  FInstance:= nil;
end;

function TCipher.GetBlockSize: Cardinal;
begin
  Result:= FInstance.GetBlockSize;
end;

procedure TCipher.GetKeyStream(var Data; DataSize: Cardinal);
begin
  HResCheck(FInstance.GetKeyStream(@Data, DataSize));
end;

function TCipher.GetNonce: UInt64;
var
  DataLen: Cardinal;

begin
  DataLen:= SizeOf(UInt64);
  HResCheck(FInstance.GetKeyParam(TF_KP_NONCE, @Result, DataLen));
end;

function TCipher.GetIV: ByteArray;
var
  DataLen: Cardinal;

begin
  DataLen:= GetBlockSize;
  if (DataLen = 0) or (DataLen > TF_MAX_CIPHER_BLOCK_SIZE) then
    CipherError(TF_E_UNEXPECTED);
  Result:= ByteArray.Allocate(DataLen);
  HResCheck(FInstance.GetKeyParam(TF_KP_IV, Result.RawData, DataLen));
end;

function TCipher.KeyStream(DataSize: Cardinal): ByteArray;
begin
  Result:= ByteArray.Allocate(DataSize);
  GetKeyStream(Result.RawData^, DataSize);
end;

function TCipher.IsAssigned: Boolean;
begin
  Result:= FInstance <> nil;
end;

function TCipher.IsBlockCipher: Boolean;
begin
  Result:= FInstance.GetIsBlockCipher;
end;

{
class function TCipher.GetInstance(const Name: string): TCipher;
begin
  HResCheck(FServer.GetByName(Pointer(Name), SizeOf(Char), Result.FInstance));
end;
}

class function TCipher.GetInstance(AlgID: TAlgID): TCipher;
begin
  HResCheck(GetCipherInstance(AlgID, Result.FInstance));
end;

class function TCipher.AES(AFlags: UInt32): TCipher;
begin
//  HResCheck(FServer.GetByAlgID(TF_ALG_AES, Result.FInstance));
  HResCheck(GetAESInstance(PAESInstance(Result.FInstance), AFlags));
end;

class function TCipher.DES(AFlags: UInt32): TCipher;
begin
//  HResCheck(FServer.GetByAlgID(TF_ALG_DES, Result.FInstance));
  HResCheck(GetDESInstance(PDESInstance(Result.FInstance), AFlags));
end;

class function TCipher.TripleDES(AFlags: UInt32): TCipher;
begin
//  HResCheck(FServer.GetByAlgID(TF_ALG_3DES, Result.FInstance));
  HResCheck(Get3DESInstance(P3DESInstance(Result.FInstance), AFlags));
end;

class function TCipher.RC4: TCipher;
begin
//  HResCheck(FServer.GetByAlgID(TF_ALG_RC4, Result.FInstance));
  HResCheck(GetRC4Instance(PRC4Instance(Result.FInstance)));
end;

class function TCipher.RC5(AFlags: UInt32): TCipher;
begin
//  HResCheck(FServer.GetByAlgID(TF_ALG_RC5, Result.FInstance));
  HResCheck(GetRC5Instance(PRC5Instance(Result.FInstance), AFlags));
end;

class function TCipher.RC5(AFlags: UInt32; BlockSize, Rounds: Cardinal): TCipher;
begin
//  HResCheck(FServer.GetRC5(BlockSize, Rounds, Result.FInstance));
  HResCheck(GetRC5InstanceEx(PRC5Instance(Result.FInstance), AFlags, BlockSize, Rounds));
end;

class function TCipher.Salsa20: TCipher;
begin
//  HResCheck(FServer.GetByAlgID(TF_ALG_SALSA20, Result.FInstance));
  HResCheck(GetSalsa20Instance(PSalsa20Instance(Result.FInstance)));
end;

class function TCipher.Salsa20(Rounds: Cardinal): TCipher;
begin
//  HResCheck(FServer.GetSalsa20(Rounds, Result.FInstance));
  HResCheck(GetSalsa20InstanceEx(PSalsa20Instance(Result.FInstance), Rounds));
end;

class function TCipher.ChaCha20: TCipher;
begin
//  HResCheck(FServer.GetByAlgID(TF_ALG_CHACHA20, Result.FInstance));
  HResCheck(GetChaCha20Instance(PSalsa20Instance(Result.FInstance)));
end;

class function TCipher.ChaCha20(Rounds: Cardinal): TCipher;
begin
//  HResCheck(FServer.GetChaCha20(Rounds, Result.FInstance));
  HResCheck(GetChaCha20InstanceEx(PSalsa20Instance(Result.FInstance), Rounds));
end;

function TCipher.ExpandKey(AKey: PByte; AKeyLen: Cardinal): TCipher;
begin
  HResCheck(FInstance.ExpandKeyIV(AKey, AKeyLen, nil, 0));
  Result:= Self;
end;

function TCipher.ExpandKey(const AKey: ByteArray): TCipher;
begin
  HResCheck(FInstance.ExpandKeyIV(AKey.RawData, AKey.Len, nil, 0));
  Result:= Self;
end;

(*
function TCipher.ExpandKey(AKey: PByte; AKeyLen: Cardinal): TCipher;
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  HResCheck(FInstance.ExpandKey(AKey, AKeyLen));
  Result:= Self;
end;
*)

function TCipher.ExpandKey(AKey: PByte; AKeyLen: Cardinal; {AFlags: UInt32;}
                           AIV: Pointer; AIVLen: Cardinal): TCipher;
begin
//  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
//  HResCheck(FInstance.SetKeyParam(TF_KP_IV, AIV, AIVLen));
  HResCheck(FInstance.ExpandKeyIV(AKey, AKeyLen, AIV, AIVLen));
  Result:= Self;
end;
(*
function TCipher.ExpandKey(const AKey: ByteArray; AFlags: UInt32): TCipher;
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  HResCheck(FInstance.ExpandKey(AKey.RawData, AKey.Len));
  Result:= Self;
end;
*)

function TCipher.ExpandKey(const AKey: ByteArray; {AFlags: UInt32;}
                           const AIV: ByteArray): TCipher;
begin
//  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
//  HResCheck(FInstance.SetKeyParam(TF_KP_IV, AIV.RawData, AIV.Len));
  HResCheck(FInstance.ExpandKeyIV(AKey.RawData, AKey.Len, AIV.RawData, AIV.Len));
  Result:= Self;
end;

function TCipher.ExpandKey(AKey: PByte; AKeyLen: Cardinal; const ANonce: UInt64): TCipher;
(*
var
  LBlockSize: Cardinal;
  LBlock: array[0..TF_MAX_CIPHER_BLOCK_SIZE - 1] of Byte;

begin

  LBlockSize:= GetBlockSize;
  if LBlockSize < SizeOf(ANonce) then begin
    if ANonce = 0 then
      Result:= ExpandKey(AKey, AKeyLen, nil, 0)
    else
      CipherError(TF_E_INVALIDARG);
  end
  else if LBlockSize = SizeOf(ANonce) then begin
    Result:= ExpandKey(AKey, AKeyLen, @ANonce, SizeOf(ANonce));
  end
  else if LBlockSize <= TF_MAX_CIPHER_BLOCK_SIZE then begin
    FillChar(LBlock, LBlockSize, 0);
    Move(ANonce, LBlock, SizeOf(ANonce));
    Result:= ExpandKey(AKey, AKeyLen, @LBlock, LBlockSize);
    FillChar(LBlock, LBlockSize, 0);
  end
  else
    CipherError(TF_E_UNEXPECTED);

//  HResCheck(FInstance.ExpandKey(AKey.RawData, AKey.Len));
*)
begin
  HResCheck(FInstance.ExpandKeyNonce(AKey, AKeyLen, ANonce));
  Result:= Self;
end;

function TCipher.ExpandKey(const AKey: ByteArray; {AFlags: UInt32;}
                           const ANonce: UInt64): TCipher;
begin
//  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
//  HResCheck(FInstance.SetKeyParam(TF_KP_NONCE, @ANonce, SizeOf(ANonce)));
  HResCheck(FInstance.ExpandKeyNonce(AKey.RawData, AKey.Len, ANonce));
  Result:= Self;
end;

procedure TCipher.Burn;
begin
  FInstance.Burn;
end;

procedure TCipher.Encrypt(var Data; var DataSize: Cardinal;
  BufSize: Cardinal; Last: Boolean);
begin
  HResCheck(FInstance.Encrypt(@Data, DataSize, BufSize, Last));
end;

procedure TCipher.Decrypt(var Data; var DataSize: Cardinal; Last: Boolean);
begin
  HResCheck(FInstance.Decrypt(@Data, DataSize, Last));
end;

procedure TCipher.Apply(var Data; DataSize: Cardinal; Last: Boolean);
begin
  HResCheck(FInstance.KeyCrypt(@Data, DataSize, Last));
end;

class function TCipher.EncryptBlock(AlgID: TAlgID; const Data, Key: ByteArray): ByteArray;
var
  Cipher: TCipher;
  BlockSize: Integer;

begin
  AlgID:= AlgID and TF_ALGID_MASK;
  Cipher:= TCipher.GetInstance(AlgID or TF_ECB_ENCRYPT)
                  .ExpandKey(Key);
  BlockSize:= Cipher.GetBlockSize;
  if (BlockSize = 0) or (BlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then
    CipherError(TF_E_UNEXPECTED);
  if (BlockSize <> Data.GetLen) then
    CipherError(TF_E_INVALIDARG);
  Result:= Data.Copy();
  Cipher.FInstance.EncryptBlock(Result.GetRawData);
{
  BlockSize:= FInstance.GetBlockSize;
  if (BlockSize = 0) or (BlockSize <> Data.GetLen) then
    CipherError(TF_E_UNEXPECTED);

  Flags:= TF_ECB_ENCRYPT;
  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @Flags, SizeOf(Flags)));
  HResCheck(FInstance.ExpandKey(Key.RawData, Key.Len, nil, 0));

  Result:= Data.Copy();
  FInstance.EncryptBlock(Result.RawData);
}
end;

class function TCipher.DecryptBlock(AlgID: TAlgID; const Data, Key: ByteArray): ByteArray;
var
  Cipher: TCipher;
  BlockSize: Integer;

begin
  AlgID:= AlgID and TF_ALGID_MASK;
  Cipher:= TCipher.GetInstance(AlgID or TF_ECB_DECRYPT)
                  .ExpandKey(Key);
  BlockSize:= Cipher.GetBlockSize;
  if (BlockSize = 0) or (BlockSize > TF_MAX_CIPHER_BLOCK_SIZE) then
    CipherError(TF_E_UNEXPECTED);
  if (BlockSize <> Data.GetLen) then
    CipherError(TF_E_INVALIDARG);
  Result:= Data.Copy();
  Cipher.FInstance.DecryptBlock(Result.GetRawData);
{
  BlockSize:= FInstance.GetBlockSize;
  if (BlockSize = 0) or (BlockSize <> Data.GetLen) then
    CipherError(TF_E_UNEXPECTED);

  Flags:= TF_ECB_DECRYPT;
  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @Flags, SizeOf(Flags)));
  HResCheck(FInstance.ExpandKey(Key.RawData, Key.Len, nil, 0));

  Result:= Data.Copy;
  FInstance.DecryptBlock(Result.RawData);
}
end;

function TCipher.EncryptByteArray(const Data: ByteArray): ByteArray;
var
  L0, L1: LongWord;

begin
  L0:= Data.GetLen;
  L1:= L0;
  if (FInstance.Encrypt(nil, L1, 0, True) <> TF_E_INVALIDARG) or (L1 <= 0)
    then CipherError(TF_E_UNEXPECTED);

  Result:= Data;
  Result.ReAllocate(L1);
  HResCheck(FInstance.Encrypt(Result.RawData, L0, L1, True));
end;
{
function TCipher.EncryptData(const Data: ByteArray): ByteArray;
var
  L0, L1: Cardinal;

begin
  L0:= Data.GetLen;
  L1:= L0;
  if (FInstance.Encrypt(nil, L1, 0, True) <> TF_E_INVALIDARG) or (L1 <= 0)
    then CipherError(TF_E_UNEXPECTED);

  Result:= Data;
  Result.ReAllocate(L1);
  HResCheck(FInstance.Encrypt(Result.RawData, L0, L1, True));
end;
function TCipher.DecryptData(const Data: ByteArray): ByteArray;
var
  L: LongWord;

begin
  L:= Data.GetLen;
  Result:= Data.Copy;
  HResCheck(FInstance.Decrypt(Result.RawData, L, True));
  Result.SetLen(L);
end;
}

function TCipher.DecryptByteArray(const Data: ByteArray): ByteArray;
var
  L: Cardinal;

begin
  L:= Data.GetLen;
  Result:= Data.Copy;
  HResCheck(FInstance.Decrypt(Result.RawData, L, True));
  Result.SetLen(L);
end;

procedure TCipher.EncryptFile(const InName, OutName: string; BufSize: Cardinal);
var
  InStream, OutStream: TStream;

begin
  InStream:= TFileStream.Create(InName, fmOpenRead or fmShareDenyWrite);
  OutStream:= TFileStream.Create(OutName, fmCreate);
  try
    EncryptStream(InStream, OutStream, BufSize);
  finally
    InStream.Free;
    OutStream.Free;
  end;
end;

procedure TCipher.EncryptStream(InStream, OutStream: TStream; BufSize: Cardinal);
const
  MIN_BUFSIZE = 4 * 1024;
  MAX_BUFSIZE = 4 * 1024 * 1024;
  DEFAULT_BUFSIZE = 16 * 1024;
  PAD_BUFSIZE = TF_MAX_CIPHER_BLOCK_SIZE;


var
  OutBufSize, DataSize: LongWord;
  Data, PData: PByte;
  N: Integer;
  Cnt: LongWord;
  Last: Boolean;

begin
  if (BufSize < MIN_BUFSIZE) or (BufSize > MAX_BUFSIZE)
    then BufSize:= DEFAULT_BUFSIZE
    else BufSize:= (BufSize + PAD_BUFSIZE - 1)
                         and not (PAD_BUFSIZE - 1);
  OutBufSize:= BufSize + PAD_BUFSIZE;
  GetMem(Data, OutBufSize);
  try
    repeat
      Cnt:= BufSize;
      PData:= Data;
      repeat
        N:= InStream.Read(PData^, Cnt);
        if N <= 0 then Break;
        Inc(PData, N);
        Dec(Cnt, N);
      until (Cnt = 0);
      Last:= Cnt > 0;
      DataSize:= BufSize - Cnt;
      Encrypt(Data^, DataSize, OutBufSize, Last);
      if DataSize > 0 then
        OutStream.WriteBuffer(Data^, DataSize);
    until Last;
  finally
    FreeMem(Data);
  end;
end;

procedure TCipher.DecryptStream(InStream, OutStream: TStream; BufSize: Cardinal);
const
  MIN_BUFSIZE = 4 * 1024;
  MAX_BUFSIZE = 4 * 1024 * 1024;
  DEFAULT_BUFSIZE = 16 * 1024;
  PAD_BUFSIZE = TF_MAX_CIPHER_BLOCK_SIZE;

var
  OutBufSize, DataSize: Cardinal;
  Data, PData: PByte;
  N: Integer;
  Cnt: Cardinal;
  Last: Boolean;

begin
  if (BufSize < MIN_BUFSIZE) or (BufSize > MAX_BUFSIZE)
    then BufSize:= DEFAULT_BUFSIZE
    else BufSize:= (BufSize + PAD_BUFSIZE - 1)
                         and not (PAD_BUFSIZE - 1);
  OutBufSize:= BufSize + PAD_BUFSIZE;
  GetMem(Data, OutBufSize);
  try
    PData:= Data;
    Cnt:= OutBufSize;
    repeat
      repeat
        N:= InStream.Read(PData^, Cnt);
        if N <= 0 then Break;
        Inc(PData, N);
        Dec(Cnt, N);
      until (Cnt = 0);
      Last:= Cnt > 0;
      if Last then begin
        DataSize:= OutBufSize - Cnt;
      end
      else begin
        DataSize:= BufSize - Cnt;
      end;
      Decrypt(Data^, DataSize, Last);
      if DataSize > 0 then
        OutStream.WriteBuffer(Data^, DataSize);
      if Last then Break
      else begin
        Move((Data + OutBufSize - PAD_BUFSIZE)^, Data^, PAD_BUFSIZE);
        PData:= Data + PAD_BUFSIZE;
        Cnt:= BufSize;
      end;
    until False;
  finally
    FreeMem(Data);
  end;
end;

procedure TCipher.DecryptFile(const InName, OutName: string; BufSize: Cardinal);
var
  InStream, OutStream: TStream;

begin
  InStream:= TFileStream.Create(InName, fmOpenRead or fmShareDenyWrite);
  OutStream:= TFileStream.Create(OutName, fmCreate);
  try
    DecryptStream(InStream, OutStream, BufSize);
  finally
    InStream.Free;
    OutStream.Free;
  end;
end;

function TCipher.Clone: TCipher;
begin
  HResCheck(FInstance.Duplicate(Result.FInstance));
end;

class function TCipher.GetCount: Integer;
begin
//  Result:= FServer.GetCount;
  Result:= GetServer.GetCount;
end;

{
function TCipher.Decrypt(const Data: ByteArray): ByteArray;
var
  L: LongWord;

begin
  L:= Data.Len;
  Result:= ByteArray.Copy(Data);
  Decrypt(Result.RawData^, L, True);
  Result.Len:= L;
end;
}

class function TCipher.GetID(Index: Cardinal): TAlgID;
begin
  HResCheck(GetServer.GetID(Index, Result));
end;

class function TCipher.GetName(Index: Cardinal): string;
var
//  Bytes: IBytes;
//  I, L: Integer;
//  P: PByte;
  P: Pointer;
//  S: string;

begin
(*  HResCheck(FServer.GetName(Index, Bytes));
  L:= Bytes.GetLen;
  P:= Bytes.GetRawData;
  SetLength(Result, L);
  for I:= 1 to L do begin
    Result[I]:= Char(P^);
    Inc(P);
  end;*)
  HResCheck(GetServer.GetName(Index, P));
//  S:= UTF8String(PAnsiChar(P));
//  Result:= S;
  Result:= UTF8String(PAnsiChar(P));
end;

class function TCipher.GetIDByName(const Name: string): TAlgID;
begin
  HResCheck(GetServer.GetIDByName(Pointer(Name), SizeOf(Char), Result));
end;

class function TCipher.GetNameByID(AlgID: TAlgID): string;
var
  P: Pointer;

begin
  HResCheck(GetServer.GetNameByID(AlgID and TF_ALGID_MASK, P));
  Result:= string(PUTF8String(P)^);
end;

(*
function TCipher.SetFlags(AFlags: UInt32): TCipher;
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  Result:= Self;
end;

procedure TCipher.SetFlagsProc(const Value: UInt32);
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_FLAGS, @Value, SizeOf(Value)));
end;
*)

procedure TCipher.SetIV(AIV: Pointer; AIVLen: Cardinal);
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_IV, AIV, AIVLen));
end;

procedure TCipher.SetIV(const AIV: ByteArray);
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_IV, AIV.RawData, AIV.Len));
end;

(*
procedure TCipher.SetIVProc(const Value: ByteArray);
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_IV, Value.RawData, Value.Len));
end;
*)
(*
function TCipher.SetNonce(const Value: ByteArray): TCipher;
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_NONCE, Value.RawData, Value.Len));
  Result:= Self;
end;

function TCipher.SetNonce(const Value: UInt64): TCipher;
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_NONCE, @Value, SizeOf(Value)));
  Result:= Self;
end;
*)

procedure TCipher.SetNonce(const Value: UInt64);
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_NONCE, @Value, SizeOf(Value)));
end;

{
function TCipher.SetBlockNo(const Value: ByteArray): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_BLOCKNO, Value.RawData, Value.Len));
  Result:= Self;
end;

function TCipher.SetBlockNo(const Value: UInt64): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_BLOCKNO_LE, @Value, SizeOf(Value)));
  Result:= Self;
end;
}
(*
function TCipher.Skip(Value: UInt32): TCipher;
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_INCNO{_LE}, @Value, SizeOf(Value)));
  Result:= Self;
end;
*)
function TCipher.Skip(Value: UInt64): TCipher;
begin
  HResCheck(FInstance.SetKeyParam(TF_KP_INCNO{_LE}, @Value, SizeOf(Value)));
  Result:= Self;
end;
{
function TCipher.Skip(Value: ByteArray): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_INCNO, @Value, SizeOf(Value)));
  Result:= Self;
end;
class operator TCipher.Explicit(AlgID: Integer): TCipher;
begin
//  HResCheck(FServer.GetByAlgID(AlgID, Result.FInstance));
  HResCheck(GetServer.GetByAlgID(AlgID, Result.FInstance));
end;

class operator TCipher.Explicit(const Name: string): TCipher;
begin
//  HResCheck(FServer.GetByName(Pointer(Name), SizeOf(Char), Result.FInstance));
  HResCheck(GetServer.GetByName(Pointer(Name), SizeOf(Char), Result.FInstance));
end;
}

{ TKeyStream }

procedure TStreamCipher.Free;
begin
  FInstance:= nil;
end;

function TStreamCipher.IsAssigned: Boolean;
begin
  Result:= FInstance <> nil;
end;

function TStreamCipher.KeyStream(ASize: Cardinal): ByteArray;
begin
  Result:= ByteArray.Allocate(ASize);
  HResCheck(FInstance.GetKeyStream(Result.GetRawData, ASize));
end;

procedure TStreamCipher.Burn;
begin
  FInstance.Burn;
end;

function TStreamCipher.ExpandKey(AKey: PByte; AKeyLen: Cardinal; ANonce: UInt64): TStreamCipher;
begin
  HResCheck(FInstance.ExpandKey(AKey, AKeyLen, ANonce));
  Result:= Self;
end;

function TStreamCipher.ExpandKey(const AKey: ByteArray; ANonce: UInt64): TStreamCipher;
begin
  HResCheck(FInstance.ExpandKey(AKey.GetRawData, AKey.GetLen, ANonce));
  Result:= Self;
end;

(*
function TStreamCipher.ExpandKey(const AKey: ByteArray): TStreamCipher;
begin
  HResCheck(FInstance.ExpandKey(AKey.GetRawData, AKey.GetLen, 0));
  Result:= Self;
end;
*)
(*
class operator TStreamCipher.Explicit(const Name: string): TStreamCipher;
begin
//  HResCheck(FServer.GetKSByName(Pointer(Name), SizeOf(Char), Result.FInstance));
  HResCheck(GetServer.GetKSByName(Pointer(Name), SizeOf(Char), Result.FInstance));
end;
*)
(*  don't want to expose
class operator TStreamCipher.Explicit(AlgID: Integer): TStreamCipher;
begin
  HResCheck(FServer.GetKSByAlgID(AlgID, Result.FInstance));
end;
*)

function TStreamCipher.Skip(const AValue: Int64): TStreamCipher;
begin
  HResCheck(FInstance.Skip(AValue));
  Result:= Self;
end;

function TStreamCipher.Clone: TStreamCipher;
begin
  HResCheck(FInstance.Duplicate(Result.FInstance));
end;

class function TStreamCipher.AES: TStreamCipher;
begin
//  HResCheck(FServer.GetKSByAlgID(TF_ALG_AES, Result.FInstance));
//  HResCheck(GetServer.GetKSByAlgID(TF_ALG_AES, Result.FInstance));
  HResCheck(GetAESStreamCipherInstance(Result.FInstance));
end;

class function TStreamCipher.DES: TStreamCipher;
begin
//  HResCheck(FServer.GetKSByAlgID(TF_ALG_DES, Result.FInstance));
//  HResCheck(GetServer.GetKSByAlgID(TF_ALG_DES, Result.FInstance));
  HResCheck(GetDESStreamCipherInstance(Result.FInstance));
end;

class function TStreamCipher.TripleDES: TStreamCipher;
begin
//  HResCheck(FServer.GetKSByAlgID(TF_ALG_3DES, Result.FInstance));
//  HResCheck(GetServer.GetKSByAlgID(TF_ALG_3DES, Result.FInstance));
  HResCheck(Get3DESStreamCipherInstance(Result.FInstance));
end;

class function TStreamCipher.Salsa20: TStreamCipher;
begin
//  HResCheck(FServer.GetKSByAlgID(TF_ALG_SALSA20, Result.FInstance));
//  HResCheck(GetServer.GetKSByAlgID(TF_ALG_SALSA20, Result.FInstance));
  HResCheck(GetSalsa20StreamCipherInstance(Result.FInstance));
end;

class function TStreamCipher.Salsa20(Rounds: Cardinal): TStreamCipher;
begin
//  HResCheck(FServer.GetKSSalsa20(Rounds, Result.FInstance));
//  HResCheck(GetServer.GetKSSalsa20(Rounds, Result.FInstance));
  HResCheck(GetSalsa20StreamCipherInstanceEx(Result.FInstance, Rounds));
end;

class function TStreamCipher.GetInstance(AlgID: TAlgID): TStreamCipher;
begin
  HResCheck(GetStreamCipherInstance(AlgID, Result.FInstance));
end;
(*
class function TStreamCipher.GetInstance(const Name: string): TStreamCipher;
begin
//  HResCheck(FServer.GetKSByName(Pointer(Name), SizeOf(Char), Result.FInstance));
  HResCheck(GetServer.GetKSByName(Pointer(Name), SizeOf(Char), Result.FInstance));
end;
*)

function TStreamCipher.GetNonce: UInt64;
begin
  HResCheck(FInstance.GetNonce(Result));
end;

procedure TStreamCipher.SetNonce(const Nonce: UInt64);
begin
  HResCheck(FInstance.SetNonce(Nonce));
end;

class function TStreamCipher.ChaCha20: TStreamCipher;
begin
//  HResCheck(FServer.GetKSByAlgID(TF_ALG_CHACHA20, Result.FInstance));
//  HResCheck(GetServer.GetKSByAlgID(TF_ALG_CHACHA20, Result.FInstance));
//  HResCheck(GetStreamCipherInstance(TF_ALG_CHACHA20, Result.FInstance));
  HResCheck(GetChacha20StreamCipherInstance(Result.FInstance));
end;

class function TStreamCipher.ChaCha20(Rounds: Cardinal): TStreamCipher;
begin
//  HResCheck(FServer.GetKSChaCha20(Rounds, Result.FInstance));
//  HResCheck(GetServer.GetKSChaCha20(Rounds, Result.FInstance));
  HResCheck(GetChacha20StreamCipherInstanceEx(Result.FInstance, Rounds));
end;

class function TStreamCipher.RC4: TStreamCipher;
begin
//  HResCheck(FServer.GetKSByAlgID(TF_ALG_RC4, Result.FInstance));
//  HResCheck(GetServer.GetKSByAlgID(TF_ALG_RC4, Result.FInstance));
  HResCheck(GetRC4StreamCipherInstance(Result.FInstance));
end;

class function TStreamCipher.RC5(BlockSize, Rounds: Cardinal): TStreamCipher;
begin
//  HResCheck(FServer.GetKSRC5(BlockSize, Rounds, Result.FInstance));
//  HResCheck(GetServer.GetKSRC5(BlockSize, Rounds, Result.FInstance));
  HResCheck(GetRC5StreamCipherInstanceEx(Result.FInstance, BlockSize, Rounds));
end;

class function TStreamCipher.RC5: TStreamCipher;
begin
//  HResCheck(FServer.GetKSByAlgID(TF_ALG_RC5, Result.FInstance));
//  HResCheck(GetServer.GetKSByAlgID(TF_ALG_RC5, Result.FInstance));
  HResCheck(GetRC5StreamCipherInstance(Result.FInstance));
end;

procedure TStreamCipher.GetKeyStream(var Data; DataSize: Cardinal);
begin
  HResCheck(FInstance.GetKeyStream(@Data, DataSize));
end;

procedure TStreamCipher.Apply(var Data; DataLen: Cardinal);
begin
  HResCheck(FInstance.Apply(@Data, DataLen));
end;

procedure TStreamCipher.ApplyTo(const InData; var OutData; DataLen: Cardinal);
var
  HRes: TF_RESULT;

begin
  Move(InData, OutData, DataLen);
  HRes:= FInstance.Apply(@OutData, DataLen);
  if HRes <> TF_S_OK then begin
    FillChar(OutData, DataLen, 0);
    CipherError(HRes);
  end;
end;

function TStreamCipher.ApplyToByteArray(const Data: ByteArray): ByteArray;
var
  L: Cardinal;
  HRes: TF_RESULT;

begin
  L:= Data.GetLen;
  Result:= Data;
  Result.ReAllocate(L);
  HRes:= FInstance.Apply(Result.RawData, L);
  if HRes <> TF_S_OK then begin
    FillChar(Result.RawData^, L, 0);
    CipherError(HRes);
  end;
end;

procedure TStreamCipher.ApplyToFile(const InName, OutName: string;
  BufSize: Cardinal);
var
  InStream, OutStream: TStream;

begin
  InStream:= TFileStream.Create(InName, fmOpenRead or fmShareDenyWrite);
  try
    OutStream:= TFileStream.Create(OutName, fmCreate);
    try
      ApplyToStream(InStream, OutStream, BufSize);
    finally
      OutStream.Free;
    end;
  finally
    InStream.Free;
  end;
end;

procedure TStreamCipher.ApplyToStream(InStream, OutStream: TStream;
  BufSize: Cardinal);
const
  MIN_BUFSIZE = 4 * 1024;
  MAX_BUFSIZE = 4 * 1024 * 1024;
  DEFAULT_BUFSIZE = 16 * 1024;
  PAD_BUFSIZE = TF_MAX_CIPHER_BLOCK_SIZE;

var
  DataSize: Cardinal;
  Data, PData: PByte;
  N: Integer;
  Cnt: Cardinal;

begin
  if (BufSize < MIN_BUFSIZE) or (BufSize > MAX_BUFSIZE)
    then BufSize:= DEFAULT_BUFSIZE
    else BufSize:= (BufSize + PAD_BUFSIZE - 1)
                         and not (PAD_BUFSIZE - 1);
  GetMem(Data, BufSize);
  try
    repeat
      Cnt:= BufSize;
      PData:= Data;
      repeat
        N:= InStream.Read(PData^, Cnt);
        if N <= 0 then Break;
        Inc(PData, N);
        Dec(Cnt, N);
      until (Cnt = 0);
      DataSize:= BufSize - Cnt;
      if DataSize > 0 then begin
        Apply(Data^, DataSize);
        OutStream.WriteBuffer(Data^, DataSize);
        FillChar(Data^, DataSize, 0);
      end;
    until Cnt > 0;
  finally
    FreeMem(Data);
  end;
end;

(*
{$IFNDEF TFL_DLL}
initialization
  GetCipherServerInstance(FServer);

{$ENDIF}
*)
end.
