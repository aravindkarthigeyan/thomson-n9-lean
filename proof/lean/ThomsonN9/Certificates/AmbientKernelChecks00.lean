import ThomsonN9.Certificates.AmbientKernelData
set_option maxRecDepth 200000
set_option maxHeartbeats 0
namespace ThomsonN9.Certificates.AmbientKernel
open IntervalCircuit
def checkChunk0 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (0+j)))
theorem checkChunk0_pass : checkChunk0 = true := by decide
#print axioms checkChunk0_pass
def checkChunk1 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (128+j)))
theorem checkChunk1_pass : checkChunk1 = true := by decide
#print axioms checkChunk1_pass
def checkChunk2 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (256+j)))
theorem checkChunk2_pass : checkChunk2 = true := by decide
#print axioms checkChunk2_pass
def checkChunk3 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (384+j)))
theorem checkChunk3_pass : checkChunk3 = true := by decide
#print axioms checkChunk3_pass
def checkChunk4 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (512+j)))
theorem checkChunk4_pass : checkChunk4 = true := by decide
#print axioms checkChunk4_pass
def checkChunk5 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (640+j)))
theorem checkChunk5_pass : checkChunk5 = true := by decide
#print axioms checkChunk5_pass
def checkChunk6 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (768+j)))
theorem checkChunk6_pass : checkChunk6 = true := by decide
#print axioms checkChunk6_pass
def checkChunk7 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (896+j)))
theorem checkChunk7_pass : checkChunk7 = true := by decide
#print axioms checkChunk7_pass
def checkChunk8 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1024+j)))
theorem checkChunk8_pass : checkChunk8 = true := by decide
#print axioms checkChunk8_pass
def checkChunk9 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1152+j)))
theorem checkChunk9_pass : checkChunk9 = true := by decide
#print axioms checkChunk9_pass
def checkChunk10 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1280+j)))
theorem checkChunk10_pass : checkChunk10 = true := by decide
#print axioms checkChunk10_pass
def checkChunk11 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1408+j)))
theorem checkChunk11_pass : checkChunk11 = true := by decide
#print axioms checkChunk11_pass
def checkChunk12 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1536+j)))
theorem checkChunk12_pass : checkChunk12 = true := by decide
#print axioms checkChunk12_pass
def checkChunk13 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1664+j)))
theorem checkChunk13_pass : checkChunk13 = true := by decide
#print axioms checkChunk13_pass
def checkChunk14 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1792+j)))
theorem checkChunk14_pass : checkChunk14 = true := by decide
#print axioms checkChunk14_pass
def checkChunk15 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (1920+j)))
theorem checkChunk15_pass : checkChunk15 = true := by decide
#print axioms checkChunk15_pass
def checkChunk16 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2048+j)))
theorem checkChunk16_pass : checkChunk16 = true := by decide
#print axioms checkChunk16_pass
def checkChunk17 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2176+j)))
theorem checkChunk17_pass : checkChunk17 = true := by decide
#print axioms checkChunk17_pass
def checkChunk18 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2304+j)))
theorem checkChunk18_pass : checkChunk18 = true := by decide
#print axioms checkChunk18_pass
def checkChunk19 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2432+j)))
theorem checkChunk19_pass : checkChunk19 = true := by decide
#print axioms checkChunk19_pass
def checkChunk20 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2560+j)))
theorem checkChunk20_pass : checkChunk20 = true := by decide
#print axioms checkChunk20_pass
def checkChunk21 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2688+j)))
theorem checkChunk21_pass : checkChunk21 = true := by decide
#print axioms checkChunk21_pass
def checkChunk22 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2816+j)))
theorem checkChunk22_pass : checkChunk22 = true := by decide
#print axioms checkChunk22_pass
def checkChunk23 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (2944+j)))
theorem checkChunk23_pass : checkChunk23 = true := by decide
#print axioms checkChunk23_pass
def checkChunk24 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3072+j)))
theorem checkChunk24_pass : checkChunk24 = true := by decide
#print axioms checkChunk24_pass
def checkChunk25 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3200+j)))
theorem checkChunk25_pass : checkChunk25 = true := by decide
#print axioms checkChunk25_pass
def checkChunk26 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3328+j)))
theorem checkChunk26_pass : checkChunk26 = true := by decide
#print axioms checkChunk26_pass
def checkChunk27 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3456+j)))
theorem checkChunk27_pass : checkChunk27 = true := by decide
#print axioms checkChunk27_pass
def checkChunk28 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3584+j)))
theorem checkChunk28_pass : checkChunk28 = true := by decide
#print axioms checkChunk28_pass
def checkChunk29 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3712+j)))
theorem checkChunk29_pass : checkChunk29 = true := by decide
#print axioms checkChunk29_pass
def checkChunk30 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3840+j)))
theorem checkChunk30_pass : checkChunk30 = true := by decide
#print axioms checkChunk30_pass
def checkChunk31 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (3968+j)))
theorem checkChunk31_pass : checkChunk31 = true := by decide
#print axioms checkChunk31_pass
def badNodes (i : ℕ) : Node := if i = 5 then
  ⟨.sqrt 4, ⟨0,0⟩⟩ else nodes i
def badChecks : Bool := (List.range 6).all
  (fun i => decide (Node.Check scale inputs badNodes i))
theorem bad_checks_rejected : badChecks = false := by decide
#print axioms bad_checks_rejected
end ThomsonN9.Certificates.AmbientKernel
