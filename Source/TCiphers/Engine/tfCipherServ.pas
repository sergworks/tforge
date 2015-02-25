{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2015         * }
{ *********************************************************** }

unit tfCipherServ;

interface

{$I TFL.inc}

uses tfRecords, tfTypes, tfByteVectors, tfAlgServ,
     tfAES, tfDES, tfRC5, tfRC4, tfSalsa20;

function GetCipherServer(var A: ICipherServer): TF_RESULT;

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

    class function GetByAlgID(Inst: PCipherServer; AlgID: LongInt;
          var Alg: ICipherAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetRC5(Inst: PCipherServer; BlockSize, Rounds: LongInt;
          var Alg: ICipherAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetSalsa20(Inst: PCipherServer; Rounds: LongInt;
          var Alg: ICipherAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
   end;

class function TCipherServer.GetByAlgID(Inst: PCipherServer; AlgID: LongInt;
                    var Alg: ICipherAlgorithm): TF_RESULT;
begin
  case AlgID of
// block ciphers
    TF_ALG_AES: Result:= GetAESAlgorithm(PAESAlgorithm(Alg));
    TF_ALG_DES: Result:= GetDESAlgorithm(PDESAlgorithm(Alg));
    TF_ALG_RC5: Result:= GetRC5Algorithm(PRC5Algorithm(Alg));
  else
    case AlgID of
// stream ciphers
      TF_ALG_RC4: Result:= GetRC4Algorithm(PRC4Algorithm(Alg));
      TF_ALG_SALSA20: Result:= GetSalsa20Algorithm(PSalsa20(Alg));
    else
      Result:= TF_E_INVALIDARG;
    end;
  end;
end;

class function TCipherServer.GetRC5(Inst: PCipherServer; BlockSize,
               Rounds: Integer; var Alg: ICipherAlgorithm): TF_RESULT;
begin
  Result:= GetRC5AlgorithmEx(PRC5Algorithm(Alg), BlockSize, Rounds);
end;

class function TCipherServer.GetSalsa20(Inst: PCipherServer; Rounds: Integer;
  var Alg: ICipherAlgorithm): TF_RESULT;
begin
  Result:= GetSalsa20AlgorithmEx(PSalsa20(Alg), Rounds);
end;

const
  VTable: array[0..9] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfSingleton.Addref,
    @TtfSingleton.Release,

    @TCipherServer.GetByAlgID,
    @TAlgServer.GetByName,
    @TAlgServer.GetByIndex,
    @TAlgServer.GetName,
    @TAlgServer.GetCount,
    @TCipherServer.GetRC5,
    @TCipherServer.GetSalsa20
  );

var
  Instance: TCipherServer;

const
  AES_LITERAL: UTF8String = 'AES';
  DES_LITERAL: UTF8String = 'DES';
  RC5_LITERAL: UTF8String = 'RC5';
  RC4_LITERAL: UTF8String = 'RC4';
  SALSA20_LITERAL: UTF8String = 'SALSA20';

procedure InitInstance;
begin
  Instance.FVTable:= @VTable;
  Instance.FCapacity:= TCipherServer.TABLE_SIZE;
//  Instance.FCount:= 0;
  TAlgServer.AddTableItem(@Instance, AES_LITERAL, @GetAESAlgorithm);
  TAlgServer.AddTableItem(@Instance, DES_LITERAL, @GetDESAlgorithm);
  TAlgServer.AddTableItem(@Instance, RC5_LITERAL, @GetRC5Algorithm);
  TAlgServer.AddTableItem(@Instance, RC4_LITERAL, @GetRC4Algorithm);
  TAlgServer.AddTableItem(@Instance, SALSA20_LITERAL, @GetSalsa20Algorithm);
end;

function GetCipherServer(var A: ICipherServer): TF_RESULT;
begin
  if Instance.FVTable = nil then InitInstance;
// Server is implemented by a singleton, no need for releasing old instance
  Pointer(A):= @Instance;
  Result:= TF_S_OK;
end;

end.
