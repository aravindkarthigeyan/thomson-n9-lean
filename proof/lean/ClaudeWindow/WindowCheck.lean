import ClaudeWindow.Interval
import Mathlib.Data.List.Sublists

/-!
# The finite Gram-window checker (definitions only)

All quantities are ordinary (undoubled) inner products of unit vectors.
For an anchor triple with pair products `a = ⟪x₀,x₁⟫`, `b = ⟪x₀,x₂⟫`, `c = ⟪x₁,x₂⟫`:

* `d3R a b c = 1 + 2abc - a² - b² - c²` is the 3×3 Gram determinant;
* `adj` is the adjugate of the 3×3 Gram matrix;
* `normR` is the 4×4 Gram determinant of `(x₀,x₁,x₂,y)` (Schur form), which must vanish;
* `pairR` is the 4×4 cross-Gram determinant of `(x₀,x₁,x₂,y)` against `(x₀,x₁,x₂,z)`,
  which must vanish (rank ≤ 3), with the products of `y` and of `z` independent.

The checker evaluates interval versions of these and accepts an exclusion only when the
interval omits `0`.  Colors are natural numbers `< 6` (index into the six P9 inner products).
-/

namespace ThomsonN9.Claude.Window

open Iv

/-! ## Real formulas -/

def d3R (a b c : ℝ) : ℝ := 1 + 2 * a * b * c - a ^ 2 - b ^ 2 - c ^ 2

def normR (a b c v0 v1 v2 : ℝ) : ℝ :=
  d3R a b c - ((1 - c ^ 2) * v0 ^ 2 + (1 - b ^ 2) * v1 ^ 2 + (1 - a ^ 2) * v2 ^ 2
    + 2 * ((b * c - a) * (v0 * v1) + (a * c - b) * (v0 * v2) + (a * b - c) * (v1 * v2)))

def pairR (a b c v0 v1 v2 w0 w1 w2 t : ℝ) : ℝ :=
  t * d3R a b c -
   ((1 - c ^ 2) * (v0 * w0) + (b * c - a) * (v0 * w1) + (a * c - b) * (v0 * w2)
  + (b * c - a) * (v1 * w0) + (1 - b ^ 2) * (v1 * w1) + (a * b - c) * (v1 * w2)
  + (a * c - b) * (v2 * w0) + (a * b - c) * (v2 * w1) + (1 - a ^ 2) * (v2 * w2))

/-! ## Interval formulas (same algebraic shape) -/

def d3Iv (A B C : Iv) : Iv :=
  sub (sub (sub (add (const 1) (mul (const 2) (mul (mul A B) C))) (sq A)) (sq B)) (sq C)

structure AdjIv where
  a00 : Iv
  a11 : Iv
  a22 : Iv
  a01 : Iv
  a02 : Iv
  a12 : Iv

def adjIv (A B C : Iv) : AdjIv :=
  ⟨sub (const 1) (sq C), sub (const 1) (sq B), sub (const 1) (sq A),
   sub (mul B C) A, sub (mul A C) B, sub (mul A B) C⟩

def normIv (D : Iv) (J : AdjIv) (V0 V1 V2 : Iv) : Iv :=
  sub D (add (add (add (mul J.a00 (sq V0)) (mul J.a11 (sq V1))) (mul J.a22 (sq V2)))
    (mul (const 2) (add (add (mul J.a01 (mul V0 V1)) (mul J.a02 (mul V0 V2)))
      (mul J.a12 (mul V1 V2)))))

def pairIv (D : Iv) (J : AdjIv) (V0 V1 V2 W0 W1 W2 T : Iv) : Iv :=
  sub (mul T D)
    (add (add (add (add (add (add (add (add
      (mul J.a00 (mul V0 W0)) (mul J.a01 (mul V0 W1))) (mul J.a02 (mul V0 W2)))
      (mul J.a01 (mul V1 W0))) (mul J.a11 (mul V1 W1))) (mul J.a12 (mul V1 W2)))
      (mul J.a02 (mul V2 W0))) (mul J.a12 (mul V2 W1))) (mul J.a22 (mul V2 W2)))

/-! ## Reference coloring of the P9 Gram matrix (labels as in `ThomsonN9.candidateAt`)

Labels 0,1,2: upper prism vertices (azimuth `i % 3`); 3,4,5: lower prism; 6,7,8: caps, cap
`6+k` opposite azimuth `k`.  Colors: 0 `-1/2`, 1 `-r`, 2 `r/2`, 3 `2r²-1`, 4 `1-3r²/2`,
5 `r²/2-1`. -/

def refColor (i j : ℕ) : ℕ :=
  if i < 6 ∧ j < 6 then (if i % 3 = j % 3 then 3 else if i / 3 = j / 3 then 4 else 5)
  else if 6 ≤ i ∧ 6 ≤ j then 0
  else if i < 6 then (if i % 3 = j - 6 then 1 else 2)
  else (if j % 3 = i - 6 then 1 else 2)

