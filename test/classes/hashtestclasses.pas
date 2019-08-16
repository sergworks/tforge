unit HashTestClasses;

interface

uses
  Classes, SysUtils, Loggers, TestClasses, tfTypes, tfArrays, tfHashes;

type
  THashTest = class(TTestObject)
  private
    FAlgID: TAlgID;
    FMsg: ByteArray;
    FCount: Integer;
    FDigest: ByteArray;
    FActualDigest: ByteArray;
    function RepeatedMsg: ByteArray;
  public
    constructor Create(ALogger: TLogger; AAlgID: TAlgID; AName: string = '');
    procedure Execute; override;
    property Msg: ByteArray read FMsg write FMsg;
    property Digest: ByteArray read FDigest write FDigest;
  end;

  TStdHashRunner = class(TFileRunner)
  protected
    FAlgID: TAlgID;

    procedure GetIsValidLine(var IsValid: Boolean); override;
    function GetTest: TTestObject; override;
  end;

implementation

{ THashTest }

function THashTest.RepeatedMsg: ByteArray;
var
  L, Cnt: Integer;
  P, LP: PByte;

begin
  if FCount <= 1 then Result:= Msg
  else begin
    L:= Msg.Len;
    Cnt:= FCount;
    Result:= ByteArray.Alloc(Cnt * L);
    LP:= Msg.Raw;
    P:= Result.Raw;
    repeat
      Move(LP^, P^, L);
      Inc(P, L);
      Dec(Cnt);
    until Cnt = 0;
  end;
end;

constructor THashTest.Create(ALogger: TLogger; AAlgID: TAlgID; AName: string);
begin
  inherited Create(ALogger, AName);
  FAlgID:= AAlgID;
  FCount:= 1;
end;

procedure THashTest.Execute;
var
  Hash: THash;
  N: Integer;

begin
  Logger.WriteLn('Message = ' + FMsg.ToHex, LOG_DETAILED);
  Logger.WriteLn('Count = ' + IntToStr(FCount), LOG_DETAILED);
  Logger.WriteLn('Expected Digest = ' + FDigest.ToHex, LOG_DETAILED);
  Hash:= THash.GetInstance(FAlgID);
  N:= FCount;
  repeat
    Hash.UpdateByteArray(FMsg);
    Dec(N);
  until N < 1;
  FActualDigest:= Hash.Digest;
  Logger.WriteLn('Actual Digest = ' + FActualDigest.ToHex, LOG_DETAILED);
  CheckEquals(FDigest, FActualDigest);
  if FCount > 1 then begin
    FActualDigest:= Hash.UpdateByteArray(RepeatedMsg).Digest;
    Logger.WriteLn('Actual Digest = ' + FActualDigest.ToHex, LOG_DETAILED);
    CheckEquals(FDigest, FActualDigest);
  end;
end;

{ TStdHashRunner }

procedure TStdHashRunner.GetIsValidLine(var IsValid: Boolean);
begin
  IsValid:= (FLine <> '') and (FLine[1] <> '#') and (FLine[1] <> '[');
end;

function TStdHashRunner.GetTest: TTestObject;
const
  MPrefix = 'message = ';
  DPrefix = 'digest = ';

var
  State: Integer;
//  S: string;
  Index: Integer;
  Factor: Integer;
  Ch: Char;
  IsError: Boolean;
  Msg, Digest: ByteArray;

function GetFactor: Boolean;
var
  SN: string;

begin
  SN:= '';
  Index:= Length(MPrefix);
  repeat
    Inc(Index);
    if Length(FLine) < Index then begin
      Result:= False;
      Exit;
    end;
    Ch:= FLine[Index];
    if (Ch >= '0') and (Ch <= '9') then begin
      SN:= SN + Ch;
    end
    else
      Break;
  until False;
  if Length(SN) > 0 then begin
    Result:= TryStrToInt(SN, Factor);
  end
  else begin
    Factor:= 1;
    Result:= True;
  end;
end;

function GetMsg: Boolean;
var
  SA: string;
  LFactor: Integer;
  LMsg: ByteArray;
  P, LP: PByte;
  L: Integer;

begin
  SA:= '';
  if FLine[Index] = '"' then begin
    repeat
      Inc(Index);
      if Length(FLine) < Index then begin
        Result:= False;
        Exit;
      end;
      Ch:= FLine[Index];
      if (Ch <> '"') then begin
        SA:= SA + Ch;
      end
      else begin
        Msg:= ByteArray.FromText(SA);
        Result:= True;
        Exit;
      end;
    until False;
  end
  else
    Result:= False;
end;

function GetDigest: Boolean;
var
  SA: string;

begin
//  SA:= Trim(Copy(FLine, Length(DPrefix), Length(FLine)));
  SA:= RemoveSpaces(Copy(FLine, Length(DPrefix), Length(FLine)));
  Result:= ByteArray.TryParseHex(SA, Digest);
end;

begin
  Result:= nil;
  State:= 0;
  repeat
    IsError:= False;
    if TryGetLine then begin
      case State of
        0: begin
          IsError:= (Copy(FLine, 1, Length(MPrefix)) <> MPrefix) or not
            GetFactor or not GetMsg;
        end;
        1: begin
          IsError:= (Copy(FLine, 1, Length(DPrefix)) <> DPrefix) or not GetDigest;
        end;
      end;
    end
    else
      if State <> 0 then IsError:= True
      else begin
        Exit;
      end;

    if IsError then ParseError;

    Inc(State);
  until State = 2;
  Result:= THashTest.Create(Logger, FAlgID, FTestName);
  THashTest(Result).Msg:= Msg;
  THashTest(Result).Digest:= Digest;
  THashTest(Result).Factor:= Factor;
end;

end.

