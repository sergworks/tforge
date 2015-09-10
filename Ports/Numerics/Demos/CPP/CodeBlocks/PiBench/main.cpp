/*
  pi / 4 = 4 * arctan(1 / 5) - arctan(1 / 239)
  arctan(x) = x - x^3 / 3 + x^5 / 5 - x^7 / 7 + ..
*/

#include <iostream>
#include <ctime>
#include "..\..\..\..\Ports\Numerics\Wrapper\CPP\numerics.hpp"

using namespace std;

void BenchMark(BigCardinal& ValidDigits)
{
    BigCardinal PiDigits = 0;
    BigCardinal Factor = BigCardinal::Pow(10, 10000);    // = 10^10000;
    BigCardinal Den = 5;
    BigCardinal Term;
    BigCardinal Num;
    Num = Cardinal(16) * Factor;
    Cardinal N = 1;
    do {
        Term = Num / (Den * (2 * N - 1));
        if (Term == 0) break;
        if ((N & 1) != 0)
            PiDigits = PiDigits + Term;
        else
            PiDigits = PiDigits - Term;
        Den = Den * (Cardinal)25;
        N++;
    } while (N != 0);

    Cardinal M = N;
    Num = (Cardinal)4 * Factor;
    Den = 239;
    N = 1;
    do {
        Term = Num / (Den * (2 * N - 1));
        if (Term == 0) break;
        if ((N & 1) != 0)
            PiDigits = PiDigits - Term;
        else
            PiDigits = PiDigits + Term;
        Den = Den * (Cardinal)(239 * 239);
        N++;
    } while (N != 0);

    Cardinal MaxError = (M + N) / 2 + 2;
    Term = 1;
    do {
        Term = Term * (Cardinal)10;
    } while (Term <= MaxError);
    do {
        ValidDigits = BigCardinal::DivRem(PiDigits, Term, Num);
        if (Num > MaxError) break;
        Term = Term * (Cardinal)10;
    } while (true);
}

int main()
{
    cout << "Benchmark test started ..." << endl;
    clock_t StartTime = clock();
    BigCardinal ValidDigits;
    BenchMark(ValidDigits);
    double duration = (clock() - StartTime) / (double)CLOCKS_PER_SEC;
    string S = ValidDigits.ToString();
    cout << "Pi = " << S[0] << '.' << S.substr(1) << endl;
    ValidDigits.Free();
    cout << endl << "Time elapsed: " << static_cast<int>(duration * 1000) << "ms." << endl;
    return 0;
}
