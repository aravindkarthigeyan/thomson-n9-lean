"""1024-bit outward dyadic intervals, adapted from certificates/check_local.py."""
from fractions import Fraction as Q
from math import isqrt

BITS = 1024
S = 1 << BITS


def ceildiv(a, b):
    return -((-a)//b)


class I:
    def __init__(self, a=0, b=None, raw=False):
        if raw:
            self.lo, self.hi = a, b
        else:
            a, b = Q(a), Q(a if b is None else b)
            self.lo = a.numerator*S//a.denominator
            self.hi = ceildiv(b.numerator*S, b.denominator)
        assert self.lo <= self.hi

    @staticmethod
    def cast(value):
        return value if isinstance(value, I) else I(value)

    def __add__(self, other):
        other = I.cast(other)
        return I(self.lo+other.lo, self.hi+other.hi, True)

    __radd__ = __add__

    def __neg__(self):
        return I(-self.hi, -self.lo, True)

    def __sub__(self, other):
        return self+-I.cast(other)

    def __rsub__(self, other):
        return I.cast(other)+-self

    def __mul__(self, other):
        other = I.cast(other)
        products = [a*b for a in (self.lo, self.hi) for b in (other.lo, other.hi)]
        return I(min(products)//S, ceildiv(max(products), S), True)

    __rmul__ = __mul__

    def inv(self):
        assert self.lo > 0 or self.hi < 0
        return I(S*S//self.hi, ceildiv(S*S, self.lo), True)

    def __truediv__(self, other):
        return self*I.cast(other).inv()

    def __rtruediv__(self, other):
        return I.cast(other)*self.inv()

    def __pow__(self, n):
        assert isinstance(n, int) and n >= 0
        result = I(1)
        for _ in range(n):
            result *= self
        return result

    def sqrt(self):
        assert self.lo >= 0
        low, high = isqrt(self.lo*S), isqrt(self.hi*S)
        return I(low, high+(high*high < self.hi*S), True)

    def endpoints(self):
        return Q(self.lo, S), Q(self.hi, S)

    def strings(self):
        return list(map(str, self.endpoints()))
