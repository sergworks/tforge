{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ *********************************************************** }

unit tfHashAlgs;

interface

uses SysUtils, tfTypes, tfCRC32, tfSHA256, tfMD5, tfConsts;

type
  HashAlg = record
    class function CRC32: IHashAlgorithm; static;
    class function MD5: IHashAlgorithm; static;
    class function SHA256: IHashAlgorithm; static;
    class function Get(const AName: string): IHashAlgorithm; static;
    class function Name(Index: Integer): string; static;
    class function Count: Integer; static;
  end;

implementation

class function HashAlg.CRC32: IHashAlgorithm;
begin
  if GetCRC32Algorithm(Result) <> TF_S_OK then OutOfMemoryError;
end;

class function HashAlg.MD5: IHashAlgorithm;
begin
  if GetMD5Algorithm(Result) <> TF_S_OK then OutOfMemoryError;
end;

class function HashAlg.SHA256: IHashAlgorithm;
begin
  if GetSHA256Algorithm(Result) <> TF_S_OK then OutOfMemoryError;
end;

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

end.
