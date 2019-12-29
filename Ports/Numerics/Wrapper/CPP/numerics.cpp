#include <string>
#include <windows.h>
#include "numerics.hpp"

using namespace std;

typedef TF_RESULT(__stdcall *PGetNumericsVersion)(LongWord&);
typedef TF_RESULT(__stdcall *PBigNumberFromUInt32)(IBigNumber**, Cardinal);
typedef TF_RESULT(__stdcall *PBigNumberFromUInt64)(IBigNumber**, UInt64);
typedef TF_RESULT(__stdcall *PBigNumberFromInt32)(IBigNumber**, Integer);
typedef TF_RESULT(__stdcall *PBigNumberFromInt64)(IBigNumber**, Int64);
typedef TF_RESULT(__stdcall *PBigNumberFromPChar)(IBigNumber**, Byte*, Integer, Integer, bool, bool);
typedef TF_RESULT(__stdcall *PBigNumberFromPByte)(IBigNumber**, Byte*, Integer, bool);
typedef TF_RESULT(__stdcall *PBigNumberAlloc)(IBigNumber**, Integer);

const LongWord NumericsVersion = 58;
const string LibName = "numerics32.dll";
//const string LibName = "numerics64.dll";

TF_RESULT __stdcall GetNumericsVersionStub(LongWord& Version);
TF_RESULT __stdcall BigNumberFromUInt32Stub(IBigNumber** A, Cardinal Value);
TF_RESULT __stdcall BigNumberFromUInt64Stub(IBigNumber** A, UInt64 Value);
TF_RESULT __stdcall BigNumberFromInt32Stub(IBigNumber** A, Integer Value);
TF_RESULT __stdcall BigNumberFromInt64Stub(IBigNumber** A, Int64 Value);
TF_RESULT __stdcall BigNumberFromPCharStub(IBigNumber**, Byte*, Integer, Integer, bool, bool);
TF_RESULT __stdcall BigNumberFromPByteStub(IBigNumber**, Byte*, Integer, bool);
TF_RESULT __stdcall BigNumberAllocStub(IBigNumber**, Integer);

PGetNumericsVersion  GetNumericsVersion  = (PGetNumericsVersion)&GetNumericsVersionStub;
PBigNumberFromUInt32 BigNumberFromUInt32 = (PBigNumberFromUInt32)&BigNumberFromUInt32Stub;
PBigNumberFromUInt64 BigNumberFromUInt64 = (PBigNumberFromUInt64)&BigNumberFromInt64Stub;
PBigNumberFromInt32  BigNumberFromInt32  = (PBigNumberFromInt32)&BigNumberFromInt32Stub;
PBigNumberFromInt64  BigNumberFromInt64  = (PBigNumberFromInt64)&BigNumberFromInt64Stub;
PBigNumberFromPChar  BigNumberFromPChar  = (PBigNumberFromPChar)&BigNumberFromPCharStub;
PBigNumberFromPByte  BigNumberFromPByte  = (PBigNumberFromPByte)&BigNumberFromPByteStub;
PBigNumberAlloc      BigNumberAlloc      = (PBigNumberAlloc)&BigNumberAllocStub;

TF_RESULT __stdcall GetNumericsVersionStub(LongWord& Version)
{
    LoadNumerics();
    return GetNumericsVersion(Version);
}

TF_RESULT __stdcall BigNumberFromUInt32Stub(IBigNumber** A, Cardinal Value)
{
    LoadNumerics();
    return BigNumberFromUInt32(A, Value);
}

TF_RESULT __stdcall BigNumberFromUInt64Stub(IBigNumber** A, UInt64 Value)
{
    LoadNumerics();
    return BigNumberFromUInt64(A, Value);
}

TF_RESULT __stdcall BigNumberFromInt32Stub(IBigNumber** A, Integer Value)
{
    LoadNumerics();
    return BigNumberFromInt32(A, Value);
}

TF_RESULT __stdcall BigNumberFromInt64Stub(IBigNumber** A, Int64 Value)
{
    LoadNumerics();
    return BigNumberFromInt64(A, Value);
}

