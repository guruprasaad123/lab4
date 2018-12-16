#include <iostream>
#include "PolyTemplate.h"

using namespace std;

int main()
{
    // WARNING: the degree of all polynomials in this test program has to be
    // less than 9 (10 coefficients)

    double coef1[10] = {0.};
    double coef2[10] = {0.};
    int n1, n2;

    // Input polynomials
    cout << " === Testing template Poly class for double === " << endl;
    cout << "Input degree of p1d: ";
    cin >> n1;
    cout << "Input coefficients of p1d: " << endl;
    for (int i = 0; i <= n1; i++)
    {
        cin >> coef1[i];
    }

    cout << "Input degree of p2d: ";
    cin >> n2;
    cout << "Input coefficients of p2d: " << endl;
    for (int i = 0; i <= n2; i++)
    {
        cin >> coef2[i];
    }

    Poly < double > p1d(coef1,n1);

    // Try do create a polynomial of degree n1 with a null order n1 coefficient
    try
    {
        Poly < double > p3d(coef1,n1+1);
    }
    catch (int e)
    {
        cout <<"Error: trying to create a polynomial of order n with null coefficient of order n" <<endl;
    }
    Poly < double > p2d(coef2,n2);

    // Test polynomial methods and operators
    cout << " Test print(): " << endl;
    cout<<"p1d: ";
    p1d.print();
    cout<<"p2d: ";
    p2d.print();

    cout << " Test addition: " << endl;
    Poly < double > padd = p1d+p2d;
    cout<<"p1d+p2d: ";
    padd.print();
    Poly < double > padd2 = p2d+p1d;
    cout<<"p2d+p1d: ";
    padd2.print();

    cout << " Test substraction: " << endl;
    cout<<"p1d-p2d: ";
    Poly < double > pneg = p1d-p2d;
    pneg.print();
    cout<<"p2d-p1d: ";
    Poly < double > pneg2 = p2d-p1d;
    pneg2.print();

    cout << " Test multiplication: " << endl;
    cout<<"p1d*p2d: ";
    Poly < double > pprod = p1d*p2d;
    pprod.print();
    cout<<"p2d*p1d: ";
    Poly < double > pprod2 = p2d*p1d;
    pprod2.print();

    cout << " Test euclidian division: " << endl;
    Poly < double > pdivQ = pprod.euclidienDivisionQ(p1d);
    cout<<"Q=(p2d*p1d)/p1d=p2d: ";
    pdivQ.print();
    Poly < double > pdivQ2 = p2d.euclidienDivisionQ(p1d);
    cout<<"Q=p2d/p1d: ";
    pdivQ2.print();
    Poly < double > pdivR = pprod.euclidienDivisionR(p1d,pdivQ);
    cout<<"R=p2d-(p2d*p1d)/p1d=0: ";
    pdivR.print();
    Poly < double > pdivR2 = p2d.euclidienDivisionR(p1d,pdivQ2);
    cout<<"R=p2d-p2d/p1d: ";
    pdivR2.print();

    cout << "Testing () operator " << endl;
    double x;
    cout<<"First try, input a value for x1: " << endl;
    cin >> x;
    cout << "p1d(x1): "<<p1d(x) <<endl;
    cout << "p2d(x1): "<<p2d(x) <<endl;
    cout<<"Second try, input a value for x2: " << endl;
    cin >> x;
    cout << "p1d(x2): "<<p1d(x) <<endl;
    cout << "p2d(x2): "<<p2d(x) <<endl;


    return 0;
}

