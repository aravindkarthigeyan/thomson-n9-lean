# Quantitative Gram Alignment

All five Lean sources below have compiled successfully with ordinary Lean
4.34.1 against the pinned Mathlib dependency. Their 46 public theorems are
delivered in `lean/ThomsonN9/`; the next consolidated axiom audit will include
them. This is a geometric proof component, not yet the complete global theorem.

- `Alignment.lean`: compact orthogonal minimization and zero skew moment.
- `GramSchmidtFrame.lean`: an explicit well-conditioned orthonormal frame.
- `GramStability.lean`: scalar perturbation estimates and norm aggregation.
- `GramAlignment.lean`: Gram closeness implies a nearby minimizing alignment.
- `CandidateAlignment.lean`: specialization to the exact Thomson candidate.

## Quantitative Statement

Let X and P be nine unit vectors, and suppose every labeled Gram entry differs
by at most delta. Assume the three anchor pairs 01, 02, 12 in both configurations
have absolute inner product at most 1/3. Then there exists an orthogonal map Q
such that

    sum_i ||Q X_i - P_i||^2 <= (10000 delta)^2.

Moreover Q can be chosen to minimize this sum over all orthogonal maps. For this
choice, every skew moment vanishes:

    sum_i ((Q X_i-P_i)_a P_ib - (Q X_i-P_i)_b P_ia) = 0.

For the exact candidate, the three anchor inner products all equal
1 - 3 r^2 / 2 and have absolute value at most 1/4, using only
71/100 <= r <= 72/100. Thus delta <= 1/12 transfers the anchor hypotheses.
The refined-window error delta = 1e-8 gives distance at most 1e-4, well inside the
local radius 1/500.

The final specialized theorem is `candidate_refined_gram_alignment`. It assumes
unit vectors and the displayed labeled Gram-error hypothesis, and concludes
both the squared-displacement bound and every zero-skew identity. Localization
and the actual Hessian certificate are separate proof components.

## Explicit Frames

For unit anchors x,y,z put a=<x,y>, d=<x,z>, e=<y,z>, and define

    v = y-a*x; s=||v||; e2=v/s;
    b = <e2,z> = (e-a*d)/s;
    w = z-d*x-b*e2; t=||w||; e3=w/t.

The vectors (x,e2,e3) form an orthonormal basis. The denominator bounds use

    s^2=1-a^2 >= 8/9,
    |b| <= (1/3+1/9)/(2/3) = 2/3,
    t^2=1-d^2-b^2 >= 4/9.

In particular s,t >= 2/3. The formal scalar perturbation lemmas use only the
weaker lower bound 1/2.

For an arbitrary unit point u, the frame coordinates are

    c1=<x,u>,
    c2=(<y,u>-a*<x,u>)/s,
    c3=(<z,u>-d*<x,u>-b*c2)/t.

Corresponding quantities in two Gram-close configurations obey:

| Quantity difference | Bound |
| --- | ---: |
| s | 2 delta |
| b | 22 delta |
| c2 | 22 delta |
| t | 46 delta |
| c3 numerator | 47 delta |
| c3 | 646 delta |

The quotient estimate used throughout is

    |a/s-b/t| <= 2*|a-b| + 4*K*|s-t|

when s,t >= 1/2 and |b| <= K. The second-coordinate numerator has absolute
value <=2 and the third-coordinate numerator has absolute value <=3.
Consequently all 27 coordinate differences are bounded by 650 delta, and
27*(650 delta)^2 <= (10000 delta)^2.

## Rotational Gauge

Orthonormal frames form a nonempty closed subset of the unit ball in
`Fin 3 -> R3`, hence a compact set. The squared displacement objective is
continuous, so a minimizing orthogonal map exists.

For any coordinate plane (a,b), apply the rational rotation with
c=(1-tau^2)/(1+tau^2), s=2*tau/(1+tau^2). The exact objective difference is

    4*(A*tau^2-B*tau)/(1+tau^2),

where A=sum_i(x_ia*p_ia+x_ib*p_ib) and
B=sum_i(x_ia*p_ib-x_ib*p_ia). Nonnegativity for all real tau implies B=0.
Subtracting P from X does not change this skew moment. Nor does adding the
radial correction used to define the tangent displacement.
