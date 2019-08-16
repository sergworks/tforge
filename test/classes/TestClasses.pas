unit TestClasses;

interface

uses
  Classes, SysUtils, tfTypes, tfArrays, tfNumerics, tfExceptions,
  {tfCiphers,} Loggers, TestUtils;

type
// ETestError is raised in Execute method of TTestObject descendants
//   and handled in ExecuteTest method by setting TTestObject.Status:= tsFailed;
// TTestRunner descendants check TTestObject.Status field in UpdateCounts method
//   and either stop execution by raising ETestError (if StopOnErrors = True)
//   or continue (if StopOnErrors = False)
  ETestError = class(Exception);

// ERunError is raised in Run method of TTestRunner descendants;
//   execution stops
  ERunError = class(Exception);

  TLogObject = class
  private
    FLogger: TLogger;
    procedure SetLogger(ALogger: TLogger);
  protected
    property Logger: TLogger read FLogger write SetLogger;
  end;

  TTestStatus = (tsUnknown, tsPassed, tsFailed, tsIgnored);

  TTestObject = class(TLogObject)
  private
    FName: string;
  protected
    FStatus: TTestStatus;
    FNegative: Boolean;
  public
    constructor Create(ALogger: TLogger; AName: string = ''; ANegative: Boolean = False);
    procedure Fail(Msg: string);
    function Validate: Boolean; virtual;
    procedure Execute; virtual; abstract;
    procedure ExecuteTest;

    procedure Check(Cond: Boolean; const Info: string = '');
    procedure CheckOK(const Actual: TF_RESULT);
    procedure CheckDerived(const Expected: TClass; const Actual: TObject);
    procedure CheckEqualFiles(const Name1, Name2: string);

    procedure CheckEquals(const Expected, Actual: ByteArray); overload;
    procedure CheckEquals(const Expected, Actual: Boolean); overload;
    procedure CheckEquals(const Expected, Actual: Int64); overload;
    procedure CheckEquals(const Expected, Actual: UInt64); overload;
    procedure CheckEquals(const Expected, Actual: TClass); overload;
    procedure CheckEquals(const Expected, Actual: LongInt); overload;
    procedure CheckEquals(const Expected, Actual: TF_RESULT); overload;
    procedure CheckEquals(const Expected, Actual: string); overload;
    procedure CheckEquals(const Expected, Actual: BigInteger); overload;

    property Name: string read FName;
    property Status: TTestStatus read FStatus;
  end;

  TTestRunnerClass = class of TTestRunner;

  TTestRunner = class(TLogObject)
  protected
    FTotal: Integer;
    FIgnored: Integer;
    FPassed: Integer;
    FFailed: Integer;
    FUnknown: Integer;
    FStopOnErrors: Boolean;

    FTestName: string;
  public
    constructor Create(ALogger: TLogger; AStopOnErrors: Boolean = False); virtual;
    procedure Fail(Msg: string);
    procedure UpdateCounts(ATest: TTestObject); overload;
    procedure LogCounts(Verbosity: Integer = LOG_NORMAL);
    procedure Run; virtual; abstract;
    class procedure RunTests(RunnerClass: TTestRunnerClass;
      ALogger: TLogger; AStopOnErrors: Boolean = False); static;

    property Total: Integer read FTotal;
    property Passed: Integer read FPassed;
    property Failed: Integer read FFailed;
    property Ignored: Integer read FIgnored;
    property Unknown: Integer read FUnknown;
    property StopOnErrors: Boolean read FStopOnErrors write FStopOnErrors;
  end;

  TTestSuiteRunner = class(TTestRunner)
  private
    FList: TList;
  public
    constructor Create(ALogger: TLogger; AStopOnErrors: Boolean = False); override;
    destructor Destroy; override;
    procedure RegisterRunner(ARunner: TTestRunnerClass);
    procedure RegisterRunners(ARunners: array of TTestRunnerClass);
    procedure UpdateCounts(ARunner: TTestRunner); overload;
    procedure Run; override;
  end;


