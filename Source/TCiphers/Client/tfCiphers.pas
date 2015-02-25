{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
{ *********************************************************** }

unit tfCiphers;

interface

{$I TFL.inc}

uses
  SysUtils, tfTypes, tfBytes, tfConsts, tfExceptions,
  {$IFDEF TFL_DLL} tfImport {$ELSE} tfCipherServ {$ENDIF};

type
  TCipher = record
  private
    class var FServer: ICipherServer;
  private
    FAlgorithm: ICipherAlgorithm;
    procedure SetFlagsProc(const Value: LongWord);
    procedure SetIVProc(const Value: ByteArray);
    procedure SetNonceProc(const Value: ByteArray);
  public
    class function Create(const Alg: ICipherAlgorithm): TCipher; static;
    procedure Free;
    function IsAssigned: Boolean;

    function SetFlags(AFlags: LongWord): TCipher; overload;

    function SetIV(AIV: Pointer; AIVLen: LongWord): TCipher; overload;
    function SetIV(const AIV: ByteArray): TCipher; overload;

    function SetNonce(const Value: ByteArray): TCipher; overload;
    function SetNonce(const Value: UInt64): TCipher; overload;
    function SetPos(const Value: ByteArray): TCipher; overload;
    function SetPos(const Value: UInt64): TCipher; overload;

    function ExpandKey(AKey: PByte; AKeyLen: LongWord): TCipher; overload;
    function ExpandKey(AKey: PByte; AKeyLen: LongWord; AFlags: LongWord): TCipher; overload;
    function ExpandKey(AKey: PByte; AKeyLen: LongWord; AFlags: LongWord;
                       AIV: Pointer; AIVLen: LongWord): TCipher; overload;

    function ExpandKey(const AKey: ByteArray): TCipher; overload;
    function ExpandKey(const AKey: ByteArray; AFlags: LongWord): TCipher; overload;
    function ExpandKey(const AKey: ByteArray; AFlags: LongWord;
                       const AIV: ByteArray): TCipher; overload;

    procedure DestroyKey;

    procedure Encrypt(var Data; var DataSize: LongWord;
                      BufSize: LongWord; Last: Boolean); overload;
    procedure Decrypt(var Data; var DataSize: LongWord;
                      Last: Boolean); overload;

    procedure GetSequence(var Data; DataSize: LongWord);
    function Sequence(DataSize: LongWord): ByteArray;

    function EncryptBlock(const Data, Key: ByteArray): ByteArray;
    function DecryptBlock(const Data, Key: ByteArray): ByteArray;

    function EncryptData(const Data: ByteArray): ByteArray;
    function DecryptData(const Data: ByteArray): ByteArray;

    class function AES: TCipher; static;
    class function DES: TCipher; static;
    class function RC5: TCipher; overload; static;
    class function RC5(BlockSize, Rounds: LongWord): TCipher; overload; static;
    class function RC4: TCipher; static;
    class function Salsa20: TCipher; overload; static;
    class function Salsa20(Rounds: LongWord): TCipher; overload; static;

    function Copy: TCipher;

    class operator Explicit(const Name: string): TCipher;
    class operator Explicit(AlgID: Integer): TCipher;

    class function Name(Index: Cardinal): string; static;
    class function Count: Integer; static;

    property Algorithm: ICipherAlgorithm read FAlgorithm;

    property Flags: LongWord write SetFlagsProc;
    property IV: ByteArray write SetIVProc;
    property Nonce: ByteArray write SetNonceProc;
//    property Position: ByteArray write SetPosProc;
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

{ TCipher }

class function TCipher.Create(const Alg: ICipherAlgorithm): TCipher;
begin
  Result.FAlgorithm:= Alg;
end;

procedure TCipher.Free;
begin
  FAlgorithm:= nil;
end;

procedure TCipher.GetSequence(var Data; DataSize: LongWord);
begin
  HResCheck(FAlgorithm.GetSequence(@Data, DataSize));
end;

function TCipher.Sequence(DataSize: LongWord): ByteArray;
begin
  Result:= ByteArray.Allocate(DataSize);
  GetSequence(Result.RawData^, DataSize);
end;

function TCipher.IsAssigned: Boolean;
begin
  Result:= FAlgorithm <> nil;
end;

class function TCipher.AES: TCipher;
begin
  HResCheck(FServer.GetByAlgID(TF_ALG_AES, Result.FAlgorithm));
end;

class function TCipher.DES: TCipher;
begin
  HResCheck(FServer.GetByAlgID(TF_ALG_DES, Result.FAlgorithm));
end;

class function TCipher.RC5: TCipher;
begin
  HResCheck(FServer.GetByAlgID(TF_ALG_RC5, Result.FAlgorithm));
end;

class function TCipher.RC4: TCipher;
begin
  HResCheck(FServer.GetByAlgID(TF_ALG_RC4, Result.FAlgorithm));
end;

class function TCipher.RC5(BlockSize, Rounds: LongWord): TCipher;
begin
  HResCheck(FServer.GetRC5(BlockSize, Rounds, Result.FAlgorithm));
end;

function TCipher.ExpandKey(AKey: PByte; AKeyLen, AFlags: LongWord;
                           AIV: Pointer; AIVLen: LongWord): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_IV, AIV, AIVLen));
  HResCheck(FAlgorithm.ExpandKey(AKey, AKeyLen));
  Result:= Self;
