unit TestUtils;

interface

uses
  SysUtils, Classes, tfTypes, tfArrays;

function GetPaddingName(Padding: UInt32): string;
function RandByteArray(Size: Cardinal): ByteArray;
function EqualFiles(const Name1, Name2: string): Boolean;
procedure CreateTestFile(ASize: Integer; const AName: string = '');
function FileSizeByName(const Name: string): Int64;

implementation

function FileSizeByName(const Name: string): Int64;
var
  Stream: TStream;

begin
  Stream:= TFileStream.Create(Name, fmOpenRead or fmShareDenyNone);
  try
    Result:= Stream.Seek(0, soEnd);
  finally
    Stream.Free;
  end;
end;

procedure CreateTestFile(ASize: Integer; const AName: string);
var
  Name: string;
  P, P1: PByte;
  I: Integer;
  Stream: TStream;

begin
  if AName <> '' then
    Name:= AName
  else
    Name:= 'test.bak';
  GetMem(P, ASize);
  try
    I:= 0;
    P1:= P;
    while I < ASize do begin
      P1^:= I;
      Inc(P1);
      Inc(I);
    end;
    Stream:= TFileStream.Create(Name, fmCreate);
    try
      Stream.WriteBuffer(P^, ASize);
    finally
      Stream.Free;
    end;
  finally
    FreeMem(P);
  end;
end;

function EqualFiles(const Name1, Name2: string): Boolean;
const
  BUFSIZE = 16 * 1024;

var
  Stream1, Stream2: TStream;
  Buffer1, Buffer2: Pointer;
  N1, N2: Integer;

begin
  Stream1:= TFileStream.Create(Name1, fmOpenRead or fmShareDenyNone);
  try
    Stream2:= TFileStream.Create(Name2, fmOpenRead or fmShareDenyNone);
    Result:= Stream1.Size = Stream2.Size;
    if not Result then Exit;
    try
      GetMem(Buffer1, BUFSIZE);
      try
        GetMem(Buffer2, BUFSIZE);
        try
          repeat
            N1:= Stream1.Read(Buffer1^, BUFSIZE);
            N2:= Stream2.Read(Buffer2^, BUFSIZE);
            if N1 <> N2 then begin
              Result:= False;
              Exit;
            end;
            Result:= CompareMem(Buffer1, Buffer2, N1);
            if not Result then Exit;
          until N1 < BUFSIZE;
        finally
          FreeMem(Buffer2, BUFSIZE);
        end;
      finally
        FreeMem(Buffer1, BUFSIZE);
      end;
    finally
      Stream2.Free;
    end;
  finally
    Stream1.Free;
  end;
//  Result:= True;
end;

function GetPaddingName(Padding: UInt32): string;
begin
  case Padding of
    TF_PADDING_DEFAULT: Result:= 'PADDING_DEFAULT';
    TF_PADDING_NONE: Result:= 'PADDING_NONE';
    TF_PADDING_ZERO: Result:= 'PADDING_ZERO';
    TF_PADDING_ANSI: Result:= 'PADDING_ANSI';
    TF_PADDING_PKCS: Result:= 'PADDING_PKCS';
    TF_PADDING_ISO: Result:= 'PADDING_ISO';
  else
    raise Exception.Create('Invalid Padding: ' + IntToHex(Padding, 8));
  end;
end;

function RandByteArray(Size: Cardinal): ByteArray;
var
  P: PByte;

begin
  Randomize;
  Result:= ByteArray.Alloc(Size);
  P:= Result.Raw;
  while Size > 0 do begin
    P^:= Byte(Random(256));
    Inc(P);
    Dec(Size);
  end;
end;

end.