const
  RootDataFolder = 'E:\TForge\tests\Data\';

type
  TFileRunner = class(TTestRunner)
  private
    FStrings: TStrings;
    FIndex: Integer;
  protected
    FFileName: string;
    FTestNo: Integer;
    FLine: string;
//    FSubNo: Integer;
    FKey: string;
    FValue: string;

    procedure GetIsValidLine(var IsValid: Boolean); virtual;

    function TryGetLine: Boolean;
    procedure GetLine;
    function GetText(const Text: string; Error: Boolean = False): Integer;

    function GetKeyValue: Boolean;
    function UnQuoteValue(var S: string): Boolean;
//    function UnQuoteHexValue(var Bytes: ByteArray): Boolean;
    function GetTest: TTestObject; virtual; abstract;
    procedure ParseError(const Mesg: string = '');

    class function RemoveSpaces(const S: string): string;
    class function UnQuoteString(var S: string): Boolean;

    class function ExtractText(var S: string): string;
    class function ExtractBytes(var S: string; var Bytes: ByteArray): Boolean;

//    procedure RunTest(Test: TTestObject);
  public
    constructor Create(ALogger: TLogger; AStopOnErrors: Boolean = False); override;
    destructor Destroy; override;
    procedure Run; override;
    property LineNo: Integer read FIndex;
    property TestNo: Integer read FTestNo;
  end;

implementation

{ TLogObject }

procedure TLogObject.SetLogger(ALogger: TLogger);
begin
  FLogger:= ALogger;
end;

{ TTestObject }

procedure TTestObject.Check(Cond: Boolean; const Info: string);
var
  S: string;

begin
  if not Cond then begin
    if Info = ''
      then S:= '= !! Error - Assertion failed'
      else S:= '= !! Error - ' + Info;
    Fail(S);
  end
end;

constructor TTestObject.Create(ALogger: TLogger; AName: string; ANegative: Boolean);
begin
  Logger:= ALogger;
  FName:= AName;
  FNegative:= ANegative;
end;

procedure TTestObject.Fail(Msg: string);
begin
  Logger.Fail(Msg);
  raise ETestError.Create(Msg);
end;

procedure TTestObject.ExecuteTest;
begin
  if not Validate then begin
    FStatus:= tsIgnored;
    Exit;
  end;
  if FNegative then begin
    try
      Execute;
      FStatus:= tsFailed;
    except
      on E: Exception do begin
        if (E is ETestError) then begin
          FStatus:= tsPassed;
        end
        else begin
          Logger.LogException(E);
          FStatus:= tsFailed;
          raise;
        end;
      end;
    end;
  end
  else begin
    try
      Execute;
      FStatus:= tsPassed;
    except
      on E: Exception do begin
        FStatus:= tsFailed;
        if not(E is ETestError) then begin
          Logger.LogException(E);
          raise;
        end;
      end;
    end;
  end;
end;

function TTestObject.Validate: Boolean;
begin
  Result:= True;
end;

procedure TTestObject.CheckEquals(const Expected, Actual: ByteArray);
var
  I, L: Integer;
  S: string;

begin
//  Logger.LogArray('Expected: ', Expected, LOG_VERBOSE);
//  Logger.LogArray('Actual  : ', Actual, LOG_VERBOSE);
  if Expected.Len <> Actual.Len then begin
    S:= Format('Array Length Error - Expected: %d, Found %d',
         [Expected.Len, Actual.Len]);
    Logger.LogArray('Expected: ', Expected, LOG_MINIMAL);
    Logger.LogArray('Actual  : ', Actual, LOG_MINIMAL);
    Fail(S);
  end
  else begin
    L:= Expected.Len;
    for I:= 0 to L - 1 do begin
      if Expected[I] <> Actual[I] then begin
        S:= Format('Expected: %.2x, Found %.2x, at index %d',
          [Expected.Raw[I], Actual.Raw[I], I]);
        Logger.LogArray('Expected: ', Expected, LOG_MINIMAL);
        Logger.LogArray('Actual  : ', Actual, LOG_MINIMAL);
        Fail(S);
      end;
    end;
  end;
