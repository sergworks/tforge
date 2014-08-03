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
  private
    FAlgorithm: IHashAlgorithm;
    class function Get(const HashName: string): THash; static;
  public
    constructor Create(const AAlgorithm: IHashAlgorithm);
    procedure Free;
    function IsAssigned: Boolean;

    procedure Init; inline;
    procedure Update(const Data; DataSize: LongWord); inline;
    procedure Done(var Digest); inline;
    function DigestSize: LongInt; inline;
    procedure Purge; inline;
    function Digest: ByteArray;
    function Copy: THash;

    class function CRC32: THash; static;
//    class function JenkinsOne: THash; static;
    class function MD5: THash; static;
    class function SHA256: THash; static;

    class function GetInterface(const HashName: string): IHashAlgorithm; static;
    class function Algorithm(Index: Integer): string; static;
    class function Count: Integer; static;

    class function HashMemory(const HashName: string;
                   const Memory; MemorySize: LongWord): THash; static;
    class function HashBytes(const HashName: string;
                   const Bytes: ByteArray): THash; static;
    class function HashStream(const HashName: string;
                   Stream: TStream; BufSize: Integer = 0): THash; static;
    class function HashFile(const HashName: string;
                   const AFileName: string; BufSize: Integer = 0): THash; static;

    class function DeriveKey(const HashName: string;
                   const Password, Salt: ByteArray;
                   Rounds, DKLen: Integer): ByteArray; static;
    class property GetHash[const HashName: string]: THash read Get; default;
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

type
  THashAlgGetter = function(var A: IHashAlgorithm): TF_RESULT;

class function THash.Algorithm(Index: Integer): string;
begin

end;

function THash.Copy: THash;
begin

end;

class function THash.Count: Integer;
var
  Inst: IHashServer;

begin
  HResCheck(GetHashServer(Inst));
  Result:= Inst.GetCount;
end;

class function THash.CRC32: THash;
begin
  Result:= Get('CRC32');
end;

class function THash.MD5: THash;
begin
  Result:= Get('MD5');
end;

class function THash.SHA256: THash;
begin
  Result:= Get('SHA256');
end;
(*
type
  GetAlgFunc = function(var Alg: IHashAlgorithm): TF_RESULT;

  TAlgData = record
    Name: string;
    Getter: GetAlgFunc;
  end;

const
  AlgList: array[0..2] of TAlgData = (
    (Name: 'CRC32'; Getter: GetCRC32Algorithm),
    (Name: 'MD5'; Getter: GetMD5Algorithm),
    (Name: 'SHA256'; Getter: GetSHA256Algorithm)
  );

class function HashAlg.Get(const AName: string): IHashAlgorithm;
var
  UName: string;
  I: Integer;


begin
  Result:= nil;
  UName:= UpperCase(AName);
  I:= 0;
  while I < Length(AlgList) do begin
    if AlgList[I].Name = UName then begin
      if AlgList[I].Getter(Result) <> TF_S_OK then OutOfMemoryError;
      Exit;
    end;
    Inc(I);
  end;
  raise ENotSupportedException.CreateResFmt(@SAlgNotSupported, [AName]);
end;

class function HashAlg.Name(Index: Integer): string;
begin
  Result:= '';
  if (Index >= 0) and (Index < Length(AlgList)) then
    Result:= AlgList[Index].Name
  else
    raise EArgumentOutOfRangeException.CreateResFmt(@SIndexOutOfRange, [Index]);
end;

class function HashAlg.Count: Integer;
begin
  Result:= Length(AlgList);
end;
*)
constructor THash.Create(const AAlgorithm: IHashAlgorithm);
begin

end;

class function THash.DeriveKey(const HashName: string; const Password,
  Salt: ByteArray; Rounds, DKLen: Integer): ByteArray;
begin

end;

function THash.Digest: ByteArray;
begin

end;

function THash.DigestSize: LongInt;
begin

end;

procedure THash.Done(var Digest);
begin

end;

procedure THash.Free;
begin
  FAlgorithm:= nil;
end;

class function THash.Get(const HashName: string): THash;
var
  Inst: IHashServer;

begin
  HResCheck(GetHashServer(Inst));
  HResCheck(Inst.GetByName(Pointer(HashName), SizeOf(Char), Result.FAlgorithm));
end;

class function THash.GetInterface(const HashName: string): IHashAlgorithm;
begin

end;

class function THash.HashBytes(const HashName: string;
  const Bytes: ByteArray): THash;
begin

end;

class function THash.HashFile(const HashName, AFileName: string;
  BufSize: Integer): THash;
begin

end;

class function THash.HashMemory(const HashName: string; const Memory;
  MemorySize: LongWord): THash;
begin

end;

class function THash.HashStream(const HashName: string; Stream: TStream;
  BufSize: Integer): THash;
begin

end;

procedure THash.Init;
begin
  FAlgorithm.Init;
end;

function THash.IsAssigned: Boolean;
begin
  Result:= FAlgorithm <> nil;
end;

procedure THash.Purge;
begin
  FAlgorithm.Purge;
end;

procedure THash.Update(const Data; DataSize: LongWord);
begin

end;

end.