TF_RESULT __stdcall BigNumberFromPCharStub(IBigNumber** A, Byte* Value, Integer L, Integer CharSize,
                                           bool AllowNegative, bool TwoCompl)
{
    LoadNumerics();
    return BigNumberFromPChar(A, Value, L, CharSize, AllowNegative, TwoCompl);
}

TF_RESULT __stdcall BigNumberFromPByteStub(IBigNumber** A, Byte* Value, Integer L, bool AllowNegative)
{
    LoadNumerics();
    return BigNumberFromPByte(A, Value, L, AllowNegative);
}

TF_RESULT __stdcall BigNumberAllocStub(IBigNumber** A, Integer L)
{
    LoadNumerics();
    return BigNumberAlloc(A, L);
}

TF_RESULT __stdcall GetNumericsVersionError(LongWord& Version)
{
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFrom32Error(IBigNumber** A, Cardinal Value)
{
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFrom64Error(IBigNumber** A, UInt64 Value)
{
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFromPCharError(IBigNumber** A, Byte* Value, Integer L, Integer CharSize,
                                           bool AllowNegative, bool TwoCompl)
{
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberFromPByteError(IBigNumber** A, Byte* Value, Integer L, bool AllowNegative)
{
    return TF_E_LOADERROR;
}

TF_RESULT __stdcall BigNumberAllocError(IBigNumber** A, Integer L)
{
    return TF_E_LOADERROR;
}

bool LibLoaded = false;

TF_RESULT LoadNumerics(string Name)
{
    if (LibLoaded)
        return TF_S_FALSE;

HINSTANCE LibHandle;
LongWord Version;

    if (Name == "")
        LibHandle = LoadLibrary(LibName.c_str());
    else
        LibHandle = LoadLibrary(Name.c_str());

    if (LibHandle != 0)
    {
        GetNumericsVersion = (PGetNumericsVersion)GetProcAddress(LibHandle, "GetNumericsVersion");
        BigNumberFromUInt32 = (PBigNumberFromUInt32)GetProcAddress(LibHandle, "BigNumberFromLimb");
        BigNumberFromUInt64 = (PBigNumberFromUInt64)GetProcAddress(LibHandle, "BigNumberFromDblLimb");
        BigNumberFromInt32 = (PBigNumberFromInt32)GetProcAddress(LibHandle, "BigNumberFromIntLimb");
        BigNumberFromInt64 = (PBigNumberFromInt64)GetProcAddress(LibHandle, "BigNumberFromDblIntLimb");
        BigNumberFromPChar = (PBigNumberFromPChar)GetProcAddress(LibHandle, "BigNumberFromPChar");
        BigNumberFromPByte = (PBigNumberFromPByte)GetProcAddress(LibHandle, "BigNumberFromPByte");
        BigNumberAlloc = (PBigNumberAlloc)GetProcAddress(LibHandle, "BigNumberAlloc");

        if ((GetNumericsVersion != NULL) &&
            (BigNumberFromUInt32 != NULL) && (BigNumberFromUInt64 != NULL) &&
            (BigNumberFromInt32 != NULL) && (BigNumberFromInt64 != NULL) &&
            (BigNumberFromPChar != NULL) && (BigNumberFromPByte != NULL) &&
            (BigNumberAlloc != NULL))
        {
            if ((GetNumericsVersion(Version) == TF_S_OK) && (Version == NumericsVersion))
            {
                LibLoaded = true;
                return TF_S_OK;
            }
        }
        FreeLibrary(LibHandle);
    }
    GetNumericsVersion = GetNumericsVersionError;
    BigNumberFromUInt32 = BigNumberFrom32Error;
    BigNumberFromUInt64 = BigNumberFrom64Error;
    BigNumberFromInt32 = (PBigNumberFromInt32)&BigNumberFrom32Error;
    BigNumberFromInt64 = (PBigNumberFromInt64)&BigNumberFrom64Error;
    BigNumberFromPChar = BigNumberFromPCharError;
    BigNumberFromPByte = BigNumberFromPByteError;
    BigNumberAlloc = BigNumberAllocError;
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
    FNumber = NULL;
    HResCheck(BigNumberFromUInt32(&FNumber, A));
}

BigCardinal::BigCardinal(Integer A)
{
    FNumber = NULL;
    if (A < 0)
        BigNumberError(TF_E_INVALIDARG);
    HResCheck(BigNumberFromInt32(&FNumber, A));
}

BigCardinal::BigCardinal(UInt64 A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromUInt64(&FNumber, A));
}

BigCardinal::BigCardinal(Int64 A)
{
    FNumber = NULL;
    if (A < 0)
        BigNumberError(TF_E_INVALIDARG);
    HResCheck(BigNumberFromInt64(&FNumber, A));
}

BigCardinal::BigCardinal(const TBytes A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromPByte(&FNumber,
                (Byte*)&A[0], A.size(), false));
}

BigCardinal::BigCardinal(const string A)
{
    FNumber = NULL;
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
            for (int I = 0; I < (int)Prefix.size(); I++)
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

int BigCardinal::Compare(const BigCardinal& A, const BigCardinal& B)
{
    return A.FNumber->CompareNumberU(B.FNumber);
}

BigCardinal BigCardinal::Pow(const BigCardinal& Base, Cardinal Value)
{
    BigCardinal Result;
    HResCheck(Base.FNumber->PowU(Value, &Result.FNumber));
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

BigCardinal operator-(const BigCardinal& A, Cardinal B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->SubLimbU(B, &Result.FNumber));
    return Result;
}

Cardinal operator-(Cardinal A, const BigCardinal& B)
{
    Cardinal Result;
    HResCheck(B.FNumber->SubLimbU2(A, &Result));
    return Result;
}

BigCardinal operator*(const BigCardinal& A, Cardinal B)
{
    BigCardinal Result;
    HResCheck(A.FNumber->MulLimbU(B, &Result.FNumber));
    return Result;
}

BigCardinal operator*(Cardinal A, const BigCardinal& B)
{
    BigCardinal Result;
    HResCheck(B.FNumber->MulLimbU(A, &Result.FNumber));
    return Result;
}

int BigCardinal::CompareToCard(Cardinal B) const
{
    return FNumber->CompareToLimbU(B);
}

int BigCardinal::CompareToInt(Integer B) const
{
    return FNumber->CompareToIntLimbU(B);
}

int BigCardinal::CompareToUInt64(UInt64 B) const
{
    return FNumber->CompareToDblLimbU(B);
}

int BigCardinal::CompareToInt64(Int64 B) const
{
    return FNumber->CompareToDblIntLimbU(B);
}

// ------------------- BigInteger ------------------- //

BigInteger::BigInteger(Cardinal A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromUInt32(&FNumber, A));
}

BigInteger::BigInteger(Integer A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromInt32(&FNumber, A));
}

BigInteger::BigInteger(UInt64 A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromUInt64(&FNumber, A));
}

