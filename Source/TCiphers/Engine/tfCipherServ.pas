{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfCipherServ;

interface

{$I TFL.inc}

uses tfRecords, tfTypes, tfByteVectors, tfAlgServ,
     tfAES;

function GetCipherServer(var A: ICipherServer): TF_RESULT;

implementation
(*
type
  PAlgItem = ^TAlgItem;
  TAlgItem = record
    Name: array[0..15] of Byte;
    Getter: Pointer;
  end;

*)

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
   end;

class function TCipherServer.GetByAlgID(Inst: PCipherServer; AlgID: LongInt;
                    var Alg: ICipherAlgorithm): TF_RESULT;
begin
  case AlgID of
    TF_ALG_AES: Result:= GetAESAlgorithm(PAESAlgorithm(Alg));
  else
    case AlgID of
      TF_ALG_CRC32: Result:= TF_E_INVALIDARG;
    else
      Result:= TF_E_INVALIDARG;
    end;
  end;
end;

const
  VTable: array[0..7] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfSingleton.Addref,
    @TtfSingleton.Release,

    @TCipherServer.GetByAlgID,
//    @GetByAlgID,
    @TAlgServer.GetByName,
    @TAlgServer.GetByIndex,
    @TAlgServer.GetName,
    @TAlgServer.GetCount
  );

var
  Instance: TCipherServer;

const
  AES_LITERAL: UTF8String = 'AES';
{
procedure AddTableItem(const AName: RawByteString; AGetter: Pointer);
var
  P: PAlgItem;
  L: Integer;

begin
  P:= @Instance.FAlgTable[Instance.FCount];
  FillChar(P^.Name, SizeOf(P^.Name), 0);
  L:= Length(AName);
  if L > SizeOf(P^.Name) then L:= SizeOf(P^.Name);
  Move(Pointer(AName)^, P^.Name, L);
  P^.Getter:= AGetter;
  Inc(Instance.FCount);
end;
}

procedure InitInstance;
begin
  Instance.FVTable:= @VTable;
  Instance.FCapacity:= TCipherServer.TABLE_SIZE;
//  Instance.FCount:= 0;
  TAlgServer.AddTableItem(@Instance, AES_LITERAL, @GetAESAlgorithm);
end;

function GetCipherServer(var A: ICipherServer): TF_RESULT;
begin
  if Instance.FVTable = nil then InitInstance;
// Server is implemented by a singleton, no need for releasing old instance
  Pointer(A):= @Instance;
  Result:= TF_S_OK;
end;

end.
