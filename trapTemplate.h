#include<iostream>
#ifndef LAB4_TRAP_TEMPLATE_FUNCTION
#define LAB4_TRAP_TEMPLATE_FUNCTION

using namespace std;

#include "trapTemplate_imp.h"

// compute the trapezoidal rule from x0 to x with N interval
// NOTE : use local function unitCircle
double trapez_rule(const double &x0, const double &x, const int &N,double (*func)(const double&) );

#endif
