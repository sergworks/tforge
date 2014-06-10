{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfUtils;

interface

function JenkinsOneHash(const Data; Len: Cardinal): Integer;

implementation

function JenkinsOneHash(const Data; Len: Cardinal): Integer;
var
  PData: PByte;

begin
  Result:= 0;
  PData:= @Data;
  while Len > 0 do begin
    Result:= Result + PData^;
    Result:= Result + (Result shl 10);
    Result:= Result xor (Result shr 6);
    Inc(PData);
    Dec(Len);
  end;
  Result:= Result + (Result shl 3);
  Result:= Result xor (Result shr 11);
  Result:= Result + (Result shl 15);
end;

end.