end;

procedure TTestObject.CheckEquals(const Expected, Actual: Int64);
var
  S: string;

begin
  Logger.WriteLn('* Expected: ' + IntToStr(Expected) + ' [0x'
                                + IntToHex(Expected, SizeOf(Int64) * 2) + ']');
  Logger.WriteLn('* Actual  : ' + IntToStr(Actual) + ' [0x'
                                + IntToHex(Actual, SizeOf(Int64) * 2) + ']');
  if Expected <> Actual then begin
    S:= Format('= !! Error - Expected: %d, Found %d',
         [Expected, Actual]);
    Fail(S);
  end
end;

procedure TTestObject.CheckEquals(const Expected, Actual: UInt64);
var
  S: string;

begin
  Logger.WriteLn('* Expected: ' + IntToStr(Expected) + ' [0x'
                                + IntToHex(Expected, SizeOf(UInt64) * 2) + ']');
  Logger.WriteLn('* Actual  : ' + IntToStr(Actual) + ' [0x'
                                + IntToHex(Actual, SizeOf(UInt64) * 2) + ']');
  if Expected <> Actual then begin
    S:= Format('= !! Error - Expected: %d, Found %d',
         [Expected, Actual]);
    Fail(S);
  end
end;

procedure TTestObject.CheckEquals(const Expected, Actual: TClass);
var
  S: string;

begin
  Logger.WriteLn(Format('* Expected: %s', [Expected.ClassName]));
  Logger.WriteLn(Format('* Actual  : %s', [Actual.ClassName]));
  if not (Actual = Expected) then begin
    S:= Format('= !! Error - Expected: %s, Found %s',
        [Expected.ClassName, Actual.ClassName]);
    Fail(S);
  end
end;

procedure TTestObject.CheckDerived(const Expected: TClass;
  const Actual: TObject);
var
  S: string;

begin
  Logger.WriteLn(Format('* Expected: %s', [Expected.ClassName]));
  Logger.WriteLn(Format('* Actual  : %s', [Actual.ClassName]));
  if not (Actual is Expected) then begin
    S:= Format('= !! Error - Expected: %s, Found %s',
        [Expected.ClassName, Actual.ClassName]);
    Fail(S);
  end
end;

procedure TTestObject.CheckEquals(const Expected, Actual: LongInt);
var
  S: string;

begin
  Logger.WriteLn(Format('* Expected: %.8x (%d)', [Expected, Expected]));
  Logger.WriteLn(Format('* Actual  : %.8x (%d)', [Actual, Actual]));
  if Expected <> Actual then begin
    S:= Format('= !! Error - Expected: %.8x (%d), Found %.8x (%d)',
        [Expected, Expected, Actual, Actual]);
    Fail(S);
  end
end;

procedure TTestObject.CheckEquals(const Expected, Actual: TF_RESULT);
var
  S: string;

begin
  Logger.WriteLn(Format('* Expected: %.8x (%s)', [Expected, ForgeInfo(Expected)]));
  Logger.WriteLn(Format('* Actual  : %.8x (%s)', [Actual, ForgeInfo(Actual)]));
  if Expected <> Actual then begin
    S:= Format('= !! Error - Expected: %.8x (%s), Found %.8x (%s)',
        [Expected, ForgeInfo(Expected), Actual, ForgeInfo(Actual)]);
    Fail(S);
  end
end;

procedure TTestObject.CheckOK(const Actual: TF_RESULT);
var
  S: string;

begin
  if TF_S_OK <> Actual then begin
    S:= Format('= !! Error - Expected: %.8x (%s), Found %.8x (%s)',
        [TF_S_OK, ForgeInfo(TF_S_OK), Actual, ForgeInfo(Actual)]);
    Fail(S);
  end