/-! ## Certificate records -/

abbrev Tri := ℕ × ℕ × ℕ

/-- A six-clique witness: node indices `S`, P9 labels of the three anchors, and the P9 label
`img[i]` of every node `i ∈ S`. -/
structure CliqueW where
  S : List ℕ
  anc : Tri
  img : List ℕ

/-- One sorted anchor color type `a = (c₀₁, c₀₂, c₁₂)`. -/
structure AnchorRec where
  a : Tri
  eligible : Bool
  ext : List Tri
  edges : List Tri
  cliques : List CliqueW

def get3 (l : List Tri) (i : ℕ) : Tri := l.getD i (0, 0, 0)

/-- Every color triple not listed as a node is excluded by the norm determinant. -/
def checkNorm (box : ℕ → Iv) (D : Iv) (J : AdjIv) (ext : List Tri) : Bool :=
  (List.range 6).all fun x => (List.range 6).all fun y => (List.range 6).all fun z =>
    decide ((x, y, z) ∈ ext) || (normIv D J (box x) (box y) (box z)).excl

/-- Every node pair `i ≤ j` and color `c` not listed as an edge is excluded by the
cross-Gram determinant (independent variables for the two points, also when `i = j`). -/
def checkPair (box : ℕ → Iv) (D : Iv) (J : AdjIv) (ext : List Tri) (edges : List Tri) : Bool :=
  (List.range ext.length).all fun i => (List.range ext.length).all fun j =>
    !(decide (i ≤ j)) || (List.range 6).all fun c =>
      decide ((i, j, c) ∈ edges) ||
        (pairIv D J (box (get3 ext i).1) (box (get3 ext i).2.1) (box (get3 ext i).2.2)
          (box (get3 ext j).1) (box (get3 ext j).2.1) (box (get3 ext j).2.2) (box c)).excl

def checkEdges (edges : List Tri) : Bool := edges.all fun e => decide (e.1 < e.2.1)

def isClique (edges : List Tri) (S : List ℕ) : Bool :=
  S.all fun i => S.all fun j => !(decide (i < j)) || edges.any fun e => decide (e.1 = i ∧ e.2.1 = j)

def wimg (w : CliqueW) (i : ℕ) : ℕ := w.img.getD i 0

def wlabels (w : CliqueW) : List ℕ := [w.anc.1, w.anc.2.1, w.anc.2.2] ++ w.S.map (wimg w)

def validW (rec : AnchorRec) (w : CliqueW) : Bool :=
  (wlabels w).all (fun v => decide (v < 9)) && decide (wlabels w).Nodup &&
  decide (refColor w.anc.1 w.anc.2.1 = rec.a.1) &&
  decide (refColor w.anc.1 w.anc.2.2 = rec.a.2.1) &&
  decide (refColor w.anc.2.1 w.anc.2.2 = rec.a.2.2) &&
  w.S.all (fun i => decide ((get3 rec.ext i).1 = refColor w.anc.1 (wimg w i)) &&
    decide ((get3 rec.ext i).2.1 = refColor w.anc.2.1 (wimg w i)) &&
    decide ((get3 rec.ext i).2.2 = refColor w.anc.2.2 (wimg w i))) &&
  rec.edges.all (fun e => !(decide (e.1 ∈ w.S ∧ e.2.1 ∈ w.S)) ||
    decide (e.2.2 = refColor (wimg w e.1) (wimg w e.2.1)))

def checkCliques (rec : AnchorRec) : Bool :=
  (List.sublistsLen 6 (List.range rec.ext.length)).all fun S =>
    !(isClique rec.edges S) || rec.cliques.any fun w => decide (w.S = S) && validW rec w

def checkRec (box : ℕ → Iv) (θ : ℚ) (rec : AnchorRec) : Bool :=
  if rec.eligible then
    checkNorm box (d3Iv (box rec.a.1) (box rec.a.2.1) (box rec.a.2.2))
        (adjIv (box rec.a.1) (box rec.a.2.1) (box rec.a.2.2)) rec.ext &&
      checkPair box (d3Iv (box rec.a.1) (box rec.a.2.1) (box rec.a.2.2))
        (adjIv (box rec.a.1) (box rec.a.2.1) (box rec.a.2.2)) rec.ext rec.edges &&
      checkEdges rec.edges && checkCliques rec
  else decide ((d3Iv (box rec.a.1) (box rec.a.2.1) (box rec.a.2.2)).hi ≤ θ)

/-- Every sorted anchor color type `x ≤ y ≤ z < 6` has a record. -/
def coverage (records : List AnchorRec) : Bool :=
  (List.range 6).all fun x => (List.range 6).all fun y => (List.range 6).all fun z =>
    !(decide (x ≤ y) && decide (y ≤ z)) || records.any fun rec => decide (rec.a = (x, y, z))

end ThomsonN9.Claude.Window
