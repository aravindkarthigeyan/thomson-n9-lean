# Exact algebraic candidate parameter

The stationarity equation from `N9_CANDIDATE.md` is

```
-sqrt(A)+sqrt(B)+sqrt(C)-sqrt(D)+sqrt(E)=0,
A=12/r^4,
B=9r^2/[4(1-r^2)^3],
C=36r^2/(4-r^2)^3,
D=36/(2+2r)^3,
E=36/(2-r)^3.
```

All square roots are positive, and `0<r<1`. Define a universal polynomial by
starting with `p2(t)=(t^2-A-B)^2-4AB`, forming
`p3(t)=p2(t+sqrt(C))*p2(t-sqrt(C))`, and then
`p4(t)=p3(t+sqrt(D))*p3(t-sqrt(D))`. Each product contains no radicals, and
`p4` is even in `t`. Substituting `t^2=E` gives an integer polynomial
`P(A,B,C,D,E)`, homogeneous of total degree eight, with 495 monomials.

The independent checker verifies by explicit multinomial expansion that

```
P(a^2,b^2,c^2,d^2,(a+b+c+d)^2)=0
```

as a polynomial identity in four variables. Taking
`a=sqrt(A), b=-sqrt(B), c=-sqrt(C), d=sqrt(D)` shows the stationarity equation
implies `P(A,B,C,D,E)=0`, with no assumption about extraneous radical signs.

Use the positive common denominator

```
L=8r^4(1-r^2)^3(4-r^2)^3.
LA=96(1-r^2)^3(4-r^2)^3,
LB=18r^6(4-r^2)^3,
LC=288r^6(1-r^2)^3,
LD=36r^4(1-r)^3(4-r^2)^3,
LE=288r^4(1-r^2)^3(2+r)^3.
```

By homogeneity, substituting these five integer polynomials gives
`L^8 P(A,B,C,D,E)`. Removing the integer content and making the leading
coefficient positive yields a primitive degree-104 polynomial `Q(r)`.
Its full integer coefficient list, in increasing powers of `r`, is in
`parameter-polynomial.json`. The checker independently recomputes the
substitution using only Python integers and fractions, without SymPy or a
numerical solver, and verifies that coefficient list exactly.

## Isolating Interval

Let

```
l=7105483340929538113277041792727912437680/10^40,
u=7105483340929538113277041792727912437681/10^40.
```

Exact rational evaluation verifies `Q(l)>0` and `Q(u)<0`. Rational interval
Horner evaluation verifies `Q'(r)<0` throughout `[l,u]`. The intermediate
value theorem and strict monotonicity therefore imply that `Q` has exactly
one real root in this interval. The already-established stationary parameter
lies in the interval and satisfies `Q=0`, so it is precisely this algebraic
root. This also supplies an equivalent polynomial-plus-isolating-interval
definition of the candidate parameter.

The degree-104 polynomial may have extraneous roots elsewhere. No such roots
are being identified with a stationary candidate. SymPy reports a single
degree-104 factor over the rationals, but the present checker verifies only
the factor product, not irreducibility or minimal algebraic degree.

## Reproduction

From the project output directory:

```powershell
python algebra/generate_parameter_polynomial.py
python algebra/check_parameter_polynomial.py --negative-control
```

Generation uses SymPy for symbolic discovery; checking uses the Python
standard library only. The exact checker passed, including rejection after
adding one to the constant coefficient. Results are recorded in
`parameter-polynomial.check.json`. This is an exact computational
mathematical certificate, not yet a Lean formalization.
