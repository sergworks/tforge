{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfHashes;

interface

{$I TFL.inc}

uses SysUtils, Classes, tfTypes, tfBytes, tfConsts, tfExceptions,
     {$IFDEF TFL_DLL} tfImport {$ELSE} tfHashServ {$ENDIF};

type
  THash = record
    class var FServer: IHashServer;
  private
    FAlgorithm: IHashAlgorithm;
  public
    constructor Create(const HashAlg: IHashAlgorithm);
    procedure Free;
    function IsAssigned: Boolean;

    procedure Init; inline;
    procedure Update(const Data; DataSize: LongWord); inline;
    procedure Done(var Digest); inline;
    procedure Purge; inline;
    function DigestSize: LongInt; inline;
    function BlockSize: LongInt; inline;

    function Digest: ByteArray;
    function Copy: THash;

    class function CRC32: THash; static;
    class function JenkinsOne: THash; static;
    class function MD5: THash; static;
    class function SHA1: THash; static;
    class function SHA256: THash; static;

    class function ByName(const HashName: string): THash; static;
    class function ByAlgID(AlgID: Integer): THash; static;
    class function HashName(Index: Integer): string; static;
    class function Count: Integer; static;

    class operator Explicit(const Name: string): THash;
    class operator Explicit(AlgID: Integer): THash;

    function UpdateData(const Data; DataSize: LongWord): THash;
    function UpdateBytes(const Bytes: ByteArray): THash;
    function UpdateStream(Stream: TStream; BufSize: Integer = 0): THash;
    function UpdateFile(const AFileName: string; BufSize: Integer = 0): THash;

    class function DeriveKey(const Hash: THash; const Password, Salt: ByteArray;
                       Rounds, DKLen: Integer): ByteArray; static;

    property Algorithm: IHashAlgorithm read FAlgorithm;
  end;

type
  EHashError = class(EForgeError);

implementation

procedure HashError(ACode: TF_RESULT; const Msg: string = '');
begin
  raise EHashError.Create(ACode, Msg);
end;

procedure HResCheck(Value: TF_RESULT); inline;
begin
  if Value <> TF_S_OK then
    HashError(Value);
end;

{ THash }

constructor THash.Create(const HashAlg: IHashAlgorithm);
begin
  FAlgorithm:= HashAlg;
end;

procedure THash.Free;
begin
  FAlgorithm:= nil;
end;

function THash.IsAssigned: Boolean;
begin
  Result:= FAlgorithm <> nil;
end;

procedure THash.Init;
begin
  FAlgorithm.Init;
end;

procedure THash.Update(const Data; DataSize: LongWord);
begin
  FAlgorithm.Update(@Data, DataSize);
end;

procedure THash.Done(var Digest);
begin
  FAlgorithm.Done(@Digest);
end;

class operator THash.Explicit(const Name: string): THash;
begin
  Result:= ByName(Name);
end;

class operator THash.Explicit(AlgID: Integer): THash;
begin
  Result:= ByAlgID(AlgID);
end;

procedure THash.Purge;
begin
  FAlgorithm.Purge;
end;

function THash.DigestSize: LongInt;
begin
  Result:= FAlgorithm.GetDigestSize;
end;

function THash.BlockSize: LongInt;
begin
  Result:= FAlgorithm.GetBlockSize;
end;


function THash.Digest: ByteArray;
begin
  Result:= ByteArray.Allocate(DigestSize);
  FAlgorithm.Done(Result.GetRawData);
end;

function THash.Copy: THash;
begin
  HResCheck(FAlgorithm.Duplicate(Result.FAlgorithm));
end;

class function THash.Count: Integer;
begin
//  HResCheck(GetHashServer(Inst));
  Result:= FServer.GetCount;
end;

class function THash.CRC32: THash;
begin
//  Result:= Get('CRC32');
  Result:= ByAlgID(TF_ALG_CRC32);
end;

class function THash.MD5: THash;
begin
//  Result:= Get('MD5');
  Result:= ByAlgID(TF_ALG_MD5);
end;

class function THash.SHA1: THash;
begin
  Result:= ByAlgID(TF_ALG_SHA1);
end;

class function THash.SHA256: THash;
begin
//  Result:= Get('SHA256');
  Result:= ByAlgID(TF_ALG_SHA256);
end;

class function THash.DeriveKey(const Hash: THash; const Password,
  Salt: ByteArray; Rounds, DKLen: Integer): ByteArray;
begin
  // todo
end;

class function THash.ByName(const HashName: string): THash;
begin
//  HResCheck(GetHashServer(Inst));
  HResCheck(FServer.GetByName(Pointer(HashName), SizeOf(Char), Result.FAlgorithm));
end;

class function THash.ByAlgID(AlgID: Integer): THash;
begin
  HResCheck(FServer.GetByAlgID(AlgID, Result.FAlgorithm));
end;

class function THash.HashName(Index: Integer): string;
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

function THash.UpdateData(const Data; DataSize: LongWord): THash;
begin
  FAlgorithm.Update(@Data, DataSize);
  Result.FAlgorithm:= FAlgorithm;
end;

function THash.UpdateFile(const AFileName: string; BufSize: Integer): THash;
begin

end;

function THash.UpdateStream(Stream: TStream; BufSize: Integer): THash;
begin

end;

function THash.UpdateBytes(const Bytes: ByteArray): THash;
begin
  Result:= UpdateData(Bytes.RawData^, Bytes.Len);
end;


class function THash.JenkinsOne: THash;
begin

end;

{$IFNDEF TFL_DLL}
initialization
  GetHashServer(THash.FServer);

{$ENDIF}
end.
