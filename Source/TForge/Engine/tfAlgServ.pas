{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfAlgServ;

interface

{$I TFL.inc}

uses tfRecords, tfTypes, tfByteVectors;

type
  TAlgGetter = function(var A: IInterface): TF_RESULT;
                {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}

type
  PAlgItem = ^TAlgItem;
  TAlgItem = record
    Name: array[0..15] of Byte;
    Getter: Pointer;
  end;

type
  PAlgServer = ^TAlgServer;
  TAlgServer = record
    FVTable: PPointer;
    FAlgTable: array[0..63] of TAlgItem;
    FCount: Integer;

    function AddTableItem(const AName: RawByteString; AGetter: Pointer): Boolean;

    class function GetByName(Inst: PAlgServer; AName: Pointer; CharSize: Integer;
          var Alg: IInterface): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetByIndex(Inst: PAlgServer; Index: Integer;
          var Alg: IInterface): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetName(Inst: PAlgServer; Index: Integer;
          var Name: PByteVector): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetCount(Inst: PAlgServer): Integer;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

function TAlgServer.AddTableItem(const AName: RawByteString; AGetter: Pointer): Boolean;
var
  P: PAlgItem;
  L: Integer;

begin
  if FCount <= High(FAlgTable) then begin
    P:= @FAlgTable[FCount];
    FillChar(P^.Name, SizeOf(P^.Name), 0);
    L:= Length(AName);
    if L > SizeOf(P^.Name) then L:= SizeOf(P^.Name);
    Move(Pointer(AName)^, P^.Name, L);
    P^.Getter:= AGetter;
    Inc(FCount);
    Result:= True;
  end
  else
    Result:= False;
end;

class function TAlgServer.GetByName(Inst: PAlgServer; AName: Pointer;
        CharSize: Integer; var Alg: IInterface): TF_RESULT;
const
  ANSI_a = Ord('a');

var
  I: Integer;
  PItem, Sentinel: PAlgItem;
  P1, P2: PByte;
  Found: Boolean;
  UP2: Byte;

begin
  PItem:= @Inst.FAlgTable;
  Sentinel:= PItem;
  Inc(Sentinel, Inst.FCount);
  while PItem <> Sentinel do begin
    P1:= @PItem.Name;
    P2:= AName;
    Found:= True;
    I:= SizeOf(PItem.Name);
    repeat
      UP2:= P2^;
      if UP2 >= ANSI_a then
        UP2:= UP2 and not $20;  { upcase }
      if P1^ <> UP2 then begin
        Found:= False;
        Break;
      end;
      if P1^ = 0 then Break;
      Inc(P1);
      Inc(P2, CharSize);
      Dec(I);
    until I = 0;
    if Found then begin
      Result:= TAlgGetter(PItem.Getter)(Alg);
      Exit;
    end;
    Inc(PItem);
  end;
  Result:= TF_E_INVALIDARG;
end;

class function TAlgServer.GetByIndex(Inst: PAlgServer; Index: Integer;
        var Alg: IInterface): TF_RESULT;
begin
  if Cardinal(Index) >= Cardinal(Length(Inst.FAlgTable)) then
    Result:= TF_E_INVALIDARG
  else
    Result:= TAlgGetter(Inst.FAlgTable[Index].Getter)(Alg);
end;

class function TAlgServer.GetCount(Inst: PAlgServer): Integer;
begin
  Result:= Inst.FCount;
end;

class function TAlgServer.GetName(Inst: PAlgServer; Index: Integer;
        var Name: PByteVector): TF_RESULT;
var
  Tmp: PByteVector;
  P, P1: PByte;
  I: Integer;

begin
  if Cardinal(Index) >= Cardinal(Length(Inst.FAlgTable)) then
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
      Tmp:= nil;
      Result:= ByteVectorReAlloc(Tmp, I);
      if Result = TF_S_OK then begin
        Move(P^, Tmp.FData, I);
        if Name <> nil then
          TtfRecord.Release(Name);
        Name:= Tmp;
      end;
    end;
  end;
end;

end.
