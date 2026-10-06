"""Generate a shared exact dyadic arithmetic trace for the ambient certificate.

This is numerical-data generation, not a trusted proof. check.py independently
checks the integer predicates that the Lean soundness layer is formalizing.
"""
import argparse
from fractions import Fraction
import hashlib
import json
from math import isqrt
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'certificates'))
import check_ambient_dd as ambient
from check_local_dd import multiply

SCALE = ambient.local.S
NODES = []
CACHE = {}


def ceildiv(a,b):
    return -((-a)//b)


class TraceInterval:
    def __new__(cls,a=0,b=None,raw=False):
        assert not raw
        if isinstance(a,TraceInterval):
            assert b is None
            return a
        a = Fraction(a)
        if b is not None:
            b = Fraction(b)
            return cls.make('input',[0],a.numerator*SCALE//a.denominator,
                            ceildiv(b.numerator*SCALE,b.denominator))
        return cls.make('const',[str(a.numerator),str(a.denominator)],
                        a.numerator*SCALE//a.denominator,
                        ceildiv(a.numerator*SCALE,a.denominator),constant=a)

    @classmethod
    def make(cls,op,args,lo,hi,constant=None):
        assert lo <= hi
        key = (op,*args)
        if key in CACHE:
            old = CACHE[key]
            assert old.lo == lo and old.hi == hi
            return old
        value = object.__new__(cls)
        value.index,value.lo,value.hi,value.constant = len(NODES),lo,hi,constant
        NODES.append({'op':op,'args':args,'lo':str(lo),'hi':str(hi)})
        CACHE[key] = value
        return value

    def __add__(self,other):
        other = TraceInterval(other)
        if self.constant == 0:
            return other
        if other.constant == 0:
            return self
        if self.constant is not None and other.constant is not None:
            return TraceInterval(self.constant+other.constant)
        return self.make('add',[self.index,other.index],self.lo+other.lo,self.hi+other.hi)

    __radd__ = __add__

    def __neg__(self):
        if self.constant is not None:
            return TraceInterval(-self.constant)
        return self.make('neg',[self.index],-self.hi,-self.lo)

    def __sub__(self,other):
        return self+-TraceInterval(other)

    def __rsub__(self,other):
        return TraceInterval(other)+-self

    def __mul__(self,other):
        other = TraceInterval(other)
        if self.constant == 0 or other.constant == 0:
            return TraceInterval(0)
        if self.constant == 1:
            return other
        if other.constant == 1:
            return self
        if self.constant is not None and other.constant is not None:
            return TraceInterval(self.constant*other.constant)
        products = [a*b for a in (self.lo,self.hi) for b in (other.lo,other.hi)]
        return self.make('mul',[self.index,other.index],min(products)//SCALE,
                         ceildiv(max(products),SCALE))

    __rmul__ = __mul__

    def inv(self):
        assert self.lo > 0, 'this circuit uses only positive reciprocals'
        if self.constant is not None:
            return TraceInterval(1/self.constant)
        return self.make('inv',[self.index],SCALE*SCALE//self.hi,
                         ceildiv(SCALE*SCALE,self.lo))

    def __truediv__(self,other):
        return self*TraceInterval(other).inv()

    def __rtruediv__(self,other):
        return TraceInterval(other)*self.inv()

    def __pow__(self,n):
        assert isinstance(n,int)
        if n < 0:
            return self.inv()**(-n)
        answer = TraceInterval(1)
        for _ in range(n):
            answer *= self
        return answer

    def sqrt(self):
        assert self.lo >= 0
        lo,hi = isqrt(self.lo*SCALE),isqrt(self.hi*SCALE)
        if hi*hi != self.hi*SCALE:
            hi += 1
        return self.make('sqrt',[self.index],lo,hi)


def ids(matrix):
    return [[value.index for value in row] for row in matrix]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--congruence',type=Path,default=ROOT/'certificates/ambient-dd.json')
    parser.add_argument('--output',type=Path,default=Path(__file__).with_name('ambient-circuit.json'))
    args = parser.parse_args()
    source = ROOT/'certificates/local.json'
    congruence = args.congruence
    data = json.loads(source.read_text())
    certificate = json.loads(congruence.read_text())
    lo,hi = Fraction(*data['radius_lower']),Fraction(*data['radius_upper'])
    old = ambient.local.I
    ambient.local.I = TraceInterval
    try:
        radius = TraceInterval(lo,hi)
        points = ambient.points(radius)
        a = ambient.augmented_hessian(radius,Fraction(certificate['normal_penalty']))
        shift = Fraction(certificate['hessian_shift'])
        for i in range(27):
            a[i][i] -= shift
        c = [[TraceInterval(Fraction(value)) for value in row] for row in certificate['unit_upper']]
        b = multiply(list(map(list,zip(*c))),multiply(a,c))
    finally:
        ambient.local.I = old
    result = {
        'format':'thomson-n9-ambient-interval-circuit-v1',
        'scale':str(SCALE),
        'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
        'congruence_sha256':hashlib.sha256(congruence.read_bytes()).hexdigest(),
        'congruence_file':congruence.name,
        'input_radius':[str(lo),str(hi)],
        'nodes':NODES,
        'point_indices':ids(points),
        'shifted_hessian_indices':ids(a),
        'congruence_indices':ids(c),
        'output_indices':ids(b),
    }
    target = args.output
    target.write_text(json.dumps(result,separators=(',',':'))+'\n')
    counts = {op:sum(node['op'] == op for node in NODES) for op in sorted({n['op'] for n in NODES})}
    print('Generated exact arithmetic circuit:',len(NODES),'nodes,',target.stat().st_size,'bytes')
    print('Operation counts:',counts)


if __name__ == '__main__':
    main()
