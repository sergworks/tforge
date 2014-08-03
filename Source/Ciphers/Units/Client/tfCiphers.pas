{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfCiphers;

interface

{$I TFL.inc}

uses
  SysUtils, tfTypes, tfBytes, tfConsts, tfExceptions,
  {$IFDEF TFL_DLL}tfImport{$ELSE}tfAES{$ENDIF};

type
  TBlockCipherAlgorithm = record
  private
    FAlgorithm: IBlockCipherAlgorithm;
  public const
    Count = 1;  // number of algorithms supported
  public
    procedure Free;
    procedure ImportKey(Key: PByte; KeyLen: LongWord; Encrypt: Boolean);
    procedure DestroyKey;
    procedure EncryptBlock(Data: PByte);
    procedure DecryptBlock(Data: PByte);

    class function AES: TBlockCipherAlgorithm; static;
    class function GetInterface(const AlgName: string): IBlockCipherAlgorithm; static;
    class function Get(const AlgName: string): TBlockCipherAlgorithm; static;
    class function Name(Index: Cardinal): string; static;
  end;

  TCipher = record
  private
    FCipher: ICipher;
  public const
    Count = 1;  // number of ciphers supported
  public
    procedure Free;
    function IsAssigned: Boolean;
    procedure ImportKey(Key: PByte; KeyLen: LongWord; Encrypt: Boolean;
                        AIV: Pointer = nil; AIVLen: LongWord = 0;
                        AKeyMode: LongWord = 0; APadding: LongWord = 0); overload;
    procedure ImportKey(Key: ByteArray; Encrypt: Boolean;
                        AIV: Pointer = nil; AIVLen: LongWord = 0;
                        AKeyMode: LongWord = 0; APadding: LongWord = 0); overload;
    procedure DestroyKey;
// todo: procedure DeriveKey();
    procedure Encrypt(var Data; var DataSize: LongWord;
                      BufSize: LongWord; Last: Boolean);
    procedure Decrypt(var Data; var DataSize: LongWord;
                      Last: Boolean);

    function DecryptBytes(const Data: ByteArray): ByteArray;
    class function AES: TCipher; static;
    class function GetInterface(const AName: string): ICipher; static;
    class function Get(const AName: string): TCipher; static;
    class function Name(Index: Cardinal): string; static;
  end;

(*
{$HINTS OFF}
    FVTable: Pointer;
    FRefCount: Integer;
{$HINTS ON}
    FAlgorithm: IBlockCipherAlgorithm;
  private type
    TBlock = record
      case Byte of                      // up to 256-bit block size
        0: (Bytes: array[0..31] of Byte);
        1: (Words: array[0..15] of Word);
        2: (DWords: array[0..7] of LongWord);
        3: (QWords: array[0..3] of UInt64);
    end;
  public
    FBufferSize: Integer;
    FIVector: TBlock;
    FBlockSize: LongWord;           // block size in bytes = 8, 16, 32
                                    //   should be a power of 2
    FMode: LongWord;
//    FModeBits: LongWord;
    FKeyExpanded: Boolean;

//    procedure ResetKey;

//    function EncryptECB(Data: PByte; var DataSize: LongWord;
//             BufSize: LongWord; Last: Boolean): Boolean; virtual;

  public

    function EncryptCBC(Data: PByte; DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): LongWord;

    function DecryptCBC(Data: PByte; DataSize: LongWord;
             Last: Boolean): LongWord;

    function DecryptCTR(Data: PByte; DataSize: LongWord;
             Last: Boolean): LongWord;

    function GetKeyParam(Param: LongWord; Data: PByte; var DataLen: LongWord): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function SetKeyParam(Param: LongWord; Data: PByte; DataLen: LongWord): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function DeriveKey(HashAlg: IHashAlgorithm; Flags: LongWord): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DestroyKey;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Encrypt(Data: PByte; var DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    function Decrypt(Data: PByte; var DataSize: LongWord;
             Last: Boolean): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

{
    function EncryptCFB(Data: PByte; var DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): TF_RESULT;
}
//    function DecryptECB(Data: PByte; var DataSize: LongWord;
//             Last: Boolean): TF_RESULT;

{    function DecryptCFB(Data: PByte; var DataSize: LongWord;
             Last: Boolean): Boolean; virtual;

//-------- interface methods --------//

    function GetKeyParam(Param: LongWord; Data: PByte;
             var DataLen: LongWord): Boolean; virtual; stdcall;

    function SetKeyParam(Param: LongWord; Data: PByte): Boolean; virtual; stdcall;

    function Encrypt(Data: PByte; var DataSize: LongWord;
             BufSize: LongWord; Last: Boolean): Boolean; virtual; stdcall;

    function Decrypt(Data: PByte; var DataSize: LongWord;
             Last: Boolean): Boolean; virtual; stdcall;

//---- end of interface methods -----//
}
    property Mode: LongWord read FMode write FMode;
  end;

//  function GetBlockCipher(var P: PBlockCipher;
//                          Alg: IBlockCipherAlgorithm): TF_RESULT;
*)

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

{ BlockCipherAlgorithm }

class function TBlockCipherAlgorithm.AES: TBlockCipherAlgorithm;
begin
{$IFDEF TFL_DLL}
  HResCheck(GetAESAlgorithm(Result.FAlgorithm))
{$ELSE}
  HResCheck(GetAESAlgorithm(PAESAlgorithm(Result.FAlgorithm)));
{$ENDIF}
end;

procedure TBlockCipherAlgorithm.ImportKey(Key: PByte; KeyLen: LongWord; Encrypt: Boolean);
begin
  if Encrypt then KeyLen:= KeyLen or TF_KEY_ENCRYPT;
  HResCheck(FAlgorithm.ImportKey(Key, KeyLen));
end;

procedure TBlockCipherAlgorithm.DestroyKey;
begin
  FAlgorithm.DestroyKey;
end;

procedure TBlockCipherAlgorithm.EncryptBlock(Data: PByte);
begin
  FAlgorithm.EncryptBlock(Data);
end;

procedure TBlockCipherAlgorithm.Free;
begin
  FAlgorithm:= nil;
end;

procedure TBlockCipherAlgorithm.DecryptBlock(Data: PByte);
begin
  FAlgorithm.DecryptBlock(Data);
end;

type
  TAlgGetter = function(var A: IBlockCipherAlgorithm): TF_RESULT;

type
  PAlgRec = ^TAlgRec;
  TAlgRec = record
    Name: string;
    ID: Integer;
    Getter: Pointer;
  end;

const
  TF_ALG_AES = $2001;

{$IFDEF TFL_DLL}
// todo:
{$ELSE}
const
  BlockCipherAlgs: array[0 .. TBlockCipherAlgorithm.Count - 1] of TAlgRec = (
    (Name: 'AES'; ID: TF_ALG_AES; Getter: @GetAESAlgorithm)
  );

{$ENDIF}

class function TBlockCipherAlgorithm.GetInterface(
      const AlgName: string): IBlockCipherAlgorithm;
var
  AlgRec: TAlgRec;
  LName: string;
  Tmp: IBlockCipherAlgorithm;

begin
  LName:= UpperCase(AlgName);
  for AlgRec in BlockCipherAlgs do begin
    if LName = AlgRec.Name then begin
      HResCheck(TAlgGetter(AlgRec.Getter)(Tmp));
      Result:= Tmp;
      Exit;
    end;
  end;
end;

class function TBlockCipherAlgorithm.Get(
      const AlgName: string): TBlockCipherAlgorithm;
begin
  Result.FAlgorithm:= GetInterface(AlgName);
end;

class function TBlockCipherAlgorithm.Name(Index: Cardinal): string;
begin
  if Index >= TBlockCipherAlgorithm.Count then
    raise ERangeError.CreateResFmt(@SIndexOutOfRange, [Index]);
  Result:= BlockCipherAlgs[Index].Name;
end;

{ TCipher }

procedure TCipher.Free;
begin
  FCipher:= nil;
end;

function TCipher.IsAssigned: Boolean;
begin
  Result:= FCipher <> nil;
end;

class function TCipher.AES: TCipher;
begin
{$IFDEF TFL_DLL}
  HResCheck(GetAESCipher(Result.FCipher))
{$ELSE}
  HResCheck(GetAESCipher(PAESCipher(Result.FCipher)));
{$ENDIF}
end;

procedure TCipher.ImportKey(Key: PByte; KeyLen: LongWord; Encrypt: Boolean;
                            AIV: Pointer; AIVLen: LongWord;
                            AKeyMode, APadding: LongWord);
begin
  if AIV <> nil then
    HResCheck(FCipher.SetKeyParam(TF_KP_IV, AIV, AIVLen));
  if AKeyMode <> 0 then
    HResCheck(FCipher.SetKeyParam(TF_KP_MODE, @AKeyMode, SizeOf(AKeyMode)));
  if APadding <> 0 then
    HResCheck(FCipher.SetKeyParam(TF_KP_PADDING, @APadding, SizeOf(APadding)));

  HResCheck(FCipher.SetKeyParam(TF_KP_KEY, Key, KeyLen shl 3));
end;

procedure TCipher.ImportKey(Key: ByteArray; Encrypt: Boolean; AIV: Pointer;
                            AIVLen, AKeyMode, APadding: LongWord);
begin
  ImportKey(Key.RawData, Key.Len, Encrypt, AIV, AIVLen, AKeyMode, APadding);
end;

procedure TCipher.DestroyKey;
begin
  FCipher.DestroyKey;
end;

procedure TCipher.Encrypt(var Data; var DataSize: LongWord;
  BufSize: LongWord; Last: Boolean);
begin
  HResCheck(FCipher.Encrypt(@Data, DataSize, BufSize, Last));
end;

procedure TCipher.Decrypt(var Data; var DataSize: LongWord; Last: Boolean);
begin
  HResCheck(FCipher.Decrypt(@Data, DataSize, Last));
end;

function TCipher.DecryptBytes(const Data: ByteArray): ByteArray;
var
  L: LongWord;

begin
  L:= Data.Len;
  Result:= ByteArray.Copy(Data);
  Decrypt(Result.RawData^, L, True);
  Result.Len:= L;
end;

type
  TCipherGetter = function(var A: ICipher): TF_RESULT;

type
  PCipherRec = ^TCipherRec;
  TCipherRec = record
    Name: string;
    ID: Integer;
    Getter: Pointer;
  end;

//const
//  TF_CIPHER_AES = $3001;

{$IFDEF TFL_DLL}
// todo:
{$ELSE}
const
  Ciphers: array[0 .. TCipher.Count - 1] of TCipherRec = (
    (Name: 'AES'; ID: TF_ALG_AES; Getter: @GetAESCipher)
  );

{$ENDIF}

class function TCipher.GetInterface(const AName: string): ICipher;
var
  Rec: TCipherRec;
  LName: string;
  Tmp: ICipher;

begin
  LName:= UpperCase(AName);
  for Rec in Ciphers do begin
    if LName = Rec.Name then begin
      HResCheck(TCipherGetter(Rec.Getter)(Tmp));
      Result:= Tmp;
      Exit;
    end;
  end;
end;

class function TCipher.Get(const AName: string): TCipher;
begin
  Result.FCipher:= GetInterface(AName);
end;

class function TCipher.Name(Index: Cardinal): string;
begin
  if Index >= TCipher.Count then
    raise ERangeError.CreateResFmt(@SIndexOutOfRange, [Index]);
  Result:= Ciphers[Index].Name;
end;

end.
