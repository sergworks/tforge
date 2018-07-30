{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfCipherServ;

interface

{$I TFL.inc}

uses tfRecords, tfTypes, tfByteVectors, tfAlgServ,
     tfAES, tfDES, tfRC5, tfRC4, tfSalsa20, //tfKeyStreams,
     tfEvpAES;

function GetCipherServerInstance(var A: ICipherServer): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

function GetCipherInstance(AlgID: TF_AlgID; var Alg: ICipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

//function GetStreamCipherInstance(AlgID: TF_AlgID; var Inst: IStreamCipher): TF_RESULT;
//          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

implementation

type
  PCipherServer = ^TCipherServer;
  TCipherServer = record
  public const
    TABLE_SIZE = 64;
  public
                          // !! inherited from TAlgServer
    FVTable: PPointer;
    FCapacity: Integer;
    FCount: Integer;
    FAlgTable: array[0..TABLE_SIZE - 1] of TAlgItem;

(*
    class function GetByAlgID(Inst: PCipherServer; AlgID: UInt32;
          var Alg: ICipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
(*
    class function GetRC5(Inst: PCipherServer; Flags: UInt32; BlockSize, Rounds: Integer;
          var Alg: ICipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetSalsa20(Inst: PCipherServer; Rounds: Integer;
          var Alg: ICipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetChaCha20(Inst: PCipherServer; Rounds: Integer;
          var Alg: ICipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
(*
    class function GetKSByAlgID(Inst: PCipherServer; AlgID: UInt32;
          var KS: IStreamCipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKSByName(Inst: PAlgServer;
          Name: Pointer; CharSize: Integer; var KS: IStreamCipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
(*
    class function GetKSRC5(Inst: PCipherServer; BlockSize, Rounds: Integer;
          var KS: IStreamCipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKSSalsa20(Inst: PCipherServer; Rounds: Integer;
          var KS: IStreamCipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetKSChaCha20(Inst: PCipherServer; Rounds: Integer;
          var KS: IStreamCipher): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)
   end;

function GetStdInstance(AlgID: TF_AlgID; var Alg: ICipher): TF_RESULT;
begin
  case AlgID and TF_ALGID_MASK of
// block ciphers
    TF_ALG_AES: Result:= GetAESInstance(PAESInstance(Alg), AlgID);
    TF_ALG_DES: Result:= GetDESInstance(PDESInstance(Alg), AlgID);
    TF_ALG_RC5: Result:= GetRC5Instance(PRC5Instance(Alg), AlgID);
    TF_ALG_3DES: Result:= Get3DESInstance(P3DESInstance(Alg), AlgID);

// stream ciphers; AlgID ignored
    TF_ALG_RC4: Result:= GetRC4Instance(PRC4Instance(Alg));
    TF_ALG_SALSA20: Result:= GetSalsa20Instance(PSalsa20Instance(Alg));
    TF_ALG_CHACHA20: Result:= GetChaCha20Instance(PSalsa20Instance(Alg));
  else
    Result:= TF_E_INVALIDARG;
  end;
end;

function GetOSSLInstance(AlgID: TF_AlgID; var Alg: ICipher): TF_RESULT;
begin
  case AlgID and TF_ALGID_MASK of
// block ciphers
    TF_ALG_AES: Result:= GetEvpAESInstance(PEvpAESInstance(Alg), AlgID);
//    TF_ALG_DES: Result:= GetDESInstance(PDESInstance(Alg), AlgID);
//    TF_ALG_RC5: Result:= GetRC5Instance(PRC5Instance(Alg), AlgID);
//    TF_ALG_3DES: Result:= Get3DESInstance(P3DESInstance(Alg), AlgID);

// stream ciphers; AlgID ignored
//    TF_ALG_RC4: Result:= GetRC4Instance(PRC4Instance(Alg));
//    TF_ALG_SALSA20: Result:= GetSalsa20Instance(PSalsa20Instance(Alg));
//    TF_ALG_CHACHA20: Result:= GetChaCha20Instance(PSalsa20Instance(Alg));
  else
    Result:= TF_E_INVALIDARG;
  end;
end;

function GetCipherInstance(AlgID: TF_AlgID; var Alg: ICipher): TF_RESULT;
begin
  case AlgID and TF_ENGINE_MASK of
    TF_ENGINE_STD:  Result:= GetStdInstance(AlgID {and not TF_ENGINE_MASK}, Alg);
    TF_ENGINE_OSSL: Result:= GetOSSLInstance(AlgID {and not TF_ENGINE_MASK}, Alg);
  else
    Result:= TF_E_INVALIDARG;
  end;
end;
{
function GetStreamCipherInstance(AlgID: TF_AlgID; var Inst: IStreamCipher): TF_RESULT;
var
  Cipher: ICipher;

begin
  if AlgID = AlgID and TF_ALGID_MASK then begin
// Flags are ignored for stream cipher algorithms
    Result:= GetCipherInstance(AlgID or TF_CTR_DECRYPT, Cipher);
    if Result = TF_S_OK then
      Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(Inst), Cipher);
  end
  else begin
    Result:= TF_E_INVALIDARG;
  end;
end;
}
(*
class function TCipherServer.GetByAlgID(Inst: PCipherServer; AlgID: UInt32;
                    var Alg: ICipher): TF_RESULT;
begin
  case AlgID of
// block ciphers
    TF_ALG_AES: Result:= GetAESAlgorithm(PAESAlgorithm(Alg));
    TF_ALG_DES: Result:= GetDESAlgorithm(PDESAlgorithm(Alg));
    TF_ALG_RC5: Result:= GetRC5Algorithm(PRC5Algorithm(Alg));
    TF_ALG_3DES: Result:= Get3DESAlgorithm(P3DESAlgorithm(Alg));
  else
    case AlgID of
// stream ciphers
      TF_ALG_RC4: Result:= GetRC4Algorithm(PRC4Algorithm(Alg));
      TF_ALG_SALSA20: Result:= GetSalsa20Algorithm(PSalsa20(Alg));
      TF_ALG_CHACHA20: Result:= GetChaCha20Algorithm(PSalsa20(Alg));
    else
      Result:= TF_E_INVALIDARG;
    end;
  end;
end;
*)
(*
class function TCipherServer.GetRC5(Inst: PCipherServer; Flags: UInt32; BlockSize,
               Rounds: Integer; var Alg: ICipher): TF_RESULT;
begin
  Result:= GetRC5InstanceEx(PRC5Instance(Alg), Flags, BlockSize, Rounds);
end;

class function TCipherServer.GetSalsa20(Inst: PCipherServer; Rounds: Integer;
  var Alg: ICipher): TF_RESULT;
begin
  Result:= GetSalsa20InstanceEx(PSalsa20Instance(Alg), Rounds);
end;

class function TCipherServer.GetChaCha20(Inst: PCipherServer; Rounds: Integer;
  var Alg: ICipher): TF_RESULT;
begin
  Result:= GetChaCha20InstanceEx(PSalsa20Instance(Alg), Rounds);
end;
*)
(*
class function TCipherServer.GetKSByAlgID(Inst: PCipherServer; AlgID: UInt32;
                 var KS: IStreamCipher): TF_RESULT;
var
  Alg: ICipher;

begin
//  Result:= GetByAlgID(Inst, AlgID, Alg);
  Result:= GetCipherInstance(AlgID, Alg);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(KS), Alg);
end;
*)
(*
class function TCipherServer.GetKSByName(Inst: PAlgServer; Name: Pointer;
                 CharSize: Integer; var KS: IStreamCipher): TF_RESULT;
var
  Alg: ICipher;

begin
  Result:= TAlgServer.GetByName(Inst, Name, CharSize, IInterface(Alg));
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(KS), Alg);
end;
*)
(*
class function TCipherServer.GetKSRC5(Inst: PCipherServer; BlockSize,
                 Rounds: Integer; var KS: IStreamCipher): TF_RESULT;
var
  Alg: ICipher;

begin
  Result:= GetRC5InstanceEx(PRC5Instance(Alg), TF_CTR_ENCRYPT, BlockSize, Rounds);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(KS), Alg);
end;

class function TCipherServer.GetKSSalsa20(Inst: PCipherServer; Rounds: Integer;
                  var KS: IStreamCipher): TF_RESULT;
var
  Alg: ICipher;

begin
  Result:= GetSalsa20InstanceEx(PSalsa20Instance(Alg), Rounds);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(KS), Alg);
end;

class function TCipherServer.GetKSChaCha20(Inst: PCipherServer; Rounds: Integer;
                 var KS: IStreamCipher): TF_RESULT;
var
  Alg: ICipher;

begin
  Result:= GetChaCha20InstanceEx(PSalsa20Instance(Alg), Rounds);
  if Result = TF_S_OK then
    Result:= TStreamCipherInstance.GetInstance(PStreamCipherInstance(KS), Alg);
end;
*)
const
  VTable: array[0..7] of Pointer = (
    @TForgeInstance.QueryIntf,
    @TForgeSingleton.Addref,
    @TForgeSingleton.Release,

//    @TCipherServer.GetByAlgID,
    @TAlgServer.GetID,
    @TAlgServer.GetName,
    @TAlgServer.GetCount,
    @TAlgServer.GetIDByName,
    @TAlgServer.GetNameByID
(*
    @TCipherServer.GetRC5,
    @TCipherServer.GetSalsa20,
    @TCipherServer.GetChaCha20,

//    @TCipherServer.GetKSByAlgID,
//    @TCipherServer.GetKSByName,
    @TCipherServer.GetKSRC5,
    @TCipherServer.GetKSSalsa20,
    @TCipherServer.GetKSChaCha20
*)
  );

var
  Instance: TCipherServer;

const
  AES_LITERAL: UTF8String = 'AES';
  DES_LITERAL: UTF8String = 'DES';
  TRIPLE_DES_LITERAL: UTF8String = '3DES';
  RC5_LITERAL: UTF8String = 'RC5';
  RC4_LITERAL: UTF8String = 'RC4';
  SALSA20_LITERAL: UTF8String = 'SALSA20';
  CHACHA20_LITERAL: UTF8String = 'CHACHA20';

procedure InitInstance;
begin
  Instance.FVTable:= @VTable;
  Instance.FCapacity:= TCipherServer.TABLE_SIZE;
//  Instance.FCount:= 0;
  TAlgServer.AddTableItem(@Instance, Pointer(AES_LITERAL), TF_ALG_AES);
  TAlgServer.AddTableItem(@Instance, Pointer(DES_LITERAL), TF_ALG_DES);
  TAlgServer.AddTableItem(@Instance, Pointer(TRIPLE_DES_LITERAL), TF_ALG_3DES);
  TAlgServer.AddTableItem(@Instance, Pointer(RC5_LITERAL), TF_ALG_RC5);
  TAlgServer.AddTableItem(@Instance, Pointer(RC4_LITERAL), TF_ALG_RC4);
  TAlgServer.AddTableItem(@Instance, Pointer(SALSA20_LITERAL), TF_ALG_SALSA20);
  TAlgServer.AddTableItem(@Instance, Pointer(CHACHA20_LITERAL), TF_ALG_CHACHA20);
end;

function GetCipherServerInstance(var A: ICipherServer): TF_RESULT;
begin
  if Instance.FVTable = nil then InitInstance;
// Server is implemented by a singleton, no need for releasing old instance
  Pointer(A):= @Instance;
  Result:= TF_S_OK;
end;

end.
