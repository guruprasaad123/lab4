#include<iostream>
using namespace std;

double trapez_rule(const double &x0, const double &x, const int &N,double (*func)(const double&) )
{

    double xi;
    double h = ( x-x0 )/N;
    double res = 0.5*( (*func)(x0)+(*func)(x));

    for (int i = 1; i < N; ++i)
    {
        xi = x0+h*i;
        res += (*func)(xi);
    }
    return res*h;


}