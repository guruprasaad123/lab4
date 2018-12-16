#include<iostream>
#include<math.h>
#include "func.h"
//#include "Real.h"

#define PI 3.14159265
using namespace std;

// 4√1−x2 
double unitCircle(const double &x)
{
    return 4.*sqrt(1.-x*x);
}


int line(const int &x)
{
return (int) x;

}
//Optional Feature ... 

/*
Real rline(const Real &x)
{
return x;

}
*/

// sin(15×x) + cos(3×x)
double trigo(const double &x)
{
    double param;
 //sin (param*PI/180);
 try{
    param = sin (15.*x) + cos (3.*x);
    return param;
 }
 catch(...)
 {
     throw -1;
 }
}
// x ifx < 0.5
// 1−x ifx > 0.5 
float biline(const float &x)
{

try{

    if(x<0.5)
    {
        return x;
    }
    else if(x>=0.5)
    {
        return 1-x;
    }
}
catch(...)
{
    throw -1;
}

}