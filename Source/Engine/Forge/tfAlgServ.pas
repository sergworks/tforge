{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2017         * }
{ *********************************************************** }

unit tfAlgServ;

interface

{$I TFL.inc}

{$R-}

uses tfRecords, tfTypes, tfByteVectors;

(*
type
  TAlgGetter = function(var A: IInterface): TF_RESULT;
                {$IFDEF TFL_STDCALL}stdcall;{$ENDIF}
*)

type
  PAlgItem = ^TAlgItem;
{
  TAlgItem = record
  public const
    NAME_SIZE = 16;
  private
    FName: array[0..NAME_SIZE - 1] of Byte;
    FGetter: Pointer;
  end;
}
  TAlgItem = record
  private
    FAlgID: TF_AlgID;
    FName: PAnsiChar;     // actually UTF8
  end;

type
  PAlgServer = ^TAlgServer;
  TAlgServer = record
  public
    FVTable: PPointer;
    FCapacity: Integer;   // set in derived classes
    FCount: Integer;
//    FAlgTable: array[0..TABLE_SIZE - 1] of TAlgItem;
    FAlgTable: array[0..0] of TAlgItem;  // var size

  public
(*
    class function AddTableItem(Inst: Pointer;
            const AName: RawByteString; AGetter: Pointer): Boolean; static;
    class function GetByName(Inst: Pointer; AName: Pointer; CharSize: Integer;
          var Alg: IInterface): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetByIndex(Inst: Pointer; Index: Integer;
          var Alg: IInterface): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetName(Inst: Pointer; Index: Integer;
          var Name: PByteVector): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetCount(Inst: Pointer): Integer;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
*)

    class function AddTableItem(Inst: Pointer;
          AName: Pointer; AAlgID: TF_AlgID): Boolean; static;
    class function GetID(Inst: Pointer; Index: Integer;
          var AlgID: TF_AlgID): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetName(Inst: Pointer; Index: Integer;
          var Name: Pointer): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetCount(Inst: Pointer): Integer;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetIDByName(Inst: Pointer; AName: Pointer; CharSize: Integer;
          var AlgID: TF_AlgID): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
    class function GetNameByID(Inst: Pointer; AlgID: TF_AlgID;
          var AName: Pointer): TF_RESULT;
          {$IFDEF TFL_STDCALL}stdcall;{$ENDIF} static;
  end;

implementation

