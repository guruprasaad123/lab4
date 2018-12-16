#include <iostream>
#include "PolyTemplate.h"
#include "Real2.h"

using namespace std;

int main()
{
    // WARNING: the degree of all polynomials in this test program has to be
    // less than 9 (10 coefficients)

    Real coef1[10];
    Real coef2[10];
    int n1, n2;
    double m;
    int e;

    // Input polynomials
    cout << " === Testing template Poly class for Real numbers === " << endl;
    cout << "Input degree of p1r: ";
    cin >> n1;
    cout << "Input coefficients of p1r (mantissa first, then exponent): " << endl;
    for (int i = 0; i <= n1; i++)
    {
        cin >> m >> e;
        coef1[i] = Real(m,e);
        cout << endl;
    }

    cout << "Input degree of p2r: ";
    cin >> n2;
    cout << "Input coefficients of p2r (mantissa first, then exponent): " << endl;
    for (int i = 0; i <= n2; i++)
    {
        cin >> m >> e;
        coef2[i] = Real(m,e);
        cout << endl;
    }

    Poly < Real > p1r(coef1,n1);

    // Try do create a polynomial of degree n1 with a null order n1 coefficient
    try
    {
        Poly < Real > p3r(coef1,n1+1);
    }
    catch (int e)
    {
        cout <<"Error: trying to create a polynomial of order n with null coefficient of order n" <<endl;
    }
    Poly < Real > p2r(coef2,n2);

    // Test polynomial methods and operators
    cout << " Test print(): " << endl;
    cout<<"p1r: ";
    p1r.print();
    cout<<"p2r: ";
    p2r.print();

    cout << " Test addition: " << endl;
    Poly < Real > padd = p1r+p2r;
    cout<<"p1r+p2r: ";
    padd.print();
    Poly < Real > padd2 = p2r+p1r;
    cout<<"p2r+p1r: ";
    padd2.print();

    cout << " Test substraction: " << endl;
    cout<<"p1r-p2r: ";
    Poly < Real > pneg = p1r-p2r;
    pneg.print();
    cout<<"p2r-p1r: ";
    Poly < Real > pneg2 = p2r-p1r;
    pneg2.print();

    cout << " Test multiplication: " << endl;
    cout<<"p1r*p2r: ";
    Poly < Real > pprod = p1r*p2r;
    pprod.print();
    cout<<"p2r*p1r: ";
    Poly < Real > pprod2 = p2r*p1r;
    pprod2.print();

    cout << " Test euclidian division: " << endl;
    Poly < Real > pdivQ = pprod.euclidienDivisionQ(p1r);
    cout<<"Q=(p2r*p1r)/p1r=p2r: ";
    pdivQ.print();
    Poly < Real > pdivQ2 = p2r.euclidienDivisionQ(p1r);
    cout<<"Q=p2r/p1r: ";
    pdivQ2.print();
    Poly < Real > pdivR = pprod.euclidienDivisionR(p1r,pdivQ);
    cout<<"R=p2r-(p2r*p1r)/p1r=0: ";
    pdivR.print();
    Poly < Real > pdivR2 = p2r.euclidienDivisionR(p1r,pdivQ2);
    cout<<"R=p2r-p2r/p1r: ";
    pdivR2.print();


    cout << "Testing () operator " << endl;
    cout<<"First try, input a value for x1 (mantissa first, then exponent): " << endl;
    cin >> m >> e;
    Real x(m,e);
    cout << "p1r(x1): "<<p1r(x) <<endl;
    cout << "p2r(x1): "<<p2r(x) <<endl;
    cout<<"Second try, input a value for x2 (mantissa first, then exponent): " << endl;
    cin >> m >> e;
    Real y(m,e);
    cout << "p1r(x2): "<<p1r(y) <<endl;
    cout << "p2r(x2): "<<p2r(y) <<endl;

    return 0;
}

