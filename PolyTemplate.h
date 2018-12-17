
#include<iostream>




#ifndef Poly_temp_lab_H
#define Poly_temp_lab_H


template <typename T>
class Poly {
    public:
        Poly(const T  *coef_, int order);
        Poly(const Poly & rhs);
        ~Poly(void);
        void print() const;
        T operator () (const T & x) const;
        Poly<T> operator + (const Poly & p) const;
        Poly<T> operator - (const Poly & p) const;
        Poly<T> operator * (const Poly & p) const;
        Poly<T> euclidienDivisionQ(const Poly& B) const;
        Poly<T> euclidienDivisionR(const Poly& B, const Poly& Q) const;
    private:
        int size;
        T *coef;
};

#include "PolyTemplate_imp.h"
#endif
