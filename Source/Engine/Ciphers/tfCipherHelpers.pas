{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # engine tricks with ICipher interface must be implemented
      as inline static class methods of TCipherHelper
  # exports inlined functions
}

unit tfCipherHelpers;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  TCipherHelper = record
  private type
    TVTable = array[0..24] of Pointer;
    PVTable = ^TVTable;
    PPVTable = ^PVTable;

  public type
    TBlock = array[0..TF_MAX_CIPHER_BLOCK_SIZE - 1] of Byte;

    TGetBlockSizeFunc = function(Inst: Pointer): Integer;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TBlockFunc = function(Inst: Pointer; Data: PByte): TF_RESULT;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TGetKeyStreamFunc = function(Inst: Pointer;
        Data: PByte; DataSize: Cardinal): TF_RESULT;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TExpandKeyFunc = function(Inst: Pointer;
        Key: Pointer; KeySize: Cardinal): TF_RESULT;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TExpandKeyIVFunc = function(Inst: Pointer;
        Key: Pointer; KeySize: Cardinal; IV: Pointer; IVSize: Cardinal): TF_RESULT;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TExpandKeyNonceFunc = function(Inst: Pointer;
        Key: Pointer; KeySize: Cardinal; Nonce: TNonce): TF_RESULT;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TIncBlockNoFunc = function(Inst: Pointer; Count: UInt64): Integer;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
    TSetNonceFunc = function(Inst: Pointer; Nonce: TNonce): Integer;
        {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

  public
    class function ExpandKey(Inst: Pointer; Key: Pointer;
                     KeySize: Cardinal): TF_RESULT; static; inline;
    class function ExpandKeyIV(Inst: Pointer; Key: Pointer; KeySize: Cardinal;
                     IV: Pointer; IVSize: Cardinal): TF_RESULT; static; inline;
    class function GetBlockSize(Inst: Pointer): Integer; static; inline;
    class function IncBlockNo(Inst: Pointer; Count: UInt64): TF_RESULT; static; inline;
    class function DecBlockNo(Inst: Pointer; Count: UInt64): TF_RESULT; static; inline;
    class function SetNonce(Inst: Pointer; Nonce: TNonce): TF_RESULT; static; inline;

    class function EncryptBlock(Inst: Pointer; Data: Pointer): TF_RESULT; static; inline;
    class function DecryptBlock(Inst: Pointer; Data: Pointer): TF_RESULT; static; inline;

    class function GetEncryptBlockFunc(Inst: Pointer): Pointer; static; inline;
    class function GetDecryptBlockFunc(Inst: Pointer): Pointer; static; inline;
    class function GetKeyStreamFunc(Inst: Pointer): Pointer; static; inline;
    class function GetKeyBlockFunc(Inst: Pointer): Pointer; static; inline;
  end;

implementation

const
//  INDEX_BURN = 3;        moved to tfHelpers
//  INDEX_CLONE = 4;
  INDEX_EXPANDKEY = 5;
  INDEX_EXPANDKEYIV = 6;
  INDEX_EXPANDKEYNONCE = 7;
  INDEX_GETBLOCKSIZE = 8;
  INDEX_ENCRYPTUPDATE = 9;
  INDEX_DECRYPTUPDATE = 10;
  INDEX_ENCRYPTBLOCK = 11;
  INDEX_DECRYPTBLOCK = 12;
  INDEX_GETKEYBLOCK = 13;
  INDEX_GETKEYSTREAM = 14;
  INDEX_ENCRYPT = 15;
  INDEX_DECRYPT = 16;
  INDEX_GETISBLOCKCIPHER = 17;
  INDEX_INCBLOCKNO = 18;
  INDEX_DECBLOCKNO = 19;
  INDEX_SKIP = 20;
  INDEX_SETIV = 21;
  INDEX_SETNONCE = 22;
  INDEX_GETIV = 23;
  INDEX_GETNONCE = 24;
  INDEX_GETIVPTR = 25;

{ TCipherHelper }

class function TCipherHelper.GetBlockSize(Inst: Pointer): Integer;
begin
  Result:= TGetBlockSizeFunc(PPVTable(Inst)^^[INDEX_GETBLOCKSIZE])(Inst);
end;

class function TCipherHelper.IncBlockNo(Inst: Pointer; Count: UInt64): TF_RESULT;
begin
  Result:= TIncBlockNoFunc(PPVTable(Inst)^^[INDEX_INCBLOCKNO])(Inst, Count);
end;

class function TCipherHelper.SetNonce(Inst: Pointer; Nonce: TNonce): TF_RESULT;
begin
  Result:= TSetNonceFunc(PPVTable(Inst)^^[INDEX_SETNONCE])(Inst, Nonce);
end;

class function TCipherHelper.DecBlockNo(Inst: Pointer; Count: UInt64): TF_RESULT;
begin
  Result:= TIncBlockNoFunc(PPVTable(Inst)^^[INDEX_DECBLOCKNO])(Inst, Count);
end;

class function TCipherHelper.DecryptBlock(Inst, Data: Pointer): TF_RESULT;
begin
  Result:= TBlockFunc(PPVTable(Inst)^^[INDEX_DECRYPTBLOCK])(Inst, Data);
end;

class function TCipherHelper.EncryptBlock(Inst, Data: Pointer): TF_RESULT;
begin
  Result:= TBlockFunc(PPVTable(Inst)^^[INDEX_ENCRYPTBLOCK])(Inst, Data);
end;

class function TCipherHelper.ExpandKey(Inst: Pointer; Key: Pointer; KeySize: Cardinal): TF_RESULT;
begin
  Result:= TExpandKeyFunc(PPVTable(Inst)^^[INDEX_EXPANDKEY])(Inst, Key, KeySize);
end;

class function TCipherHelper.ExpandKeyIV(Inst, Key: Pointer; KeySize: Cardinal;
                 IV: Pointer; IVSize: Cardinal): TF_RESULT;
begin
  Result:= TExpandKeyIVFunc(PPVTable(Inst)^^[INDEX_EXPANDKEYIV])(Inst, Key, KeySize, IV, IVSize);
end;

class function TCipherHelper.GetEncryptBlockFunc(Inst: Pointer): Pointer;
begin
  Result:= PPVTable(Inst)^^[INDEX_ENCRYPTBLOCK];
end;

class function TCipherHelper.GetDecryptBlockFunc(Inst: Pointer): Pointer;
begin
  Result:= PPVTable(Inst)^^[INDEX_DECRYPTBLOCK];
end;

class function TCipherHelper.GetKeyStreamFunc(Inst: Pointer): Pointer;
begin
  Result:= PPVTable(Inst)^^[INDEX_GETKEYSTREAM];
end;

class function TCipherHelper.GetKeyBlockFunc(Inst: Pointer): Pointer;
begin
  Result:= PPVTable(Inst)^^[INDEX_GETKEYBLOCK];
end;

end.
