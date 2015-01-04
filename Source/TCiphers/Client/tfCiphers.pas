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
  public
    class function Create(const Alg: ICipherAlgorithm): TCipher; static;
    procedure Free;
    function IsAssigned: Boolean;

    function SetFlags(AFlags: LongWord): TCipher; overload;

    function SetIV(AIV: Pointer; AIVLen: LongWord): TCipher; overload;
    function SetIV(const AIV: ByteArray): TCipher; overload;

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

    function EncryptBlock(const Data, Key: ByteArray): ByteArray;
    function DecryptBlock(const Data, Key: ByteArray): ByteArray;

    function EncryptData(const Data: ByteArray): ByteArray;
    function DecryptData(const Data: ByteArray): ByteArray;

    class function AES: TCipher; static;
    function Copy: TCipher;

    class operator Explicit(const Name: string): TCipher;
    class operator Explicit(AlgID: Integer): TCipher;

    class function Name(Index: Cardinal): string; static;
    class function Count: Integer; static;

    property Algorithm: ICipherAlgorithm read FAlgorithm;
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

function TCipher.IsAssigned: Boolean;
begin
  Result:= FAlgorithm <> nil;
end;

class function TCipher.AES: TCipher;
begin
  HResCheck(FServer.GetByAlgID(TF_ALG_AES, Result.FAlgorithm));
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

function TCipher.SetFlags(AFlags: LongWord): TCipher;
begin
  HResCheck(FAlgorithm.SetKeyParam(TF_KP_FLAGS, @AFlags, SizeOf(AFlags)));
  Result:= Self;
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
