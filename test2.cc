#include <iostream>
#include <cmath>
using namespace std;

#include "trapTemplateGeneral.h"
#include "func.h"


int main()
{
    
    {
        // integration setting
        int a = 0, b = 1,nbi=5;

        // compute and display
        int res = trapTemplateGeneral(a,b,nbi,line);
        cout << "LINE : "<<res<< endl;
    }

}
