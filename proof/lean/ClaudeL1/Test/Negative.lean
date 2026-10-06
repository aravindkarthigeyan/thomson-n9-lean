/-
ClaudeL1.Test.Negative : negative controls.  The kernel must *reject* corrupted checks; each
theorem below proves that the corrupted check evaluates to `false` (by `decide +kernel`).

* `asm_tight`        : the residual l1 bound is exact — `Lres - 1` is rejected;
* `asm_bad_kscale`   : a wrong kernel scale (1874 instead of 1875) is rejected;
* `ktotal_bad_total` : a wrong claimed kernel total (zero) is rejected;
* `chunk01_bad_code` : chunk 1 with a different multiplier (code 1 instead of 0) is rejected.

Claude, L1.
-/
import ClaudeL1.Data.Assembly
import ClaudeL1.Data.SOS.C01

namespace ThomsonN9.Claude.L1.Test
open ThomsonN9.Claude.L1.KC ThomsonN9.Claude.L1.Data ThomsonN9.Claude.L1.Data.SOS

theorem asm_tight : asm.checkL1 (Lres - 1) = false := by decide +kernel

theorem asm_bad_kscale : ({ asm with kscale := 1874 } : Assembly).checkL1 Lres = false := by
  decide +kernel

theorem ktotal_bad_total : ({ ktotal with total := zeroTree } : KTotal).check = false := by
  decide +kernel

theorem chunk01_bad_code :
    (SOSChunk.ofCode gtree 433 1 cols01 T00 T01).check = false := by
  decide +kernel

end ThomsonN9.Claude.L1.Test