BigInteger::BigInteger(Int64 A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromInt64(&FNumber, A));
}

BigInteger::BigInteger(const TBytes A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromPByte(&FNumber,
                (Byte*)&A[0], A.size(), true));
}

BigInteger::BigInteger(const string A)
{
    FNumber = NULL;
    HResCheck(BigNumberFromPChar(&FNumber, (Byte*)&A[0], A.size(),
                sizeof(char), true, false));
}

BigInteger& BigInteger::operator= (const BigInteger& A)
{
    if (A.FNumber != NULL)
        A.FNumber->AddRef();
    if (FNumber != NULL)
        FNumber->Release();
    FNumber = A.FNumber;
    return *this;
}

string BigInteger::ToString()
{
    int BytesUsed = FNumber->GetSize();
// log(256) approximated from above by 41/17
    int L = (BytesUsed * 41) / 17 + 1;
    Byte* P = new Byte[L];
    TF_RESULT HR = FNumber->ToDec(P, L);
    if (HR == TF_S_OK)
    {
        bool IsMinus = FNumber->GetSign() < 0;
        if (IsMinus)
            L++;
        string S;
        S.resize(L);
        if (IsMinus)
        {
            S[0] = '-';
            for (int I = 1; I < L; I++)
                S[I+1] = (char)P[I];
        }
        else
        {
            for (int I = 0; I < L; I++)
            S[I] = (char)P[I];
        }
        delete[] P;
        return S;
    }
    delete[] P;
    BigNumberError(HR);
}

