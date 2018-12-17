#include <iostream>
#include <iomanip>
#include <cstdlib>
#include <cmath>
// mandatory inclusion of class declaration
#include "Real1.h"

using namespace std;

// A example of macro usage (rather complicate but
// give macro EXPP and EXPM that give double constant
// syntax as function of exponent)
#define MX 15
#define MXM1 14
#define AFTERP(a) 1.e ## a
#define AFTERM(a) 1.e- ## a
#define EXPP(a)  AFTERP(a)
#define EXPM(a)  AFTERM(a)

// Constructor
Real::Real(double m_, int e_) : m(m_),e(e_)
{
    const double one = 1.;
    const double mone = -1.;
    const double zone = 0.1;
    const double mzone = -0.1;
    const double eps=EXPM(MX);
    if (m < eps && m>-eps)
    {
        m=0.;
        e = 0;
    }
    else
    {
        while ( !( m < one ) || !( m > mone ) )
        {
            m /= 10.;
            e++;
        }
        while ( m < zone  && m > mzone)
        {
            m=floor(m*EXPP(MX))/EXPP(MXM1); //equivalent to "m *= 10.;" but truncate to MX digit so that approximation on digit 16 and higher do 
                                            // not interfere in computation. This is improving a little precision of the class. 
            e--;
        }
    }
}

// display function
void Real::display() const
{
    cout <<setprecision(MX)<< m << "E";
    cout << e << endl;
}

// addition operator
Real Real::operator+(const Real & rhs) const
{
    const double zero=0.;
    // we must check if one operand is null because a zero value should not
    // hide a tiny one. Only need to test mantissa with zero as constructor already
    // do the job to compare with EXPM(MX)
    // Test first "this"
    if (m == zero)
    {
        return Real(rhs.m, rhs.e);
    }
    // Test second rhs
    if (rhs.m == zero)
    {
        return Real(m, e);
    }
    // Now  use exponent
    int de = e-rhs.e;
    if (abs(de) > MX)
    {
        if (de > 0) return Real(m, e);
        else return Real(rhs.m, rhs.e);
    }
    else
    {
        if (de > 0)
        {
            return Real(m*pow(10.,de)+rhs.m,rhs.e);
        }
        else
        {
            return Real(m+rhs.m*pow(10.,-de),e);
        }

    }
}

// subtraction operator
Real Real::operator-(const Real & rhs) const
{
    const double zero=0.;
    // we must check if one operand is null because a zero value should not
    // hide a tiny one. Only need to test mantissa with zero as constructor already
    // do the job to compare with EXPM(MX)
    // Test first "this"
    if (m == zero)
    {
        return Real(-rhs.m, rhs.e);
    }
    // Test second rhs
    if (rhs.m == zero)
    {
        return Real(m, e);
    }
    // Now  use exponent
    int de = e-rhs.e;
    if (abs(de) > MX)
    {
        if (de > 0) return Real(m, e);
        else return Real(-rhs.m, rhs.e);
    }
    else
    {
        if (de > 0)
        {
            return Real(m*pow(10.,de)-rhs.m,rhs.e);
        }
        else
        {
            return Real(m-rhs.m*pow(10.,-de),e);
        }

    }
}

// multiplication operator
Real Real::operator*(const Real & rhs) const
{
    return Real(m*rhs.m, e + rhs.e);
}

// division operator
Real Real::operator/(const Real & rhs) const
{
    if (rhs.m == 0.)
    {
        cout << "Warning : trying to divide by a null real number !!! " << endl;
        throw -1;
    }
    else
    {
        return Real( m/rhs.m,e-rhs.e);
    }
}

// power of n
Real Real::power(int n) const
{
    Real prod(m,e);
    while (--n)
    {
        prod = prod*( *this );
    }
    return prod;
}
std::ostream & operator << (std::ostream & ofs, const Real & R)
{
    ofs <<setprecision(MX)<< R.m << "E";
    ofs << R.e;
    return ofs;
}

