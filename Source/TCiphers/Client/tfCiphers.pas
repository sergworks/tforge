{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
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

    function KeyParams(AFlags: LongWord; AIV: Pointer; AIVLen: LongWord): TCipher; overload;
    function KeyParams(AFlags: LongWord; AIV: ByteArray): TCipher; overload;

    function Key(AKey: PByte; AKeyLen: LongWord): TCipher; overload;
    function Key(AKey: ByteArray): TCipher; overload;


    procedure ImportKey(Key: PByte; KeyLen: LongWord; Flags: LongWord;
                        AKeyMode: LongWord; AIV: Pointer; AIVLen: LongWord;
                        APadding: LongWord = TF_PADDING_DEFAULT); overload;
    procedure ImportKey(Key: ByteArray; Flags: LongWord;
                        AKeyMode: LongWord; AIV: ByteArray;
                        APadding: LongWord = TF_PADDING_DEFAULT); overload;
    procedure DestroyKey;

    procedure Encrypt(var Data; var DataSize: LongWord;
                      BufSize: LongWord; Last: Boolean); overload;
    procedure Decrypt(var Data; var DataSize: LongWord;
                      Last: Boolean); overload;

    procedure EncryptBlock(var Data); overload;
    procedure DecryptBlock(var Data); overload;

    procedure EncryptBlock(var Data: ByteArray); overload;
    procedure DecryptBlock(var Data: ByteArray); overload;

    function EncryptBytes(const Data: ByteArray): ByteArray; overload;
    function DecryptBytes(const Data: ByteArray): ByteArray; overload;

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

procedure TCipher.ImportKey(Key: PByte; KeyLen: LongWord; Flags: LongWord;
                            AKeyMode: LongWord; AIV: Pointer; AIVLen: LongWord;
                            APadding: LongWord);
begin
//  if AIV <> nil then
    HResCheck(FAlgorithm.SetKeyParam(TF_KP_IV, AIV, AIVLen));
//  if AKeyMode <> 0 then
    HResCheck(FAlgorithm.SetKeyParam(TF_KP_MODE, @AKeyMode, SizeOf(AKeyMode)));
//  if APadding <> 0 then
    HResCheck(FAlgorithm.SetKeyParam(TF_KP_PADDING, @APadding, SizeOf(APadding)));

  HResCheck(FAlgorithm.ExpandKey(Key, KeyLen, Flags));
end;

procedure TCipher.ImportKey(Key: ByteArray; Flags: LongWord;
                        AKeyMode: LongWord; AIV: ByteArray;
                        APadding: LongWord);
begin
  ImportKey(Key.RawData, Key.Len, Flags, AKeyMode, AIV.RawData, AIV.Len, APadding);
end;

procedure TCipher.DestroyKey;
begin
  FAlgorithm.DestroyKey;
end;

function TCipher.Encrypt(const Data: ByteArray): ByteArray;
begin

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

function TCipher.Copy: TCipher;
begin

end;

class function TCipher.Count: Integer;
begin

end;

function TCipher.Decrypt(const Data: ByteArray): ByteArray;
var
  L: LongWord;

begin
  L:= Data.Len;
  Result:= ByteArray.Copy(Data);
  Decrypt(Result.RawData^, L, True);
  Result.Len:= L;
end;

procedure TCipher.DecryptBlock(var Data);
begin

end;

function TCipher.DecryptBlock(const Data: ByteArray): ByteArray;
begin

end;

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

function TCipher.EncryptBlock(const Data: ByteArray): ByteArray;
begin

end;

procedure TCipher.EncryptBlock(var Data);
begin

end;

class operator TCipher.Explicit(AlgID: Integer): TCipher;
begin

end;

class operator TCipher.Explicit(const Name: string): TCipher;
begin

end;

end.