string BigInteger::ToHexString(int Digits, const string Prefix, bool TwoCompl)
{
    const Byte ASCII_8 = 56;    // Ord('8')
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
            int I = 0;
            string S;
            if ((FNumber->GetSign() < 0) && (!TwoCompl))
            {
                I++;
                S.resize(Digits + Prefix.size() + 1);
                S[0] = '-';
            }
            else
            {
                S.resize(Digits + Prefix.size());
            }
// copy prefix
            for (int J = 0; J < (int)Prefix.size(); J++)
            {
                S[I] = Prefix[J];
                I++;
            }
// copy leading '0' or 'F'
            if (Digits > L)
            {
                char Filler;
                if (TwoCompl and (P[L] >= ASCII_8))
                    Filler = 'F';
                else
                    Filler = '0';
                while (I + L < S.size()) {
                    S[I] = Filler;
                    I++;
                }
            }
            int J = I;
            while (I < S.size()) {
                S[I] = (char)P[I - J];
                I++;
            }
            delete[] P;
            return S;
        }
        else
            delete[] P;
    }
    BigNumberError(HR);
}

TBytes BigInteger::ToBytes()
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

bool BigInteger::TryParse(const string S, bool TwoCompl)
{
    return (BigNumberFromPChar(&FNumber, (Byte*)&S[0], S.size(),
            sizeof(char), true, TwoCompl) == TF_S_OK);
}

int BigInteger::Sign()
{
    return FNumber->GetSign();
}

BigInteger BigInteger::Abs(const BigInteger& A)
{
    BigInteger Result;
    HResCheck(A.FNumber->AbsNumber(&Result.FNumber));
    return Result;
}

BigInteger BigInteger::Pow(const BigInteger& Base, Cardinal Value)
{
    BigInteger Result;
    HResCheck(Base.FNumber->Pow(Value, &Result.FNumber));
    return Result;
}

BigInteger BigInteger::DivRem(const BigInteger& Dividend, const BigInteger& Divisor,
                                BigInteger& Remainder)
{
    BigInteger Result;
    HResCheck(Dividend.FNumber->DivRemNumber(Divisor.FNumber,
              &Result.FNumber, &Remainder.FNumber));
    return Result;
}

BigInteger BigInteger::Sqrt(const BigInteger& A)
{
    BigInteger Result;
    HResCheck(A.FNumber->SqrtNumber(&Result.FNumber));
    return Result;
}

BigInteger BigInteger::GCD(const BigInteger& A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(A.FNumber->GCD(B.FNumber, &Result.FNumber));
    return Result;
}

BigInteger BigInteger::EGCD(const BigInteger& A, const BigInteger& B, BigInteger& X, BigInteger& Y)
{
    BigInteger Result;
    HResCheck(A.FNumber->EGCD(B.FNumber, &Result.FNumber, &X.FNumber, &Y.FNumber));
    return Result;
}

BigInteger BigInteger::ModPow(const BigInteger& BaseValue, const BigInteger& ExpValue,
                              const BigInteger& Modulo)
{
    BigInteger Result;
    HResCheck(BaseValue.FNumber->ModPow(ExpValue.FNumber, Modulo.FNumber, &Result.FNumber));
    return Result;
}

BigInteger BigInteger::ModInverse(const BigInteger& A, const BigInteger& Modulo)
{
    BigInteger Result;
    HResCheck(A.FNumber->ModInverse(Modulo.FNumber, &Result.FNumber));
    return Result;
}

int BigInteger::Compare(const BigInteger& A, const BigInteger& B)
{
    return A.FNumber->CompareNumber(B.FNumber);
}