// AName should be uppecase string
//function TAlgServer.AddTableItem(const AName: RawByteString; AGetter: Pointer): Boolean;
(*
class function TAlgServer.AddTableItem(Inst: Pointer;
        const AName: RawByteString; AGetter: Pointer): Boolean;
var
  P: PAlgItem;
  L: Integer;

begin
  with PAlgServer(Inst)^ do
    if FCount < FCapacity then begin
      P:= @FAlgTable[FCount];
      FillChar(P^.FName, SizeOf(P^.FName), 0);
      L:= Length(AName);
      if L > SizeOf(P^.FName) then L:= SizeOf(P^.FName);
      Move(Pointer(AName)^, P^.FName, L);
      P^.FGetter:= AGetter;
      Inc(FCount);
      Result:= True;
    end
    else
      Result:= False;
end;

class function TAlgServer.GetByName(Inst: Pointer; AName: Pointer;
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
  PItem:= @PAlgServer(Inst).FAlgTable;
  Sentinel:= PItem;
  Inc(Sentinel, PAlgServer(Inst).FCount);
  while PItem <> Sentinel do begin
    P1:= @PItem.FName;
    P2:= AName;
    Found:= True;
    I:= SizeOf(PItem.FName);
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
      Result:= TAlgGetter(PItem.FGetter)(Alg);
      Exit;
    end;
    Inc(PItem);
  end;
  Result:= TF_E_INVALIDARG;
end;

class function TAlgServer.GetByIndex(Inst: Pointer; Index: Integer;
        var Alg: IInterface): TF_RESULT;
begin
  if Cardinal(Index) >= Cardinal(PAlgServer(Inst).FCount) then
    Result:= TF_E_INVALIDARG
  else
    Result:= TAlgGetter(PAlgServer(Inst).FAlgTable[Index].FGetter)(Alg);
end;

class function TAlgServer.GetName(Inst: Pointer; Index: Integer;
        var Name: PByteVector): TF_RESULT;
var
  Tmp: PByteVector;
  P, P1: PByte;
  I: Integer;

begin
  if Cardinal(Index) >= Cardinal(PAlgServer(Inst).FCount) then
    Result:= TF_E_INVALIDARG
  else begin
    P:= @PAlgServer(Inst).FAlgTable[Index].FName;
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
      Result:= ByteVectorAlloc(Tmp, I);
      if Result = TF_S_OK then begin
        Move(P^, Tmp.FData, I);
        tfFreeInstance(Name); //if Name <> nil then TtfRecord.Release(Name);
        Name:= Tmp;
      end;
    end;
  end;
end;
*)

class function TAlgServer.AddTableItem(Inst: Pointer;
         AName: Pointer; AAlgID: TF_AlgID): Boolean;
var
  P: PAlgItem;
  L: Integer;

begin
  with PAlgServer(Inst)^ do
    if FCount < FCapacity then begin
      P:= @FAlgTable[FCount];
      P^.FAlgID:= AAlgID;
      P^.FName:= AName;
      Inc(FCount);
      Result:= True;
    end
    else
      Result:= False;
end;

class function TAlgServer.GetIDByName(Inst: Pointer; AName: Pointer; CharSize: Integer;
               var AlgID: TF_AlgID): TF_RESULT;
const
  ANSI_a = Ord('a');
  ANSI_z = Ord('z');

var
  PItem, Sentinel: PAlgItem;
  P1, P2: PByte;
  Found: Boolean;
  Ch: Byte;
  LCharSize: Integer;

begin
  PItem:= @PAlgServer(Inst).FAlgTable;
  Sentinel:= PItem;
  Inc(Sentinel, PAlgServer(Inst).FCount);
  while PItem <> Sentinel do begin
    P1:= PByte(PItem.FName);
    P2:= PByte(AName);
//    Found:= True;
    repeat
      if (P1^ = 0) then begin
        Found:= P2^ = 0;
        Break;
      end;
      Ch:= P2^;
      if (Ch >= ANSI_a) and (Ch <= ANSI_z) then
        PByte(@Ch)^:= Byte(Ch) and not $20;  { upcase }
      if P1^ <> Ch then begin
        Found:= False;
        Break;
      end;
      Inc(P1);
//      Inc(P2, CharSize);
      Inc(P2);
      if CharSize > 1 then begin
        LCharSize:= CharSize - 1;
        repeat
          if (P2^ <> 0) then begin
            Found:= False;
            Break;
          end;
          Inc(P2);
          Dec(LCharSize);
        until LCharSize = 0;
      end;
    until False;
    if Found then begin
      AlgID:= PItem^.FAlgID;
      Result:= TF_S_OK;
      Exit;
    end;
    Inc(PItem);
  end;
  Result:= TF_E_INVALIDARG;
end;

class function TAlgServer.GetNameByID(Inst: Pointer; AlgID: TF_AlgID;
  var AName: Pointer): TF_RESULT;
var
  PItem, Sentinel: PAlgItem;

begin
  PItem:= @PAlgServer(Inst).FAlgTable;
  Sentinel:= PItem;
  Inc(Sentinel, PAlgServer(Inst).FCount);
  while PItem <> Sentinel do begin
    if PItem^.FAlgID = AlgID then begin
      AName:= PItem^.FName;
      Result:= TF_S_OK;
      Exit;
    end;
    Inc(PItem);
  end;
  Result:= TF_E_INVALIDARG;
end;

class function TAlgServer.GetID(Inst: Pointer; Index: Integer;
          var AlgID: TF_AlgID): TF_RESULT;
begin
  if Cardinal(Index) >= Cardinal(PAlgServer(Inst).FCount) then
    Result:= TF_E_INVALIDARG
  else begin
    AlgID:= PAlgServer(Inst).FAlgTable[Index].FAlgID;
    Result:= TF_S_OK;
  end;
end;

class function TAlgServer.GetCount(Inst: Pointer): Integer;
begin
  Result:= PAlgServer(Inst).FCount;
end;

class function TAlgServer.GetName(Inst: Pointer; Index: Integer;
        var Name: Pointer): TF_RESULT;
begin
  if Cardinal(Index) >= Cardinal(PAlgServer(Inst).FCount) then
    Result:= TF_E_INVALIDARG
  else begin
    Name:= PAlgServer(Inst).FAlgTable[Index].FName;
    Result:= TF_S_OK;
  end;
end;

end.