end;

procedure TTestObject.CheckEquals(const Expected, Actual: string);
var
  S: string;

begin
  Logger.WriteLn(Format('* Expected: %s', [Expected]));
  Logger.WriteLn(Format('* Actual  : %s', [Actual]));
  if Expected <> Actual then begin
    S:= Format('= !! Error - Expected: %s, Found %s',
        [Expected, Actual]);
    Fail(S);
  end
end;

procedure TTestObject.CheckEquals(const Expected, Actual: Boolean);

function BooleanStr(Value: Boolean): string;
begin
  if Value
    then Result:= 'True'
    else Result:= 'False';
end;

var
  S: string;

begin
  Logger.WriteLn(Format('* Expected: %s', [BooleanStr(Expected)]));
  Logger.WriteLn(Format('* Actual  : %s', [BooleanStr(Actual)]));
  if Expected <> Actual then begin
    S:= Format('= !! Error - Expected: %s, Found %s',
        [BooleanStr(Expected), BooleanStr(Actual)]);
    Fail(S);
  end
end;

procedure TTestObject.CheckEqualFiles(const Name1, Name2: string);
begin
  if not EqualFiles(Name1, Name2) then begin
    Fail('Files ' + Name1 + ' and ' + Name2 + ' are different');
  end
end;

procedure TTestObject.CheckEquals(const Expected, Actual: BigInteger);
var
  S: string;

begin
  if Expected <> Actual then begin
    S:= Format('= !! Error - Expected: %s, Found %s',
        [Expected.ToString, Actual.ToString]);
    Fail(S);
  end
  else
    Logger.WriteLn(Format('* Actual: %s; Check passed', [Actual.ToString]));
    Logger.WriteLn;
end;

{ TTestRunner }

constructor TTestRunner.Create(ALogger: TLogger; AStopOnErrors: Boolean);
begin
  Logger:= ALogger;
  FStopOnErrors:= AStopOnErrors;
end;

procedure TTestRunner.Fail(Msg: string);
begin
  Logger.Fail(Msg);
  raise ERunError.Create(Msg);
end;

procedure TTestRunner.LogCounts(Verbosity: Integer);
begin
  if Total > 0 then begin
    Logger.Writeln('Total: ' + IntToStr(Total), Verbosity);
  end;
  if Passed > 0 then begin
    Logger.Writeln('Passed: ' + IntToStr(Passed), Verbosity);
  end;
  if Failed > 0 then begin
    Logger.Writeln('Failed: ' + IntToStr(Failed), Verbosity);
  end;
  if Ignored > 0 then begin
    Logger.Writeln('Ignored: ' + IntToStr(Ignored), Verbosity);
  end;
  if Unknown > 0 then begin
    Logger.Writeln('Unknown: ' + IntToStr(Unknown), Verbosity);
  end;
end;

class procedure TTestRunner.RunTests(RunnerClass: TTestRunnerClass;
  ALogger: TLogger; AStopOnErrors: Boolean);
var
  Runner: TTestRunner;

begin
  Runner:= RunnerClass.Create(ALogger, AStopOnErrors);
  try
    Runner.Run;
  finally
    Runner.Free;
  end;
end;

procedure TTestRunner.UpdateCounts(ATest: TTestObject);
begin
  Inc(FTotal);
  case ATest.Status of
    tsPassed: Inc(FPassed);
    tsFailed: Inc(FFailed);
    tsIgnored: Inc(FIgnored);
  else
    Inc(FUnknown);
    Logger.WriteLn('* Invalid Test Status, Test: ' + ATest.Name);
  end;
  if StopOnErrors and (ATest.Status in [tsFailed, tsUnknown]) then
    raise ETestError.Create(ATest.Name + ' Error');
end;

{ TFileRunner }

