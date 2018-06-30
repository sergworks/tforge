{
                       TForge Library
        Copyright (c) Sergey Kasandrov 1997, 2018
  -------------------------------------------------------
  # funny tricks with ICipher interface must be implemented
      as inline static class methods of TCipherHelper
  # due to inlining the unit should be 'used'
      in implementation section of other units
}

unit tfCipherHelpers;

{$I TFL.inc}

interface

uses
  tfTypes;

type
  TCipherHelper = record
  private type
    TVTable = array[0..18] of Pointer;
    PVTable = ^TVTable;
    PPVTable = ^PVTable;

  public type
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
  public
    class function GetBlockSize(Inst: Pointer): Integer; static; inline;
    class function ExpandKey(Inst: Pointer; Key: Pointer;
                     KeySize: Cardinal): TF_RESULT; static; inline;

    class function GetEncryptBlockFunc(Inst: Pointer): Pointer; static; inline;
    class function GetDecryptBlockFunc(Inst: Pointer): Pointer; static; inline;
    class function GetKeyStreamFunc(Inst: Pointer): Pointer; static; inline;
    class function GetKeyBlockFunc(Inst: Pointer): Pointer; static; inline;
  end;

implementation

const
  INDEX_BURN = 3;
  INDEX_DUPLICATE = 4;
  INDEX_EXPANDKEY = 5;
  INDEX_GETBLOCKSIZE = 8;
  INDEX_ENCRYPTBLOCK = 11;
  INDEX_DECRYPTBLOCK = 12;
  INDEX_GETKEYSTREAM = 13;
  INDEX_GETKEYBLOCK = 14;

{ TCipherHelper }

class function TCipherHelper.GetBlockSize(Inst: Pointer): Integer;
begin
  Result:= TGetBlockSizeFunc(PPVTable(Inst)^^[INDEX_GETBLOCKSIZE])(Inst);
end;

class function TCipherHelper.ExpandKey(Inst: Pointer; Key: Pointer; KeySize: Cardinal): TF_RESULT;
begin
  Result:= TExpandKeyFunc(PPVTable(Inst)^^[INDEX_EXPANDKEY])(Inst, Key, KeySize);
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
