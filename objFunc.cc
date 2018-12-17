#include<iostream>
#include<math.h>
#include "objFunc.h"
//#include "Real.h"

#define PI 3.14159265
using namespace std;

// 4√1−x2 
double unitCircleOF(const double &x)
{
    return 4.*sqrt(1.-x*x);
}


double lineOF(const double &x)
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
double trigoOF(const double &x)
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
double bilineOF(const double &x)
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