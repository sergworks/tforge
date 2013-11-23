#ifndef NUMERICS_HPP_INCLUDED
#define NUMERICS_HPP_INCLUDED

#include <vector>
#include <string>

using namespace std;

typedef uint8_t Byte;
typedef uint16_t Word;
typedef uint32_t LongWord;
typedef uint64_t UInt64;

typedef int8_t ShortInt;
typedef int16_t SmallInt;
typedef int32_t LongInt;
typedef int64_t Int64;

typedef LongInt Integer;
typedef LongWord Cardinal;

typedef LongInt TF_RESULT;
typedef vector<Byte> TBytes;

//typedef void* REFIID;

const TF_RESULT TF_S_OK           = 0x00000000;     // Operation successful
const TF_RESULT TF_S_FALSE        = 0x00000001;     // Operation successful
const TF_RESULT TF_E_FAIL         = 0x80004005;     // Unspecified failure
const TF_RESULT TF_E_INVALIDARG   = 0x80070057;     // One or more arguments are not valid
const TF_RESULT TF_E_NOINTERFACE  = 0x80004002;     // No such interface supported
const TF_RESULT TF_E_NOTIMPL      = 0x80004001;     // Not implemented
const TF_RESULT TF_E_OUTOFMEMORY  = 0x8007000E;     // Failed to allocate necessary memory
const TF_RESULT TF_E_UNEXPECTED   = 0x8000FFFF;     // Unexpected failure
                                                    // = TFL specific codes =
const TF_RESULT TF_E_NOMEMORY     = 0xA0000003;     // specific TFL memory error
const TF_RESULT TF_E_LOADERROR    = 0xA0000004;     // Error loading dll

class IBigNumber {
  public:
    virtual TF_RESULT __stdcall QueryInterface(void* riid, void** ppvObject) = 0;
    virtual LongWord __stdcall AddRef() = 0;
    virtual LongWord __stdcall Release() = 0;

    virtual bool __stdcall GetIsEven() = 0;
    virtual bool __stdcall GetIsOne() = 0;
    virtual bool __stdcall GetIsPowerOfTwo() = 0;
    virtual bool __stdcall GetIsZero() = 0;
    virtual LongInt __stdcall GetSign() = 0;
    virtual LongInt __stdcall GetSize() = 0;

    virtual LongInt __stdcall CompareNumber(IBigNumber* Num) = 0;
    virtual LongInt __stdcall CompareNumberU(IBigNumber* Num) = 0;

