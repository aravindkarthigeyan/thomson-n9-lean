# Compact E-Prime Hessian Cross-Check

`certificates/check_soft_block.py` provides an additional exact interval certificate for the delicate 3-by-3 E-prime Hessian block. It does not replace the complete 18-by-18 proof in `check_local.py` and does not claim to verify the entire representation decomposition.

## Provenance and Independence

The displayed mathematical block equations were inspected in the independent Claude L-workstream report `claude/candidate/REPTHEORY.md`, section 4. That report attributes its derivation to an exact D3h decomposition and records a separate Arb check. The present implementation was written from those equations; no source from `claude/candidate/reptheory.py` or another Claude source file was copied. No redistribution license for those source files is presumed.

This cross-check uses the already audited standard-library dyadic interval arithmetic in `check_local.py`, but computes the block through the six inverse pair distances, independently of that file's pair-by-pair Hessian assembly. It tests positivity by three determinant inequalities rather than by the full 18-by-18 LDL calculation. Thus the matrix construction and positivity criterion are independently checked routes, while the interval arithmetic remains shared.

## Direct Fourier Basis

Let `c=(1,-1/2,-1/2)` and `s=(0,sqrt(3)/2,-sqrt(3)/2)`. In the tangent-frame convention of `LOCAL_PROOF.md`, define three vectors:

- Cap azimuthal coefficients `sqrt(2/3)*c`, with all other components zero.
- Prism azimuthal coefficients `c/sqrt(3)` on both upper and lower triangles, with all other components zero.
- Prism meridional coefficients `-s/sqrt(3)` upstairs and `+s/sqrt(3)` downstairs, with all other components zero.

The identities `sum c=sum s=sum c*s=0` and `sum c^2=sum s^2=3/2` prove these vectors are orthonormal. They are orthogonal to all rotation vectors: the azimuthal cap/prism sums cancel for the axial rotation; opposite-height or opposite-meridional coefficients cancel the horizontal rotations. This is the first-partner E-prime subspace. The opposite sign in the last vector is important for matching the reported positive off-diagonal entries.

The checker independently constructs this basis and verifies interval consistency between the reported 3-by-3 formula and its projection of the full augmented matrix. As with the frame checks, interval containment of zero is a sanity check, not an algebraic proof that two formulas coincide. A formal proof must expand the exact projected entries or establish the representation identity in Lean.

## Sylvester Certificate

Set

```
z=sqrt(1-r^2),
a1=1/(sqrt(3)*r), a2=1/(2*z), a3=1/sqrt(4-r^2),
a4=1/sqrt(3), a5=1/sqrt(2+2*r), a6=1/sqrt(2-r).
```

The six symmetric block entries are evaluated as the explicit polynomial expressions in r,z,a1,...,a6 implemented in `soft_block`. For the certified rational radius interval, the three leading principal minors of `H_Eprime-(7/50)I` are enclosed in strictly positive intervals. Their diagnostic values are approximately

```
2.24239744, 8.49334772, 0.05779425.
```

Sylvester's criterion therefore proves positivity of this explicit symmetric 3-by-3 matrix minus `(7/50)I`. A negative control at the stronger claimed bound `3/20=0.15` has a strictly negative principal determinant and is rejected. The true soft eigenvalue is numerically about 0.143935, but no floating eigenvalue is used for acceptance.

Reproduce from the project output directory:

```powershell
python certificates/check_soft_block.py --negative-control --report results/soft-block.check.json
```

The report deliberately sets `complete_block_decomposition_proved_by_this_program` to false. To turn this into a standalone full Hessian proof, one must additionally verify the complete orthogonal basis, all off-block zero identities, the companion E-prime block, and the remaining irreducible blocks and rotational kernels. The inspected report supplies a plausible compact mathematical route; those exact identification steps have not been substituted for the already verified full-matrix certificate.
