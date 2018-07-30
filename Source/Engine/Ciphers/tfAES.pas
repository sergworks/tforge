{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfAES;

interface

{$I TFL.inc}

uses
  tfTypes;

type
  PAESInstance = ^TAESInstance;
  TAESInstance = record
  private const
    MaxRounds = 14;

  private type
    PBlock = ^TAESBlock;
    TAESBlock = record
      case Byte of
        0: (Bytes: array[0..15] of Byte);
        1: (LWords: array[0..3] of UInt32);
    end;

    PExpandedKey = ^TExpandedKey;
    TExpandedKey = record
      case Byte of
        0: (Bytes: array[0 .. (MaxRounds + 2) * SizeOf(TAESBlock) - 1] of Byte);
        1: (LWords: array[0 .. (MaxRounds + 2) * (SizeOf(TAESBlock) shr 2) - 1] of UInt32);
        2: (Blocks: array[0 .. MaxRounds + 1] of TAESBlock);
    end;

  private
{$HINTS OFF}
                                // from tfRecord
    FVTable:   Pointer;
    FRefCount: Integer;
                                // from tfBlockCipher
    FValidKey: Boolean;
    FAlgID:    UInt32;

    FIVector:  TAESBlock;
{$HINTS ON}

    FExpandedKey: TExpandedKey;
    FRounds: Cardinal;

    class procedure DoRound(const RoundKey: TAESBlock;
                    var State: TAESBlock; Last: Boolean); static;
    class procedure DoInvRound(const RoundKey: TAESBlock;
                    var State: TAESBlock; First: Boolean); static;
  public
    class function Release(Inst: PAESInstance): Integer; stdcall; static;
    class function ExpandKey(Inst: PAESInstance; Key: PByte; KeySize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
(*
    class function ExpandKeyIV(Inst: PAESInstance; Key: PByte; KeySize: Cardinal;
          IV: PByte; IVSize: Cardinal): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function ExpandKeyNonce(Inst: PAESInstance; Key: PByte; KeySize: Cardinal;
          Nonce: UInt64): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
    class function GetBlockSize(Inst: PAESInstance): Integer;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DuplicateKey(Inst: PAESInstance; var Key: PAESInstance): TF_RESULT;
      {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class procedure DestroyKey(Inst: PAESInstance);{$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function EncryptBlock(Inst: PAESInstance; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DecryptBlock(Inst: PAESInstance; Data: PByte): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

function GetAESInstance(var A: PAESInstance; AlgID: TAlgID): TF_RESULT;

implementation

uses
  tfRecords, tfCipherInstances, tfBlockCiphers, tfAESBlockCiphers, tfAlgAES, tfBaseCiphers;

function GetAESBlockSize(Inst: Pointer): Integer; {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
begin
  Result:= TAESAlgorithm.BLOCK_SIZE;
end;

const
  ECBCipherVTable: array[0..22] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESBlockCipherInstance.Burn,
    @TAESBlockCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESBlockCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @GetAESBlockSize,
    @TBlockCipherInstance.EncryptECB,
    @TBlockCipherInstance.DecryptECB,
    @TAESBlockCipherInstance.EncryptBlock,
    @TAESBlockCipherInstance.DecryptBlock,
    @TCipherInstance.GetKeyBlockStub,
    @TCipherInstance.GetKeyStreamStub,
    @TCipherInstance.ApplyKeyStreamStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce
  );

  CBCCipherVTable: array[0..22] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeInstance.Addref,
    @TForgeInstance.SafeRelease,

    @TAESBlockCipherInstance.Burn,
    @TAESBlockCipherInstance.Clone,
    @TBlockCipherInstance.ExpandKey,
    @TAESBlockCipherInstance.ExpandKeyIV,
    @TBlockCipherInstance.ExpandKeyNonce,
    @GetAESBlockSize,
    @TBlockCipherInstance.EncryptCBC,
    @TBlockCipherInstance.DecryptCBC,
    @TAESBlockCipherInstance.EncryptBlock,
    @TAESBlockCipherInstance.DecryptBlock,
    @TCipherInstance.GetKeyBlockStub,
    @TCipherInstance.GetKeyStreamStub,
    @TCipherInstance.ApplyKeyStreamStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TCipherInstance.IncBlockNoStub,
    @TBlockCipherInstance.SetIV,
    @TBlockCipherInstance.SetNonce,
    @TBlockCipherInstance.GetIV,
    @TBlockCipherInstance.GetNonce
  );


const
  AES_BLOCK_SIZE = 16;  // 16 bytes = 128 bits

const
  AESCipherVTable: array[0..18] of Pointer = (
   @TForgeInstance.QueryIntf,
   @TForgeInstance.Addref,
   @TAESInstance.Release,

   @TAESInstance.DestroyKey,
   @TAESInstance.DuplicateKey,
   @TAESInstance.ExpandKey,
   @TBaseBlockCipher.SetKeyParam,
   @TBaseBlockCipher.GetKeyParam,
   @TAESInstance.GetBlockSize,
   @TBaseBlockCipher.Encrypt,
   @TBaseBlockCipher.Decrypt,
   @TAESInstance.EncryptBlock,
   @TAESInstance.DecryptBlock,
   @TBaseBlockCipher.GetRand,
   @TBaseBlockCipher.RandBlock,
   @TBaseBlockCipher.RandCrypt,
   @TBaseBlockCipher.GetIsBlockCipher,
   @TBaseBlockCipher.ExpandKeyIV,
   @TBaseBlockCipher.ExpandKeyNonce
   );

procedure BurnKey(Inst: PAESInstance); inline;
var
  BurnSize: Integer;

begin
  BurnSize:= SizeOf(TAESInstance) - Integer(@PAESInstance(nil)^.FValidKey);
  FillChar(Inst.FValidKey, BurnSize, 0);
end;

class function TAESInstance.Release(Inst: PAESInstance): Integer;
begin
  if Inst.FRefCount > 0 then begin
    Result:= tfDecrement(Inst.FRefCount);
    if Result = 0 then begin
      BurnKey(Inst);
      FreeMem(Inst);
    end;
  end
  else
    Result:= Inst.FRefCount;
end;

function GetAESInstance(var A: PAESInstance; AlgID: TAlgID): TF_RESULT;
var
  Tmp: PAESInstance;
//  Mode, Padding: Word;

begin
  if not TBaseBlockCipher.ValidFlags(AlgID) then begin
    Result:= TF_E_INVALIDARG;
    Exit;
  end;
  try
    Tmp:= AllocMem(SizeOf(TAESInstance));
    Tmp^.FVTable:= @AESCipherVTable;
    Tmp^.FRefCount:= 1;
    Tmp^.FAlgID:= AlgID;
{
    Result:= PBaseBlockCipher(Tmp).SetFlags(Flags);
    if Result <> TF_S_OK then begin
      FreeMem(Tmp);
      Exit;
    end;
}
    if A <> nil then TAESInstance.Release(A);
    A:= Tmp;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

procedure Xor128(Target: Pointer; Value: Pointer); inline;
begin
  PUInt32(Target)^:= PUInt32(Target)^ xor PUInt32(Value)^;
  Inc(PUInt32(Target));
  Inc(PUInt32(Value));
  PUInt32(Target)^:= PUInt32(Target)^ xor PUInt32(Value)^;
  Inc(PUInt32(Target));
  Inc(PUInt32(Value));
  PUInt32(Target)^:= PUInt32(Target)^ xor PUInt32(Value)^;
  Inc(PUInt32(Target));
  Inc(PUInt32(Value));
  PUInt32(Target)^:= PUInt32(Target)^ xor PUInt32(Value)^;
end;

procedure XorBytes(Target: Pointer; Value: Pointer; Count: Integer); inline;
var
  LCount: Integer;

begin
  LCount:= Count shr 2;
  while LCount > 0 do begin
    PUInt32(Target)^:= PUInt32(Target)^ xor PUInt32(Value)^;
    Inc(PUInt32(Target));
    Inc(PUInt32(Value));
    Dec(LCount);
  end;
  LCount:= Count and 3;
  while LCount > 0 do begin
    PByte(Target)^:= PByte(Target)^ xor PByte(Value)^;
    Inc(PByte(Target));
    Inc(PByte(Value));
    Dec(LCount);
  end;
end;

{ TAESAlgorithm }

const
  RDLSBox : array[$00..$FF] of Byte =
   ($63, $7C, $77, $7B, $F2, $6B, $6F, $C5, $30, $01, $67, $2B, $FE, $D7, $AB, $76,
    $CA, $82, $C9, $7D, $FA, $59, $47, $F0, $AD, $D4, $A2, $AF, $9C, $A4, $72, $C0,
    $B7, $FD, $93, $26, $36, $3F, $F7, $CC, $34, $A5, $E5, $F1, $71, $D8, $31, $15,
    $04, $C7, $23, $C3, $18, $96, $05, $9A, $07, $12, $80, $E2, $EB, $27, $B2, $75,
    $09, $83, $2C, $1A, $1B, $6E, $5A, $A0, $52, $3B, $D6, $B3, $29, $E3, $2F, $84,
    $53, $D1, $00, $ED, $20, $FC, $B1, $5B, $6A, $CB, $BE, $39, $4A, $4C, $58, $CF,
    $D0, $EF, $AA, $FB, $43, $4D, $33, $85, $45, $F9, $02, $7F, $50, $3C, $9F, $A8,
    $51, $A3, $40, $8F, $92, $9D, $38, $F5, $BC, $B6, $DA, $21, $10, $FF, $F3, $D2,
    $CD, $0C, $13, $EC, $5F, $97, $44, $17, $C4, $A7, $7E, $3D, $64, $5D, $19, $73,
    $60, $81, $4F, $DC, $22, $2A, $90, $88, $46, $EE, $B8, $14, $DE, $5E, $0B, $DB,
    $E0, $32, $3A, $0A, $49, $06, $24, $5C, $C2, $D3, $AC, $62, $91, $95, $E4, $79,
    $E7, $C8, $37, $6D, $8D, $D5, $4E, $A9, $6C, $56, $F4, $EA, $65, $7A, $AE, $08,
    $BA, $78, $25, $2E, $1C, $A6, $B4, $C6, $E8, $DD, $74, $1F, $4B, $BD, $8B, $8A,
    $70, $3E, $B5, $66, $48, $03, $F6, $0E, $61, $35, $57, $B9, $86, $C1, $1D, $9E,
    $E1, $F8, $98, $11, $69, $D9, $8E, $94, $9B, $1E, $87, $E9, $CE, $55, $28, $DF,
    $8C, $A1, $89, $0D, $BF, $E6, $42, $68, $41, $99, $2D, $0F, $B0, $54, $BB, $16);

const
  RDLInvSBox : array[$00..$FF] of Byte =
   ($52, $09, $6A, $D5, $30, $36, $A5, $38, $BF, $40, $A3, $9E, $81, $F3, $D7, $FB,
    $7C, $E3, $39, $82, $9B, $2F, $FF, $87, $34, $8E, $43, $44, $C4, $DE, $E9, $CB,
    $54, $7B, $94, $32, $A6, $C2, $23, $3D, $EE, $4C, $95, $0B, $42, $FA, $C3, $4E,
    $08, $2E, $A1, $66, $28, $D9, $24, $B2, $76, $5B, $A2, $49, $6D, $8B, $D1, $25,
    $72, $F8, $F6, $64, $86, $68, $98, $16, $D4, $A4, $5C, $CC, $5D, $65, $B6, $92,
    $6C, $70, $48, $50, $FD, $ED, $B9, $DA, $5E, $15, $46, $57, $A7, $8D, $9D, $84,
    $90, $D8, $AB, $00, $8C, $BC, $D3, $0A, $F7, $E4, $58, $05, $B8, $B3, $45, $06,
    $D0, $2C, $1E, $8F, $CA, $3F, $0F, $02, $C1, $AF, $BD, $03, $01, $13, $8A, $6B,
    $3A, $91, $11, $41, $4F, $67, $DC, $EA, $97, $F2, $CF, $CE, $F0, $B4, $E6, $73,
    $96, $AC, $74, $22, $E7, $AD, $35, $85, $E2, $F9, $37, $E8, $1C, $75, $DF, $6E,
    $47, $F1, $1A, $71, $1D, $29, $C5, $89, $6F, $B7, $62, $0E, $AA, $18, $BE, $1B,
    $FC, $56, $3E, $4B, $C6, $D2, $79, $20, $9A, $DB, $C0, $FE, $78, $CD, $5A, $F4,
    $1F, $DD, $A8, $33, $88, $07, $C7, $31, $B1, $12, $10, $59, $27, $80, $EC, $5F,
    $60, $51, $7F, $A9, $19, $B5, $4A, $0D, $2D, $E5, $7A, $9F, $93, $C9, $9C, $EF,
    $A0, $E0, $3B, $4D, $AE, $2A, $F5, $B0, $C8, $EB, $BB, $3C, $83, $53, $99, $61,
    $17, $2B, $04, $7E, $BA, $77, $D6, $26, $E1, $69, $14, $63, $55, $21, $0C, $7D);

const
  RCon : array[1..TAESInstance.MaxRounds] of UInt32 =
   ($00000001, $00000002, $00000004, $00000008, $00000010, $00000020, $00000040,
    $00000080, $0000001B, $00000036, $0000006C, $000000D8, $000000AB, $0000004D);

const
  RDL_T0 : array[Byte] of UInt32 =
    ($A56363C6, $847C7CF8, $997777EE, $8D7B7BF6, $0DF2F2FF, $BD6B6BD6, $B16F6FDE, $54C5C591,
     $50303060, $03010102, $A96767CE, $7D2B2B56, $19FEFEE7, $62D7D7B5, $E6ABAB4D, $9A7676EC,
     $45CACA8F, $9D82821F, $40C9C989, $877D7DFA, $15FAFAEF, $EB5959B2, $C947478E, $0BF0F0FB,
     $ECADAD41, $67D4D4B3, $FDA2A25F, $EAAFAF45, $BF9C9C23, $F7A4A453, $967272E4, $5BC0C09B,
     $C2B7B775, $1CFDFDE1, $AE93933D, $6A26264C, $5A36366C, $413F3F7E, $02F7F7F5, $4FCCCC83,
     $5C343468, $F4A5A551, $34E5E5D1, $08F1F1F9, $937171E2, $73D8D8AB, $53313162, $3F15152A,
     $0C040408, $52C7C795, $65232346, $5EC3C39D, $28181830, $A1969637, $0F05050A, $B59A9A2F,
     $0907070E, $36121224, $9B80801B, $3DE2E2DF, $26EBEBCD, $6927274E, $CDB2B27F, $9F7575EA,
     $1B090912, $9E83831D, $742C2C58, $2E1A1A34, $2D1B1B36, $B26E6EDC, $EE5A5AB4, $FBA0A05B,
     $F65252A4, $4D3B3B76, $61D6D6B7, $CEB3B37D, $7B292952, $3EE3E3DD, $712F2F5E, $97848413,
     $F55353A6, $68D1D1B9, $00000000, $2CEDEDC1, $60202040, $1FFCFCE3, $C8B1B179, $ED5B5BB6,
     $BE6A6AD4, $46CBCB8D, $D9BEBE67, $4B393972, $DE4A4A94, $D44C4C98, $E85858B0, $4ACFCF85,
     $6BD0D0BB, $2AEFEFC5, $E5AAAA4F, $16FBFBED, $C5434386, $D74D4D9A, $55333366, $94858511,
     $CF45458A, $10F9F9E9, $06020204, $817F7FFE, $F05050A0, $443C3C78, $BA9F9F25, $E3A8A84B,
     $F35151A2, $FEA3A35D, $C0404080, $8A8F8F05, $AD92923F, $BC9D9D21, $48383870, $04F5F5F1,
     $DFBCBC63, $C1B6B677, $75DADAAF, $63212142, $30101020, $1AFFFFE5, $0EF3F3FD, $6DD2D2BF,
     $4CCDCD81, $140C0C18, $35131326, $2FECECC3, $E15F5FBE, $A2979735, $CC444488, $3917172E,
     $57C4C493, $F2A7A755, $827E7EFC, $473D3D7A, $AC6464C8, $E75D5DBA, $2B191932, $957373E6,
     $A06060C0, $98818119, $D14F4F9E, $7FDCDCA3, $66222244, $7E2A2A54, $AB90903B, $8388880B,
     $CA46468C, $29EEEEC7, $D3B8B86B, $3C141428, $79DEDEA7, $E25E5EBC, $1D0B0B16, $76DBDBAD,
     $3BE0E0DB, $56323264, $4E3A3A74, $1E0A0A14, $DB494992, $0A06060C, $6C242448, $E45C5CB8,
     $5DC2C29F, $6ED3D3BD, $EFACAC43, $A66262C4, $A8919139, $A4959531, $37E4E4D3, $8B7979F2,
     $32E7E7D5, $43C8C88B, $5937376E, $B76D6DDA, $8C8D8D01, $64D5D5B1, $D24E4E9C, $E0A9A949,
     $B46C6CD8, $FA5656AC, $07F4F4F3, $25EAEACF, $AF6565CA, $8E7A7AF4, $E9AEAE47, $18080810,
     $D5BABA6F, $887878F0, $6F25254A, $722E2E5C, $241C1C38, $F1A6A657, $C7B4B473, $51C6C697,
     $23E8E8CB, $7CDDDDA1, $9C7474E8, $211F1F3E, $DD4B4B96, $DCBDBD61, $868B8B0D, $858A8A0F,
     $907070E0, $423E3E7C, $C4B5B571, $AA6666CC, $D8484890, $05030306, $01F6F6F7, $120E0E1C,
     $A36161C2, $5F35356A, $F95757AE, $D0B9B969, $91868617, $58C1C199, $271D1D3A, $B99E9E27,
     $38E1E1D9, $13F8F8EB, $B398982B, $33111122, $BB6969D2, $70D9D9A9, $898E8E07, $A7949433,
     $B69B9B2D, $221E1E3C, $92878715, $20E9E9C9, $49CECE87, $FF5555AA, $78282850, $7ADFDFA5,
     $8F8C8C03, $F8A1A159, $80898909, $170D0D1A, $DABFBF65, $31E6E6D7, $C6424284, $B86868D0,
     $C3414182, $B0999929, $772D2D5A, $110F0F1E, $CBB0B07B, $FC5454A8, $D6BBBB6D, $3A16162C);

const
  RDL_T1 : array[Byte] of UInt32 =
    ($6363C6A5, $7C7CF884, $7777EE99, $7B7BF68D, $F2F2FF0D, $6B6BD6BD, $6F6FDEB1, $C5C59154,
     $30306050, $01010203, $6767CEA9, $2B2B567D, $FEFEE719, $D7D7B562, $ABAB4DE6, $7676EC9A,
     $CACA8F45, $82821F9D, $C9C98940, $7D7DFA87, $FAFAEF15, $5959B2EB, $47478EC9, $F0F0FB0B,
     $ADAD41EC, $D4D4B367, $A2A25FFD, $AFAF45EA, $9C9C23BF, $A4A453F7, $7272E496, $C0C09B5B,
     $B7B775C2, $FDFDE11C, $93933DAE, $26264C6A, $36366C5A, $3F3F7E41, $F7F7F502, $CCCC834F,
     $3434685C, $A5A551F4, $E5E5D134, $F1F1F908, $7171E293, $D8D8AB73, $31316253, $15152A3F,
     $0404080C, $C7C79552, $23234665, $C3C39D5E, $18183028, $969637A1, $05050A0F, $9A9A2FB5,
     $07070E09, $12122436, $80801B9B, $E2E2DF3D, $EBEBCD26, $27274E69, $B2B27FCD, $7575EA9F,
     $0909121B, $83831D9E, $2C2C5874, $1A1A342E, $1B1B362D, $6E6EDCB2, $5A5AB4EE, $A0A05BFB,
     $5252A4F6, $3B3B764D, $D6D6B761, $B3B37DCE, $2929527B, $E3E3DD3E, $2F2F5E71, $84841397,
     $5353A6F5, $D1D1B968, $00000000, $EDEDC12C, $20204060, $FCFCE31F, $B1B179C8, $5B5BB6ED,
     $6A6AD4BE, $CBCB8D46, $BEBE67D9, $3939724B, $4A4A94DE, $4C4C98D4, $5858B0E8, $CFCF854A,
     $D0D0BB6B, $EFEFC52A, $AAAA4FE5, $FBFBED16, $434386C5, $4D4D9AD7, $33336655, $85851194,
     $45458ACF, $F9F9E910, $02020406, $7F7FFE81, $5050A0F0, $3C3C7844, $9F9F25BA, $A8A84BE3,
     $5151A2F3, $A3A35DFE, $404080C0, $8F8F058A, $92923FAD, $9D9D21BC, $38387048, $F5F5F104,
     $BCBC63DF, $B6B677C1, $DADAAF75, $21214263, $10102030, $FFFFE51A, $F3F3FD0E, $D2D2BF6D,
     $CDCD814C, $0C0C1814, $13132635, $ECECC32F, $5F5FBEE1, $979735A2, $444488CC, $17172E39,
     $C4C49357, $A7A755F2, $7E7EFC82, $3D3D7A47, $6464C8AC, $5D5DBAE7, $1919322B, $7373E695,
     $6060C0A0, $81811998, $4F4F9ED1, $DCDCA37F, $22224466, $2A2A547E, $90903BAB, $88880B83,
     $46468CCA, $EEEEC729, $B8B86BD3, $1414283C, $DEDEA779, $5E5EBCE2, $0B0B161D, $DBDBAD76,
     $E0E0DB3B, $32326456, $3A3A744E, $0A0A141E, $494992DB, $06060C0A, $2424486C, $5C5CB8E4,
     $C2C29F5D, $D3D3BD6E, $ACAC43EF, $6262C4A6, $919139A8, $959531A4, $E4E4D337, $7979F28B,
     $E7E7D532, $C8C88B43, $37376E59, $6D6DDAB7, $8D8D018C, $D5D5B164, $4E4E9CD2, $A9A949E0,
     $6C6CD8B4, $5656ACFA, $F4F4F307, $EAEACF25, $6565CAAF, $7A7AF48E, $AEAE47E9, $08081018,
     $BABA6FD5, $7878F088, $25254A6F, $2E2E5C72, $1C1C3824, $A6A657F1, $B4B473C7, $C6C69751,
     $E8E8CB23, $DDDDA17C, $7474E89C, $1F1F3E21, $4B4B96DD, $BDBD61DC, $8B8B0D86, $8A8A0F85,
     $7070E090, $3E3E7C42, $B5B571C4, $6666CCAA, $484890D8, $03030605, $F6F6F701, $0E0E1C12,
     $6161C2A3, $35356A5F, $5757AEF9, $B9B969D0, $86861791, $C1C19958, $1D1D3A27, $9E9E27B9,
     $E1E1D938, $F8F8EB13, $98982BB3, $11112233, $6969D2BB, $D9D9A970, $8E8E0789, $949433A7,
     $9B9B2DB6, $1E1E3C22, $87871592, $E9E9C920, $CECE8749, $5555AAFF, $28285078, $DFDFA57A,
     $8C8C038F, $A1A159F8, $89890980, $0D0D1A17, $BFBF65DA, $E6E6D731, $424284C6, $6868D0B8,
     $414182C3, $999929B0, $2D2D5A77, $0F0F1E11, $B0B07BCB, $5454A8FC, $BBBB6DD6, $16162C3A);

const
  RDL_T2 : array[Byte] of UInt32 =
    ($63C6A563, $7CF8847C, $77EE9977, $7BF68D7B, $F2FF0DF2, $6BD6BD6B, $6FDEB16F, $C59154C5,
     $30605030, $01020301, $67CEA967, $2B567D2B, $FEE719FE, $D7B562D7, $AB4DE6AB, $76EC9A76,
     $CA8F45CA, $821F9D82, $C98940C9, $7DFA877D, $FAEF15FA, $59B2EB59, $478EC947, $F0FB0BF0,
     $AD41ECAD, $D4B367D4, $A25FFDA2, $AF45EAAF, $9C23BF9C, $A453F7A4, $72E49672, $C09B5BC0,
     $B775C2B7, $FDE11CFD, $933DAE93, $264C6A26, $366C5A36, $3F7E413F, $F7F502F7, $CC834FCC,
     $34685C34, $A551F4A5, $E5D134E5, $F1F908F1, $71E29371, $D8AB73D8, $31625331, $152A3F15,
     $04080C04, $C79552C7, $23466523, $C39D5EC3, $18302818, $9637A196, $050A0F05, $9A2FB59A,
     $070E0907, $12243612, $801B9B80, $E2DF3DE2, $EBCD26EB, $274E6927, $B27FCDB2, $75EA9F75,
     $09121B09, $831D9E83, $2C58742C, $1A342E1A, $1B362D1B, $6EDCB26E, $5AB4EE5A, $A05BFBA0,
     $52A4F652, $3B764D3B, $D6B761D6, $B37DCEB3, $29527B29, $E3DD3EE3, $2F5E712F, $84139784,
     $53A6F553, $D1B968D1, $00000000, $EDC12CED, $20406020, $FCE31FFC, $B179C8B1, $5BB6ED5B,
     $6AD4BE6A, $CB8D46CB, $BE67D9BE, $39724B39, $4A94DE4A, $4C98D44C, $58B0E858, $CF854ACF,
     $D0BB6BD0, $EFC52AEF, $AA4FE5AA, $FBED16FB, $4386C543, $4D9AD74D, $33665533, $85119485,
     $458ACF45, $F9E910F9, $02040602, $7FFE817F, $50A0F050, $3C78443C, $9F25BA9F, $A84BE3A8,
     $51A2F351, $A35DFEA3, $4080C040, $8F058A8F, $923FAD92, $9D21BC9D, $38704838, $F5F104F5,
     $BC63DFBC, $B677C1B6, $DAAF75DA, $21426321, $10203010, $FFE51AFF, $F3FD0EF3, $D2BF6DD2,
     $CD814CCD, $0C18140C, $13263513, $ECC32FEC, $5FBEE15F, $9735A297, $4488CC44, $172E3917,
     $C49357C4, $A755F2A7, $7EFC827E, $3D7A473D, $64C8AC64, $5DBAE75D, $19322B19, $73E69573,
     $60C0A060, $81199881, $4F9ED14F, $DCA37FDC, $22446622, $2A547E2A, $903BAB90, $880B8388,
     $468CCA46, $EEC729EE, $B86BD3B8, $14283C14, $DEA779DE, $5EBCE25E, $0B161D0B, $DBAD76DB,
     $E0DB3BE0, $32645632, $3A744E3A, $0A141E0A, $4992DB49, $060C0A06, $24486C24, $5CB8E45C,
     $C29F5DC2, $D3BD6ED3, $AC43EFAC, $62C4A662, $9139A891, $9531A495, $E4D337E4, $79F28B79,
     $E7D532E7, $C88B43C8, $376E5937, $6DDAB76D, $8D018C8D, $D5B164D5, $4E9CD24E, $A949E0A9,
     $6CD8B46C, $56ACFA56, $F4F307F4, $EACF25EA, $65CAAF65, $7AF48E7A, $AE47E9AE, $08101808,
     $BA6FD5BA, $78F08878, $254A6F25, $2E5C722E, $1C38241C, $A657F1A6, $B473C7B4, $C69751C6,
     $E8CB23E8, $DDA17CDD, $74E89C74, $1F3E211F, $4B96DD4B, $BD61DCBD, $8B0D868B, $8A0F858A,
     $70E09070, $3E7C423E, $B571C4B5, $66CCAA66, $4890D848, $03060503, $F6F701F6, $0E1C120E,
     $61C2A361, $356A5F35, $57AEF957, $B969D0B9, $86179186, $C19958C1, $1D3A271D, $9E27B99E,
     $E1D938E1, $F8EB13F8, $982BB398, $11223311, $69D2BB69, $D9A970D9, $8E07898E, $9433A794,
     $9B2DB69B, $1E3C221E, $87159287, $E9C920E9, $CE8749CE, $55AAFF55, $28507828, $DFA57ADF,
     $8C038F8C, $A159F8A1, $89098089, $0D1A170D, $BF65DABF, $E6D731E6, $4284C642, $68D0B868,
     $4182C341, $9929B099, $2D5A772D, $0F1E110F, $B07BCBB0, $54A8FC54, $BB6DD6BB, $162C3A16);

const
  RDL_T3 : array[Byte] of UInt32 =
    ($C6A56363, $F8847C7C, $EE997777, $F68D7B7B, $FF0DF2F2, $D6BD6B6B, $DEB16F6F, $9154C5C5,
     $60503030, $02030101, $CEA96767, $567D2B2B, $E719FEFE, $B562D7D7, $4DE6ABAB, $EC9A7676,
     $8F45CACA, $1F9D8282, $8940C9C9, $FA877D7D, $EF15FAFA, $B2EB5959, $8EC94747, $FB0BF0F0,
     $41ECADAD, $B367D4D4, $5FFDA2A2, $45EAAFAF, $23BF9C9C, $53F7A4A4, $E4967272, $9B5BC0C0,
     $75C2B7B7, $E11CFDFD, $3DAE9393, $4C6A2626, $6C5A3636, $7E413F3F, $F502F7F7, $834FCCCC,
     $685C3434, $51F4A5A5, $D134E5E5, $F908F1F1, $E2937171, $AB73D8D8, $62533131, $2A3F1515,
     $080C0404, $9552C7C7, $46652323, $9D5EC3C3, $30281818, $37A19696, $0A0F0505, $2FB59A9A,
     $0E090707, $24361212, $1B9B8080, $DF3DE2E2, $CD26EBEB, $4E692727, $7FCDB2B2, $EA9F7575,
     $121B0909, $1D9E8383, $58742C2C, $342E1A1A, $362D1B1B, $DCB26E6E, $B4EE5A5A, $5BFBA0A0,
     $A4F65252, $764D3B3B, $B761D6D6, $7DCEB3B3, $527B2929, $DD3EE3E3, $5E712F2F, $13978484,
     $A6F55353, $B968D1D1, $00000000, $C12CEDED, $40602020, $E31FFCFC, $79C8B1B1, $B6ED5B5B,
     $D4BE6A6A, $8D46CBCB, $67D9BEBE, $724B3939, $94DE4A4A, $98D44C4C, $B0E85858, $854ACFCF,
     $BB6BD0D0, $C52AEFEF, $4FE5AAAA, $ED16FBFB, $86C54343, $9AD74D4D, $66553333, $11948585,
     $8ACF4545, $E910F9F9, $04060202, $FE817F7F, $A0F05050, $78443C3C, $25BA9F9F, $4BE3A8A8,
     $A2F35151, $5DFEA3A3, $80C04040, $058A8F8F, $3FAD9292, $21BC9D9D, $70483838, $F104F5F5,
     $63DFBCBC, $77C1B6B6, $AF75DADA, $42632121, $20301010, $E51AFFFF, $FD0EF3F3, $BF6DD2D2,
     $814CCDCD, $18140C0C, $26351313, $C32FECEC, $BEE15F5F, $35A29797, $88CC4444, $2E391717,
     $9357C4C4, $55F2A7A7, $FC827E7E, $7A473D3D, $C8AC6464, $BAE75D5D, $322B1919, $E6957373,
     $C0A06060, $19988181, $9ED14F4F, $A37FDCDC, $44662222, $547E2A2A, $3BAB9090, $0B838888,
     $8CCA4646, $C729EEEE, $6BD3B8B8, $283C1414, $A779DEDE, $BCE25E5E, $161D0B0B, $AD76DBDB,
     $DB3BE0E0, $64563232, $744E3A3A, $141E0A0A, $92DB4949, $0C0A0606, $486C2424, $B8E45C5C,
     $9F5DC2C2, $BD6ED3D3, $43EFACAC, $C4A66262, $39A89191, $31A49595, $D337E4E4, $F28B7979,
     $D532E7E7, $8B43C8C8, $6E593737, $DAB76D6D, $018C8D8D, $B164D5D5, $9CD24E4E, $49E0A9A9,
     $D8B46C6C, $ACFA5656, $F307F4F4, $CF25EAEA, $CAAF6565, $F48E7A7A, $47E9AEAE, $10180808,
     $6FD5BABA, $F0887878, $4A6F2525, $5C722E2E, $38241C1C, $57F1A6A6, $73C7B4B4, $9751C6C6,
     $CB23E8E8, $A17CDDDD, $E89C7474, $3E211F1F, $96DD4B4B, $61DCBDBD, $0D868B8B, $0F858A8A,
     $E0907070, $7C423E3E, $71C4B5B5, $CCAA6666, $90D84848, $06050303, $F701F6F6, $1C120E0E,
     $C2A36161, $6A5F3535, $AEF95757, $69D0B9B9, $17918686, $9958C1C1, $3A271D1D, $27B99E9E,
     $D938E1E1, $EB13F8F8, $2BB39898, $22331111, $D2BB6969, $A970D9D9, $07898E8E, $33A79494,
     $2DB69B9B, $3C221E1E, $15928787, $C920E9E9, $8749CECE, $AAFF5555, $50782828, $A57ADFDF,
     $038F8C8C, $59F8A1A1, $09808989, $1A170D0D, $65DABFBF, $D731E6E6, $84C64242, $D0B86868,
     $82C34141, $29B09999, $5A772D2D, $1E110F0F, $7BCBB0B0, $A8FC5454, $6DD6BBBB, $2C3A1616);

const
  RDL_InvT0 : array[Byte] of UInt32 =
    ($00000000, $0B0D090E, $161A121C, $1D171B12, $2C342438, $27392D36, $3A2E3624, $31233F2A,
     $58684870, $5365417E, $4E725A6C, $457F5362, $745C6C48, $7F516546, $62467E54, $694B775A,
     $B0D090E0, $BBDD99EE, $A6CA82FC, $ADC78BF2, $9CE4B4D8, $97E9BDD6, $8AFEA6C4, $81F3AFCA,
     $E8B8D890, $E3B5D19E, $FEA2CA8C, $F5AFC382, $C48CFCA8, $CF81F5A6, $D296EEB4, $D99BE7BA,
     $7BBB3BDB, $70B632D5, $6DA129C7, $66AC20C9, $578F1FE3, $5C8216ED, $41950DFF, $4A9804F1,
     $23D373AB, $28DE7AA5, $35C961B7, $3EC468B9, $0FE75793, $04EA5E9D, $19FD458F, $12F04C81,
     $CB6BAB3B, $C066A235, $DD71B927, $D67CB029, $E75F8F03, $EC52860D, $F1459D1F, $FA489411,
     $9303E34B, $980EEA45, $8519F157, $8E14F859, $BF37C773, $B43ACE7D, $A92DD56F, $A220DC61,
     $F66D76AD, $FD607FA3, $E07764B1, $EB7A6DBF, $DA595295, $D1545B9B, $CC434089, $C74E4987,
     $AE053EDD, $A50837D3, $B81F2CC1, $B31225CF, $82311AE5, $893C13EB, $942B08F9, $9F2601F7,
     $46BDE64D, $4DB0EF43, $50A7F451, $5BAAFD5F, $6A89C275, $6184CB7B, $7C93D069, $779ED967,
     $1ED5AE3D, $15D8A733, $08CFBC21, $03C2B52F, $32E18A05, $39EC830B, $24FB9819, $2FF69117,
     $8DD64D76, $86DB4478, $9BCC5F6A, $90C15664, $A1E2694E, $AAEF6040, $B7F87B52, $BCF5725C,
     $D5BE0506, $DEB30C08, $C3A4171A, $C8A91E14, $F98A213E, $F2872830, $EF903322, $E49D3A2C,
     $3D06DD96, $360BD498, $2B1CCF8A, $2011C684, $1132F9AE, $1A3FF0A0, $0728EBB2, $0C25E2BC,
     $656E95E6, $6E639CE8, $737487FA, $78798EF4, $495AB1DE, $4257B8D0, $5F40A3C2, $544DAACC,
     $F7DAEC41, $FCD7E54F, $E1C0FE5D, $EACDF753, $DBEEC879, $D0E3C177, $CDF4DA65, $C6F9D36B,
     $AFB2A431, $A4BFAD3F, $B9A8B62D, $B2A5BF23, $83868009, $888B8907, $959C9215, $9E919B1B,
     $470A7CA1, $4C0775AF, $51106EBD, $5A1D67B3, $6B3E5899, $60335197, $7D244A85, $7629438B,
     $1F6234D1, $146F3DDF, $097826CD, $02752FC3, $335610E9, $385B19E7, $254C02F5, $2E410BFB,
     $8C61D79A, $876CDE94, $9A7BC586, $9176CC88, $A055F3A2, $AB58FAAC, $B64FE1BE, $BD42E8B0,
     $D4099FEA, $DF0496E4, $C2138DF6, $C91E84F8, $F83DBBD2, $F330B2DC, $EE27A9CE, $E52AA0C0,
     $3CB1477A, $37BC4E74, $2AAB5566, $21A65C68, $10856342, $1B886A4C, $069F715E, $0D927850,
     $64D90F0A, $6FD40604, $72C31D16, $79CE1418, $48ED2B32, $43E0223C, $5EF7392E, $55FA3020,
     $01B79AEC, $0ABA93E2, $17AD88F0, $1CA081FE, $2D83BED4, $268EB7DA, $3B99ACC8, $3094A5C6,
     $59DFD29C, $52D2DB92, $4FC5C080, $44C8C98E, $75EBF6A4, $7EE6FFAA, $63F1E4B8, $68FCEDB6,
     $B1670A0C, $BA6A0302, $A77D1810, $AC70111E, $9D532E34, $965E273A, $8B493C28, $80443526,
     $E90F427C, $E2024B72, $FF155060, $F418596E, $C53B6644, $CE366F4A, $D3217458, $D82C7D56,
     $7A0CA137, $7101A839, $6C16B32B, $671BBA25, $5638850F, $5D358C01, $40229713, $4B2F9E1D,
     $2264E947, $2969E049, $347EFB5B, $3F73F255, $0E50CD7F, $055DC471, $184ADF63, $1347D66D,
     $CADC31D7, $C1D138D9, $DCC623CB, $D7CB2AC5, $E6E815EF, $EDE51CE1, $F0F207F3, $FBFF0EFD,
     $92B479A7, $99B970A9, $84AE6BBB, $8FA362B5, $BE805D9F, $B58D5491, $A89A4F83, $A397468D);

const
  RDL_InvT1 : array[Byte] of UInt32 =
    ($00000000, $0D090E0B, $1A121C16, $171B121D, $3424382C, $392D3627, $2E36243A, $233F2A31,
     $68487058, $65417E53, $725A6C4E, $7F536245, $5C6C4874, $5165467F, $467E5462, $4B775A69,
     $D090E0B0, $DD99EEBB, $CA82FCA6, $C78BF2AD, $E4B4D89C, $E9BDD697, $FEA6C48A, $F3AFCA81,
     $B8D890E8, $B5D19EE3, $A2CA8CFE, $AFC382F5, $8CFCA8C4, $81F5A6CF, $96EEB4D2, $9BE7BAD9,
     $BB3BDB7B, $B632D570, $A129C76D, $AC20C966, $8F1FE357, $8216ED5C, $950DFF41, $9804F14A,
     $D373AB23, $DE7AA528, $C961B735, $C468B93E, $E757930F, $EA5E9D04, $FD458F19, $F04C8112,
     $6BAB3BCB, $66A235C0, $71B927DD, $7CB029D6, $5F8F03E7, $52860DEC, $459D1FF1, $489411FA,
     $03E34B93, $0EEA4598, $19F15785, $14F8598E, $37C773BF, $3ACE7DB4, $2DD56FA9, $20DC61A2,
     $6D76ADF6, $607FA3FD, $7764B1E0, $7A6DBFEB, $595295DA, $545B9BD1, $434089CC, $4E4987C7,
     $053EDDAE, $0837D3A5, $1F2CC1B8, $1225CFB3, $311AE582, $3C13EB89, $2B08F994, $2601F79F,
     $BDE64D46, $B0EF434D, $A7F45150, $AAFD5F5B, $89C2756A, $84CB7B61, $93D0697C, $9ED96777,
     $D5AE3D1E, $D8A73315, $CFBC2108, $C2B52F03, $E18A0532, $EC830B39, $FB981924, $F691172F,
     $D64D768D, $DB447886, $CC5F6A9B, $C1566490, $E2694EA1, $EF6040AA, $F87B52B7, $F5725CBC,
     $BE0506D5, $B30C08DE, $A4171AC3, $A91E14C8, $8A213EF9, $872830F2, $903322EF, $9D3A2CE4,
     $06DD963D, $0BD49836, $1CCF8A2B, $11C68420, $32F9AE11, $3FF0A01A, $28EBB207, $25E2BC0C,
     $6E95E665, $639CE86E, $7487FA73, $798EF478, $5AB1DE49, $57B8D042, $40A3C25F, $4DAACC54,
     $DAEC41F7, $D7E54FFC, $C0FE5DE1, $CDF753EA, $EEC879DB, $E3C177D0, $F4DA65CD, $F9D36BC6,
     $B2A431AF, $BFAD3FA4, $A8B62DB9, $A5BF23B2, $86800983, $8B890788, $9C921595, $919B1B9E,
     $0A7CA147, $0775AF4C, $106EBD51, $1D67B35A, $3E58996B, $33519760, $244A857D, $29438B76,
     $6234D11F, $6F3DDF14, $7826CD09, $752FC302, $5610E933, $5B19E738, $4C02F525, $410BFB2E,
     $61D79A8C, $6CDE9487, $7BC5869A, $76CC8891, $55F3A2A0, $58FAACAB, $4FE1BEB6, $42E8B0BD,
     $099FEAD4, $0496E4DF, $138DF6C2, $1E84F8C9, $3DBBD2F8, $30B2DCF3, $27A9CEEE, $2AA0C0E5,
     $B1477A3C, $BC4E7437, $AB55662A, $A65C6821, $85634210, $886A4C1B, $9F715E06, $9278500D,
     $D90F0A64, $D406046F, $C31D1672, $CE141879, $ED2B3248, $E0223C43, $F7392E5E, $FA302055,
     $B79AEC01, $BA93E20A, $AD88F017, $A081FE1C, $83BED42D, $8EB7DA26, $99ACC83B, $94A5C630,
     $DFD29C59, $D2DB9252, $C5C0804F, $C8C98E44, $EBF6A475, $E6FFAA7E, $F1E4B863, $FCEDB668,
     $670A0CB1, $6A0302BA, $7D1810A7, $70111EAC, $532E349D, $5E273A96, $493C288B, $44352680,
     $0F427CE9, $024B72E2, $155060FF, $18596EF4, $3B6644C5, $366F4ACE, $217458D3, $2C7D56D8,
     $0CA1377A, $01A83971, $16B32B6C, $1BBA2567, $38850F56, $358C015D, $22971340, $2F9E1D4B,
     $64E94722, $69E04929, $7EFB5B34, $73F2553F, $50CD7F0E, $5DC47105, $4ADF6318, $47D66D13,
     $DC31D7CA, $D138D9C1, $C623CBDC, $CB2AC5D7, $E815EFE6, $E51CE1ED, $F207F3F0, $FF0EFDFB,
     $B479A792, $B970A999, $AE6BBB84, $A362B58F, $805D9FBE, $8D5491B5, $9A4F83A8, $97468DA3);

const
  RDL_InvT2 : array[Byte] of UInt32 =
    ($00000000, $090E0B0D, $121C161A, $1B121D17, $24382C34, $2D362739, $36243A2E, $3F2A3123,
     $48705868, $417E5365, $5A6C4E72, $5362457F, $6C48745C, $65467F51, $7E546246, $775A694B,
     $90E0B0D0, $99EEBBDD, $82FCA6CA, $8BF2ADC7, $B4D89CE4, $BDD697E9, $A6C48AFE, $AFCA81F3,
     $D890E8B8, $D19EE3B5, $CA8CFEA2, $C382F5AF, $FCA8C48C, $F5A6CF81, $EEB4D296, $E7BAD99B,
     $3BDB7BBB, $32D570B6, $29C76DA1, $20C966AC, $1FE3578F, $16ED5C82, $0DFF4195, $04F14A98,
     $73AB23D3, $7AA528DE, $61B735C9, $68B93EC4, $57930FE7, $5E9D04EA, $458F19FD, $4C8112F0,
     $AB3BCB6B, $A235C066, $B927DD71, $B029D67C, $8F03E75F, $860DEC52, $9D1FF145, $9411FA48,
     $E34B9303, $EA45980E, $F1578519, $F8598E14, $C773BF37, $CE7DB43A, $D56FA92D, $DC61A220,
     $76ADF66D, $7FA3FD60, $64B1E077, $6DBFEB7A, $5295DA59, $5B9BD154, $4089CC43, $4987C74E,
     $3EDDAE05, $37D3A508, $2CC1B81F, $25CFB312, $1AE58231, $13EB893C, $08F9942B, $01F79F26,
     $E64D46BD, $EF434DB0, $F45150A7, $FD5F5BAA, $C2756A89, $CB7B6184, $D0697C93, $D967779E,
     $AE3D1ED5, $A73315D8, $BC2108CF, $B52F03C2, $8A0532E1, $830B39EC, $981924FB, $91172FF6,
     $4D768DD6, $447886DB, $5F6A9BCC, $566490C1, $694EA1E2, $6040AAEF, $7B52B7F8, $725CBCF5,
     $0506D5BE, $0C08DEB3, $171AC3A4, $1E14C8A9, $213EF98A, $2830F287, $3322EF90, $3A2CE49D,
     $DD963D06, $D498360B, $CF8A2B1C, $C6842011, $F9AE1132, $F0A01A3F, $EBB20728, $E2BC0C25,
     $95E6656E, $9CE86E63, $87FA7374, $8EF47879, $B1DE495A, $B8D04257, $A3C25F40, $AACC544D,
     $EC41F7DA, $E54FFCD7, $FE5DE1C0, $F753EACD, $C879DBEE, $C177D0E3, $DA65CDF4, $D36BC6F9,
     $A431AFB2, $AD3FA4BF, $B62DB9A8, $BF23B2A5, $80098386, $8907888B, $9215959C, $9B1B9E91,
     $7CA1470A, $75AF4C07, $6EBD5110, $67B35A1D, $58996B3E, $51976033, $4A857D24, $438B7629,
     $34D11F62, $3DDF146F, $26CD0978, $2FC30275, $10E93356, $19E7385B, $02F5254C, $0BFB2E41,
     $D79A8C61, $DE94876C, $C5869A7B, $CC889176, $F3A2A055, $FAACAB58, $E1BEB64F, $E8B0BD42,
     $9FEAD409, $96E4DF04, $8DF6C213, $84F8C91E, $BBD2F83D, $B2DCF330, $A9CEEE27, $A0C0E52A,
     $477A3CB1, $4E7437BC, $55662AAB, $5C6821A6, $63421085, $6A4C1B88, $715E069F, $78500D92,
     $0F0A64D9, $06046FD4, $1D1672C3, $141879CE, $2B3248ED, $223C43E0, $392E5EF7, $302055FA,
     $9AEC01B7, $93E20ABA, $88F017AD, $81FE1CA0, $BED42D83, $B7DA268E, $ACC83B99, $A5C63094,
     $D29C59DF, $DB9252D2, $C0804FC5, $C98E44C8, $F6A475EB, $FFAA7EE6, $E4B863F1, $EDB668FC,
     $0A0CB167, $0302BA6A, $1810A77D, $111EAC70, $2E349D53, $273A965E, $3C288B49, $35268044,
     $427CE90F, $4B72E202, $5060FF15, $596EF418, $6644C53B, $6F4ACE36, $7458D321, $7D56D82C,
     $A1377A0C, $A8397101, $B32B6C16, $BA25671B, $850F5638, $8C015D35, $97134022, $9E1D4B2F,
     $E9472264, $E0492969, $FB5B347E, $F2553F73, $CD7F0E50, $C471055D, $DF63184A, $D66D1347,
     $31D7CADC, $38D9C1D1, $23CBDCC6, $2AC5D7CB, $15EFE6E8, $1CE1EDE5, $07F3F0F2, $0EFDFBFF,
     $79A792B4, $70A999B9, $6BBB84AE, $62B58FA3, $5D9FBE80, $5491B58D, $4F83A89A, $468DA397);

const
  RDL_InvT3 : array[Byte] of UInt32 =
    ($00000000, $0E0B0D09, $1C161A12, $121D171B, $382C3424, $3627392D, $243A2E36, $2A31233F,
     $70586848, $7E536541, $6C4E725A, $62457F53, $48745C6C, $467F5165, $5462467E, $5A694B77,
     $E0B0D090, $EEBBDD99, $FCA6CA82, $F2ADC78B, $D89CE4B4, $D697E9BD, $C48AFEA6, $CA81F3AF,
     $90E8B8D8, $9EE3B5D1, $8CFEA2CA, $82F5AFC3, $A8C48CFC, $A6CF81F5, $B4D296EE, $BAD99BE7,
     $DB7BBB3B, $D570B632, $C76DA129, $C966AC20, $E3578F1F, $ED5C8216, $FF41950D, $F14A9804,
     $AB23D373, $A528DE7A, $B735C961, $B93EC468, $930FE757, $9D04EA5E, $8F19FD45, $8112F04C,
     $3BCB6BAB, $35C066A2, $27DD71B9, $29D67CB0, $03E75F8F, $0DEC5286, $1FF1459D, $11FA4894,
     $4B9303E3, $45980EEA, $578519F1, $598E14F8, $73BF37C7, $7DB43ACE, $6FA92DD5, $61A220DC,
     $ADF66D76, $A3FD607F, $B1E07764, $BFEB7A6D, $95DA5952, $9BD1545B, $89CC4340, $87C74E49,
     $DDAE053E, $D3A50837, $C1B81F2C, $CFB31225, $E582311A, $EB893C13, $F9942B08, $F79F2601,
     $4D46BDE6, $434DB0EF, $5150A7F4, $5F5BAAFD, $756A89C2, $7B6184CB, $697C93D0, $67779ED9,
     $3D1ED5AE, $3315D8A7, $2108CFBC, $2F03C2B5, $0532E18A, $0B39EC83, $1924FB98, $172FF691,
     $768DD64D, $7886DB44, $6A9BCC5F, $6490C156, $4EA1E269, $40AAEF60, $52B7F87B, $5CBCF572,
     $06D5BE05, $08DEB30C, $1AC3A417, $14C8A91E, $3EF98A21, $30F28728, $22EF9033, $2CE49D3A,
     $963D06DD, $98360BD4, $8A2B1CCF, $842011C6, $AE1132F9, $A01A3FF0, $B20728EB, $BC0C25E2,
     $E6656E95, $E86E639C, $FA737487, $F478798E, $DE495AB1, $D04257B8, $C25F40A3, $CC544DAA,
     $41F7DAEC, $4FFCD7E5, $5DE1C0FE, $53EACDF7, $79DBEEC8, $77D0E3C1, $65CDF4DA, $6BC6F9D3,
     $31AFB2A4, $3FA4BFAD, $2DB9A8B6, $23B2A5BF, $09838680, $07888B89, $15959C92, $1B9E919B,
     $A1470A7C, $AF4C0775, $BD51106E, $B35A1D67, $996B3E58, $97603351, $857D244A, $8B762943,
     $D11F6234, $DF146F3D, $CD097826, $C302752F, $E9335610, $E7385B19, $F5254C02, $FB2E410B,
     $9A8C61D7, $94876CDE, $869A7BC5, $889176CC, $A2A055F3, $ACAB58FA, $BEB64FE1, $B0BD42E8,
     $EAD4099F, $E4DF0496, $F6C2138D, $F8C91E84, $D2F83DBB, $DCF330B2, $CEEE27A9, $C0E52AA0,
     $7A3CB147, $7437BC4E, $662AAB55, $6821A65C, $42108563, $4C1B886A, $5E069F71, $500D9278,
     $0A64D90F, $046FD406, $1672C31D, $1879CE14, $3248ED2B, $3C43E022, $2E5EF739, $2055FA30,
     $EC01B79A, $E20ABA93, $F017AD88, $FE1CA081, $D42D83BE, $DA268EB7, $C83B99AC, $C63094A5,
     $9C59DFD2, $9252D2DB, $804FC5C0, $8E44C8C9, $A475EBF6, $AA7EE6FF, $B863F1E4, $B668FCED,
     $0CB1670A, $02BA6A03, $10A77D18, $1EAC7011, $349D532E, $3A965E27, $288B493C, $26804435,
     $7CE90F42, $72E2024B, $60FF1550, $6EF41859, $44C53B66, $4ACE366F, $58D32174, $56D82C7D,
     $377A0CA1, $397101A8, $2B6C16B3, $25671BBA, $0F563885, $015D358C, $13402297, $1D4B2F9E,
     $472264E9, $492969E0, $5B347EFB, $553F73F2, $7F0E50CD, $71055DC4, $63184ADF, $6D1347D6,
     $D7CADC31, $D9C1D138, $CBDCC623, $C5D7CB2A, $EFE6E815, $E1EDE51C, $F3F0F207, $FDFBFF0E,
     $A792B479, $A999B970, $BB84AE6B, $B58FA362, $9FBE805D, $91B58D54, $83A89A4F, $8DA39746);

type
  TRDLVector = record
    case Byte of
      0 : (LWord: UInt32);
      1 : (Bytes: array[0..3] of Byte);
    end;

  TRDLVectors = array[0..3] of TRDLVector;    // block size = 128 bits
  TRDLMixColMatrix = array[0..3, 0..3] of Byte;

function RdlSubVector(const v : TRDLVector) : TRDLVector;
  { S-Box substitution }
begin
  Result.Bytes[0]:= RdlSBox[v.Bytes[0]];
  Result.Bytes[1]:= RdlSBox[v.Bytes[1]];
  Result.Bytes[2]:= RdlSBox[v.Bytes[2]];
  Result.Bytes[3]:= RdlSBox[v.Bytes[3]];
end;
{ ------------------------------------------------------------------- }
function RdlRotateVector(v : TRDLVector; Count : Byte) : TRDLVector;
  { rotate vector (count bytes) to the right, e.g. }
  { |3 2 1 0| -> |0 3 2 1| for Count = 1 }
var
  i : Byte;
begin
  i := Count mod 4;
  Result.Bytes[0] := v.Bytes[i];
  Result.Bytes[1] := v.Bytes[(i+1) mod 4];
  Result.Bytes[2] := v.Bytes[(i+2) mod 4];
  Result.Bytes[3] := v.Bytes[(i+3) mod 4];
end;

function SubVector(const Vector: TRDLVector): TRDLVector;
  { S-Box substitution }
begin
  Result.Bytes[0]:= RdlSBox[Vector.Bytes[0]];
  Result.Bytes[1]:= RdlSBox[Vector.Bytes[1]];
  Result.Bytes[2]:= RdlSBox[Vector.Bytes[2]];
  Result.Bytes[3]:= RdlSBox[Vector.Bytes[3]];
end;

function RotVector(const Vector: TRDLVector): TRDLVector;
  { rotate vector to the right, |a b c d| -> |d a b c| }
begin
  Result.Bytes[0]:= Vector.Bytes[1];
  Result.Bytes[1]:= Vector.Bytes[2];
  Result.Bytes[2]:= Vector.Bytes[3];
  Result.Bytes[3]:= Vector.Bytes[0];
end;

class procedure TAESInstance.DoRound(const RoundKey: TAESBlock;
                var State: TAESBlock; Last: Boolean);
var
  i : Integer;
  e : TRDLVectors;
begin
  for i := 0 to 3 do begin
    if not Last then begin
      e[i].LWord:= RDL_T0[TRDlVectors(State)[(i+0) mod 4].Bytes[0]] xor
                   RDL_T1[TRDlVectors(State)[(i+1) mod 4].Bytes[1]] xor
                   RDL_T2[TRDlVectors(State)[(i+2) mod 4].Bytes[2]] xor
                   RDL_T3[TRDlVectors(State)[(i+3) mod 4].Bytes[3]]
    end
    else begin
      e[i].Bytes[0]:= RDLSBox[TRDlVectors(State)[(i+0) mod 4].Bytes[0]];
      e[i].Bytes[1]:= RDLSBox[TRDlVectors(State)[(i+1) mod 4].Bytes[1]];
      e[i].Bytes[2]:= RDLSBox[TRDlVectors(State)[(i+2) mod 4].Bytes[2]];
      e[i].Bytes[3]:= RDLSBox[TRDlVectors(State)[(i+3) mod 4].Bytes[3]];
    end;
  end;
  Xor128(@e, @RoundKey);
  State:= TAESBlock(e);
end;

class procedure TAESInstance.DoInvRound(const RoundKey: TAESBlock;
             var State: TAESBlock; First: Boolean);
  { Rijndael inverse round transformation }
var
  i : Integer;
  r : TRDLVectors;
  e : TRDLVector;
begin
  Xor128(PUInt32(@State), PUInt32(@RoundKey));
  for i := 0 to 3 do begin
    if not First then begin
      e.LWord:= RDL_InvT0[TRDlVectors(State)[i].Bytes[0]] xor
                RDL_InvT1[TRDlVectors(State)[i].Bytes[1]] xor
                RDL_InvT2[TRDlVectors(State)[i].Bytes[2]] xor
                RDL_InvT3[TRDlVectors(State)[i].Bytes[3]];
      r[(i+0) mod 4].Bytes[0] := RDLInvSBox[e.Bytes[0]];
      r[(i+1) mod 4].Bytes[1] := RDLInvSBox[e.Bytes[1]];
      r[(i+2) mod 4].Bytes[2] := RDLInvSBox[e.Bytes[2]];
      r[(i+3) mod 4].Bytes[3] := RDLInvSBox[e.Bytes[3]];
    end else begin
      r[i].Bytes[0] := RDLInvSBox[TRDlVectors(State)[(i+0) mod 4].Bytes[0]];
      r[i].Bytes[1] := RDLInvSBox[TRDlVectors(State)[(i+3) mod 4].Bytes[1]];
      r[i].Bytes[2] := RDLInvSBox[TRDlVectors(State)[(i+2) mod 4].Bytes[2]];
      r[i].Bytes[3] := RDLInvSBox[TRDlVectors(State)[(i+1) mod 4].Bytes[3]];
    end;
  end;
  State := TAESBlock(r);
end;

class function TAESInstance.ExpandKey(Inst: PAESInstance; Key: PByte;
  KeySize: Cardinal): TF_RESULT;
var
  I: Cardinal;
  Temp: TRDLVector;
  Nk: Cardinal;

begin
  if (KeySize = 16) or (KeySize = 24) or (KeySize = 32) then begin
    Move(Key^, Inst.FExpandedKey, KeySize);
                                // key length in 4-byte words (# of key columns)
    Nk:= KeySize shr 2;         //   Nk = 4, 6 or 8
    Inst.FRounds:= 6 + Nk;      // # of rounds = 10, 12 or 14

// expand key into round keys
    for I:= Nk to 4 * (Inst.FRounds + 1) do begin
      Temp.LWord:= Inst.FExpandedKey.LWords[I-1];
      case Nk of 4, 6: begin
        if (I mod Nk) = 0 then
          Temp.LWord:= SubVector(RotVector(Temp)).LWord xor RCon[I div Nk];
        Inst.FExpandedKey.LWords[I]:= Inst.FExpandedKey.LWords[I - Nk] xor Temp.LWord;
      end
      else { Nk = 8 }
        if (I mod Nk) = 0 then
          Temp.LWord:= SubVector(RotVector(Temp)).LWord xor RCon[I div Nk]
        else if (I mod Nk) = 4 then
          Temp:= SubVector(Temp);
        Inst.FExpandedKey.LWords[I]:= Inst.FExpandedKey.LWords[I - Nk] xor Temp.LWord;
      end;
    end;
    Inst.FValidKey:= True;
    Result:= TF_S_OK;
  end
  else
    Result:= TF_E_INVALIDARG;
end;

(*
class function TAESInstance.ExpandKeyIV(Inst: PAESInstance; Key: PByte; KeySize: Cardinal;
               IV: PByte; IVSize: Cardinal): TF_RESULT;
begin
  Result:= PBaseBlockCipher(Inst).SetIV(IV, IVSize);
  if Result = TF_S_OK then
    Result:= ExpandKey(Inst, Key, KeySize);
end;

class function TAESInstance.ExpandKeyNonce(Inst: PAESInstance; Key: PByte;
  KeySize: Cardinal; Nonce: UInt64): TF_RESULT;
begin
  Result:= PBaseBlockCipher(Inst).SetNonce(@Nonce, SizeOf(Nonce));
  if Result = TF_S_OK then
    Result:= ExpandKey(Inst, Key, KeySize);
end;
*)

class procedure TAESInstance.DestroyKey(Inst: PAESInstance);
begin
  BurnKey(Inst);
end;

class function TAESInstance.EncryptBlock(Inst: PAESInstance; Data: PByte): TF_RESULT;
var
  I: Integer;

begin
  Xor128(Data, @Inst.FExpandedKey);
  for I:= 1 to Inst.FRounds - 1 do
    DoRound(Inst.FExpandedKey.Blocks[I], PBlock(Data)^, False);
  DoRound(Inst.FExpandedKey.Blocks[Inst.FRounds], PBlock(Data)^, True);
  Result:= TF_S_OK;
end;

class function TAESInstance.DecryptBlock(Inst: PAESInstance; Data: PByte): TF_RESULT;
var
  I: Integer;

begin
  DoInvRound(Inst.FExpandedKey.Blocks[Inst.FRounds], PBlock(Data)^, True);
  for I:= (Inst.FRounds - 1) downto 1 do
    DoInvRound(Inst.FExpandedKey.Blocks[I], PBlock(Data)^, False);
  Xor128(Data, @Inst.FExpandedKey);
  Result:= TF_S_OK;
end;

{ TAESCipher }

class function TAESInstance.DuplicateKey(Inst: PAESInstance;
                          var Key: PAESInstance): TF_RESULT;
begin
  Result:= GetAESInstance(Key, PBaseBlockCipher(Inst).GetFlags);
  if Result = TF_S_OK then begin
    Key.FValidKey:= Inst.FValidKey;
//    Key.FDir:= Inst.FDir;
//    Key.FMode:= Inst.FMode;
//    Key.FPadding:= Inst.FPadding;
    Key.FIVector:= Inst.FIVector;
    Key.FExpandedKey:= Inst.FExpandedKey;
    Key.FRounds:= Inst.FRounds;
  end;
end;

class function TAESInstance.GetBlockSize(Inst: PAESInstance): Integer;
begin
  Result:= AES_BLOCK_SIZE;
end;

end.
