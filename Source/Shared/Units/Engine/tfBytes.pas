{ *********************************************************** }
{ *                     TForge Library                      * }
{ *       Copyright (c) Sergey Kasandrov 1997, 2014         * }
{ *********************************************************** }

unit tfBytes;

{$I TFL.inc}

{$R-}   // range checking is not allowed

interface

uses tfTypes;

type
  PByteVector = ^TByteVector;
  PPByteVector = ^PByteVector;
  TByteVector = record
  private const
    FUsedSize = SizeOf(Integer); // because SizeOf(FUsed) does not compile
  public type
{$IFDEF DEBUG}
    TByteArray = array[0..7] of Byte;
{$ELSE}
    TByteArray = array[0..0] of Byte;
{$ENDIF}

  public
    FVTable: Pointer;
    FRefCount: Integer;
    FCapacity: Integer;         // number of bytes allocated
    FUsed: Integer;             // number of bytes used
    FBytes: TByteArray;

    class function AllocVector(var A: PByteVector; NBytes: Cardinal): TF_RESULT; static;

  end;

implementation

uses tfRecords;

const
  ByteVecVTable: array[0..2] of Pointer = (
   @TtfRecord.QueryIntf,
   @TtfRecord.Addref,
   @TtfRecord.Release//,

//   @TByteVec.CompareBytes,

//   @TByteVec.AddVectors,

//   @TByteVec.AddBytes,
//   @TByteVec.SubBytes,
//   @TByteVec.AndBytes,
//   @TByteVec.OrBytes,
//   @TByteVec.XorBytes,

//   @TByteVec.CopyNumber,
//   @TByteVec.NegateNumber,

//   @TByteVec.ToDec,
//   @TByteVec.ToHex,
//   @TByteVec.ToPByte,

//   @TByteVec.AddByte,

//   @TByteVec.CompareToByte,
   );

const
  ByteVecZero: TByteVector = (
    FVTable: @ByteVecVTable;
    FRefCount: -1;
    FCapacity: 0;
    FUsed: 1;
{$IFDEF DEBUG}
    FBytes: (0, 0, 0, 0, 0, 0, 0, 0);
{$ELSE}
    FBytes: (0);
{$ENDIF}
    );


{ TByteVector }

const
  ByteVecPrefixSize = SizeOf(TByteVector) - SizeOf(TByteVector.TByteArray);
  MaxCapacity = $01000000;

class function TByteVector.AllocVector(var A: PByteVector;
                                       NBytes: Cardinal): TF_RESULT;
var
  BytesRequired: Cardinal;

begin
  if NBytes >= MaxCapacity then begin
    Result:= TF_E_NOMEMORY;
    Exit;
  end;
  BytesRequired:= NBytes + ByteVecPrefixSize;
  BytesRequired:= (BytesRequired + 7) and not 7;
  try
    GetMem(A, BytesRequired);
    A^.FVTable:= @ByteVecVTable;
    A^.FRefCount:= 1;
    A^.FCapacity:= BytesRequired - ByteVecPrefixSize;
    A^.FUsed:= 1;
    A^.FBytes[0]:= 0;
    Result:= TF_S_OK;
  except
    Result:= TF_E_OUTOFMEMORY;
  end;
end;

end.
