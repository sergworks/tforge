{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2013         * }
{ *********************************************************** }

unit tfClasses;

interface

uses SysUtils, Classes, tfTypes, tfConsts;

// to get a file's MD5 use:
//   var
//     MD5Digest: TMD5Digest;
//   begin
//     HashFunction.Create(HashAlg.MD5).HashFile(FileName, MD5Digest);

type
  HashFunction = record
  private
    FAlgorithm: IHashAlgorithm;
  public
    constructor Create(const AAlgorithm: IHashAlgorithm);
    procedure Init; inline;
    procedure Update(var Data; DataSize: LongWord); inline;
    procedure Done(var Digest); inline;
    function HashSize: LongInt; inline;
    procedure Purge; inline;
    procedure Free;

    procedure HashMemory(var Memory; MemorySize: LongWord; var Digest); overload;
    procedure HashBytes(const Bytes: TBytes; var Digest); overload;
    procedure HashStream(Stream: TStream; var Digest; BufSize: Integer = 0); overload;
    procedure HashFile(const AFileName: string; var Digest); overload;

    function HashMemory(var Memory; MemorySize: LongWord): TBytes; overload;
    function HashBytes(const Bytes: TBytes): TBytes; overload;
    function HashStream(Stream: TStream; BufSize: Integer = 0): TBytes; overload;
    function HashFile(const AFileName: string): TBytes; overload;
  end;

// HexConv type implements conversion routines for hexadecimal strings, ex:
//     HexConv.HexToText('313233') = '123'
type
  HexConv = record
    class function HexToData(const Hex: string; Data: PByte;
            var DataLen: Integer; Reverse: Boolean = False): Boolean; static;
    class function HexToBytes(const Hex: string;
                   Reverse: Boolean = False): TBytes; static;
    class function HexToText(const Hex: string): string; static;
    class function DataToHex(const Data; DataSize: Cardinal): string; static;
    class function BytesToHex(const Data: TBytes): string; static;
    class function TextToHex(const Text: string): string; static;
    class function TextToBytes(const Text: string): TBytes; static;
  end;

type
  ByteArray = record
  private
    FBytes: TBytes;
    function Get(Index: Integer): Byte;
  public
    class function FromBit7String(const S: string): ByteArray; static;
    class function FromText(const S: string): ByteArray; static;
    class operator BitwiseXor(const A, B: ByteArray): ByteArray;
    function Slice(I: Integer; L: Integer = 0): ByteArray;
    function Len: Integer;
    function ToText: string;
    property Bytes[Index: Integer]: Byte read Get; default;
  end;

implementation

{ THash }

constructor HashFunction.Create(const AAlgorithm: IHashAlgorithm);
begin
  FAlgorithm:= AAlgorithm;
end;

procedure HashFunction.Init;
begin
  FAlgorithm.Init;
end;

procedure HashFunction.Update(var Data; DataSize: LongWord);
begin
  FAlgorithm.Update(@Data, DataSize);
end;

procedure HashFunction.Done(var Digest);
begin
  FAlgorithm.Done(@Digest);
end;

function HashFunction.HashSize: LongInt;
begin
  Result:= FAlgorithm.GetHashSize;
end;

procedure HashFunction.Free;
begin
  FAlgorithm:= nil;
end;

procedure HashFunction.Purge;
begin
  FAlgorithm.Purge;
end;

procedure HashFunction.HashMemory(var Memory; MemorySize: LongWord; var Digest);
begin
  Init;
  Update(Memory, MemorySize);
  Done(Digest);
end;

function HashFunction.HashMemory(var Memory; MemorySize: LongWord): TBytes;
begin
  Result:= nil;
  SetLength(Result, HashSize);
  HashMemory(Memory, MemorySize, Pointer(Result)^);
end;

procedure HashFunction.HashStream(Stream: TStream; var Digest; BufSize: Integer);
const
  MIN_SIZE = 1024;
  MAX_SIZE = 1024 * 1024;
  DEFAULT_SIZE = 16 * 1024;

var
  Buf: Pointer;
  N: Integer;

