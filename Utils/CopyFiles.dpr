program CopyFiles;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows;

const
  SourceDir = 'c:\projects\tforge\tforge';
  TargetDir = 'c:\projects\tforge\release';

type
  TIgnoreList = array of string;

var
  DirIgnoreList: TIgnoreList;
  ExtIgnoreList: TIgnoreList;

function ValidName(const Name: string; const List: TIgnoreList): Boolean;
var
  CurrName, UpperName: string;

begin
  UpperName:= UpperCase(Name);
  for CurrName in List do begin
    if UpperCase(CurrName) = UpperName then begin
      Result:= False;
      Exit;
    end;
  end;
  Result:= True;
end;

procedure ClearDir(const DirName: string; Level: Integer = 0);
var
  Path: string;
  F: TSearchRec;

begin
  Path:= DirName + '\*.*';
  if SysUtils.FindFirst(Path, faAnyFile, F) = 0 then begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then begin
          if (F.Name <> '.') and (F.Name <> '..') then begin
            ClearDir(DirName + '\' + F.Name, Level + 1);
          end;
        end
        else
          Windows.DeleteFile(PChar(DirName + '\' + F.Name));
      until SysUtils.FindNext(F) <> 0;
    finally
      SysUtils.FindClose(F);
    end;
  end;
  if Level > 0 then RemoveDir(DirName);
end;

procedure CopyDir(const FromName, ToName: string);
var
  Path: string;
  FromPath, ToPath: string;
  F: TSearchRec;

begin
  Path:= FromName + '\*.*';
  if SysUtils.FindFirst(Path, faAnyFile, F) = 0 then begin
    try
      repeat
        FromPath:= FromName + '\' + F.Name;
        ToPath:= ToName + '\' + F.Name;
        if (F.Attr and faDirectory <> 0) then begin
          if (F.Name <> '.') and (F.Name <> '..') then begin
            if ValidName(F.Name, DirIgnoreList) then begin
              ForceDirectories(ToPath);
              CopyDir(FromPath, ToPath);
            end;
          end;
        end
        else begin
          if ValidName(ExtractFileExt(F.Name), ExtIgnoreList) then begin
            if not CopyFile(PChar(FromPath), PChar(ToPath), True)
              then raise Exception.Create('Copy Failed !');
          end;
        end;
      until SysUtils.FindNext(F) <> 0;
    finally
      SysUtils.FindClose(F);
    end;
  end;
end;

begin
  try
    DirIgnoreList:= TIgnoreList.Create('Utils', 'Ports', 'Misc',
       'backup', '__history', '.hg', 'Debug', 'Release', 'lib');
    ExtIgnoreList:= TIgnoreList.Create('.exe', '.dcu', '.hgignore', '.md',
       '.identcache', '.local', '.lps', '.bak', '.aes', '.rc4');
    ClearDir(TargetDir);
    CopyDir(SourceDir, TargetDir);
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;
end.