    virtual TF_RESULT __stdcall AddNumber(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall AddNumberU(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SubNumber(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SubNumberU(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall MulNumber(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall MulNumberU(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall DivRemNumber(IBigNumber* Num, IBigNumber** Q, IBigNumber** R) = 0;
    virtual TF_RESULT __stdcall DivRemNumberU(IBigNumber* Num, IBigNumber** Q, IBigNumber** R) = 0;

    virtual TF_RESULT __stdcall AndNumber(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall AndNumberU(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall OrNumber(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall OrNumberU(IBigNumber* Num, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall XorNumber(IBigNumber* Num, IBigNumber** Res) = 0;

    virtual TF_RESULT __stdcall ShlNumber(LongWord Shift, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall ShrNumber(LongWord Shift, IBigNumber** Res) = 0;

    virtual TF_RESULT __stdcall AssignNumber(IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall AbsNumber(IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall NegateNumber(IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall PowLimb(LongWord Power, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall PowLimbU(LongWord Power, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall ModPow(IBigNumber* IExp, IBigNumber* IMod, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SqrtNumber(IBigNumber** Res) = 0;

    virtual TF_RESULT __stdcall ToLimb(LongWord& Value) = 0;
    virtual TF_RESULT __stdcall ToIntLimb(LongInt& Value) = 0;
    virtual TF_RESULT __stdcall ToDec(Byte* P, LongInt& L) = 0;
    virtual TF_RESULT __stdcall ToHex(Byte* P, LongInt& L, bool TwoCompl) = 0;
    virtual TF_RESULT __stdcall ToPByte(Byte* P, LongInt& L) = 0;

    virtual LongInt __stdcall CompareToLimb(LongWord Value) = 0;
    virtual LongInt __stdcall CompareToLimbU(LongWord Value) = 0;
    virtual LongInt __stdcall CompareToIntLimb(LongInt Value) = 0;
    virtual LongInt __stdcall CompareToIntLimbU(LongInt Value) = 0;

    virtual TF_RESULT __stdcall AddLimb(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall AddLimbU(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall AddIntLimb(LongInt Limb, IBigNumber** Res) = 0;

    virtual TF_RESULT __stdcall SubLimb(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SubLimb2(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SubLimbU(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SubLimbU2(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SubIntLimb(LongInt Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall SubIntLimb2(LongInt Limb, IBigNumber** Res) = 0;

    virtual TF_RESULT __stdcall MulLimb(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall MulLimbU(LongWord Limb, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall MulIntLimb(LongInt Limb, IBigNumber** Res) = 0;

    virtual TF_RESULT __stdcall DivRemLimb(LongWord Limb, IBigNumber** Q, IBigNumber** R) = 0;
    virtual TF_RESULT __stdcall DivRemLimb2(LongWord Limb, IBigNumber** Q, LongWord& R) = 0;
    virtual TF_RESULT __stdcall DivRemLimbU(LongWord Limb, IBigNumber** Q, LongWord& R) = 0;
    virtual TF_RESULT __stdcall DivRemLimbU2(LongWord Limb, LongWord& Q, LongWord& R) = 0;
    virtual TF_RESULT __stdcall DivRemIntLimb(LongInt Limb, IBigNumber** Q, LongInt& R) = 0;
    virtual TF_RESULT __stdcall DivRemIntLimb2(LongInt Limb, LongInt& Q, LongInt& R) = 0;

    virtual TF_RESULT __stdcall ToDblLimb(UInt64& Value) = 0;
    virtual TF_RESULT __stdcall ToDblIntLimb(Int64& Value) = 0;
    virtual LongInt __stdcall CompareToDblLimb(UInt64 Value) = 0;
    virtual LongInt __stdcall CompareToDblLimbU(UInt64 Value) = 0;
    virtual LongInt __stdcall CompareToDblIntLimb(Int64 Value) = 0;
    virtual LongInt __stdcall CompareToDblIntLimbU(Int64 Value) = 0;
};

TF_RESULT LoadNumerics(string Name);

class BigCardinal {
  private:
    IBigNumber* FNumber;
  public:
    BigCardinal() : FNumber(NULL) {};
    BigCardinal(const BigCardinal& A)
    {
    	FNumber = A.FNumber;
    	if (FNumber != NULL)
    	{
    		FNumber->AddRef();
    	}
    };
    BigCardinal(Cardinal A);
    BigCardinal(Integer A);
    BigCardinal(UInt64 A);
    BigCardinal(Int64 A);
    BigCardinal(const TBytes A);
    BigCardinal(const string A);


    ~BigCardinal()      // !! non-virtual !!
    {
  	    if (FNumber != NULL)
  	    {
  		    FNumber->Release();
  	    }
    };
    BigCardinal& operator= (const BigCardinal& A);

    string ToString();
    string ToHexString(int Digits = 0, const string Prefix = "", bool TwoCompl = false);
    TBytes ToBytes();
    bool TryParse(const string S, bool TwoCompl = false);
    void Free();

    static int Compare(const BigCardinal& A, const BigCardinal& B);
    Integer CompareTo(const BigCardinal& B)
    {
        return Compare(*this, B);
    }

    static BigCardinal Pow(const BigCardinal& Base, Cardinal Value);
    static BigCardinal DivRem(const BigCardinal& Dividend, const BigCardinal& Divisor,
                              BigCardinal& Remainder);

    operator Cardinal();
    operator Integer();
    operator UInt64();
    operator Int64();

    friend bool operator==(const BigCardinal& A, const BigCardinal& B)
    {
        return (Compare(A, B) == 0);
    }
    friend bool operator!=(const BigCardinal& A, const BigCardinal& B)
    {
        return (Compare(A, B) != 0);
    }
    friend bool operator>(const BigCardinal& A, const BigCardinal& B)
    {
        return (Compare(A, B) > 0);
    }
    friend bool operator>=(const BigCardinal& A, const BigCardinal& B)
    {
        return (Compare(A, B) >= 0);
    }
    friend bool operator<(const BigCardinal& A, const BigCardinal& B)
    {
        return (Compare(A, B) < 0);
    }
    friend bool operator<=(const BigCardinal& A, const BigCardinal& B)
    {
        return (Compare(A, B) <= 0);
    }

    friend BigCardinal operator+(const BigCardinal& A, const BigCardinal& B);
    friend BigCardinal operator-(const BigCardinal& A, const BigCardinal& B);
    friend BigCardinal operator*(const BigCardinal& A, const BigCardinal& B);
    friend BigCardinal operator/(const BigCardinal& A, const BigCardinal& B);
    friend BigCardinal operator%(const BigCardinal& A, const BigCardinal& B);

    friend BigCardinal operator<<(const BigCardinal& A, Cardinal Shift);
    friend BigCardinal operator>>(const BigCardinal& A, Cardinal Shift);

    friend BigCardinal operator&(const BigCardinal& A, const BigCardinal& B);
    friend BigCardinal operator|(const BigCardinal& A, const BigCardinal& B);

    Integer CompareToCard(Cardinal B) const;
    Integer CompareToInt(Integer B) const;
    Integer CompareTo(Cardinal B) const
    {
        return CompareToCard(B);
    }
    Integer CompareTo(Integer B) const
    {
        return CompareToInt(B);
    }

    friend bool operator==(const BigCardinal& A, Cardinal B)
    {
        return (A.CompareToCard(B) == 0);
    }
    friend bool operator==(Cardinal A, const BigCardinal& B)
    {
        return (B.CompareToCard(A) == 0);
    }
    friend bool operator==(const BigCardinal& A, Integer B)
    {
        return (A.CompareToInt(B) == 0);
    }
    friend bool operator==(Integer A, const BigCardinal& B)
    {
        return (B.CompareToInt(A) == 0);
    }

    friend bool operator!=(const BigCardinal& A, Cardinal B)
    {
        return (A.CompareToCard(B) != 0);
    }
    friend bool operator!=(Cardinal A, const BigCardinal& B)
    {
        return (B.CompareToCard(A) != 0);
    }
    friend bool operator!=(const BigCardinal& A, Integer B)
    {
        return (A.CompareToInt(B) != 0);
    }
    friend bool operator!=(Integer A, const BigCardinal& B)
    {
        return (B.CompareToInt(A) != 0);
    }

    friend bool operator>(const BigCardinal& A, Cardinal B)
    {
        return (A.CompareToCard(B) > 0);
    }
    friend bool operator>(Cardinal A, const BigCardinal& B)
    {
        return (B.CompareToCard(A) < 0);
    }
    friend bool operator>(const BigCardinal& A, Integer B)
    {
        return (A.CompareToInt(B) > 0);
    }
    friend bool operator>(Integer A, const BigCardinal& B)
    {
        return (B.CompareToInt(A) < 0);
    }

    friend bool operator>=(const BigCardinal& A, Cardinal B)
    {
        return (A.CompareToCard(B) >= 0);
    }
    friend bool operator>=(Cardinal A, const BigCardinal& B)
    {
        return (B.CompareToCard(A) <= 0);
    }
    friend bool operator>=(const BigCardinal& A, Integer B)
    {
        return (A.CompareToInt(B) >= 0);
    }
    friend bool operator>=(Integer A, const BigCardinal& B)
    {
        return (B.CompareToInt(A) <= 0);
    }

    friend bool operator<(const BigCardinal& A, Cardinal B)
    {
        return (A.CompareToCard(B) < 0);
    }
    friend bool operator<(Cardinal A, const BigCardinal& B)
    {
        return (B.CompareToCard(A) > 0);
    }
    friend bool operator<(const BigCardinal& A, Integer B)
    {
        return (A.CompareToInt(B) < 0);
    }
    friend bool operator<(Integer A, const BigCardinal& B)
    {
        return (B.CompareToInt(A) > 0);
    }

    friend bool operator<=(const BigCardinal& A, Cardinal B)
    {
        return (A.CompareToCard(B) <= 0);
    }
    friend bool operator<=(Cardinal A, const BigCardinal& B)
    {
        return (B.CompareToCard(A) >= 0);
    }
    friend bool operator<=(const BigCardinal& A, Integer B)
    {
        return (A.CompareToInt(B) <= 0);
    }
    friend bool operator<=(Integer A, const BigCardinal& B)
    {
        return (B.CompareToInt(A) >= 0);
    }

    Integer CompareToUInt64(UInt64 B) const;
    Integer CompareToInt64(Int64 B) const;
    Integer CompareTo(UInt64 B) const
    {
        return CompareToUInt64(B);
    }
    Integer CompareTo(Int64 B) const
    {
        return CompareToInt64(B);
    }

    friend bool operator==(const BigCardinal& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) == 0);
    }
    friend bool operator==(UInt64 A, const BigCardinal& B)
    {
        return (B.CompareToUInt64(A) == 0);
    }
    friend bool operator==(const BigCardinal& A, Int64 B)
    {
        return (A.CompareToInt64(B) == 0);
    }
    friend bool operator==(Int64 A, const BigCardinal& B)
    {
        return (B.CompareToInt64(A) == 0);
    }

    friend bool operator!=(const BigCardinal& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) != 0);
    }
    friend bool operator!=(UInt64 A, const BigCardinal& B)
    {
        return (B.CompareToUInt64(A) != 0);
    }
    friend bool operator!=(const BigCardinal& A, Int64 B)
    {
        return (A.CompareToInt64(B) != 0);
    }
    friend bool operator!=(Int64 A, const BigCardinal& B)
    {
        return (B.CompareToInt64(A) != 0);
    }

    friend bool operator>(const BigCardinal& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) > 0);
    }
    friend bool operator>(UInt64 A, const BigCardinal& B)
    {
        return (B.CompareToUInt64(A) < 0);
    }
    friend bool operator>(const BigCardinal& A, Int64 B)
    {
        return (A.CompareToInt64(B) > 0);
    }
    friend bool operator>(Int64 A, const BigCardinal& B)
    {
        return (B.CompareToInt64(A) < 0);
    }

    friend bool operator>=(const BigCardinal& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) >= 0);
    }
    friend bool operator>=(UInt64 A, const BigCardinal& B)
    {
        return (B.CompareToUInt64(A) <= 0);
    }
    friend bool operator>=(const BigCardinal& A, Int64 B)
    {
        return (A.CompareToInt64(B) >= 0);
    }
    friend bool operator>=(Int64 A, const BigCardinal& B)
    {
        return (B.CompareToInt64(A) <= 0);
    }

    friend bool operator<(const BigCardinal& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) < 0);
    }
    friend bool operator<(UInt64 A, const BigCardinal& B)
    {
        return (B.CompareToUInt64(A) > 0);
    }
    friend bool operator<(const BigCardinal& A, Int64 B)
    {
        return (A.CompareToInt64(B) < 0);
    }
    friend bool operator<(Int64 A, const BigCardinal& B)
    {
        return (B.CompareToInt64(A) > 0);
    }

    friend bool operator<=(const BigCardinal& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) <= 0);
    }
    friend bool operator<=(UInt64 A, const BigCardinal& B)
    {
        return (B.CompareToUInt64(A) >= 0);
    }
    friend bool operator<=(const BigCardinal& A, Int64 B)
    {
        return (A.CompareToInt64(B) <= 0);
    }
    friend bool operator<=(Int64 A, const BigCardinal& B)
    {
        return (B.CompareToInt64(A) >= 0);
    }

    static BigCardinal DivRem(const BigCardinal& Dividend, Cardinal Divisor,
                Cardinal& Remainder);
    static Cardinal DivRem(Cardinal Dividend, const BigCardinal& Divisor,
             Cardinal& Remainder);

    friend BigCardinal operator+(const BigCardinal& A, Cardinal B);
    friend BigCardinal operator+(Cardinal A, const BigCardinal& B);
    friend BigCardinal operator-(const BigCardinal& A, Cardinal B);
    friend Cardinal operator-(Cardinal A, const BigCardinal& B);

    friend BigCardinal operator*(const BigCardinal& A, Cardinal B);
    friend BigCardinal operator*(Cardinal A, const BigCardinal& B);
    friend BigCardinal operator/(const BigCardinal& A, Cardinal B);
    friend Cardinal operator/(Cardinal A, BigCardinal& B);
    friend Cardinal operator%(const BigCardinal& A, Cardinal B);
    friend Cardinal operator%(const Cardinal A, const BigCardinal& B);
};
#endif // NUMERICS_HPP_INCLUDED
