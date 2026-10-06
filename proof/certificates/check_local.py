"""Exact dyadic interval checker, Python standard library only.

Every endpoint is an integer divided by 2**BITS. Division, multiplication and
square root round outwards by integer floor/ceil operations. This program is
an auditable exact checker, NOT a Lean theorem. Its mathematical connection
to local minimality is proved separately in LOCAL_PROOF.md.
"""
import argparse
from fractions import Fraction
import json
from math import isqrt
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run the exact checker without Python -O: assertions enforce certificate checks')

BITS = 180
S = 1 << BITS


def ceildiv(a,b):
    return -((-a)//b)


class I:
    def __init__(self, a=0, b=None, raw=False):
        if raw:
            self.lo,self.hi = a,b
        else:
            a = Fraction(a)
            b = a if b is None else Fraction(b)
            self.lo = (a.numerator*S)//a.denominator
            self.hi = ceildiv(b.numerator*S,b.denominator)
        assert self.lo <= self.hi

    @staticmethod
    def cast(x):
        return x if isinstance(x,I) else I(x)

    def __add__(self,other):
        other = I.cast(other)
        return I(self.lo+other.lo,self.hi+other.hi,True)

    __radd__ = __add__

    def __neg__(self):
        return I(-self.hi,-self.lo,True)

    def __sub__(self,other):
        return self+-I.cast(other)

    def __rsub__(self,other):
        return I.cast(other)+-self

    def __mul__(self,other):
        other = I.cast(other)
        q = [a*b for a in (self.lo,self.hi) for b in (other.lo,other.hi)]
        return I(min(q)//S,ceildiv(max(q),S),True)

    __rmul__ = __mul__

    def inv(self):
        assert self.lo>0 or self.hi<0, 'interval division contains zero'
        return I((S*S)//self.hi,ceildiv(S*S,self.lo),True)

    def __truediv__(self,other):
        return self*I.cast(other).inv()

    def __rtruediv__(self,other):
        return I.cast(other)*self.inv()

    def __pow__(self,n):
        assert isinstance(n,int)
        if n<0:
            return self.inv()**(-n)
        y=I(1)
        for _ in range(n):
            y=y*self
        return y

    def sqrt(self):
        assert self.lo>=0, 'negative square-root interval'
        low = isqrt(self.lo*S)
        high = isqrt(self.hi*S)
        if high*high != self.hi*S:
            high += 1
        return I(low,high,True)

    def decimal(self):
        return [float(Fraction(self.lo,S)),float(Fraction(self.hi,S))]

    def exact(self):
        return [str(Fraction(self.lo,S)),str(Fraction(self.hi,S))]


def dot(a,b):
    return sum(x*y for x,y in zip(a,b))


def cross(a,b):
    return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]


def energy(r):
    return (2*I(3).sqrt()/r+3/(2*(1-r*r).sqrt())+6/(4-r*r).sqrt()
            +I(3).sqrt()+6/(2+2*r).sqrt()+12/(2-r).sqrt())


def derivative(r):
    return (-2*I(3).sqrt()/r**2 + 3*r/(2*(1-r*r).sqrt()**3)
            +6*r/(4-r*r).sqrt()**3-6/(2+2*r).sqrt()**3+6/(2-r).sqrt()**3)


def points_frames(r):
    z=(1-r*r).sqrt()
    rt=I(3).sqrt()/2
    radial=[(I(1),I(0)),(I(Fraction(-1,2)),rt),(I(Fraction(-1,2)),-rt)]
    points=[]
    frames=[]
    for h in (z,-z):
        for c,s in radial:
            points.append([r*c,r*s,h])
            frames.append([[-s,c,I(0)],[h*c,h*s,-r]])
    for c,s in radial:
        points.append([-c,-s,I(0)])
        frames.append([[s,-c,I(0)],[I(0),I(0),I(-1)]])
    return points,frames


def validate_frames(points,frames):
    # These reject malformed formulas; exact frame identities are proved separately.
    assert len(points)==9 and len(frames)==9, 'wrong point/frame count'
    for i,(point,frame) in enumerate(zip(points,frames)):
        assert len(point)==3 and len(frame)==2 and all(len(v)==3 for v in frame)
        norm=dot(point,point)
        assert norm.lo<=S<=norm.hi, f'point norm does not enclose one at {i}'
        for m,v in enumerate(frame):
            tangent=dot(point,v)
            assert tangent.lo<=0<=tangent.hi, f'frame is not tangent at point {i}, vector {m}'
            for n,w in enumerate(frame):
                gram=dot(v,w)
                target=S if m==n else 0
                assert gram.lo<=target<=gram.hi, f'frame Gram does not enclose identity at {i},{m},{n}'


def tangent_hessian(r):
    p,t=points_frames(r)
    validate_frames(p,t)
    h=[[I(0) for _ in range(18)] for _ in range(18)]
    lambdas=[I(0) for _ in range(9)]
    min_distance=I(10)
    for i in range(9):
        for j in range(i):
            d=[a-b for a,b in zip(p[i],p[j])]
            q=dot(d,d)
            distance=q.sqrt()
            assert distance.lo>S, 'candidate distance must exceed one'
            if distance.lo<min_distance.lo:
                min_distance=distance
            a=distance**-3
            b=3*distance**-5
            for m in range(2):
                for n in range(2):
                    for u,v,sgn in [(i,i,1),(j,j,1),(i,j,-1),(j,i,-1)]:
                        h[2*u+m][2*v+n]+=sgn*(b*dot(t[u][m],d)*dot(t[v][n],d)-a*dot(t[u][m],t[v][n]))
            # Ambient gradient radial component is -sum_j 1/(2 distance).
            lambdas[i]-=1/(2*distance)
            lambdas[j]-=1/(2*distance)
    for i in range(9):
        for m in range(2):
            h[2*i+m][2*i+m]-=lambdas[i]
    axes=[[I(int(k==j)) for j in range(3)] for k in range(3)]
    rotations=[[dot(t[i][m],cross(axis,p[i])) for axis in axes] for i in range(9) for m in range(2)]
    augmented=[[h[i][j]+dot(rotations[i],rotations[j]) for j in range(18)] for i in range(18)]
    return augmented,min_distance


def positive_ldlt(a):
    n=len(a)
    l=[[I(int(i==j)) for j in range(n)] for i in range(n)]
    ds=[]
    for j in range(n):
        d=a[j][j]-sum(l[j][k]*l[j][k]*ds[k] for k in range(j))
        assert d.lo>0, f'nonpositive LDL pivot {j}: {d.decimal()}'
        ds.append(d)
        for i in range(j+1,n):
            l[i][j]=(a[i][j]-sum(l[i][k]*l[j][k]*ds[k] for k in range(j)))/d
    return ds


def check(data):
    assert data['format']=='thomson-n9-local-v1'
    assert data['arithmetic_bits']==BITS
    lo=Fraction(*data['radius_lower'])
    hi=Fraction(*data['radius_upper'])
    assert Fraction(7,10)<lo<hi<Fraction(18,25), 'root interval must satisfy the Gram-rigidity radius bounds'
    dl,du=derivative(I(lo)),derivative(I(hi))
    assert dl.hi<0, 'lower endpoint derivative not negative'
    assert du.lo>0, 'upper endpoint derivative not positive'
    r=I(lo,hi)
    a,dmin=tangent_hessian(r)
    c=Fraction(*data['hessian_lower'])
    assert c>0
    for i in range(18):
        a[i][i]-=c
    pivots=positive_ldlt(a)
    radius=Fraction(*data['local_chord_radius'])
    gain=Fraction(*data['local_energy_coefficient'])
    assert radius>0 and gain>0
    # sqrt(2)<3/2; all line-segment pair distances remain >=1.
    assert Fraction(dmin.lo,S)-Fraction(3,2)*radius>=1
    # ||Hc||<=22. |D^3(1/|d|)[v,v,v]|<=6|v|^3/|d|^4, and
    # sum_edges |b_i-b_j|^3 <= 9 sqrt(2) rho^3 < (27/2) rho^3.
    assert c/2-Fraction(49,2)*radius-(c/8+Fraction(22,8))*radius**2>=gain
    return {'passed':True,'derivative_lower':dl.exact(),'derivative_upper':du.exact(),
            'energy_interval':energy(r).exact(),'minimum_distance_interval':dmin.exact(),
            'hessian_lower':str(c),'LDL_pivots':[d.exact() for d in pivots],
            'local_chord_radius':str(radius),'local_energy_coefficient':str(gain),
            'frame_sanity_checks_passed':True,
            'root_interval_inside_gram_rigidity_bounds':True}


def selftest():
    for a in [Fraction(-7,3),Fraction(-1,11),Fraction(0),Fraction(1,13),Fraction(21,4)]:
        for b in [Fraction(-19,7),Fraction(2,9),Fraction(1,17)]:
            for enclosure,value in [(I(a)+I(b),a+b),(I(a)*I(b),a*b),(I(a)/I(b),a/b)]:
                assert Fraction(enclosure.lo,S)<=value<=Fraction(enclosure.hi,S)
        if a>=0:
            s=I(a).sqrt()
            assert Fraction(s.lo,S)**2<=a<=Fraction(s.hi,S)**2


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('certificate',nargs='?',type=Path,default=Path(__file__).with_name('local.json'))
    ap.add_argument('--report',type=Path)
    ap.add_argument('--negative-controls',action='store_true')
    args=ap.parse_args()
    selftest()
    data=json.loads(args.certificate.read_text())
    result=check(data)
    if args.negative_controls:
        rejected=[]
        for label,change in [('false Hessian lower bound',{'hessian_lower':[1,1]}),
                             ('wrong isolating interval',{'radius_lower':[701,1000],'radius_upper':[702,1000]}),
                             ('root interval outside Gram bounds',{'radius_lower':[69,100],'radius_upper':[73,100]})]:
            try:
                check(dict(data,**change))
            except AssertionError:
                print('REJECTED:',label)
                rejected.append(label)
            else:
                raise AssertionError('negative control accepted: '+label)
        original_frames=points_frames
        def mutant_m8(r):
            points,frames=original_frames(r)
            for frame in frames[:6]:
                frame[1][2]=-frame[1][2]
            return points,frames
        globals()['points_frames']=mutant_m8
        try:
            try:
                check(data)
            except AssertionError as error:
                assert 'not tangent' in str(error), 'M8 was not rejected by the intended tangency check'
                print('REJECTED: M8 meridional tangent z-sign flip')
                rejected.append('M8 meridional tangent z-sign flip')
            else:
                raise AssertionError('negative control accepted: M8 frame mutation')
        finally:
            globals()['points_frames']=original_frames
        result['negative_controls_rejected']=True
        result['rejected_controls']=rejected
    if args.report:
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(json.dumps(result,indent=2)+'\n')
    print('PASS: exact derivative bracket, augmented Hessian >= 7/50, quantitative local constants')
    print('Energy enclosure (diagnostic decimals):',I(Fraction(result['energy_interval'][0]),Fraction(result['energy_interval'][1])).decimal())


if __name__=='__main__':
    main()