constructor TFileRunner.Create(ALogger: TLogger; AStopOnErrors: Boolean);
begin
  inherited Create(ALogger, AStopOnErrors);
  FStrings:= TStringList.Create;
//  FIndex:= 0;
end;

destructor TFileRunner.Destroy;
begin
  FStrings.Free;
  inherited Destroy;
end;

procedure TFileRunner.Run;
var
  Test: TTestObject;

begin
  Logger.WriteLn;
  Logger.WriteLn('Running ' + FTestName, LOG_NORMAL);
  Logger.WriteLn('Test Vectors: ' + FFileName, LOG_NORMAL);
  Logger.WriteLn;

  FStrings.LoadFromFile(FFileName);
  FTestNo:= 0;
  try
    repeat
      Inc(FTestNo);
      Test:= GetTest;
      if Test <> nil then begin
        try
          Test.ExecuteTest;
          UpdateCounts(Test);
        finally
          Test.Free;
        end;
      end
      else
        Break;
    until False;

    Logger.WriteLn(FTestName + ' Statistics', LOG_NORMAL);
    LogCounts;

  finally
    FStrings.Clear;
  end;
end;

class function TFileRunner.ExtractBytes(var S: string;
                                        var Bytes: ByteArray): Boolean;
var
  S1: string;
  TmpBytes: ByteArray;

begin
  Bytes:= ByteArray.Alloc(0);
  S1:= ExtractText(S);
  if S1 <> '' then begin
    Result:= ByteArray.TryParseHex(S1, TmpBytes);
    if Result then
      Bytes:= TmpBytes
    else
      Exit;
  end
  else
    Result:= True;
end;

class function TFileRunner.ExtractText(var S: string): string;
var
  S1: string;
  N: Integer;

begin
  S1:= Trim(S);
  N:= Pos(' ', S1);
  if N > 0 then begin
    Result:= Copy(S1, 1, N - 1);
    S:= Copy(S1, N + 1, Length(S1));
  end
  else begin
    Result:= S1;
    S:= '';
  end;
end;

procedure TFileRunner.GetIsValidLine({const Line: string; }var IsValid: Boolean);
begin
  IsValid:= True;
end;

function TFileRunner.GetKeyValue: Boolean;
var
  N: Integer;

begin
  Result:= TryGetLine;
  if Result then begin
    N:= Pos('=', FLine);
    if N = 0 then ParseError
    else begin
      FKey:= Trim(Copy(FLine, 1, N - 1));
      FValue:= Trim(Copy(FLine, N + 1, Length(FLine)));
    end;
  end;
end;

procedure TFileRunner.GetLine;
begin
  if not TryGetLine then ParseError('Unexpected EOF');
end;

function TFileRunner.GetText(const Text: string; Error: Boolean): Integer;
begin
  Result:= 0;
  while TryGetLine do begin
    Result:= Pos(Text, FLine);
    if Result > 0 then Exit;
  end;
  if Error then
    ParseError('Expected ' + Text + ' not found');
end;

function TFileRunner.TryGetLine: Boolean;
var
  Done: Boolean;

begin
  repeat
    Done:= True;
    Result:= FIndex < FStrings.Count;
    if Result then begin
      FLine:= FStrings[FIndex];
      Logger.WriteLn('>> ' + FLine, LOG_DETAILED);
      FLine:= Trim(FLine);
      Inc(FIndex);
      GetIsValidLine(Done);
    end;
  until Done;
end;

procedure TFileRunner.ParseError(const Mesg: string);
var
  S: string;

begin
  S:= Format('Error parsing file %s at line %d (%s)',
              [ExtractFileName(FFileName), LineNo, FLine]);

  if Mesg <> '' then S:= S + ' - ' + Mesg;
  Fail(S);
end;

class function TFileRunner.RemoveSpaces(const S: string): string;
var
  I, L, N: Integer;
  Ch: Char;

