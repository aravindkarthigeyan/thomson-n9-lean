"""Independent integer-predicate replay of an ambient interval circuit.

This validates arithmetic and coarse output enclosures. The circuit-to-Hessian
semantic identity is a separate obligation; passing this file alone is not a
proof that an arbitrary supplied circuit computes the intended matrix.
"""
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

if not __debug__:
    raise RuntimeError('Do not disable certificate assertions with Python -O')


def check(data):
    assert data['format'] == 'thomson-n9-ambient-interval-circuit-v1'
    scale = int(data['scale'])
    assert scale == 2**180
    source = ROOT/'certificates/local.json'
    congruence_name = data.get('congruence_file','ambient-dd.json')
    assert congruence_name in ('ambient-dd.json','ambient-dd-k10000.json','ambient-dd-k0.json')
    congruence = ROOT/'certificates'/congruence_name
    assert hashlib.sha256(source.read_bytes()).hexdigest() == data['source_sha256']
    assert hashlib.sha256(congruence.read_bytes()).hexdigest() == data['congruence_sha256']
    penalty = Fraction(json.loads(congruence.read_text())['normal_penalty'])
    source_data = json.loads(source.read_text())
    radius = list(map(Fraction,data['input_radius']))
    assert radius == [Fraction(*source_data['radius_lower']),Fraction(*source_data['radius_upper'])]
    intervals = []
    for i,node in enumerate(data['nodes']):
        op,args = node['op'],node['args']
        assert op in ('input','const','add','neg','mul','inv','sqrt')
        assert len(args) == (2 if op in ('const','add','mul') else 1)
        lo,hi = int(node['lo']),int(node['hi'])
        assert lo <= hi
        if op == 'const':
            numerator,denominator = map(int,args)
            assert denominator > 0
            assert lo*denominator <= numerator*scale <= hi*denominator
        elif op == 'input':
            assert args == [0]
            assert Fraction(lo,scale) <= radius[0] <= radius[1] <= Fraction(hi,scale)
        else:
            assert all(isinstance(j,int) and 0 <= j < i for j in args)
            a,b = intervals[args[0]]
            if op == 'add':
                c,d = intervals[args[1]]
                assert lo <= a+c and b+d <= hi
            elif op == 'neg':
                assert lo <= -b and -a <= hi
            elif op == 'mul':
                c,d = intervals[args[1]]
                assert all(lo*scale <= x*y <= hi*scale for x in (a,b) for y in (c,d))
            elif op == 'inv':
                assert a > 0 and lo >= 0 and hi >= 0
                assert lo*b <= scale*scale <= hi*a
            elif op == 'sqrt':
                assert a >= 0 and lo >= 0 and hi >= 0
                assert lo*lo <= a*scale and b*scale <= hi*hi
            else:
                raise AssertionError('Unknown operation: '+op)
        intervals.append((lo,hi))
    output = data['output_indices']
    assert len(output) == 27 and all(len(row) == 27 for row in output)
    for i,row in enumerate(output):
        for j,index in enumerate(row):
            assert isinstance(index,int) and 0 <= index < len(intervals)
            lo,hi = intervals[index]
            diagonal = (Fraction(1,1000),Fraction(100)) if penalty == 0 else \
                       (Fraction(1,20),Fraction(2000000))
            lower,upper = diagonal if i == j else (Fraction(-1,100000),Fraction(1,100000))
            assert lower <= Fraction(lo,scale) <= Fraction(hi,scale) <= upper
    return {'passed':True,'nodes_checked':len(intervals),'outputs_checked':729,
            'scope':'Arithmetic and output enclosures only; intended-expression identity remains separate'}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('certificate',nargs='?',type=Path,
                        default=Path(__file__).with_name('ambient-circuit.json'))
    parser.add_argument('--report',type=Path)
    parser.add_argument('--negative-controls',action='store_true')
    args = parser.parse_args()
    data = json.loads(args.certificate.read_text())
    result = check(data)
    result['certificate_sha256'] = hashlib.sha256(args.certificate.read_bytes()).hexdigest()
    if args.negative_controls:
        rejected = []
        for name in ('false square-root bound','forward reference','false product bound'):
            mutant = json.loads(json.dumps(data))
            if name == 'forward reference':
                index = next(i for i,n in enumerate(mutant['nodes']) if n['op'] == 'add')
                mutant['nodes'][index]['args'][0] = index
            else:
                op = 'sqrt' if name == 'false square-root bound' else 'mul'
                index = next(i for i,n in enumerate(mutant['nodes']) if n['op'] == op and int(n['lo']) > 0)
                mutant['nodes'][index]['lo'] = '0'
                mutant['nodes'][index]['hi'] = '0'
            try:
                check(mutant)
            except AssertionError:
                rejected.append(name)
            else:
                raise AssertionError('Corruption accepted: '+name)
        result['rejected_controls'] = rejected
    if args.report:
        args.report.write_text(json.dumps(result,indent=2)+'\n')
    print('PASS:',result['nodes_checked'],'integer node checks and 729 output enclosures')


if __name__ == '__main__':
    main()
