"""Generate explicit Lean interval proofs for a rational comparison energy.

Adapted from the user's Astra Pro delivery, scripts/generate_energy_lean.py,
archive SHA256 0f8662d5a4726bad1b1024811e6b9b6d67fc1ca7e594752470e3b7414970e8b0.
Changes: parameterized paths, 256-bit scale for D60, standalone constants and
namespace, explicit Interval import, and an independent per-node replay.
Generated proof scripts must still be compiled; Python success is not a proof.
"""
import argparse
from dataclasses import dataclass
from fractions import Fraction as Q
from hashlib import sha256
from math import isqrt
from pathlib import Path
import json

if not __debug__:
    raise RuntimeError('Exact generation requires assertions.')

S = 1 << 256


def ceildiv(a, b):
    return -((-a)//b)


@dataclass(frozen=True)
class Interval:
    lo: int
    hi: int

    def __post_init__(self):
        assert self.lo <= self.hi

    @classmethod
    def const(cls, q):
        q = Q(q)
        return cls(q.numerator*S//q.denominator, ceildiv(q.numerator*S, q.denominator))

    def add(self, other):
        return Interval(self.lo+other.lo, self.hi+other.hi)

    def neg(self):
        return Interval(-self.hi, -self.lo)

    def mul(self, other):
        products = [a*b for a in (self.lo, self.hi) for b in (other.lo, other.hi)]
        return Interval(min(products)//S, ceildiv(max(products), S))

    def inv(self):
        assert self.lo > 0
        return Interval(S*S//self.hi, ceildiv(S*S, self.lo))

    def sqrt(self):
        assert self.lo >= 0
        lo, hi = isqrt(self.lo*S), isqrt(self.hi*S)
        return Interval(lo, hi+(hi*hi < self.hi*S))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--report', type=Path, required=True)
    args = parser.parse_args()
    raw = args.source.read_bytes()
    data = json.loads(raw)
    midpoint, upper = Q(data['energy_midpoint']), Q(data['candidate_energy_upper'])
    nodes = []

    def node(op, *refs):
        if op == 'constant':
            box = Interval.const(refs[0])
        elif op in ('add', 'mul'):
            box = getattr(nodes[refs[0]][2], op)(nodes[refs[1]][2])
        else:
            box = getattr(nodes[refs[0]][2], op)()
        nodes.append((op, refs, box))
        return len(nodes)-1

    def c(q): return node('constant', Q(q))
    def add(a, b): return node('add', a, b)
    def mul(a, b): return node('mul', a, b)
    def sub(a, b): return add(a, node('neg', b))
    def div(a, b): return mul(a, node('inv', b))
    def sqrt(a): return node('sqrt', a)

    r, one, two, three, four, six, twelve = [c(q) for q in (midpoint, 1, 2, 3, 4, 6, 12)]
    root3, rr = sqrt(three), mul(r, r)
    terms = [root3, div(mul(two, root3), r), div(three, mul(two, sqrt(sub(one, rr)))),
             div(six, sqrt(sub(four, rr))), div(six, sqrt(add(two, mul(two, r)))),
             div(twelve, sqrt(sub(two, r)))]
    final = terms[0]
    for t in terms[1:]:
        final = add(final, t)
    final_upper = Q(nodes[final][2].hi, S)
    assert 0 < midpoint < 1 and final_upper <= upper < Q(6439996633, 250000000)
    for i, (op, refs, out) in enumerate(nodes):
        if op == 'constant':
            assert Q(out.lo, S) <= refs[0] <= Q(out.hi, S)
            continue
        assert all(0 <= j < i for j in refs)
        a = nodes[refs[0]][2]
        if op == 'add':
            b = nodes[refs[1]][2]
            assert out.lo <= a.lo+b.lo and a.hi+b.hi <= out.hi
        elif op == 'neg':
            assert out.lo <= -a.hi and -a.lo <= out.hi
        elif op == 'mul':
            b = nodes[refs[1]][2]
            assert all(out.lo*S <= x*y <= out.hi*S for x in (a.lo, a.hi) for y in (b.lo, b.hi))
        elif op == 'sqrt':
            assert a.lo >= 0 and out.lo >= 0 and out.hi >= 0
            assert out.lo*out.lo <= a.lo*S and a.hi*S <= out.hi*out.hi
        elif op == 'inv':
            assert a.lo > 0 and out.lo*a.hi <= S*S <= out.hi*a.lo
        else:
            raise AssertionError(op)

    source = '''import ThomsonN9.Certificates.Interval
import ThomsonN9.CandidateEnergy
import ThomsonN9.FamilyMinimum

/-! Generated from the user-provided Astra Pro energy-enclosure construction,
adapted to the reduced D60 certificate. Every enclosure is a Lean obligation. -/
set_option maxRecDepth 100000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace ThomsonN9.Certificates.ReducedEnergy

'''
    source += f'def energyMidpoint : ℚ := {midpoint.numerator}/{midpoint.denominator}\n'
    source += f'def energyUpper : ℚ := {upper.numerator}/{upper.denominator}\n\n'
    for i, (op, refs, box) in enumerate(nodes):
        if op == 'constant':
            q = refs[0]
            expr = '(energyMidpoint : ℝ)' if i == r else f'({q.numerator}/{q.denominator} : ℝ)'
        elif op in ('add', 'mul'):
            expr = f'v{refs[0]}'+('+' if op == 'add' else '*')+f'v{refs[1]}'
        elif op == 'neg': expr = f'-v{refs[0]}'
        elif op == 'inv': expr = f'(v{refs[0]})⁻¹'
        else: expr = f'Real.sqrt (v{refs[0]})'
        source += f'noncomputable def v{i} : ℝ := {expr}\n'
        source += f'def b{i} : RatInterval := ⟨{box.lo}/{S}, {box.hi}/{S}⟩\n\n'
        source += f'theorem h{i} : b{i}.Contains v{i} := by\n'
        if op == 'constant':
            source += f'  constructor <;> norm_num [RatInterval.Contains, b{i}, v{i}, energyMidpoint]\n\n'
        elif op == 'sqrt':
            j = refs[0]
            source += f'  apply RatInterval.contains_sqrt (a := b{j}) h{j}\n'
            source += f'  norm_num [RatInterval.SqrtBounds, b{i}, b{j}]\n\n'
        else:
            if op in ('add', 'mul'):
                j, k = refs
                proof = f'RatInterval.contains_{op} h{j} h{k}'
            elif op == 'neg': proof = f'RatInterval.contains_neg h{refs[0]}'
            else: proof = f'RatInterval.contains_inv_of_pos h{refs[0]} (by norm_num [b{refs[0]}])'
            used = ', '.join(f'b{j}' for j in refs)
            source += f'  apply RatInterval.contains_widen ({proof})\n'
            source += f'  · norm_num [b{i}, {used}, RatInterval.{op}]\n'*2+'\n'
    defs = ', '.join(f'v{i}' for i in range(len(nodes)))
    source += f'''theorem final_identity : v{final} = symmetricEnergy (energyMidpoint : ℝ) := by
  simp only [{defs}, symmetricEnergy, div_eq_mul_inv, sub_eq_add_neg, pow_two]
  ring

theorem midpoint_upper : symmetricEnergy (energyMidpoint : ℝ) ≤ (energyUpper : ℝ) := by
  have h := h{final}
  rw [final_identity] at h
  have hb : (b{final}.hi : ℝ) ≤ (energyUpper : ℝ) := by norm_num [b{final}, energyUpper]
  exact h.2.trans hb

theorem midpoint_mem : (0 : ℚ) < energyMidpoint ∧ energyMidpoint < 1 := by
  norm_num [energyMidpoint]

theorem candidate_energy_upper (r : CandidateParameter) :
    coulombEnergy (candidate r) ≤ (energyUpper : ℝ) := by
  rw [candidate_energy]
  have h := symmetricEnergy_unique_min r (s := (energyMidpoint : ℝ))
    (by exact_mod_cast midpoint_mem.1) (by exact_mod_cast midpoint_mem.2)
  exact h.1.trans midpoint_upper

theorem energy_upper_below_threshold : energyUpper < (6439996633/250000000 : ℚ) := by
  norm_num [energyUpper]

#print axioms candidate_energy_upper
end ThomsonN9.Certificates.ReducedEnergy
'''
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(source, encoding='utf-8', newline='\n')
    report = {'result': 'PASS', 'kernel_checked': False, 'source_sha256': sha256(raw).hexdigest(),
              'arithmetic_nodes': len(nodes), 'sqrt_nodes': sum(op == 'sqrt' for op, _, _ in nodes),
              'scale_bits': 256, 'upper_margin': str(upper-final_upper),
              'lean_sha256': sha256(args.output.read_bytes()).hexdigest()}
    args.report.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
