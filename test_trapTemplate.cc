#include <iostream>
#include <cmath>
using namespace std;

#include "trapTemplate.h"
#include "objFunc.h"

int main()
{
    // integration setting
    double a = 0., b = 1.;
    int nbi;

    cout << "Give number of interval "<< endl;
    cin >> nbi;

    //local
    double res;
    double resref=acos(-1.);

    res=trapTemplate(a,b,nbi,unitCircleOF());
    cout << "PI : "<<res<< endl ;
    cout << "ERRORPI : "<<(resref-res)/resref<< endl ;

    res=trapTemplate(a,b,nbi,lineOF());
    cout << "LINE : "<<res<< endl ;
    cout << "ERRORLINE : "<<(0.5-res)/0.5<< endl ;

    res=trapTemplate(a,b,nbi,trigoOF());
    resref=(1.-cos(15.))/15.+sin(3.)/3.;
    cout << "TRIGO : "<<res<< endl ;
    cout << "ERRORTRIGO : "<<(resref-res)/resref<< endl ;

    res=trapTemplate(a,b,nbi,bilineOF());
    cout << "BILINE : "<<res<< endl ;
    cout << "ERRORBILINE : "<<(0.25-res)/0.25<< endl ;

    return 0;
}