end;

function TCipher.ExpandKey(const AKey: ByteArray; AFlags: LongWord;
                           const AIV: ByteArray): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_IV, AIV.RawData, AIV.Len));
  HResCheck(FAlgorithm.ExpandKey(AKey.RawData, AKey.Len));
  Result:= Self;
end;

function TCipher.ExpandKey(AKey: PByte; AKeyLen: LongWord; AFlags: LongWord): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
{
//  if AKeyMode <> 0 then
    HResCheck(FAlgorithm.SetKeyParam(TF_KP_MODE, @AKeyMode, SizeOf(AKeyMode)));
//  if APadding <> 0 then
    HResCheck(FAlgorithm.SetKeyParam(TF_KP_PADDING, @APadding, SizeOf(APadding)));
}
  HResCheck(FAlgorithm.ExpandKey(AKey, AKeyLen));
  Result:= Self;
end;

function TCipher.ExpandKey(const AKey: ByteArray; AFlags: LongWord): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  HResCheck(FAlgorithm.ExpandKey(AKey.RawData, AKey.Len));
  Result:= Self;
end;

procedure TCipher.DestroyKey;
begin
  FAlgorithm.DestroyKey;
end;

procedure TCipher.Encrypt(var Data; var DataSize: LongWord;
  BufSize: LongWord; Last: Boolean);
begin
  HResCheck(FAlgorithm.Encrypt(@Data, DataSize, BufSize, Last));
end;

procedure TCipher.Decrypt(var Data; var DataSize: LongWord; Last: Boolean);
begin
  HResCheck(FAlgorithm.Decrypt(@Data, DataSize, Last));
end;

function TCipher.EncryptBlock(const Data, Key: ByteArray): ByteArray;
var
  Flags: LongWord;
  BlockSize: Integer;

begin
  BlockSize:= FAlgorithm.GetBlockSize;
  if (BlockSize = 0) or (BlockSize <> Data.GetLen) then
    CipherError(TF_E_UNEXPECTED);

  Flags:= ECB_ENCRYPT;
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @Flags, SizeOf(Flags)));
  HResCheck(FAlgorithm.ExpandKey(Key.RawData, Key.Len));

  Result:= ByteArray.Copy(Data);
  FAlgorithm.EncryptBlock(Result.RawData);
end;

function TCipher.DecryptBlock(const Data, Key: ByteArray): ByteArray;
var
  Flags: LongWord;
  BlockSize: Integer;

begin
  BlockSize:= FAlgorithm.GetBlockSize;
  if (BlockSize = 0) or (BlockSize <> Data.GetLen) then
    CipherError(TF_E_UNEXPECTED);

  Flags:= ECB_DECRYPT;
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @Flags, SizeOf(Flags)));
  HResCheck(FAlgorithm.ExpandKey(Key.RawData, Key.Len));

  Result:= ByteArray.Copy(Data);
  FAlgorithm.DecryptBlock(Result.RawData);
