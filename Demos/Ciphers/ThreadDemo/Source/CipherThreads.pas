unit CipherThreads;

interface

uses
  Windows, Classes, tfCiphers;

type
  TCipherThread = class(TThread)
  private
    FCipher: TCipher;
    FOrigin: Pointer;
    FSize: LongWord;
    FLast: Boolean;
    FEvent: THandle;
  protected
    procedure Execute; override;
  public
    constructor Create(ACipher: TCipher; AOrigin: Pointer; ASize: LongWord;
                       ALast: Boolean; AEvent: THandle);
  end;

implementation

{ TCipherThread }

constructor TCipherThread.Create(ACipher: TCipher; AOrigin: Pointer;
  ASize: LongWord; ALast: Boolean; AEvent: THandle);
begin
  FCipher:= ACipher;
  FOrigin:= AOrigin;
  FSize:= ASize;
  FLast:= ALast;
  FEvent:= AEvent;
  FreeOnTerminate:= True;
  inherited Create(False);
end;

procedure TCipherThread.Execute;
var
  DataSize: LongWord;

begin
  DataSize:= FSize;
  FCipher.KeyCrypt(FOrigin^, DataSize, FLast);
  SetEvent(FEvent);
end;

end.
