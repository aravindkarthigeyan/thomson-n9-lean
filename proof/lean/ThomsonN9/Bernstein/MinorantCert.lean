import ThomsonN9.Bernstein.Checker
import ThomsonN9.Bernstein.MinorantData

/-!
# Kernel certificates for the N=9 minorant

The two finite computations behind `Minorant.lean`, each evaluated by the Lean kernel
(`decide +kernel`, GMP-accelerated `Nat`/`Int` arithmetic, no compiled-code evaluation):
* `global_cert`: the binary forms of `D·(1 - 2y·h(1-2y²))` on the 13 intervals of the cover
  `globalPts` of `[0,1]` have nonnegative coefficients;
* `ext_cert0 … ext_cert6`: the same for `h + 10⁻⁴⁶` on the seven exterior `y`-intervals,
  together with the rational comparisons placing `√((1-t)/2)` in them.
-/

namespace ThomsonN9.Bernstein

/-- Lower end of the 40-digit radius bracket (same literal as `ThomsonN9.radiusLower`). -/
def rLower : ℚ :=
  7105483340929538113277041792727912437680 / 10000000000000000000000000000000000000000

/-- Upper end of the 40-digit radius bracket (same literal as `ThomsonN9.radiusUpper`). -/
def rUpper : ℚ :=
  7105483340929538113277041792727912437681 / 10000000000000000000000000000000000000000

/-- Window half width `ε`. -/
def winEps : ℚ := 1 / 10000

/-- The seven closed exterior intervals (rational, built from the radius bracket):
`[-1+ε, u₁-ε]`, `[lⱼ+ε, u_{j+1}-ε]` (`j=1..5`), `[l₆+ε, 5593/10000]`, where `[lⱼ,uⱼ]`
encloses `sⱼ(r)`. -/
def extLo : List ℚ :=
  [-1 + winEps,
   rLower * rLower / 2 - 1 + winEps,
   -rUpper + winEps,
   -1 / 2 + winEps,
   2 * rLower * rLower - 1 + winEps,
   1 - 3 * rUpper * rUpper / 2 + winEps,
   rLower / 2 + winEps]

def extHi : List ℚ :=
  [rUpper * rUpper / 2 - 1 - winEps,
   -rLower - winEps,
   -1 / 2 - winEps,
   2 * rUpper * rUpper - 1 - winEps,
   1 - 3 * rLower * rLower / 2 - winEps,
   rUpper / 2 - winEps,
   5593 / 10000]

/-! ### The kernel computations -/

/-- The scaled integer numerators reproduce the rational JSON coefficients exactly. -/
theorem minorantRat_eq : minorantRat = minorantNum.map (fun z : ℤ => (z : ℚ) / minorantDen) := by
  decide +kernel


/-! Global certificate: `D(1 - 2y h(1-2y²)) ≥ 0` on each of the 13 intervals of the cover of
`[0,1]` (one kernel check per interval; they run as separate declarations). -/

theorem global_cert0 : checkInterval (potential minorantNum minorantDen) globalPt0 globalPt1
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert1 : checkInterval (potential minorantNum minorantDen) globalPt1 globalPt2
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert2 : checkInterval (potential minorantNum minorantDen) globalPt2 globalPt3
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert3 : checkInterval (potential minorantNum minorantDen) globalPt3 globalPt4
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert4 : checkInterval (potential minorantNum minorantDen) globalPt4 globalPt5
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert5 : checkInterval (potential minorantNum minorantDen) globalPt5 globalPt6
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert6 : checkInterval (potential minorantNum minorantDen) globalPt6 globalPt7
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert7 : checkInterval (potential minorantNum minorantDen) globalPt7 globalPt8
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert8 : checkInterval (potential minorantNum minorantDen) globalPt8 globalPt9
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert9 : checkInterval (potential minorantNum minorantDen) globalPt9 globalPt10
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert10 : checkInterval (potential minorantNum minorantDen) globalPt10 globalPt11
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert11 : checkInterval (potential minorantNum minorantDen) globalPt11 globalPt12
    globalM 1 1 1 = true := by decide +kernel
theorem global_cert12 : checkInterval (potential minorantNum minorantDen) globalPt12 globalPt13
    globalM 1 1 1 = true := by decide +kernel

/-- The whole cover at once. -/
theorem global_cert :
    checkCover (potential minorantNum minorantDen) globalM globalPt0 globalPts = true := by
  simp only [globalPts, checkCover, global_cert0, global_cert1, global_cert2, global_cert3, global_cert4, global_cert5, global_cert6, global_cert7, global_cert8, global_cert9, global_cert10, global_cert11, global_cert12, Bool.and_true]

/-- Rational side conditions for an exterior interval `[lo,hi]` in `t` and its `y`-interval
`[A/M, B/M]`: `0 ≤ A`, `0 ≤ B`, `hi < 1`, `(A/M)² ≤ (1-hi)/2`, `(1-lo)/2 ≤ (B/M)²`. -/
def extOk (A B M : ℤ) (lo hi : ℚ) : Bool :=
  decide (0 ≤ A) && decide (0 ≤ B) && decide (hi < 1) &&
    decide ((A : ℚ) * A ≤ (M : ℚ) * M * ((1 - hi) / 2)) &&
    decide ((M : ℚ) * M * ((1 - lo) / 2) ≤ (B : ℚ) * B)

/-- Exterior certificate for interval `j`. -/
def extCheck (j : ℕ) : Bool :=
  checkInterval (potential (addL [gapNum] minorantNum) minorantDen)
      (extA.getD j 0) (extB.getD j 0) extM 1 1 1 &&
    extOk (extA.getD j 0) (extB.getD j 0) extM (extLo.getD j 0) (extHi.getD j 0)

theorem ext_cert0 : extCheck 0 = true := by decide +kernel
theorem ext_cert1 : extCheck 1 = true := by decide +kernel
theorem ext_cert2 : extCheck 2 = true := by decide +kernel
theorem ext_cert3 : extCheck 3 = true := by decide +kernel
theorem ext_cert4 : extCheck 4 = true := by decide +kernel
theorem ext_cert5 : extCheck 5 = true := by decide +kernel
theorem ext_cert6 : extCheck 6 = true := by decide +kernel

end ThomsonN9.Bernstein
