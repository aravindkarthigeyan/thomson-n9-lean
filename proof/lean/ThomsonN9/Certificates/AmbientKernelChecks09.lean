import ThomsonN9.Certificates.AmbientKernelData
set_option maxRecDepth 200000
set_option maxHeartbeats 0
namespace ThomsonN9.Certificates.AmbientKernel
open IntervalCircuit
def checkChunk288 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (36864+j)))
theorem checkChunk288_pass : checkChunk288 = true := by decide
#print axioms checkChunk288_pass
def checkChunk289 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (36992+j)))
theorem checkChunk289_pass : checkChunk289 = true := by decide
#print axioms checkChunk289_pass
def checkChunk290 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (37120+j)))
theorem checkChunk290_pass : checkChunk290 = true := by decide
#print axioms checkChunk290_pass
def checkChunk291 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (37248+j)))
theorem checkChunk291_pass : checkChunk291 = true := by decide
#print axioms checkChunk291_pass
def checkChunk292 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (37376+j)))
theorem checkChunk292_pass : checkChunk292 = true := by decide
#print axioms checkChunk292_pass
def checkChunk293 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (37504+j)))
theorem checkChunk293_pass : checkChunk293 = true := by decide
#print axioms checkChunk293_pass
def checkChunk294 : Bool := (List.range 128).all
  (fun j => decide (Node.Check scale inputs nodes (37632+j)))
theorem checkChunk294_pass : checkChunk294 = true := by decide
#print axioms checkChunk294_pass
def checkChunk295 : Bool := (List.range 55).all
  (fun j => decide (Node.Check scale inputs nodes (37760+j)))
theorem checkChunk295_pass : checkChunk295 = true := by decide
#print axioms checkChunk295_pass
end ThomsonN9.Certificates.AmbientKernel