int BigInteger::Compare(const BigInteger& A, const BigCardinal& B)
{
    return A.FNumber->CompareNumber(B.FNumber);
}

int BigInteger::Compare(const BigCardinal& A, const BigInteger& B)
{
    return A.FNumber->CompareNumber(B.FNumber);
}

BigInteger operator+(const BigInteger& A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(A.FNumber->AddNumber(B.FNumber, &Result.FNumber));
    return Result;
}

BigInteger operator-(const BigInteger& A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(A.FNumber->SubNumber(B.FNumber, &Result.FNumber));
    return Result;
}

BigInteger operator*(const BigInteger& A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(A.FNumber->MulNumber(B.FNumber, &Result.FNumber));
    return Result;
}

BigInteger operator/(const BigInteger& A, const BigInteger& B)
{
    BigInteger Quotient;
    BigInteger Remainder;
    HResCheck(A.FNumber->DivRemNumber(B.FNumber, &Quotient.FNumber, &Remainder.FNumber));
    return Quotient;
}

BigInteger operator%(const BigInteger& A, const BigInteger& B)
{
    BigInteger Quotient;
    BigInteger Remainder;
    HResCheck(A.FNumber->DivRemNumber(B.FNumber, &Quotient.FNumber, &Remainder.FNumber));
    return Remainder;
}

BigInteger operator<<(const BigInteger& A, Cardinal Shift)
{
    BigInteger Result;
    HResCheck(A.FNumber->ShlNumber(Shift, &Result.FNumber));
    return Result;
}

BigInteger operator>>(const BigInteger& A, Cardinal Shift)
{
    BigInteger Result;
    HResCheck(A.FNumber->ShrNumber(Shift, &Result.FNumber));
    return Result;
}

BigInteger operator&(const BigInteger& A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(A.FNumber->AndNumber(B.FNumber, &Result.FNumber));
    return Result;
}

BigInteger operator|(const BigInteger& A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(A.FNumber->OrNumber(B.FNumber, &Result.FNumber));
    return Result;
}

BigInteger operator^(const BigInteger& A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(A.FNumber->XorNumber(B.FNumber, &Result.FNumber));
    return Result;
}

int BigInteger::CompareToCard(Cardinal B) const
{
    return FNumber->CompareToLimb(B);
}

int BigInteger::CompareToInt(Integer B) const
{
    return FNumber->CompareToIntLimb(B);
}

int BigInteger::CompareToUInt64(UInt64 B) const
{
    return FNumber->CompareToDblLimb(B);
}

int BigInteger::CompareToInt64(Int64 B) const
{
    return FNumber->CompareToDblIntLimb(B);
}


// --- arithmetic operations on BigInteger & Cardinal ---
BigInteger operator+(const BigInteger& A, Cardinal B)
{
    BigInteger Result;
    HResCheck(A.FNumber->AddLimb(B, &Result.FNumber));
    return Result;
}

BigInteger operator-(const BigInteger& A, Cardinal B)
{
    BigInteger Result;
    HResCheck(A.FNumber->SubLimb(B, &Result.FNumber));
    return Result;
}

BigInteger operator*(const BigInteger& A, Cardinal B)
{
    BigInteger Result;
    HResCheck(A.FNumber->MulLimb(B, &Result.FNumber));
    return Result;
}

BigInteger operator/(const BigInteger& A, Cardinal B)
{
    BigInteger Remainder;
    BigInteger Result;
    HResCheck(A.FNumber->DivRemLimb(B, &Result.FNumber, &Remainder.FNumber));
    return Result;
}

BigInteger operator%(const BigInteger& A, Cardinal B)
{
    BigInteger Quotient;
    BigInteger Result;
    HResCheck(A.FNumber->DivRemLimb(B, &Quotient.FNumber, &Result.FNumber));
    return Result;
}