begin
  if (BufSize < MIN_SIZE) or (BufSize > MAX_SIZE)
    then BufSize:= DEFAULT_SIZE;
  GetMem(Buf, BufSize);
  try
    Init;
    try
      repeat
        N:= Stream.Read(Buf^, BufSize);
        if N = 0 then Break;
        Update(Buf^, N);
      until False;
      Done(Digest);
    except
      Purge;
      raise;
    end;
  finally
    FreeMem(Buf, BufSize);
  end;
end;

function HashFunction.HashStream(Stream: TStream; BufSize: Integer): TBytes;
var
  Tmp: TBytes;

begin
  Result:= nil;
  SetLength(Tmp, HashSize);
  HashStream(Stream, Pointer(Tmp)^, BufSize);
  Result:= Tmp;
end;

procedure HashFunction.HashBytes(const Bytes: TBytes; var Digest);
begin
  HashMemory(Pointer(Bytes)^, Length(Bytes), Digest);
end;

function HashFunction.HashBytes(const Bytes: TBytes): TBytes;
begin
  Result:= nil;
  SetLength(Result, HashSize);
  HashMemory(Pointer(Bytes)^, Length(Bytes), Pointer(Result)^);
end;

procedure HashFunction.HashFile(const AFileName: string; var Digest);
var
  Stream: TStream;

begin
  Stream:= TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    HashStream(Stream, Digest);
  finally
    Stream.Free;
  end;
end;

function HashFunction.HashFile(const AFileName: string): TBytes;
var
  Tmp: TBytes;

begin
  Result:= nil;
  SetLength(Tmp, HashSize);
  HashFile(AFileName, Pointer(Tmp)^);
  Result:= Tmp;
end;

{ HexConv }

class function HexConv.BytesToHex(const Data: TBytes): string;
begin
  Result:= DataToHex(Pointer(Data)^, Length(Data));
end;

class function HexConv.DataToHex(const Data; DataSize: Cardinal): string;
var
  I: Cardinal;
  P1: PByte;
  P2: PChar;
  Hex: string;

begin
  SetLength(Result, DataSize shl 1);
  if DataSize = 0 then Exit;
  P1:= @Data;
  P2:= Pointer(Result);
  for I:= 0 to DataSize - 1 do begin
    Hex:= IntToHex(P1^, 2);
    P2^:= Hex[1];
    Inc(P2);
    P2^:= Hex[2];
    Inc(P2);
    Inc(P1);
  end;
end;

class function HexConv.HexToBytes(const Hex: string; Reverse: Boolean): TBytes;
var
  L: Integer;

begin
  Result:= nil;
  L:= 0;
  HexToData(Hex, nil, L);
  if L <= 0 then Exit;
  SetLength(Result, L);
  HexToData(Hex, Pointer(Result), L, Reverse);
end;

class function HexConv.HexToData(const Hex: string; Data: PByte;
               var DataLen: Integer; Reverse: Boolean): Boolean;
var
  L, N, Index, Value: Integer;

begin
  if Odd(Length(Hex))
    then raise EConvertError.CreateResFmt(@SOddStringLength, [Length(Hex)]);
  L:= Length(Hex) shr 1;
  Result:= DataLen >= L;
  DataLen:= L;
  if not Result then Exit;
  N:= 0;
  while N < L do begin
    if Reverse then
      Index:= (L - N) shl 1 - 1
    else
      Index:= 1 + N shl 1;
    if not TryStrToInt('$' + Copy(Hex, Index, 2), Value)
      then raise EConvertError.CreateResFmt(@SInvalidHexCode,
                [Copy(Hex, Index, 2)]);
    Data^:= Byte(Value);
    Inc(Data);
    Inc(N);
  end;
end;

// HexConv.HexToText('313233616263') = '123abc'
class function HexConv.HexToText(const Hex: string): string;
var
  I: Integer;
  Tmp: Integer;

