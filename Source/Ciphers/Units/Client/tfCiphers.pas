{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfCiphers;

interface

{$I TFL.inc}

uses
  SysUtils, tfTypes, tfExceptions, {$IFDEF TFL_DLL}tfImport{$ELSE}tfAES{$ENDIF};

function GetBlockCipherAlgorithm(const AlgName: string): IBlockCipherAlgorithm;

type
  BlockCipherAlgorithm = record
  private
    FAlgorithm: IBlockCipherAlgorithm;
  public
    constructor Create(Alg: IBlockCipherAlgorithm);
    procedure Free;
    function ImportKey(Key: PByte; Flags: LongWord): TF_RESULT;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DestroyKey;{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure EncryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    procedure DecryptBlock(Data: PByte);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
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
  TF_ALG_AES = $1001;

{$IFDEF TFL_DLL}
// todo:
{$ELSE}
const
  BlockCipherAlgs: array[0..0] of TAlgRec = (
    (Name: 'AES'; ID: TF_ALG_AES; Getter: @GetAESAlgorithm)
  );

{$ENDIF}

function GetBlockCipherAlgorithm(const AlgName: string): IBlockCipherAlgorithm;
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
    end;
  end;
end;

{ BlockCipherAlgorithm }

constructor BlockCipherAlgorithm.Create(Alg: IBlockCipherAlgorithm);
begin
  FAlgorithm:= Alg;
end;

procedure BlockCipherAlgorithm.DecryptBlock(Data: PByte);
begin
  FAlgorithm.DecryptBlock(Data);
end;

procedure BlockCipherAlgorithm.DestroyKey;
begin
  FAlgorithm.DestroyKey;
end;

procedure BlockCipherAlgorithm.EncryptBlock(Data: PByte);
begin

end;

procedure BlockCipherAlgorithm.Free;
begin

end;

function BlockCipherAlgorithm.ImportKey(Key: PByte; Flags: LongWord): TF_RESULT;
begin

end;

end.
