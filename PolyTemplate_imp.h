
#include<iostream>
using namespace std;
#include "PolyTemplate.h"

template <typename T>
int orderNoNull(const T* v, const int & size_v)
{
    const T zero=0.;
    int order=size_v-1;
    while (order>-1 && v[order]==zero ) --order;
    return ((order>-1)?order:0);
}
template <typename T>
Poly<T>::Poly(const T  *coef_, int order)
    : size(++order)
{
    coef = new T[size];
    for(int i=0;i<order;++i)
        coef[i]=coef_[i];
    if (coef[order-1]==0. && order>1)
    {
        cout <<"This is not possible : You cannot define a polynome of order "<<order-1<<" with a null coeficient for monome X^"<<order-1<<endl; 
        throw -1;
    }
}
template <typename T>
Poly<T>::Poly(const Poly& rhs)
{
    size=rhs.size;
    const int order =size-1;
    coef = new T[size];
    for(int i=0;i<size;++i)
        coef[i]=rhs.coef[i];
    if (coef[order]==0. && size>1)
    {
        cout <<"This is not possible : You cannot define a polynome of order "<<order<<" with a null coeficient for monome X^"<<order<<endl; 
        throw -1;
    }
}

template <typename T>
Poly<T>::~Poly(void)
{
    delete [] coef;
}

template <typename T>
void Poly<T>::print(void) const
{
  const T zero=0.;
  std::cout <<"poly(x)=";
  if (coef[0] || size<2 )
        cout <<coef[0];
  for(int i=1;i<size;++i)
  {
      T v=coef[i];
      // as testing both less and greater then zero, zero value are not printed
      if (v>zero)
      {
          std::cout <<"+"<<v<<"*x^"<<i; 
      }
      else if (v<zero)
      {
          std::cout <<v<<"*x^"<<i; 
      }
  }
  std::cout<<endl;
  return;
}

template <typename T>
T Poly<T>::operator () (const T & x) const
{
    T poly_x=0.;
    for(int i=size-1;i>0;--i)
    {
        poly_x+=coef[i];
        poly_x*=x;
    }
    poly_x+=coef[0];

    return poly_x;
}

template <typename T>
Poly<T> Poly<T>::operator+(const Poly& p) const
{
    const int psize = p.size;
    const bool psize_is_min = size>psize;
    const int min_size = psize_is_min?p.size:size;
    const int max_size = psize_is_min?size:p.size;
    int i;
    T *coef_add = new T[max_size];

    for(i=0;i<min_size;++i)
        coef_add[i] = coef[i] + p.coef[i];

    if (psize_is_min)
    {
        for(;i<size;++i)
            coef_add[i] = coef[i];
    }
    else
    {
        for(;i<psize;++i)
            coef_add[i] = p.coef[i];
    }
    Poly ret(coef_add,orderNoNull(coef_add,max_size));
    delete [] coef_add;
    return ret;

}

template <typename T>
Poly<T> Poly<T>::operator-(const Poly& p) const
{
    const int psize = p.size;
    const bool psize_is_min = size>psize;
    const int min_size = psize_is_min?p.size:size;
    const int max_size = psize_is_min?size:p.size;
    int i;
    T *coef_neg = new T[max_size];

    for(i=0;i<min_size;++i)
        coef_neg[i] = coef[i] - p.coef[i];

    if (psize_is_min)
    {
        for(;i<size;++i)
            coef_neg[i] = coef[i];
    }
    else
    {
        for(;i<psize;++i)
            coef_neg[i] = -p.coef[i];
    }
    Poly ret(coef_neg,orderNoNull(coef_neg,max_size));
    delete [] coef_neg;
    return ret;

}

template <typename T>
Poly<T> Poly<T>::operator*(const Poly& p) const
{
    const T zero=0.;
    const int psize = p.size;
    if ((size==1 && coef[0]==zero) || (psize==1 && p.coef[0]==zero)) return Poly(&zero,0);
    const int prod_order = size+psize-2;
    const int prod_size = prod_order+1;
    T *coef_prod = new T[prod_size];
    int i,j;
    for(i=0;i<prod_size;++i)
        coef_prod[i]=zero;
    T p_coef_i;

    for(i=0;i<psize;++i)
    {
        p_coef_i=p.coef[i];
        if (p_coef_i!=zero)
        {
            for(j=0;j<size;++j)
                coef_prod[i+j] += coef[j]*p_coef_i;
        }
    }

    Poly ret(coef_prod,prod_order);
    delete [] coef_prod;
    return ret;
}

template <typename T>
Poly<T> Poly<T>::euclidienDivisionQ(const Poly& B) const
{
    const T zero=0.;
    const int Bsize = B.size;
    if (Bsize>size)
        return Poly(&zero,0);
    const int Q_order = size-Bsize;
    const int B_order = Bsize-1;
    T *coef_Q = new T[Q_order+1];
    T div=1./B.coef[B_order];
    T num,prod;
    T *coef_R = new T[size];
    int order_Q=Q_order;
    int order_R=size-1;
    int delta_order=Q_order;

    for(int i=0;i<size;++i)
        coef_R[i]=coef[i];

    while (delta_order>-1)
    {
        num=coef_R[order_R];
        if (num!=zero)
        {
            prod=num*div;
            coef_Q[order_Q]=prod;
            for(int j=0;j<B_order;++j)
                coef_R[j+delta_order] -= prod*B.coef[j];
        }
        else 
            coef_Q[order_Q]=zero;
        --order_Q;
        delta_order=(order_R--)-Bsize;
    }

    Poly ret(coef_Q,Q_order);
    delete [] coef_Q;
    delete [] coef_R;
    return ret;

}
template <typename T>
Poly<T> Poly<T>::euclidienDivisionR(const Poly& B, const Poly& Q) const
{
    return (*this)-(B*Q);
}
