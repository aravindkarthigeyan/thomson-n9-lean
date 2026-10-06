import ClaudeWindow.WindowData
import ClaudeWindow.Antipodal

/-! Negative controls: the kernel-evaluated checker REJECTS corrupted certificates.
Each theorem proves `checkRec … = false` (or `antiCheck`-style `false`) by `decide +kernel`. -/

namespace ThomsonN9.Claude.Window

/-- M1: an actual node is omitted from the node list of anchor (1,2,4). -/
def mutDropNode : AnchorRec :=
  { rec28 with ext := rec28.ext.drop 1 }
theorem mut_drop_node : checkRec box thetaQ mutDropNode = false := by decide +kernel

/-- M2: the color of one retained edge of anchor (0,1,2) is changed. -/
def mutEdgeColor : AnchorRec :=
  { rec07 with edges := match rec07.edges with
      | e :: es => (e.1, e.2.1, (e.2.2 + 1) % 6) :: es
      | [] => [] }
theorem mut_edge_color : checkRec box thetaQ mutEdgeColor = false := by decide +kernel

/-- M3: one retained edge of anchor (4,4,4) is deleted. -/
def mutDropEdge : AnchorRec :=
  { rec52 with edges := rec52.edges.drop 1 }
theorem mut_drop_edge : checkRec box thetaQ mutDropEdge = false := by decide +kernel

/-- M4: a clique witness is corrupted (a node is sent to an anchor's label). -/
def mutWitness : AnchorRec :=
  { rec54 with cliques := rec54.cliques.map fun w =>
      { w with img := w.img.set (w.S.headD 0) w.anc.1 } }
theorem mut_witness : checkRec box thetaQ mutWitness = false := by decide +kernel

/-- M5: the clique list of anchor (2,2,3) is emptied. -/
def mutNoClique : AnchorRec := { rec37 with cliques := [] }
theorem mut_no_clique : checkRec box thetaQ mutNoClique = false := by decide +kernel

/-- M6: an eligible anchor (1,2,5) (determinant interval near 0.19) is declared ineligible. -/
def mutIneligible : AnchorRec := { rec29 with eligible := false }
theorem mut_ineligible : checkRec box thetaQ mutIneligible = false := by decide +kernel

/-- Positive control: the genuine record (1,2,5) passes. -/
theorem genuine_rec29 : checkRec box thetaQ rec29 = true := by decide +kernel

/-- M8: doubling the antipodal window width breaks the 49-case exclusion. -/
def antiCheckWide : Bool :=
  (List.range 7).all fun a => (List.range 7).all fun b =>
    decide ((Iv.sub (Iv.sub (Iv.mul (Iv.const 2) (Iv.mul ⟨0, 2 * epsQ⟩
      (Iv.add (Iv.const 1) (Iv.mul (box7 a) (box7 b))))) (Iv.sq ⟨0, 2 * epsQ⟩))
      (Iv.sq (Iv.add (box7 a) (box7 b)))).hi < 0)
theorem mut_anti_wide : antiCheckWide = false := by decide +kernel

end ThomsonN9.Claude.Window


