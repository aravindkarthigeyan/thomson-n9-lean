import ThomsonN9.Certificates.CircuitAlgebra
import ThomsonN9.Candidate

/-! The checked coordinate prefix computes the actual candidate family. -/

namespace ThomsonN9.Certificates.IntervalCircuit

def coordinateOps : Array Op := #[
  .input 0, .mul 0 0, .constant 1 1, .neg 1, .add 2 3, .sqrt 4,
  .constant 3 1, .sqrt 6, .constant 2 1, .constant 1 2, .mul 7 9,
  .constant 0 1, .constant (-1) 2, .neg 10, .neg 5, .mul 0 12,
  .mul 0 10, .mul 0 13, .constant (-1) 1, .neg 13]

def CoordinateCheck (nodes : ℕ → Node) : Prop :=
  ∀ i : Fin 20, (nodes i).op = coordinateOps[i.val]?.getD (.input 0)

instance (nodes : ℕ → Node) : Decidable (CoordinateCheck nodes) := by
  unfold CoordinateCheck
  infer_instance

def pointIndices : Fin 9 → Fin 3 → ℕ :=
  ![![0,11,5], ![15,16,5], ![15,17,5], ![0,11,14], ![15,16,14],
    ![15,17,14], ![18,11,11], ![9,13,11], ![9,19,11]]

noncomputable def parameterInputs (r : ℝ) (i : ℕ) : ℝ := if i = 0 then r else 0

theorem coordinate_recipe_sound (r : ℝ) (nodes : ℕ → Node) (h : CoordinateCheck nodes)
    (i : Fin 9) (a : Fin 3) :
    value (parameterInputs r) nodes (pointIndices i a) = candidateAt r i a := by
  let V := value (parameterInputs r) nodes
  have h0 : (nodes 0).op = .input 0 := h ⟨0,by decide⟩
  have h1 : (nodes 1).op = .mul 0 0 := h ⟨1,by decide⟩
  have h2 : (nodes 2).op = .constant 1 1 := h ⟨2,by decide⟩
  have h3 : (nodes 3).op = .neg 1 := h ⟨3,by decide⟩
  have h4 : (nodes 4).op = .add 2 3 := h ⟨4,by decide⟩
  have h5 : (nodes 5).op = .sqrt 4 := h ⟨5,by decide⟩
  have h6 : (nodes 6).op = .constant 3 1 := h ⟨6,by decide⟩
  have h7 : (nodes 7).op = .sqrt 6 := h ⟨7,by decide⟩
  have h9 : (nodes 9).op = .constant 1 2 := h ⟨9,by decide⟩
  have h10 : (nodes 10).op = .mul 7 9 := h ⟨10,by decide⟩
  have h11 : (nodes 11).op = .constant 0 1 := h ⟨11,by decide⟩
  have h12 : (nodes 12).op = .constant (-1) 2 := h ⟨12,by decide⟩
  have h13 : (nodes 13).op = .neg 10 := h ⟨13,by decide⟩
  have h14 : (nodes 14).op = .neg 5 := h ⟨14,by decide⟩
  have h15 : (nodes 15).op = .mul 0 12 := h ⟨15,by decide⟩
  have h16 : (nodes 16).op = .mul 0 10 := h ⟨16,by decide⟩
  have h17 : (nodes 17).op = .mul 0 13 := h ⟨17,by decide⟩
  have h18 : (nodes 18).op = .constant (-1) 1 := h ⟨18,by decide⟩
  have h19 : (nodes 19).op = .neg 13 := h ⟨19,by decide⟩
  have v0 : V 0 = r := by
    simpa [V,parameterInputs] using value_input (parameterInputs r) nodes 0 0 h0
  have v1 : V 1 = r*r := by
    rw [show V 1 = V 0*V 0 from value_mul _ _ _ _ _ h1 (by decide) (by decide), v0]
  have v2 : V 2 = 1 := by
    simpa [V] using value_constant (parameterInputs r) nodes 2 1 1 h2
  have v3 : V 3 = -(r*r) := by
    rw [show V 3 = -V 1 from value_neg _ _ _ _ h3 (by decide), v1]
  have v4 : V 4 = 1-r^2 := by
    rw [show V 4 = V 2+V 3 from value_add _ _ _ _ _ h4 (by decide) (by decide), v2,v3]
    ring
  have v5 : V 5 = Real.sqrt (1-r^2) := by
    rw [show V 5 = Real.sqrt (V 4) from value_sqrt _ _ _ _ h5 (by decide), v4]
  have v6 : V 6 = 3 := by
    simpa [V] using value_constant (parameterInputs r) nodes 6 3 1 h6
  have v7 : V 7 = Real.sqrt 3 := by
    rw [show V 7 = Real.sqrt (V 6) from value_sqrt _ _ _ _ h7 (by decide), v6]
  have v9 : V 9 = 1/2 := by
    simpa [V] using value_constant (parameterInputs r) nodes 9 1 2 h9
  have v10 : V 10 = Real.sqrt 3/2 := by
    rw [show V 10 = V 7*V 9 from value_mul _ _ _ _ _ h10 (by decide) (by decide),v7,v9]
    ring
  have v11 : V 11 = 0 := by
    simpa [V] using value_constant (parameterInputs r) nodes 11 0 1 h11
  have v12 : V 12 = -1/2 := by
    simpa [V] using value_constant (parameterInputs r) nodes 12 (-1) 2 h12
  have v13 : V 13 = -(Real.sqrt 3/2) := by
    rw [show V 13 = -V 10 from value_neg _ _ _ _ h13 (by decide),v10]
  have v14 : V 14 = -Real.sqrt (1-r^2) := by
    rw [show V 14 = -V 5 from value_neg _ _ _ _ h14 (by decide),v5]
  have v15 : V 15 = -r/2 := by
    rw [show V 15 = V 0*V 12 from value_mul _ _ _ _ _ h15 (by decide) (by decide),v0,v12]
    ring
  have v16 : V 16 = r*(Real.sqrt 3/2) := by
    rw [show V 16 = V 0*V 10 from value_mul _ _ _ _ _ h16 (by decide) (by decide),v0,v10]
  have v17 : V 17 = -r*(Real.sqrt 3/2) := by
    rw [show V 17 = V 0*V 13 from value_mul _ _ _ _ _ h17 (by decide) (by decide),v0,v13]
    ring
  have v18 : V 18 = -1 := by
    simpa [V] using value_constant (parameterInputs r) nodes 18 (-1) 1 h18
  have v19 : V 19 = Real.sqrt 3/2 := by
    rw [show V 19 = -V 13 from value_neg _ _ _ _ h19 (by decide),v13,neg_neg]
  change V (pointIndices i a) = candidateAt r i a
  fin_cases i <;> fin_cases a <;>
    simp [pointIndices,candidateAt,vec,v0,v5,v9,v11,v13,v14,v15,v16,v17,v18,v19]

#print axioms coordinate_recipe_sound

end ThomsonN9.Certificates.IntervalCircuit
