import ThomsonN9.Certificates.AmbientKernelData
set_option maxRecDepth 200000
set_option maxHeartbeats 0
namespace ThomsonN9.Certificates.AmbientKernel
open IntervalCircuit
def checkChunk64 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (8192+j)))
theorem checkChunk64_pass : checkChunk64 = true := by decide
#print axioms checkChunk64_pass
def checkChunk65 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (8320+j)))
theorem checkChunk65_pass : checkChunk65 = true := by decide
#print axioms checkChunk65_pass
def checkChunk66 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (8448+j)))
theorem checkChunk66_pass : checkChunk66 = true := by decide
#print axioms checkChunk66_pass
def checkChunk67 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (8576+j)))
theorem checkChunk67_pass : checkChunk67 = true := by decide
#print axioms checkChunk67_pass
def checkChunk68 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (8704+j)))
theorem checkChunk68_pass : checkChunk68 = true := by decide
#print axioms checkChunk68_pass
def checkChunk69 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (8832+j)))
theorem checkChunk69_pass : checkChunk69 = true := by decide
#print axioms checkChunk69_pass
def checkChunk70 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (8960+j)))
theorem checkChunk70_pass : checkChunk70 = true := by decide
#print axioms checkChunk70_pass
def checkChunk71 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9088+j)))
theorem checkChunk71_pass : checkChunk71 = true := by decide
#print axioms checkChunk71_pass
def checkChunk72 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9216+j)))
theorem checkChunk72_pass : checkChunk72 = true := by decide
#print axioms checkChunk72_pass
def checkChunk73 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9344+j)))
theorem checkChunk73_pass : checkChunk73 = true := by decide
#print axioms checkChunk73_pass
def checkChunk74 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9472+j)))
theorem checkChunk74_pass : checkChunk74 = true := by decide
#print axioms checkChunk74_pass
def checkChunk75 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9600+j)))
theorem checkChunk75_pass : checkChunk75 = true := by decide
#print axioms checkChunk75_pass
def checkChunk76 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9728+j)))
theorem checkChunk76_pass : checkChunk76 = true := by decide
#print axioms checkChunk76_pass
def checkChunk77 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9856+j)))
theorem checkChunk77_pass : checkChunk77 = true := by decide
#print axioms checkChunk77_pass
def checkChunk78 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (9984+j)))
theorem checkChunk78_pass : checkChunk78 = true := by decide
#print axioms checkChunk78_pass
def checkChunk79 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (10112+j)))
theorem checkChunk79_pass : checkChunk79 = true := by decide
#print axioms checkChunk79_pass
def checkChunk80 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (10240+j)))
theorem checkChunk80_pass : checkChunk80 = true := by decide
#print axioms checkChunk80_pass
def checkChunk81 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (10368+j)))
theorem checkChunk81_pass : checkChunk81 = true := by decide
#print axioms checkChunk81_pass
def checkChunk82 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (10496+j)))
theorem checkChunk82_pass : checkChunk82 = true := by decide
#print axioms checkChunk82_pass
def checkChunk83 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (10624+j)))
theorem checkChunk83_pass : checkChunk83 = true := by decide
#print axioms checkChunk83_pass
def checkChunk84 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (10752+j)))
theorem checkChunk84_pass : checkChunk84 = true := by decide
#print axioms checkChunk84_pass
def checkChunk85 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (10880+j)))
theorem checkChunk85_pass : checkChunk85 = true := by decide
#print axioms checkChunk85_pass
def checkChunk86 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11008+j)))
theorem checkChunk86_pass : checkChunk86 = true := by decide
#print axioms checkChunk86_pass
def checkChunk87 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11136+j)))
theorem checkChunk87_pass : checkChunk87 = true := by decide
#print axioms checkChunk87_pass
def checkChunk88 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11264+j)))
theorem checkChunk88_pass : checkChunk88 = true := by decide
#print axioms checkChunk88_pass
def checkChunk89 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11392+j)))
theorem checkChunk89_pass : checkChunk89 = true := by decide
#print axioms checkChunk89_pass
def checkChunk90 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11520+j)))
theorem checkChunk90_pass : checkChunk90 = true := by decide
#print axioms checkChunk90_pass
def checkChunk91 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11648+j)))
theorem checkChunk91_pass : checkChunk91 = true := by decide
#print axioms checkChunk91_pass
def checkChunk92 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11776+j)))
theorem checkChunk92_pass : checkChunk92 = true := by decide
#print axioms checkChunk92_pass
def checkChunk93 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (11904+j)))
theorem checkChunk93_pass : checkChunk93 = true := by decide
#print axioms checkChunk93_pass
def checkChunk94 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (12032+j)))
theorem checkChunk94_pass : checkChunk94 = true := by decide
#print axioms checkChunk94_pass
def checkChunk95 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (12160+j)))
theorem checkChunk95_pass : checkChunk95 = true := by decide
#print axioms checkChunk95_pass
end ThomsonN9.Certificates.AmbientKernel
