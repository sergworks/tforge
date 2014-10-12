{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfHashes;

interface

{$I TFL.inc}

uses SysUtils, Classes, tfTypes, tfBytes, tfConsts, tfExceptions,
     {$IFDEF TFL_DLL} tfImport {$ELSE} tfHashServ, tfHMAC {$ENDIF};

type
  THMAC = record
  private
    FAlgorithm: IHMACAlgorithm;
  public
//    constructor Create(const HMACAlg: IHMACAlgorithm);
    class function Create(const HMACAlg: IHMACAlgorithm): THMAC; static;
    procedure Free;
    function IsAssigned: Boolean;

    procedure Init(AKey: ByteArray); inline;
    procedure Update(const Data; DataSize: LongWord); inline;
    procedure Done(var Digest); inline;
    procedure Burn; inline;
    function DigestSize: LongInt; inline;

    function Digest: ByteArray;
    function Copy: THMAC;

    class function MD5: THMAC; static;
    class function SHA1: THMAC; static;
    class function SHA256: THMAC; static;

    class operator Explicit(const Name: string): THMAC;
    class operator Explicit(AlgID: Integer): THMAC;

    function ExpandKey(const Key; KeySize: LongWord): THMAC; overload;
    function ExpandKey(const Key: ByteArray): THMAC; overload;
    function UpdateData(const Data; DataSize: LongWord): THMAC; overload;
    function UpdateData(const Bytes: ByteArray): THMAC; overload;
    function UpdateStream(Stream: TStream; BufSize: Integer = 0): THMAC;
    function UpdateFile(const AFileName: string; BufSize: Integer = 0): THMAC;

    function DeriveKey(const Password, Salt: ByteArray;
                       Rounds, DKLen: Integer): ByteArray;

    property Algorithm: IHMACAlgorithm read FAlgorithm;
  end;

  THash = record
  private
    class var FServer: IHashServer;
  private
    FAlgorithm: IHashAlgorithm;
  public
    class function Create(const HashAlg: IHashAlgorithm): THash; static;
    procedure Free;
    function IsAssigned: Boolean;

    procedure Init; inline;
    procedure Update(const Data; DataSize: LongWord); inline;
    procedure Done(var Digest); inline;
    procedure Burn; inline;
    function DigestSize: LongInt; inline;
    function BlockSize: LongInt; inline;

    function Digest: ByteArray;
    function Copy: THash;

    class function CRC32: THash; static;
    class function JenkinsOne: THash; static;
    class function MD5: THash; static;
    class function SHA1: THash; static;
    class function SHA256: THash; static;

//    class function ByName(const HashName: string): THash; static;
//    class function ByAlgID(AlgID: Integer): THash; static;
    class function HashName(Index: Integer): string; static;
    class function Count: Integer; static;

    class operator Explicit(const Name: string): THash;
    class operator Explicit(AlgID: Integer): THash;

    function UpdateData(const Data; DataSize: LongWord): THash; overload;
    function UpdateData(const Bytes: ByteArray): THash; overload;
    function UpdateStream(Stream: TStream; BufSize: Integer = 0): THash;
    function UpdateFile(const AFileName: string; BufSize: Integer = 0): THash;

    function DeriveKey(const Password, Salt: ByteArray;
                       Rounds, DKLen: Integer): ByteArray;

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

class function THash.Create(const HashAlg: IHashAlgorithm): THash;
begin
  Result.FAlgorithm:= HashAlg;
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
  HResCheck(FServer.GetByName(Pointer(Name), SizeOf(Char), Result.FAlgorithm));
//  Result:= ByName(Name);
end;

class operator THash.Explicit(AlgID: Integer): THash;
begin
  HResCheck(FServer.GetByAlgID(AlgID, Result.FAlgorithm));
//  Result:= ByAlgID(AlgID);
end;

procedure THash.Burn;
begin
  FAlgorithm.Burn;
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
//  Result:= ByAlgID(TF_ALG_CRC32);
  HResCheck(FServer.GetByAlgID(TF_ALG_CRC32, Result.FAlgorithm));
end;

class function THash.JenkinsOne: THash;
begin
//  Result:= ByAlgID(TF_ALG_JENKINS_1);
  HResCheck(FServer.GetByAlgID(TF_ALG_JENKINS_1, Result.FAlgorithm));
end;

class function THash.MD5: THash;
begin
//  Result:= Get('MD5');
//  Result:= ByAlgID(TF_ALG_MD5);
  HResCheck(FServer.GetByAlgID(TF_ALG_MD5, Result.FAlgorithm));
end;

class function THash.SHA1: THash;
begin
//  Result:= ByAlgID(TF_ALG_SHA1);
  HResCheck(FServer.GetByAlgID(TF_ALG_SHA1, Result.FAlgorithm));
end;

class function THash.SHA256: THash;
begin
//  Result:= Get('SHA256');
//  Result:= ByAlgID(TF_ALG_SHA256);
  HResCheck(FServer.GetByAlgID(TF_ALG_SHA256, Result.FAlgorithm));
end;

function THash.DeriveKey(const Password, Salt: ByteArray;
                         Rounds, DKLen: Integer): ByteArray;
begin
  HResCheck(FServer.PBKDF1(FAlgorithm,
                           Password.GetRawData, Password.GetLen,
                           Salt.GetRawData, Salt.GetLen,
                           Rounds, DKLen, IBytes(Result)));
end;
{
class function THash.ByName(const HashName: string): THash;
begin
//  HResCheck(GetHashServer(Inst));
  HResCheck(FServer.GetByName(Pointer(HashName), SizeOf(Char), Result.FAlgorithm));
end;

class function THash.ByAlgID(AlgID: Integer): THash;
begin
  HResCheck(FServer.GetByAlgID(AlgID, Result.FAlgorithm));
end;
}
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

function THash.UpdateData(const Bytes: ByteArray): THash;
begin
  FAlgorithm.Update(Bytes.RawData, Bytes.Len);
  Result.FAlgorithm:= FAlgorithm;
end;


function THash.UpdateStream(Stream: TStream; BufSize: Integer): THash;
const
  MIN_BUFSIZE = 4 * 1024;
  MAX_BUFSIZE = 4 * 1024 * 1024;
  DEFAULT_BUFSIZE = 16 * 1024;

var
  Buffer: Pointer;
  N: Integer;

begin
  if (BufSize < MIN_BUFSIZE) or (BufSize > MAX_BUFSIZE)
    then BufSize:= DEFAULT_BUFSIZE;

  GetMem(Buffer, BufSize);
  try
    repeat
      N:= Stream.Read(Buffer^, BufSize);
      if N <= 0 then Break
      else
        FAlgorithm.Update(Buffer, N);
    until False;

    Result.FAlgorithm:= FAlgorithm;

  finally
    FreeMem(Buffer);
  end;
end;

function THash.UpdateFile(const AFileName: string; BufSize: Integer): THash;
var
  Stream: TStream;

begin
  Stream:= TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result:= UpdateStream(Stream, BufSize);
  finally
    Stream.Free;
  end;
end;

{ THMAC }
{
constructor THMAC.Create(const HMACAlg: IHMACAlgorithm);
begin
  FAlgorithm:= HMACAlg;
end;
}

class function THMAC.Create(const HMACAlg: IHMACAlgorithm): THMAC;
begin
  Result.FAlgorithm:= HMACAlg;
end;

procedure THMAC.Free;
begin
  FAlgorithm:= nil;
end;

function THMAC.IsAssigned: Boolean;
begin
  Result:= FAlgorithm <> nil;
end;

procedure THMAC.Init(AKey: ByteArray);
begin
  FAlgorithm.Init(AKey.GetRawData, AKey.GetLen);
end;

procedure THMAC.Update(const Data; DataSize: LongWord);
begin
  FAlgorithm.Update(@Data, DataSize);
end;

procedure THMAC.Done(var Digest);
begin
  FAlgorithm.Done(@Digest);
end;

class operator THMAC.Explicit(const Name: string): THMAC;
var
  HashAlgorithm: IHashAlgorithm;

begin
  HResCheck(THash.FServer.GetByName(Pointer(Name), SizeOf(Char), HashAlgorithm));
  HResCheck(GetHMACAlgorithm(PHMACAlg(Result.FAlgorithm), HashAlgorithm));
end;

class operator THMAC.Explicit(AlgID: Integer): THMAC;
var
  HashAlgorithm: IHashAlgorithm;

begin
  HResCheck(THash.FServer.GetByAlgID(AlgID, HashAlgorithm));
  HResCheck(GetHMACAlgorithm(PHMACAlg(Result.FAlgorithm), HashAlgorithm));
end;

procedure THMAC.Burn;
begin
  FAlgorithm.Burn;
end;

function THMAC.DigestSize: LongInt;
begin
  Result:= FAlgorithm.GetDigestSize;
end;

function THMAC.Digest: ByteArray;
begin
  Result:= ByteArray.Allocate(DigestSize);
  FAlgorithm.Done(Result.GetRawData);
end;

function THMAC.Copy: THMAC;
begin
  HResCheck(FAlgorithm.Duplicate(Result.FAlgorithm));
end;

class function THMAC.MD5: THMAC;
var
  HashAlgorithm: IHashAlgorithm;

begin
  HResCheck(THash.FServer.GetByAlgID(TF_ALG_MD5, HashAlgorithm));
  HResCheck(GetHMACAlgorithm(PHMACAlg(Result.FAlgorithm), HashAlgorithm));
end;

class function THMAC.SHA1: THMAC;
var
  HashAlgorithm: IHashAlgorithm;

begin
  HResCheck(THash.FServer.GetByAlgID(TF_ALG_SHA1, HashAlgorithm));
  HResCheck(GetHMACAlgorithm(PHMACAlg(Result.FAlgorithm), HashAlgorithm));
end;

class function THMAC.SHA256: THMAC;
var
  HashAlgorithm: IHashAlgorithm;

begin
  HResCheck(THash.FServer.GetByAlgID(TF_ALG_SHA256, HashAlgorithm));
  HResCheck(GetHMACAlgorithm(PHMACAlg(Result.FAlgorithm), HashAlgorithm));
end;

function THMAC.DeriveKey(const Password, Salt: ByteArray; Rounds,
  DKLen: Integer): ByteArray;
begin
  HResCheck(FAlgorithm.PBKDF2(
                           Password.GetRawData, Password.GetLen,
                           Salt.GetRawData, Salt.GetLen,
                           Rounds, DKLen, IBytes(Result)));
end;

function THMAC.ExpandKey(const Key; KeySize: LongWord): THMAC;
begin
  FAlgorithm.Init(@Key, KeySize);
  Result.FAlgorithm:= FAlgorithm;
end;

function THMAC.ExpandKey(const Key: ByteArray): THMAC;
begin
  FAlgorithm.Init(Key.GetRawData, Key.GetLen);
  Result.FAlgorithm:= FAlgorithm;
end;

function THMAC.UpdateData(const Data; DataSize: LongWord): THMAC;
begin
  FAlgorithm.Update(@Data, DataSize);
  Result.FAlgorithm:= FAlgorithm;
end;

function THMAC.UpdateData(const Bytes: ByteArray): THMAC;
begin
  FAlgorithm.Update(Bytes.RawData, Bytes.Len);
  Result.FAlgorithm:= FAlgorithm;
end;

function THMAC.UpdateStream(Stream: TStream; BufSize: Integer): THMAC;
const
  MIN_BUFSIZE = 4 * 1024;
  MAX_BUFSIZE = 4 * 1024 * 1024;
  DEFAULT_BUFSIZE = 16 * 1024;

var
  Buffer: Pointer;
  N: Integer;

begin
  if (BufSize < MIN_BUFSIZE) or (BufSize > MAX_BUFSIZE)
    then BufSize:= DEFAULT_BUFSIZE;

  GetMem(Buffer, BufSize);
  try
    repeat
      N:= Stream.Read(Buffer^, BufSize);
      if N <= 0 then Break
      else
        FAlgorithm.Update(Buffer, N);
    until False;

    Result.FAlgorithm:= FAlgorithm;

  finally
    FreeMem(Buffer);
  end;
end;

function THMAC.UpdateFile(const AFileName: string; BufSize: Integer): THMAC;
var
  Stream: TStream;

begin
  Stream:= TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result:= UpdateStream(Stream, BufSize);
  finally
    Stream.Free;
  end;
end;

{$IFNDEF TFL_DLL}
initialization
  GetHashServer(THash.FServer);

{$ENDIF}
end.
