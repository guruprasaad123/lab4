#include "trapezoidal.h"
#include <cmath>

using namespace std;

double unitCircle(const double &x)
{
    return 4.*sqrt(1.-x*x);
}

double trapez_rule(const double &x0, const double &x, const int &N )
{
    double xi;
    double h = ( x-x0 )/N;
    double res = 0.5*( unitCircle(x0)+unitCircle(x));

    for (int i = 1; i < N; ++i)
    {
        xi = x0+h*i;
        res += unitCircle(xi);
    }
    return res*h;
}
