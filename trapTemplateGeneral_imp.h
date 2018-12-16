#include<iostream>

using namespace std;
template <class T>
T  trapTemplateGeneral(const T &x0, const T &x, const int &N,T (*func)(const T&) )
{
    T xi;
    T h = ( x-x0 )/N;
        T res = 0.5*( (*func)(x0)+(*func)(x));

    for (int i = 1; i < N; ++i)
    {
        xi = x0+h*i;
        res += (*func)(xi);
    }
    return res*h;
}