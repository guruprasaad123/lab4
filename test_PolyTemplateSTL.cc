#include <iostream>
#include "PolyTemplateSTL.h"
#include "Real2.h"

using namespace std;

template < typename T >
void testPolyClass(T* coef1,int n1, T* coef2,int n2,T &x1, T &x2)
{

    Poly < T > p1(coef1,n1);
    Poly < T > p2(coef2,n2);

    // Test polynomial methods and operators
    cout << " Test print() : " << endl;
    cout<<"p1 : ";
    p1.print();
    cout<<"p2 : ";
    p2.print();

    cout << " Test addition : " << endl;
    Poly < T > padd = p1+p2;
    cout<<"p1+p2 : ";
    padd.print();
    Poly < T > padd2 = p2+p1;
    cout<<"p2+p1 : ";
    padd2.print();

    cout << " Test substraction : " << endl;
    cout<<"p1-p2 : ";
    Poly < T > pneg = p1-p2;
    pneg.print();
    cout<<"p2-p1 : ";
    Poly < T > pneg2 = p2-p1;
    pneg2.print();

    cout << " Test multiplication : " << endl;
    cout<<"p1*p2 : ";
    Poly < T > pprod = p1*p2;
    pprod.print();
    cout<<"p2*p1 : ";
    Poly < T > pprod2 = p2*p1;
    pprod2.print();

    cout << " Test euclidian division : " << endl;
    Poly < T > pdivQ = pprod.euclidienDivisionQ(p1);
    cout<<"Q=(p2*p1)/p1=p2 : ";
    pdivQ.print();
    Poly < T > pdivQ2 = p2.euclidienDivisionQ(p1);
    cout<<"Q=p2/p1 : ";
    pdivQ2.print();
    Poly < T > pdivR = pprod.euclidienDivisionR(p1,pdivQ);
    cout<<"R=p2-(p2*p1)/p1=0 : ";
    pdivR.print();
    Poly < T > pdivR2 = p2.euclidienDivisionR(p1,pdivQ2);
    cout<<"R=p2-p2/p1 : ";
    pdivR2.print();

    cout << "Testing () operator " << endl;
    cout<<"First try, with x1 : " << endl;
    cout << "p1(x1) : "<<p1(x1) <<endl;
    cout << "p2(x1) : "<<p2(x1) <<endl;
    cout<<"Second try, with x2 : " << endl;
    cout << "p1(x2) : "<<p1(x2) <<endl;
    cout << "p2(x2) : "<<p2(x2) <<endl;

    return;
}


int main()
{

    // WARNING : the degree of all polynomials in this test program has to be
    // less than 9 (10 coefficients)

    // double type
    {
        double coef1[10];
        double coef2[10];
        int n1, n2;
        double x1,x2;

        // Input polynomials
        cout << " === Testing template Poly class for double === " << endl;
        cout << "Input degree of p1d : ";
        cin >> n1;
        cout << "Input coefficients of p1d : " << endl;
        for (int i = 0; i <= n1; i++)
        {
            cin >> coef1[i];
        }

        cout << "Input degree of p2d : ";
        cin >> n2;
        cout << "Input coefficients of p2d : " << endl;
        for (int i = 0; i <= n2; i++)
        {
            cin >> coef2[i];
        }

        cout<<"Input first testing value x1 : " << endl;
        cin >> x1;
        cout<<"Input second testing value x2 : " << endl;
        cin >> x2;
        testPolyClass(coef1,n1,coef2,n2,x1,x2);
    }
    // Real type
    {
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

        cout<<"Input first testing value x1 : " << endl;
        cin >> m >> e;
        Real x1(m,e);
        cout<<"Input second testing value x2 : " << endl;
        cin >> m >> e;
        Real x2(m,e);

        testPolyClass(coef1,n1,coef2,n2,x1,x2);
    }


    return 0;
}

