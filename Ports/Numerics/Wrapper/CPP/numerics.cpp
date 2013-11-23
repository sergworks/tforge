#include <string>
#include <windows.h>
#include "numerics.hpp"

using namespace std;

typedef TF_RESULT(__stdcall *PBigNumberFromUInt32)(IBigNumber**, Cardinal);
typedef TF_RESULT(__stdcall *PBigNumberFromUInt64)(IBigNumber**, UInt64);
typedef TF_RESULT(__stdcall *PBigNumberFromInt32)(IBigNumber**, Integer);
typedef TF_RESULT(__stdcall *PBigNumberFromInt64)(IBigNumber**, Int64);
typedef TF_RESULT(__stdcall *PBigNumberFromPChar)(IBigNumber**, Byte*, Integer, Integer, bool, bool);
typedef TF_RESULT(__stdcall *PBigNumberFromPByte)(IBigNumber**, Byte*, Integer, bool);

const string LibName = "numerics32.dll";
//const string LibName = "numerics64.dll";

int LoadResult = 0;

TF_RESULT __stdcall BigNumberFromUInt32Stub(IBigNumber** A, Cardinal Value);
TF_RESULT __stdcall BigNumberFromUInt64Stub(IBigNumber** A, UInt64 Value);
TF_RESULT __stdcall BigNumberFromInt32Stub(IBigNumber** A, Integer Value);
TF_RESULT __stdcall BigNumberFromInt64Stub(IBigNumber** A, Int64 Value);
TF_RESULT __stdcall BigNumberFromPCharStub(IBigNumber**, Byte*, Integer, Integer, bool, bool);
TF_RESULT __stdcall BigNumberFromPByteStub(IBigNumber**, Byte*, Integer, bool);

PBigNumberFromUInt32 BigNumberFromUInt32 = (PBigNumberFromUInt32)&BigNumberFromUInt32Stub;
PBigNumberFromUInt64 BigNumberFromUInt64 = (PBigNumberFromUInt64)&BigNumberFromInt64Stub;
PBigNumberFromInt32 BigNumberFromInt32 = (PBigNumberFromInt32)&BigNumberFromInt32Stub;
PBigNumberFromInt64 BigNumberFromInt64 = (PBigNumberFromInt64)&BigNumberFromInt64Stub;
PBigNumberFromPChar BigNumberFromPChar = (PBigNumberFromPChar)&BigNumberFromPCharStub;
PBigNumberFromPByte BigNumberFromPByte = (PBigNumberFromPByte)&BigNumberFromPByteStub;

