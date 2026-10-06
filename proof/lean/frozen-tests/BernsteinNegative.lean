import ThomsonN9.Bernstein.MinorantCert

/-! Negative controls: the kernel rejects corrupted data (each `= false` is kernel-evaluated). -/

open ThomsonN9.Bernstein

-- minorant constant raised by 10^-120: the first cover interval is rejected
theorem neg_raised_constant :
    checkInterval (potential (addL [10 ^ 60] minorantNum) minorantDen) globalPt0 globalPt1
      globalM 1 1 1 = false := by decide +kernel

-- exterior gap 1 instead of 10^-46: the first exterior interval is rejected
theorem neg_gap_one :
    checkInterval (potential (addL [minorantDen] minorantNum) minorantDen)
      (extA.getD 0 0) (extB.getD 0 0) extM 1 1 1 = false := by decide +kernel

-- the whole of [0,1] as a single unsplit leaf is rejected
theorem neg_unsplit_root :
    checkInterval (potential minorantNum minorantDen) 0 1 1 1 1 1 = false := by decide +kernel

-- a cover with the contact interval [globalPt1, globalPt2] deleted is rejected
theorem neg_gap_in_cover :
    checkCover (potential minorantNum minorantDen) globalM globalPt0
      [globalPt2, globalPt3] = false := by decide +kernel