begin
  if Odd(Length(Hex))
    then raise EConvertError.CreateResFmt(@SOddStringLength, [Length(Hex)]);
  SetLength(Result, Length(Hex) shr 1);
  for I:= 0 to Length(Result) - 1 do begin
    if not TryStrToInt('$' + Copy(Hex, 1 + I shl 1, 2), Tmp)
      then raise EConvertError.CreateResFmt(@SInvalidHexCode,
                [Copy(Hex, 1 + I shl 1, 2)]);
    Result[I + 1]:= Char(Tmp);
  end;
end;

// HexConv.TextToHex('123abc') = '313233616263'
class function HexConv.TextToHex(const Text: string): string;
var
  I: Integer;
  P1, P2: PChar;
  Hex: string;

begin
  SetLength(Result, Length(Text) shl 1);
  P1:= Pointer(Text);
  P2:= Pointer(Result);
  for I:= 0 to Length(Text) - 1 do begin
    Hex:= IntToHex(PByte(P1)^, 2);
    P2^:= Hex[1];
    Inc(P2);
    P2^:= Hex[2];
    Inc(P2);
    Inc(P1);
  end;
end;

class function HexConv.TextToBytes(const Text: string): TBytes;
var
  I: Integer;
  P1: PChar;
  P2: PByte;

begin
  SetLength(Result, Length(Text));
  P1:= Pointer(Text);
  P2:= Pointer(Result);
  for I:= 0 to Length(Text) - 1 do begin
    P2^:= PByte(P1)^;
    Inc(P2);
    Inc(P1);
  end;
end;

{ ByteArray }

class operator ByteArray.BitwiseXor(const A, B: ByteArray): ByteArray;
var
  I: Integer;

begin
  Result.FBytes:= nil;
  if A.Len <> B.Len then
    raise Exception.Create('Wrong lengths');
  SetLength(Result.FBytes, A.Len);
  for I:= 0 to Length(Result.FBytes) - 1 do begin
    Result.FBytes[I]:= A.FBytes[I] xor B.FBytes[I];
  end;
end;

class function ByteArray.FromBit7String(const S: string): ByteArray;
var
  Ch: Char;
  I: Integer;
  Tmp: Cardinal;

begin
  Result.FBytes:= nil;
  if Length(S) mod 7 <> 0 then
    raise Exception.Create('Wrong string length');
  SetLength(Result.FBytes, Length(S) div 7);
  I:= 0;
  Tmp:= 0;
  for Ch in S do begin
    Tmp:= Tmp shl 1;
    if Ch = '1' then Tmp:= Tmp or 1
    else if Ch <> '0' then
      raise Exception.Create('Wrong string char');
    Inc(I);
    if I mod 7 = 0 then begin
      Result.FBytes[I div 7 - 1]:= Tmp;
      Tmp:= 0;
    end;
  end;
end;

class function ByteArray.FromText(const S: string): ByteArray;
var
  Ch: Char;
  I: Integer;

begin
  Result.FBytes:= nil;
  SetLength(Result.FBytes, Length(S));
  I:= 0;
  for Ch in S do begin
    if Integer(Ch) >= 256 then
      raise Exception.Create('Wrong string char');
    Result.FBytes[I]:= Byte(Ch);
    Inc(I);
  end;
end;

function ByteArray.Get(Index: Integer): Byte;
begin
  if Cardinal(Index) < Cardinal(Length(FBytes)) then
    Result:= FBytes[Index]
  else
    raise EArgumentOutOfRangeException.CreateResFmt(@SIndexOutOfRange, [Index]);
end;

function ByteArray.Len: Integer;
begin
  Result:= Length(FBytes);
end;

function ByteArray.Slice(I, L: Integer): ByteArray;
var
  LL: Integer;

begin
  Result.FBytes:= nil;
  LL:= Length(FBytes);
  if I < LL then begin
    if (L = 0) or (I + L > LL)
      then L:= LL - I;
    Result.FBytes:= Copy(FBytes, I, L);
  end;
end;

function ByteArray.ToText: string;
var
  I: Integer;
  B: Byte;

begin
  Result:= '';
  SetLength(Result, Len);
  for I:= 0 to Len - 1 do begin
    B:= FBytes[I];
    Result[I + 1]:= Char(B);
  end;
end;

end.