TF_RESULT __stdcall BigNumberFromUInt32Stub(IBigNumber** A, Cardinal Value)
{
    if (LoadResult == 0)
    {
        if (LoadNumerics(LibName) >= 0) return BigNumberFromUInt32(A, Value);
    }
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFromUInt64Stub(IBigNumber** A, UInt64 Value)
{
    if (LoadResult == 0)
    {
        if (LoadNumerics(LibName) >= 0) return BigNumberFromUInt64(A, Value);
    }
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFromInt32Stub(IBigNumber** A, Integer Value)
{
    if (LoadResult == 0)
    {
        if (LoadNumerics(LibName) >= 0) return BigNumberFromInt32(A, Value);
    }
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFromInt64Stub(IBigNumber** A, Int64 Value)
{
    if (LoadResult == 0)
    {
        if (LoadNumerics(LibName) >= 0) return BigNumberFromInt64(A, Value);
    }
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFromPCharStub(IBigNumber** A, Byte* Value, Integer L, Integer CharSize,
                                           bool AllowNegative, bool TwoCompl)
{
    if (LoadResult == 0)
    {
        if (LoadNumerics(LibName) >= 0) return BigNumberFromPChar(A, Value, L, CharSize, AllowNegative, TwoCompl);
    }
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFromPByteStub(IBigNumber** A, Byte* Value, Integer L, bool AllowNegative)
{
    if (LoadResult == 0)
    {
        if (LoadNumerics(LibName) >= 0) return BigNumberFromPByte(A, Value, L, AllowNegative);
    }
    return TF_E_LOADERROR;
}

HINSTANCE LibHandle = 0;

TF_RESULT LoadNumerics(string Name)
{
    if (LoadResult > 0)
        return TF_S_FALSE;

    if (LoadResult < 0)
        return TF_E_LOADERROR;

    LibHandle = LoadLibrary(Name.c_str());
    if (LibHandle != 0)
    {
        PBigNumberFromUInt32 FromUInt32 = (PBigNumberFromUInt32)GetProcAddress(LibHandle, "BigNumberFromLimb");
        PBigNumberFromUInt64 FromUInt64 = (PBigNumberFromUInt64)GetProcAddress(LibHandle, "BigNumberFromDblLimb");
        PBigNumberFromInt32 FromInt32 = (PBigNumberFromInt32)GetProcAddress(LibHandle, "BigNumberFromIntLimb");
        PBigNumberFromInt64 FromInt64 = (PBigNumberFromInt64)GetProcAddress(LibHandle, "BigNumberFromDblIntLimb");
        PBigNumberFromPChar FromPChar = (PBigNumberFromPChar)GetProcAddress(LibHandle, "BigNumberFromPChar");
        PBigNumberFromPByte FromPByte = (PBigNumberFromPByte)GetProcAddress(LibHandle, "BigNumberFromPByte");

        if ((FromUInt32 != NULL) && (FromUInt64 != NULL) && (FromInt32 != NULL) &&
            (FromInt64 != NULL) && (FromPChar != NULL) && (FromPByte != NULL))
        {
            BigNumberFromUInt32 = FromUInt32;
            BigNumberFromUInt64 = FromUInt64;
            BigNumberFromInt32 = FromInt32;
            BigNumberFromInt64 = FromInt64;
            BigNumberFromPChar = FromPChar;
            BigNumberFromPByte = FromPByte;
            LoadResult++;
            return TF_S_OK;
        }
    }
    LoadResult--;
    return TF_E_LOADERROR;
}

void BigNumberError(TF_RESULT H)
{
    throw(H);
}

inline void HResCheck(TF_RESULT H)
{
    if (H < 0) BigNumberError(H);
}

BigCardinal::BigCardinal(Cardinal A)
{
    HResCheck(BigNumberFromUInt32(&FNumber, A));
}

BigCardinal::BigCardinal(Integer A)
{
    HResCheck(BigNumberFromInt32(&FNumber, A));
}

BigCardinal::BigCardinal(UInt64 A)
{
    HResCheck(BigNumberFromUInt64(&FNumber, A));
}

BigCardinal::BigCardinal(Int64 A)
{
    HResCheck(BigNumberFromInt64(&FNumber, A));
}

BigCardinal::BigCardinal(const TBytes A)
{
    HResCheck(BigNumberFromPByte(&FNumber,
                (Byte*)&A[0], A.size(), false));
}

BigCardinal::BigCardinal(string A)
{
    HResCheck(BigNumberFromPChar(&FNumber, (Byte*)&A[0], A.size(),
                sizeof(char), false, false));
}

BigCardinal& BigCardinal::operator= (const BigCardinal& A)
{
    if (A.FNumber != NULL)
        A.FNumber->AddRef();
    if (FNumber != NULL)
        FNumber->Release();
    FNumber = A.FNumber;
    return *this;
}

string BigCardinal::ToString()
{
    int BytesUsed = FNumber->GetSize();
// log(256) approximated from above by 41/17
    int L = (BytesUsed * 41) / 17 + 1;
    Byte* P = new Byte[L];
    TF_RESULT HR = FNumber->ToDec(P, L);
    if (HR == TF_S_OK)
    {
        string S;
        S.resize(L);
        for (int I = 0; I < L; I++)
            S[I] = (char)P[I];
        delete[] P;
        return S;
    }
    delete[] P;
    BigNumberError(HR);
}

string BigCardinal::ToHexString(int Digits, const string Prefix, bool TwoCompl)
{
    int L;
    TF_RESULT HR = FNumber->ToHex(NULL, L, TwoCompl);
    if (HR == TF_E_INVALIDARG)
    {
        Byte* P = new Byte[L];
        HR = FNumber->ToHex(P, L, TwoCompl);
        if (HR == TF_S_OK)
        {
            if (Digits < L)
                Digits = L;
            Digits = Digits + Prefix.size();
            string S;
            S.resize(Digits);
// copy prefix
            for (int I = 0; I < Prefix.size(); I++)
                S[I] = Prefix[I];
// copy leading zeroes
            for (int I = Prefix.size(); I < Digits - L; I++)
                S[I] = '0';

            for (int I = Prefix.size() + Digits - L; I < Digits; I++)
                S[I] = (char)P[I - (Prefix.size() + Digits - L)];

            delete[] P;
            return S;
        }
        else
            delete[] P;
    }
    BigNumberError(HR);
}

TBytes BigCardinal::ToBytes()
{
    int L;
    TF_RESULT HR = FNumber->ToPByte(NULL, L);
    if ((HR == TF_E_INVALIDARG) && (L > 0))
    {
        TBytes Bytes(L);
        HR = FNumber->ToPByte(&Bytes[0], L);
        if (HR == TF_S_OK)
            return Bytes;
    }
    BigNumberError(HR);
}

bool BigCardinal::TryParse(const string S, bool TwoCompl)
{
    return (BigNumberFromPChar(&FNumber, (Byte*)&S[0], S.size(),
            sizeof(char), false, TwoCompl) == TF_S_OK);
}

void BigCardinal::Free()
{
    if (FNumber != NULL)
    {
        FNumber->Release();
        FNumber = NULL;
    }
}

int BigCardinal::Compare(const BigCardinal& A, const BigCardinal& B)
{
    return A.FNumber->CompareNumberU(B.FNumber);
}

BigCardinal BigCardinal::Pow(const BigCardinal& Base, Cardinal Value)
{
    BigCardinal Result;
    HResCheck(Base.FNumber->PowLimbU(Value, &Result.FNumber));
    return Result;
}

BigCardinal BigCardinal::DivRem(const BigCardinal& Dividend, const BigCardinal& Divisor,
                                BigCardinal& Remainder)
{
    BigCardinal Result;
    HResCheck(Dividend.FNumber->DivRemNumberU(Divisor.FNumber,
              &Result.FNumber, &Remainder.FNumber));
    return Result;
}

BigCardinal::operator Cardinal()
{
    Cardinal Result;
    HResCheck(FNumber->ToLimb(Result));
    return Result;
}

BigCardinal::operator Integer()
{
    Integer Result;
    HResCheck(FNumber->ToIntLimb(Result));
    return Result;
}

BigCardinal::operator UInt64()
{
    UInt64 Result;
    HResCheck(FNumber->ToDblLimb(Result));
    return Result;
}

BigCardinal::operator Int64()
{
    Int64 Result;
    HResCheck(FNumber->ToDblIntLimb(Result));
    return Result;
}

BigCardinal operator+(const BigCardinal& A, const BigCardinal& B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->AddNumberU(B.FNumber, &Result.FNumber));
    return Result;
}

BigCardinal operator-(const BigCardinal& A, const BigCardinal& B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->SubNumberU(B.FNumber, &Result.FNumber));
    return Result;
}

BigCardinal operator*(const BigCardinal& A, const BigCardinal& B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->MulNumberU(B.FNumber, &Result.FNumber));
    return Result;
}

BigCardinal operator/(const BigCardinal& A, const BigCardinal& B)
{
    BigCardinal Quotient;
    BigCardinal Remainder;
    HResCheck(A.FNumber->DivRemNumberU(B.FNumber, &Quotient.FNumber, &Remainder.FNumber));
    return Quotient;
}

BigCardinal operator%(const BigCardinal& A, const BigCardinal& B)
{
    BigCardinal Quotient;
    BigCardinal Remainder;
    HResCheck(A.FNumber->DivRemNumberU(B.FNumber, &Quotient.FNumber, &Remainder.FNumber));
    return Remainder;
}

BigCardinal operator<<(const BigCardinal& A, Cardinal Shift)
{
    BigCardinal Result;
    HResCheck(A.FNumber->ShlNumber(Shift, &Result.FNumber));
    return Result;
}

BigCardinal operator>>(const BigCardinal& A, Cardinal Shift)
{
    BigCardinal Result;
    HResCheck(A.FNumber->ShrNumber(Shift, &Result.FNumber));
    return Result;
}

BigCardinal operator&(const BigCardinal& A, const BigCardinal& B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->AndNumberU(B.FNumber, &Result.FNumber));
    return Result;
}

BigCardinal operator|(const BigCardinal& A, const BigCardinal& B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->OrNumberU(B.FNumber, &Result.FNumber));
    return Result;
}

BigCardinal BigCardinal::DivRem(const BigCardinal& Dividend, Cardinal Divisor,
                                Cardinal& Remainder)
{
    BigCardinal Result;
    HResCheck(Dividend.FNumber->DivRemLimbU(Divisor, &Result.FNumber, Remainder));
    return Result;
}

Cardinal BigCardinal::DivRem(Cardinal Dividend, const BigCardinal& Divisor,
                             Cardinal& Remainder)
{
    Cardinal Result;
    HResCheck(Divisor.FNumber->DivRemLimbU2(Dividend, Result, Remainder));
    return Result;
}

BigCardinal operator+(const BigCardinal& A, Cardinal B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->AddLimbU(B, &Result.FNumber));
    return Result;
}

BigCardinal operator+(Cardinal A, const BigCardinal& B)
{
    BigCardinal Result;
    HResCheck(B.FNumber->AddLimbU(A, &Result.FNumber));
    return Result;
}
