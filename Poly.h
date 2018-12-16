#ifndef Poly_lab_H
#define Poly_lab_H
#include<iostream>

class Poly {
    public:
        Poly(const double  *coef_, int order);
        Poly(const Poly & rhs);
        ~Poly(void);
        void print() const;
        double operator () (const double & x) const;
        Poly operator + (const Poly & p) const;
        Poly operator - (const Poly & p) const;
        Poly operator * (const Poly & p) const;
        Poly euclidienDivisionQ(const Poly& B) const;
        Poly euclidienDivisionR(const Poly& B, const Poly& Q) const;
    private:
        int size;
        double *coef;
};

#endif
