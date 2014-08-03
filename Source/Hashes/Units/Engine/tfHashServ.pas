{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfHashServ;

interface

{$I TFL.inc}

uses tfRecords, tfTypes, tfByteVectors, tfMD5, tfSHA256, tfHMAC;

function GetHashServer(var A: IHashServer): TF_RESULT;

implementation

type
  PAlgItem = ^TAlgItem;
  TAlgItem = record
    Name: array[0..15] of Byte;
    Getter: Pointer;
  end;

type
  PHashServer = ^THashServer;
  THashServer = record
    FVTable: PPointer;
    FAlgTable: array[0..63] of TAlgItem;
    FCount: Integer;

    class function GetByName(Inst: PHashServer; AName: Pointer; CharSize: Integer;
          var Alg: IHashAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetByIndex(Inst: PHashServer; Index: Integer;
          var Alg: IHashAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetName(Inst: PHashServer; Index: Integer;
          var Name: PByteVector): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetCount(Inst: PHashServer): Integer;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function RegisterHash(Inst: PHashServer; Name: Pointer;
          Getter: THashGetter; var Index: Integer; CharSize: Integer): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetHMAC(Inst: PHashServer; var HMACAlg: IHashAlgorithm;
          Key: Pointer; KeySize: Cardinal; const HashAlg: IHashAlgorithm): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function DeriveKey(Inst: PHashServer; HashName: Pointer; CharSize: Integer;
          const Password, Salt: IBytes; Rounds, DKLen: Integer;
          var Key: IBytes): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

const
  VTable: array[0..8] of Pointer = (
    @TtfRecord.QueryIntf,
    @TtfSingleton.Addref,
    @TtfSingleton.Release,

    @THashServer.GetByName,
    @THashServer.GetByIndex,
    @THashServer.GetName,
    @THashServer.GetCount,
    @THashServer.RegisterHash,
    @THashServer.DeriveKey
  );

var
  Instance: THashServer;

const
  MD5_LITERAL: UTF8String = 'MD5';
  SHA256_LITERAL: UTF8String = 'SHA256';

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

procedure InitInstance;
begin
  Instance.FVTable:= @VTable;
//  Instance.FCount:= 0;
  AddTableItem(MD5_LITERAL, @GetMD5Algorithm);
  AddTableItem(SHA256_LITERAL, @GetSHA256Algorithm);
{
  Move(Pointer(MD5_LITERAL)^, Instance.FAlgTable[0].Name, Length(MD5_LITERAL));
  Instance.FAlgTable[0].Getter:= @GetMD5Algorithm;
  Move(Pointer(SHA256_LITERAL)^, Instance.FAlgTable[1].Name, Length(SHA256_LITERAL));
  Instance.FAlgTable[1].Getter:= @GetSHA256Algorithm;
  Instance.FCount:= 2; }
end;

function GetHashServer(var A: IHashServer): TF_RESULT;
begin
  if Instance.FVTable = nil then InitInstance;
// IHashServer is implemented by a singleton, no need for releasing old instance
  Pointer(A):= @Instance;
  Result:= TF_S_OK;
end;

{ THashServer }

class function THashServer.GetByName(Inst: PHashServer; AName: Pointer;
        CharSize: Integer; var Alg: IHashAlgorithm): TF_RESULT;
var
  I: Integer;
  PItem, Sentinel: PAlgItem;
  P1, P2: PByte;
  Found: Boolean;

begin
  PItem:= @Inst.FAlgTable;
  Sentinel:= PItem;
  Inc(PItem, Inst.FCount);
  while PItem <> Sentinel do begin
    P1:= @PItem.Name;
    P2:= AName;
    Found:= True;
    I:= SizeOf(PItem.Name);
    repeat
      if P1^ <> (P2^ and not $20) { upcase } then begin
        Found:= False;
        Break;
      end;
      if P1^ = 0 then Break;
      Inc(P1);
      Inc(P2, CharSize);
      Dec(I);
    until I = 0;
    if Found then begin
      Result:= THashGetter(PItem.Getter)(Alg);
      Exit;
    end;
    Inc(PItem);
  end;
  Result:= TF_E_INVALIDARG;
end;

class function THashServer.DeriveKey(Inst: PHashServer; HashName: Pointer;
  CharSize: Integer; const Password, Salt: IBytes; Rounds, DKLen: Integer;
  var Key: IBytes): TF_RESULT;
begin
// todo:
end;

class function THashServer.GetByIndex(Inst: PHashServer; Index: Integer;
        var Alg: IHashAlgorithm): TF_RESULT;
begin
  if Cardinal(Index) >= Length(Inst.FAlgTable) then
    Result:= TF_E_INVALIDARG
  else
    Result:= THashGetter(Inst.FAlgTable[Index].Getter)(Alg);
end;

class function THashServer.GetCount(Inst: PHashServer): Integer;
begin
  Result:= Inst.FCount;
end;

class function THashServer.GetHMAC(Inst: PHashServer; var HMACAlg: IHashAlgorithm;
        Key: Pointer; KeySize: Cardinal; const HashAlg: IHashAlgorithm): TF_RESULT;
begin
  Result:= GetHMACAlgorithm(PHMACAlg(HMACAlg), Key, KeySize, HashAlg);
end;

class function THashServer.GetName(Inst: PHashServer; Index: Integer;
        var Name: PByteVector): TF_RESULT;
var
  Tmp: PByteVector;
  P, P1: PByte;
  I: Integer;

begin
  if Cardinal(Index) >= Length(Instance.FAlgTable) then
    Result:= TF_E_INVALIDARG
  else begin
    P:= @Inst.FAlgTable[Index].Name;
    P1:= P;
    I:= 0;
    repeat
      if P1^ = 0 then Break;
      Inc(P1);
      Inc(I);
    until I = 16;
    if I = 0 then
      Result:= TF_E_UNEXPECTED
    else begin
      Result:= ByteVectorReAlloc(Tmp, I);
      if Result = TF_S_OK then
        Move(P^, Tmp.FData, I);
    end;
  end;
end;

class function THashServer.RegisterHash(Inst: PHashServer; Name: Pointer;
  Getter: THashGetter; var Index: Integer; CharSize: Integer): TF_RESULT;
begin

end;

end.
