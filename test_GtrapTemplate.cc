#include <iostream>
#include <cmath>
using namespace std;

#include "trapTemplateGeneral.h"
#include "func.h"
#include "Real1.h"

int main()
{
    // first enter nb of intervals
    int nbi;
    cout << "Give number of interval "<< endl;
    cin >> nbi;

    // integer arithmetic
    // It is just to check that it is functional : it compile and run
    // It doesn't have any sense and give stupid results
    // ==============================================================================
    {
        // integration setting
        int a = 0, b = 1;

        // compute and display
        int res = trapTemplateGeneral(a,b,nbi,line);
        cout << "LINE : "<<res<< endl;

    }
    // float arithmetic
    // ==============================================================================
    {
        // integration setting
        float a = 0.F, b = 1.F;

        // compute and display
        float res = trapTemplateGeneral(a,b,nbi,biline);
        cout << "BILINE : "<<res<< endl;
        cout << "ERRORBILINE : "<<( 0.25F-res )/0.25F<< endl;

    }
    // double arithmetic
    // ==============================================================================
    {
        // integration setting
        double a = 0., b = 1.;

        // compute and display
        double res = trapTemplateGeneral(a,b,nbi,unitCircle);
        cout << "PI : "<<res<< endl;
        cout << "ERRORPI : "<<( acos(-1.)-res )/acos(-1.)<< endl;
        res = trapTemplateGeneral(a,b,nbi,trigo);
        double resref = ( 1.-cos(15.))/15.+sin(3.)/3.;
        cout << "TRIGO : "<<res<< endl;
        cout << "ERRORTRIGO : "<<( resref-res )/resref<< endl;

    }
    // Real arithmetic
    // ==============================================================================
    {
        // integration setting
        Real a = 0., b(1.,20);

        // compute and display
        Real res = trapTemplateGeneral(a,b,nbi,rline);
        Real resref (0.5,40);
        Real one (0.1,1);
        cout << "RLINE : "<<res<< endl;
        // Note that if res == resref, the error will be 1 and not 0. ERRORLINE should be equal to (res-resref)/resref
        // but we chose this formula to avoid rounding problems
        cout << "ERRORRLINE : "<<res/resref<< endl ;
    }
    return 0;
}
