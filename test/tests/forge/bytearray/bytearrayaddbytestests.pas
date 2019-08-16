unit ByteArrayAddBytesTests;

interface

uses
  Classes, SysUtils, {tfTypes, tfExceptions, tfUtils, }tfArrays,
  Loggers, TestClasses;

type
  TByteArrayAddBytesTest = class(TTestObject)
  private
    FLeft: ByteArray;
    FRight: ByteArray;
    FExpected: ByteArray;
    FActual: ByteArray;
  public
    constructor Create(ALogger: TLogger;
                  const ALeft, ARight, AExpected: array of Byte);
    function TestVector: string;
    procedure Execute; override;
  end;

  TByteArrayAddBytesRunner = class(TTestRunner)
  public
    procedure RunTest(const ALeft, ARight, AExpected: array of Byte);
    procedure Run; override;
  end;

implementation

{ TByteArrayAddBytesTest }

constructor TByteArrayAddBytesTest.Create(ALogger: TLogger; const ALeft,
  ARight, AExpected: array of Byte);
begin
  inherited Create(ALogger, 'ByteArray.AddBytes');
  FLeft:= ByteArray.FromBytes(ALeft);
  FRight:= ByteArray.FromBytes(ARight);
  FExpected:= ByteArray.FromBytes(AExpected);
end;

procedure TByteArrayAddBytesTest.Execute;
begin
  FActual:= ByteArray.AddBytes(FLeft, FRight);
  CheckEquals(FExpected, FActual);
end;

function TByteArrayAddBytesTest.TestVector: string;
begin
  Result:= FLeft.ToHex + ' + ' + FRight.ToHex + ' = ' + FExpected.ToHex;
end;


{ TByteArrayAddBytesRunner }

procedure TByteArrayAddBytesRunner.Run;
begin
  Logger.WriteLn;
  Logger.WriteLn('>>> ByteArray.AddBytes Test Started ...', LOG_NORMAL);

  RunTest([0, 1, 2],    [10, 11, 12], [10, 12, 14]);
  RunTest([1, 5],       [10, 11, 12], [11, 16]);
  RunTest([1, 2, 3, 4], [10, 20],     [11, 22]);
  RunTest([$FF, $EE],   [1, 20, 40],  [0, 2]);

  Logger.WriteLn('>>> ByteArray.AddBytes Test Statistics', LOG_NORMAL);
  LogCounts;
end;

procedure TByteArrayAddBytesRunner.RunTest(const ALeft, ARight,
  AExpected: array of Byte);

var
  Test: TByteArrayAddBytesTest;

begin
//  Logger.WriteLn;
  Test:= TByteArrayAddBytesTest.Create(Logger, ALeft, ARight, AExpected);
  try
    Logger.WriteLn('#' + IntToStr(FTotal + 1) + ': ' + Test.TestVector, LOG_DETAILED);
    Test.ExecuteTest;
    UpdateCounts(Test);
  finally
    Test.Free;
  end;
end;

end.