begin
  L:= Length(S);
  SetLength(Result, L);
  N:= 0;
  for I:= 1 to L do begin
    Ch:= S[I];
    if Ch <> ' ' then begin
      Inc(N);
      Result[N]:= Ch;
    end;
  end;
  SetLength(Result, N);
end;

{
procedure TTestParser.RunTest(Test: TTestObject);
begin
  Inc(FTestNo);
  try
    Test.Execute;
  finally
    Test.Free;
  end;
end;
}
{
function TFileRunner.UnQuoteHexValue(var Bytes: ByteArray): Boolean;
var
  S: string;
  I: Integer;

begin
  if FValue[1] = '"' then begin
    Result:= UnQuoteValue(S);
    if Result then Bytes:= ByteArray.FromText(S);
  end
  else begin
    I:= Pos('//', FValue);
    if I > 0 then
      S:= Copy(FValue, 1, I - 1)
    else
      S:= FValue;
    Result:= ByteArray.TryParseHex(RemoveSpaces(S), Bytes);
  end;
end;
}

class function TFileRunner.UnQuoteString(var S: string): Boolean;
const
  SingleQuot: Char = '''';
  DoubleQuot: Char = '"';

var
//  S1: string;
  QuotChar: Char;
  N: Integer;

begin
  Result:= False;
  if Length(S) >= 2 then begin
    if (S[1] = SingleQuot) or (S[1] = DoubleQuot) then
      QuotChar:= S[1]
    else
      Exit;

// unquote
    S:= Copy(S, 2, Length(S));
    N:= Pos(QuotChar, S);
    if N > 0 then begin
      S:= Trim(Copy(S, 1, N - 1));
      Result:= True;
    end;
  end;
end;

function TFileRunner.UnQuoteValue(var S: string): Boolean;
var
  I: Integer;
  Ch: Char;

begin
  S:= '';
  if FValue[1] = '"' then begin
    I:= 1;
    repeat
      Inc(I);
      if Length(FValue) < I then begin
        Result:= False;
        Exit;
      end;
      Ch:= FValue[I];
      if (Ch <> '"') then begin
        S:= S + Ch;
      end
      else begin
        Result:= True;
        Exit;
      end;
    until False;
  end
  else
    Result:= False;
end;

{ TTestSuitRunner }

constructor TTestSuiteRunner.Create(ALogger: TLogger; AStopOnErrors: Boolean);
begin
  inherited Create(Alogger, AStopOnErrors);
  FList:= TList.Create;
end;

destructor TTestSuiteRunner.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TTestSuiteRunner.RegisterRunner(ARunner: TTestRunnerClass);
begin
  FList.Add(ARunner);
end;

procedure TTestSuiteRunner.RegisterRunners(ARunners: array of TTestRunnerClass);
var
  I: Integer;

begin
  I:= 0;
  while I < Length(ARunners) do begin
    FList.Add(ARunners[I]);
    Inc(I);
  end;
end;

procedure TTestSuiteRunner.Run;
var
  I: Integer;
  Runner: TTestRunner;

begin
  I:= 0;
  while I < FList.Count do begin
    Runner:= TTestRunnerClass(FList[I]).Create(Logger, StopOnErrors);
    try
      Runner.Run;
      UpdateCounts(Runner);
    finally
      Runner.Free;
    end;
    Inc(I);
  end;
  Logger.WriteLn;
  Logger.WriteLn('------------------------------');
  Logger.WriteLn(FTestName + ' Suite Statistics');
  LogCounts;
end;

procedure TTestSuiteRunner.UpdateCounts(ARunner: TTestRunner);
begin
  Inc(FTotal, ARunner.Total);
  Inc(FPassed, ARunner.FPassed);
  Inc(FFailed, ARunner.FFailed);
  Inc(FIgnored, ARunner.FIgnored);
  Inc(FUnknown, ARunner.FUnknown);
//  if StopOnErrors and ((FFailed > 0) or (FUnknown > 0)) then
//    raise ETestError.Create('Test Error');
end;

end.