BigInteger BigInteger::DivRem(const BigInteger& Dividend, Cardinal Divisor,
                              BigInteger& Remainder)
{
    BigInteger Result;
    HResCheck(Dividend.FNumber->DivRemLimb(Divisor, &Result.FNumber, &Remainder.FNumber));
    return Result;
}

// --- arithmetic operations on Cardinal & BigInteger ---
BigInteger operator+(Cardinal A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(B.FNumber->AddLimb(A, &Result.FNumber));
    return Result;
}

BigInteger operator-(Cardinal A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(B.FNumber->SubLimb2(A, &Result.FNumber));
    return Result;
}

BigInteger operator*(Cardinal A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(B.FNumber->MulLimb(A, &Result.FNumber));
    return Result;
}

BigInteger operator/(Cardinal A, const BigInteger& B)
{
    Cardinal Remainder;
    BigInteger Result;
    HResCheck(B.FNumber->DivRemLimb2(A, &Result.FNumber, Remainder));
    return Result;
}

Cardinal operator%(Cardinal A, const BigInteger& B)
{
    BigInteger Quotient;
    Cardinal Result;
    HResCheck(B.FNumber->DivRemLimb2(A, &Quotient.FNumber, Result));
    return Result;
}

BigInteger BigInteger::DivRem(Cardinal Dividend, const BigInteger& Divisor,
                              Cardinal& Remainder)
{
    BigInteger Result;
    HResCheck(Divisor.FNumber->DivRemLimb2(Dividend, &Result.FNumber, Remainder));
    return Result;
}

// --- arithmetic operations on BigInteger & Integer ---
BigInteger operator+(const BigInteger& A, Integer B)
{
    BigInteger Result;
    HResCheck(A.FNumber->AddIntLimb(B, &Result.FNumber));
    return Result;
}

BigInteger operator-(const BigInteger& A, Integer B)
{
    BigInteger Result;
    HResCheck(A.FNumber->SubIntLimb(B, &Result.FNumber));
    return Result;
}

BigInteger operator*(const BigInteger& A, Integer B)
{
    BigInteger Result;
    HResCheck(A.FNumber->MulIntLimb(B, &Result.FNumber));
    return Result;
}

BigInteger operator/(const BigInteger& A, Integer B)
{
    Integer Remainder;
    BigInteger Result;
    HResCheck(A.FNumber->DivRemIntLimb(B, &Result.FNumber, Remainder));
    return Result;
}

Integer operator%(const BigInteger& A, Integer B)
{
    BigInteger Quotient;
    Integer Result;
    HResCheck(A.FNumber->DivRemIntLimb(B, &Quotient.FNumber, Result));
    return Result;
}

BigInteger BigInteger::DivRem(const BigInteger& Dividend, Integer Divisor,
                              Integer& Remainder)
{
    BigInteger Result;
    HResCheck(Dividend.FNumber->DivRemIntLimb(Divisor, &Result.FNumber, Remainder));
    return Result;
}

// --- arithmetic operations on Integer & BigInteger ---

BigInteger operator+(Integer A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(B.FNumber->AddIntLimb(A, &Result.FNumber));
    return Result;
}

BigInteger operator-(Integer A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(B.FNumber->SubIntLimb(A, &Result.FNumber));
    return Result;
}

BigInteger operator*(Integer A, const BigInteger& B)
{
    BigInteger Result;
    HResCheck(B.FNumber->MulIntLimb(A, &Result.FNumber));
    return Result;
}

Integer operator/(Integer A, const BigInteger& B)
{
    Integer Result;
    Integer Remainder;
    HResCheck(B.FNumber->DivRemIntLimb2(A, Result, Remainder));
    return Result;
}

Integer operator%(Integer A, const BigInteger& B)
{
    Integer Result;
    Integer Quotient;
    HResCheck(B.FNumber->DivRemIntLimb2(A, Quotient, Result));
    return Result;
}

Integer BigInteger::DivRem(Integer Dividend, const BigInteger& Divisor,
                           Integer& Remainder)
{
    Integer Result;
    HResCheck(Divisor.FNumber->DivRemIntLimb2(Dividend, Result, Remainder));
    return Result;
}