end;

function TCipher.EncryptData(const Data: ByteArray): ByteArray;
var
  L0, L1: LongWord;

begin
  L0:= Data.GetLen;
  L1:= L0;
  if (FAlgorithm.Encrypt(nil, L1, 0, True) <> TF_E_INVALIDARG) or (L1 <= 0)
    then CipherError(TF_E_UNEXPECTED);

  Result:= Data;
  Result.ReAllocate(L1);
  HResCheck(FAlgorithm.Encrypt(Result.RawData, L0, L1, True));
end;

function TCipher.DecryptData(const Data: ByteArray): ByteArray;
var
  L: LongWord;

begin
  L:= Data.GetLen;
  Result:= ByteArray.Copy(Data);
  HResCheck(FAlgorithm.Decrypt(Result.RawData, L, True));
  Result.SetLen(L);
end;

function TCipher.Copy: TCipher;
begin
  HResCheck(FAlgorithm.DuplicateKey(Result.FAlgorithm));
end;

class function TCipher.Count: Integer;
begin
  Result:= FServer.GetCount;
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

class function TCipher.Name(Index: Cardinal): string;
var
  Bytes: IBytes;
  I, L: Integer;
  P: PByte;

begin
  HResCheck(FServer.GetName(Index, Bytes));
  L:= Bytes.GetLen;
  P:= Bytes.GetRawData;
  SetLength(Result, L);
  for I:= 1 to L do begin
    Result[I]:= Char(P^);
    Inc(P);
  end;
end;

class function TCipher.Salsa20: TCipher;
begin
  HResCheck(FServer.GetByAlgID(TF_ALG_SALSA20, Result.FAlgorithm));
end;

class function TCipher.Salsa20(Rounds: LongWord): TCipher;
begin
  HResCheck(FServer.GetSalsa20(Rounds, Result.FAlgorithm));
end;

function TCipher.SetFlags(AFlags: LongWord): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  Result:= Self;
end;

procedure TCipher.SetFlagsProc(const Value: LongWord);
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @Value, SizeOf(Value)));
end;

function TCipher.SetIV(AIV: Pointer; AIVLen: LongWord): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_IV, AIV, AIVLen));
  Result:= Self;
end;

function TCipher.SetIV(const AIV: ByteArray): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_IV, AIV.RawData, AIV.Len));
  Result:= Self;
end;

procedure TCipher.SetIVProc(const Value: ByteArray);
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_IV, Value.RawData, Value.Len));
end;

function TCipher.SetNonce(const Value: ByteArray): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_NONCE, Value.RawData, Value.Len));
  Result:= Self;
end;

function TCipher.SetNonce(const Value: UInt64): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_NONCE_LE, @Value, SizeOf(Value)));
  Result:= Self;
end;

procedure TCipher.SetNonceProc(const Value: ByteArray);
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_NONCE, Value.RawData, Value.Len));
end;

function TCipher.SetPos(const Value: ByteArray): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_POS, Value.RawData, Value.Len));
  Result:= Self;
end;

function TCipher.SetPos(const Value: UInt64): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_POS_LE, @Value, SizeOf(Value)));
  Result:= Self;
end;

function TCipher.ExpandKey(AKey: PByte; AKeyLen: LongWord): TCipher;
begin
  HResCheck(FAlgorithm.ExpandKey(AKey, AKeyLen));
  Result:= Self;
end;

function TCipher.ExpandKey(const AKey: ByteArray): TCipher;
begin
  HResCheck(FAlgorithm.ExpandKey(AKey.RawData, AKey.Len));
  Result:= Self;
end;

class operator TCipher.Explicit(AlgID: Integer): TCipher;
begin
  HResCheck(FServer.GetByAlgID(AlgID, Result.FAlgorithm));
end;

class operator TCipher.Explicit(const Name: string): TCipher;
begin
  HResCheck(FServer.GetByName(Pointer(Name), SizeOf(Char), Result.FAlgorithm));
end;

{$IFNDEF TFL_DLL}
initialization
  GetCipherServer(TCipher.FServer);

{$ENDIF}
end.
