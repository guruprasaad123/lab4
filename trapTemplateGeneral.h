#include <iostream>

#ifndef LAB4_TRAP_TEMPLATE_GENERAL_FUNCTION
#define LAB4_TRAP_TEMPLATE_GENERAL_FUNCTION

using namespace std;
#include "func.h"
#include "trapTemplateGeneral_imp.h"

// compute the trapezoidal rule from x0 to x with N interval
// NOTE : use local function unitCircle

template <class T>
T  trapTemplateGeneral(const T &x0, const T &x, const int &N,T (*func)(const T &) );

#endif
