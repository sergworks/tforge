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

typedef LongInt Int32;
typedef LongWord UInt32;
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
    virtual TF_RESULT __stdcall Pow(LongWord Power, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall PowU(LongWord Power, IBigNumber** Res) = 0;

    virtual TF_RESULT __stdcall SqrtNumber(IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall GCD(IBigNumber* B, IBigNumber** G) = 0;
    virtual TF_RESULT __stdcall EGCD(IBigNumber* B, IBigNumber** G, IBigNumber** X, IBigNumber** Y) = 0;
    virtual TF_RESULT __stdcall ModPow(IBigNumber* IExp, IBigNumber* IMod, IBigNumber** Res) = 0;
    virtual TF_RESULT __stdcall ModInverse(IBigNumber* M, IBigNumber** R) = 0;

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
    virtual TF_RESULT __stdcall SubLimbU2(LongWord Limb, Cardinal* Res) = 0;
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

TF_RESULT LoadNumerics(string Name = "");

class BigCardinal {
    friend class BigInteger;
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
  		    FNumber = NULL;
  	    }
    };

    BigCardinal& operator= (const BigCardinal& A);

    string ToString();
    string ToHexString(int Digits = 0, const string Prefix = "", bool TwoCompl = false);
    TBytes ToBytes();
    bool TryParse(const string S, bool TwoCompl = false);

    void Free()
    {
        if (FNumber != NULL)
        {
            FNumber->Release();
            FNumber = NULL;
        }
    }


    static int Compare(const BigCardinal& A, const BigCardinal& B);
    int CompareTo(const BigCardinal& B) const
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

    int CompareToCard(Cardinal B) const;
    int CompareToInt(Integer B) const;
    int CompareTo(Cardinal B) const
    {
        return CompareToCard(B);
    }
    int CompareTo(Integer B) const
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

    int CompareToUInt64(UInt64 B) const;
    int CompareToInt64(Int64 B) const;
    int CompareTo(UInt64 B) const
    {
        return CompareToUInt64(B);
    }
    int CompareTo(Int64 B) const
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

class BigInteger {
  private:
    IBigNumber* FNumber;
  public:
    BigInteger() : FNumber(NULL) {};
    BigInteger(const BigCardinal& A)
    {
    	FNumber = A.FNumber;
    	if (FNumber != NULL)
    	{
    		FNumber->AddRef();
    	}
    };
    BigInteger(const BigInteger& A)
    {
    	FNumber = A.FNumber;
    	if (FNumber != NULL)
    	{
    		FNumber->AddRef();
    	}
    };
    BigInteger(Cardinal A);
    BigInteger(Integer A);
    BigInteger(UInt64 A);
    BigInteger(Int64 A);
    BigInteger(const TBytes A);
    BigInteger(const string A);


    ~BigInteger()      // !! non-virtual !!
    {
  	    if (FNumber != NULL)
  	    {
  		    FNumber->Release();
  		    FNumber = NULL;
  	    }
    };

    BigInteger& operator= (const BigInteger& A);

    string ToString();
    string ToHexString(int Digits = 0, const string Prefix = "", bool TwoCompl = false);
    TBytes ToBytes();
    bool TryParse(const string S, bool TwoCompl = false);

    void Free()
    {
        if (FNumber != NULL)
        {
            FNumber->Release();
            FNumber = NULL;
        }
    }

    int Sign();

    static BigInteger Abs(const BigInteger& A);
    static BigInteger Pow(const BigInteger& Base, Cardinal Value);
    static BigInteger DivRem(const BigInteger& Dividend, const BigInteger& Divisor,
                             BigInteger& Remainder);

    static BigInteger Sqrt(const BigInteger& A);
    static BigInteger GCD(const BigInteger& A, const BigInteger& B);
    static BigInteger EGCD(const BigInteger& A, const BigInteger& B, BigInteger& X, BigInteger& Y);
    static BigInteger ModPow(const BigInteger& BaseValue, const BigInteger& ExpValue,
                             const BigInteger& Modulo);
    static BigInteger ModInverse(const BigInteger& A, const BigInteger& Modulo);
/*
    class operator Implicit(const Value: BigCardinal): BigInteger; inline;
    class operator Explicit(const Value: BigInteger): BigCardinal; inline;

    class operator Explicit(const Value: BigInteger): Cardinal;
    class operator Explicit(const Value: BigInteger): UInt64;
    class operator Explicit(const Value: BigInteger): Integer;
    class operator Explicit(const Value: BigInteger): Int64;
    class operator Implicit(const Value: UInt32): BigInteger;
    class operator Implicit(const Value: UInt64): BigInteger;
    class operator Implicit(const Value: Int32): BigInteger;
    class operator Implicit(const Value: Int64): BigInteger;
    class operator Explicit(const Value: TBytes): BigInteger;
    class operator Explicit(const Value: string): BigInteger;
*/

    static int Compare(const BigInteger& A, const BigInteger& B);
    static int Compare(const BigInteger& A, const BigCardinal& B);
    static int Compare(const BigCardinal& A, const BigInteger& B);

    int CompareTo(const BigInteger& B) const
    {
        return Compare(*this, B);
    }
    int CompareTo(const BigCardinal& B) const
    {
        return Compare(*this, B);
    }

    friend bool operator==(const BigInteger& A, const BigInteger& B)
    {
        return (Compare(A, B) == 0);
    }

    friend bool operator==(const BigInteger& A, const BigCardinal& B)
    {
        return (Compare(A, B) == 0);
    }

    friend bool operator==(const BigCardinal& A, const BigInteger& B)
    {
        return (Compare(A, B) == 0);
    }

    friend bool operator!=(const BigInteger& A, const BigInteger& B)
    {
        return (Compare(A, B) != 0);
    }

    friend bool operator!=(const BigInteger& A, const BigCardinal& B)
    {
        return (Compare(A, B) != 0);
    }

    friend bool operator!=(const BigCardinal& A, const BigInteger& B)
    {
        return (Compare(A, B) != 0);
    }

    friend bool operator>(const BigInteger& A, const BigInteger& B)
    {
        return (Compare(A, B) > 0);
    }

    friend bool operator>(const BigInteger& A, const BigCardinal& B)
    {
        return (Compare(A, B) > 0);
    }

    friend bool operator>(const BigCardinal& A, const BigInteger& B)
    {
        return (Compare(A, B) > 0);
    }

    friend bool operator>=(const BigInteger& A, const BigInteger& B)
    {
        return (Compare(A, B) >= 0);
    }

    friend bool operator>=(const BigInteger& A, const BigCardinal& B)
    {
        return (Compare(A, B) >= 0);
    }

    friend bool operator>=(const BigCardinal& A, const BigInteger& B)
    {
        return (Compare(A, B) >= 0);
    }

    friend bool operator<(const BigInteger& A, const BigInteger& B)
    {
        return (Compare(A, B) < 0);
    }

    friend bool operator<(const BigInteger& A, const BigCardinal& B)
    {
        return (Compare(A, B) < 0);
    }

    friend bool operator<(const BigCardinal& A, const BigInteger& B)
    {
        return (Compare(A, B) < 0);
    }

    friend bool operator<=(const BigInteger& A, const BigInteger& B)
    {
        return (Compare(A, B) <= 0);
    }

    friend bool operator<=(const BigInteger& A, const BigCardinal& B)
    {
        return (Compare(A, B) <= 0);
    }

    friend bool operator<=(const BigCardinal& A, const BigInteger& B)
    {
        return (Compare(A, B) <= 0);
    }


    friend BigInteger operator+(const BigInteger& A, const BigInteger& B);
    friend BigInteger operator-(const BigInteger& A, const BigInteger& B);
    friend BigInteger operator*(const BigInteger& A, const BigInteger& B);
    friend BigInteger operator/(const BigInteger& A, const BigInteger& B);
    friend BigInteger operator%(const BigInteger& A, const BigInteger& B);

    friend BigInteger operator<<(const BigInteger& A, Cardinal Shift);
    friend BigInteger operator>>(const BigInteger& A, Cardinal Shift);

    friend BigInteger operator&(const BigInteger& A, const BigInteger& B);
    friend BigInteger operator|(const BigInteger& A, const BigInteger& B);
    friend BigInteger operator^(const BigInteger& A, const BigInteger& B);

    int CompareToCard(Cardinal B) const;
    int CompareToInt(Integer B) const;
    int CompareTo(Cardinal B) const
    {
        return CompareToCard(B);
    }
    int CompareTo(Integer B) const
    {
        return CompareToInt(B);
    }

    friend bool operator==(const BigInteger& A, Cardinal B)
    {
        return (A.CompareToCard(B) == 0);
    }
    friend bool operator==(Cardinal A, const BigInteger& B)
    {
        return (B.CompareToCard(A) == 0);
    }
    friend bool operator==(const BigInteger& A, Integer B)
    {
        return (A.CompareToInt(B) == 0);
    }
    friend bool operator==(Integer A, const BigInteger& B)
    {
        return (B.CompareToInt(A) == 0);
    }

    friend bool operator!=(const BigInteger& A, Cardinal B)
    {
        return (A.CompareToCard(B) != 0);
    }
    friend bool operator!=(Cardinal A, const BigInteger& B)
    {
        return (B.CompareToCard(A) != 0);
    }
    friend bool operator!=(const BigInteger& A, Integer B)
    {
        return (A.CompareToInt(B) != 0);
    }
    friend bool operator!=(Integer A, const BigInteger& B)
    {
        return (B.CompareToInt(A) != 0);
    }

    friend bool operator>(const BigInteger& A, Cardinal B)
    {
        return (A.CompareToCard(B) > 0);
    }
    friend bool operator>(Cardinal A, const BigInteger& B)
    {
        return (B.CompareToCard(A) < 0);
    }
    friend bool operator>(const BigInteger& A, Integer B)
    {
        return (A.CompareToInt(B) > 0);
    }
    friend bool operator>(Integer A, const BigInteger& B)
    {
        return (B.CompareToInt(A) < 0);
    }

    friend bool operator>=(const BigInteger& A, Cardinal B)
    {
        return (A.CompareToCard(B) >= 0);
    }
    friend bool operator>=(Cardinal A, const BigInteger& B)
    {
        return (B.CompareToCard(A) <= 0);
    }
    friend bool operator>=(const BigInteger& A, Integer B)
    {
        return (A.CompareToInt(B) >= 0);
    }
    friend bool operator>=(Integer A, const BigInteger& B)
    {
        return (B.CompareToInt(A) <= 0);
    }

    friend bool operator<(const BigInteger& A, Cardinal B)
    {
        return (A.CompareToCard(B) < 0);
    }
    friend bool operator<(Cardinal A, const BigInteger& B)
    {
        return (B.CompareToCard(A) > 0);
    }
    friend bool operator<(const BigInteger& A, Integer B)
    {
        return (A.CompareToInt(B) < 0);
    }
    friend bool operator<(Integer A, const BigInteger& B)
    {
        return (B.CompareToInt(A) > 0);
    }

    friend bool operator<=(const BigInteger& A, Cardinal B)
    {
        return (A.CompareToCard(B) <= 0);
    }
    friend bool operator<=(Cardinal A, const BigInteger& B)
    {
        return (B.CompareToCard(A) >= 0);
    }
    friend bool operator<=(const BigInteger& A, Integer B)
    {
        return (A.CompareToInt(B) <= 0);
    }
    friend bool operator<=(Integer A, const BigInteger& B)
    {
        return (B.CompareToInt(A) >= 0);
    }

    int CompareToUInt64(UInt64 B) const;
    int CompareToInt64(Int64 B) const;
    int CompareTo(UInt64 B) const
    {
        return CompareToUInt64(B);
    }
    int CompareTo(Int64 B) const
    {
        return CompareToInt64(B);
    }

    friend bool operator==(const BigInteger& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) == 0);
    }
    friend bool operator==(UInt64 A, const BigInteger& B)
    {
        return (B.CompareToUInt64(A) == 0);
    }
    friend bool operator==(const BigInteger& A, Int64 B)
    {
        return (A.CompareToInt64(B) == 0);
    }
    friend bool operator==(Int64 A, const BigInteger& B)
    {
        return (B.CompareToInt64(A) == 0);
    }

    friend bool operator!=(const BigInteger& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) != 0);
    }
    friend bool operator!=(UInt64 A, const BigInteger& B)
    {
        return (B.CompareToUInt64(A) != 0);
    }
    friend bool operator!=(const BigInteger& A, Int64 B)
    {
        return (A.CompareToInt64(B) != 0);
    }
    friend bool operator!=(Int64 A, const BigInteger& B)
    {
        return (B.CompareToInt64(A) != 0);
    }

    friend bool operator>(const BigInteger& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) > 0);
    }
    friend bool operator>(UInt64 A, const BigInteger& B)
    {
        return (B.CompareToUInt64(A) < 0);
    }
    friend bool operator>(const BigInteger& A, Int64 B)
    {
        return (A.CompareToInt64(B) > 0);
    }
    friend bool operator>(Int64 A, const BigInteger& B)
    {
        return (B.CompareToInt64(A) < 0);
    }

    friend bool operator>=(const BigInteger& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) >= 0);
    }
    friend bool operator>=(UInt64 A, const BigInteger& B)
    {
        return (B.CompareToUInt64(A) <= 0);
    }
    friend bool operator>=(const BigInteger& A, Int64 B)
    {
        return (A.CompareToInt64(B) >= 0);
    }
    friend bool operator>=(Int64 A, const BigInteger& B)
    {
        return (B.CompareToInt64(A) <= 0);
    }

    friend bool operator<(const BigInteger& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) < 0);
    }
    friend bool operator<(UInt64 A, const BigInteger& B)
    {
        return (B.CompareToUInt64(A) > 0);
    }
    friend bool operator<(const BigInteger& A, Int64 B)
    {
        return (A.CompareToInt64(B) < 0);
    }
    friend bool operator<(Int64 A, const BigInteger& B)
    {
        return (B.CompareToInt64(A) > 0);
    }

    friend bool operator<=(const BigInteger& A, UInt64 B)
    {
        return (A.CompareToUInt64(B) <= 0);
    }
    friend bool operator<=(UInt64 A, const BigInteger& B)
    {
        return (B.CompareToUInt64(A) >= 0);
    }
    friend bool operator<=(const BigInteger& A, Int64 B)
    {
        return (A.CompareToInt64(B) <= 0);
    }
    friend bool operator<=(Int64 A, const BigInteger& B)
    {
        return (B.CompareToInt64(A) >= 0);
    }

