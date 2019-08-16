{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2018         * }
{ *********************************************************** }

// Logger class outputs messages to console and/or file

unit Loggers;

//{$I TFL.inc}

interface

uses SysUtils, Classes, tfArrays;//, tfExceptions;

const
  LOG_QUIET = -1;
  LOG_MINIMAL = 0;
  LOG_NORMAL = 1;
  LOG_DETAILED = 2;
  LOG_DIAGNOSTIC = 3;

type
  TLogger = class
  private
    FStream: TStream;
//    FRoutines: TStringList;
//    FRoutineLevel: Integer;
    FConsoleVerb: Integer;
    FFileVerb: Integer;
  public
    constructor Create(ConsoleVerb: Integer = LOG_MINIMAL;
                       FileVerb: Integer = LOG_NORMAL);
    destructor Destroy; override;
//    procedure EnterRoutine(const RoutName: string);
//    procedure ExitRoutine(const RoutName: string);
    procedure Write(const S: string; AVerbosity: Integer = 0);
    procedure WriteLn(const S: string = ''; AVerbosity: Integer = 0);
    procedure Fail(const S: string);
    procedure LogException(E: Exception; AVerbosity: Integer = 0);
    procedure LogArray(const Prefix: string; const Value: ByteArray; AVerbosity: Integer);

//    property Verbosity: Integer read FVerbosity write FVerbosity;
  end;

//  function Logger: TLogger;

implementation

{ TLogger }

constructor TLogger.Create(ConsoleVerb: Integer; FileVerb: Integer);
var
  FileName: string;

begin
  FConsoleVerb:= ConsoleVerb;
  FFileVerb:= FileVerb;
  if FileVerb >= 0 then begin
    FileName:= ChangeFileExt(ParamStr(0), '.log');
    FStream:= TFileStream.Create(FileName, fmCreate);
  end;
  Write('Compiler Defines:', LOG_MINIMAL);
{$IFDEF FPC}
  Write(' FPC', LOG_MINIMAL);
{$ENDIF}
{$IFDEF DCC}
  Write(' DCC', LOG_MINIMAL);
{$ENDIF}
{$IFDEF CPU386}
  Write(' CPU386', LOG_MINIMAL);
{$ENDIF}
{$IFDEF CPUX86_64}
  Write(' CPUX86_64', LOG_MINIMAL);
{$ENDIF}
{$IFDEF CPUX64}
  Write(' CPUX64', LOG_MINIMAL);
{$ENDIF}
{$IFDEF CPU32BITS}
  Write(' CPU32BITS', LOG_MINIMAL);
{$ENDIF}
{$IFDEF CPU64BITS}
  Write(' CPU64BITS', LOG_MINIMAL);
{$ENDIF}
{$IFDEF WIN32}
  Write(' WIN32', LOG_MINIMAL);
{$ENDIF}
{$IFDEF WIN64}
  Write(' WIN64', LOG_MINIMAL);
{$ENDIF}
  Writeln;
//  WriteLn('========================');
//  FRoutines:= TStringList.Create;
//  FRoutines.Sorted:= True;
end;

destructor TLogger.Destroy;
begin
//  FRoutines.Free;
  FStream.Free;
  inherited Destroy;
end;

{
procedure TLogger.EnterRoutine(const RoutName: string);
var
  Tmp: string;
  I: Integer;

begin
  Tmp:= UpperCase(RoutName);
  if not FRoutines.Find(Tmp, I) then begin
    FRoutines.Add(Tmp);
  end;
  Writeln('--- Entering ' + RoutName);
  Inc(FRoutineLevel);
end;

procedure TLogger.ExitRoutine(const RoutName: string);
begin
  Dec(FRoutineLevel);
  Writeln('--- Exiting ' + RoutName);
end;
}

procedure TLogger.Fail(const S: string);
begin
  WriteLn('!!! ERROR: ' + S);
end;

procedure TLogger.LogException(E: Exception; AVerbosity: Integer);
begin
  WriteLn('* Exception >> ' + E.ClassName, AVerbosity);
  if E.Message <> '' then
    WriteLn('*   Message >> ' + E.Message, AVerbosity);
end;

procedure TLogger.Write(const S: string; AVerbosity: Integer);
var
  S1: UTF8String;

begin
  if not Assigned(Self) then Exit;
  if (FFileVerb >= 0) and (AVerbosity <= FFileVerb) then begin
    S1:= UTF8String(S);
    FStream.WriteBuffer(Pointer(S1)^, Length(S1));
  end;
  if (FConsoleVerb >= 0) and (AVerbosity <= FConsoleVerb) then begin
    System.Write(S);
  end;
end;

procedure TLogger.WriteLn(const S: string; AVerbosity: Integer);
const
  CRLF: string = #13#10;

begin
  Write(S + CRLF, AVerbosity);
end;

procedure TLogger.LogArray(const Prefix: string; const Value: ByteArray; AVerbosity: Integer);
const
  NLines = 4;
  MaxLen = 40;

var
  S: string;
  L: Integer;
  Tmp: ByteArray;

begin
  Write(Prefix);
  if Value.Len < MaxLen then begin
    WriteLn(Value.ToHex);
  end
  else begin
    S:= StringOfChar(' ', Length(Prefix));
    L:= 0;
    repeat
      if L > 0 then Write(S);
      Tmp:= ByteArray.Copy(Value, L * MaxLen, MaxLen);
      WriteLn(Tmp.ToHex);
      Inc(L);
      if L * MaxLen >= Value.Len then Exit;
    until L = NLines;
    Writeln(S + '...');
  end;
end;

end.
