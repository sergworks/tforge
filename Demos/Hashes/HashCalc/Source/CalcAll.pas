unit CalcAll;

interface

uses
  SysUtils,
  Classes,
  tfTypes,
  tfBytes,
  tfHashes;

procedure CalcHash(const FileName: string);

implementation

procedure CalcHash(const FileName: string);
const
  BufSize = 16 * 1024;

var
  HashName: array of string;
  HashArr: array of THash;
  Stream: TStream;
  Buffer: array[0 .. BufSize - 1] of Byte;
  I, N, HashCount, L: Integer;

begin
  HashCount:= THash.AlgCount;
  SetLength(HashName, HashCount);
  SetLength(HashArr, HashCount);
  L:= 0;
  for I:= 0 to HashCount - 1 do begin
    HashName[I]:= THash.AlgName(I);
    if Length(HashName[I]) > L then L:= Length(HashName[I]);
    HashArr[I]:= THash(HashName[I]);
  end;
  Stream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    repeat
      N:= Stream.Read(Buffer, BufSize);
      if N <= 0 then Break
      else begin
        for I:= 0 to HashCount - 1 do begin
          HashArr[I].Update(Buffer, N);
        end;
      end;
    until False;
  finally
    Stream.Free;
  end;
  for I:= 0 to HashCount - 1 do begin
    Writeln(HashName[I]:L, ':  ', HashArr[I].Digest.ToHex);
  end;
end;

end.