// arithmetic operations on BigInteger & Cardinal
    friend BigInteger operator+(const BigInteger& A, Cardinal B);
    friend BigInteger operator-(const BigInteger& A, Cardinal B);
    friend BigInteger operator*(const BigInteger& A, Cardinal B);
    friend BigInteger operator/(const BigInteger& A, Cardinal B);
    friend BigInteger operator%(const BigInteger& A, Cardinal B);
    static BigInteger DivRem(const BigInteger& Dividend, Cardinal Divisor,
                             BigInteger& Remainder);

// arithmetic operations on Cardinal & BigInteger
    friend BigInteger operator+(Cardinal A, const BigInteger& B);
    friend BigInteger operator-(Cardinal A, const BigInteger& B);
    friend BigInteger operator*(Cardinal A, const BigInteger& B);
    friend BigInteger operator/(Cardinal A, const BigInteger& B);
    friend Cardinal operator%(Cardinal A, const BigInteger& B);
    static BigInteger DivRem(Cardinal Dividend, const BigInteger& Divisor,
                             Cardinal& Remainder);

// arithmetic operations on BigInteger & Integer
    friend BigInteger operator+(const BigInteger& A, Integer B);
    friend BigInteger operator-(const BigInteger& A, Integer B);
    friend BigInteger operator*(const BigInteger& A, Integer B);
    friend BigInteger operator/(const BigInteger& A, Integer B);
    friend Integer operator%(const BigInteger& A, Integer B);
    static BigInteger DivRem(const BigInteger& Dividend, Integer Divisor,
                             Integer& Remainder);

// arithmetic operations on Integer & BigInteger
    friend BigInteger operator+(Integer A, const BigInteger& B);
    friend BigInteger operator-(Integer A, const BigInteger& B);
    friend BigInteger operator*(Integer A, const BigInteger& B);
    friend Integer operator/(Integer A, const BigInteger& B);
    friend Integer operator%(Integer A, const BigInteger& B);
    static Integer DivRem(Integer Dividend, const BigInteger& Divisor,
                          Integer& Remainder);

};

#endif // NUMERICS_HPP_INCLUDED
