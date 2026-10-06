import ThomsonN9.Certificates.AmbientKernelData
import ThomsonN9.Certificates.CircuitRadial
import ThomsonN9.Certificates.CircuitMatrices
set_option maxRecDepth 200000
set_option maxHeartbeats 0
namespace ThomsonN9.Certificates.AmbientKernel
open IntervalCircuit
-- Witness JSON SHA256: 1bb60db24b796f7ef84c89f11cc042fd9c67bae1ebd2b29dc0b2b046b99d4e3e
def pairBlock_1_0 : PairBlockRecipe where
  distance := {
    difference := ![21,16,22]
    squares := {
      left := fun i => #[21,16,22][i]?.getD 0
      right := fun i => #[21,16,22][i]?.getD 0
      product := fun i => #[23,24,26][i]?.getD 0
      accumulator := fun i => #[11,23,25,27][i]?.getD 0 }
    root := 28
    inverse := 29 }
  powers := { base := 29, accumulator := fun i => #[2,29,30,31,32,33][i]?.getD 0 }
  three := 6
  scaledFifth := 34
  timesFirst := ![35,44,52]
  numerator := ![![36,40,42],![45,47,50],![53,55,57]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![31,11,11],![11,31,11],![11,11,31]]
  negativeDiagonal := ![![37,11,11],![11,37,11],![11,11,37]]
  block := ![![38,40,42],![45,48,50],![53,55,58]]
theorem pairBlock_1_0_check : pairBlock_1_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_1_0_check
def difference_1_0 : DifferenceRecipe where
  left := ![15,16,5]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![21,16,22]
theorem difference_1_0_check : difference_1_0.Check nodes := by decide
def halfInverse_1_0 : HalfInverseRecipe where
  distance := pairBlock_1_0.distance
  two := 8
  twice := 60
  inverse := 61
  negative := 62
theorem halfInverse_1_0_check : halfInverse_1_0.Check nodes := by
  constructor
  · exact pairBlock_1_0_check.distance
  all_goals decide
def pairBlock_2_0 : PairBlockRecipe where
  distance := {
    difference := ![21,17,22]
    squares := {
      left := fun i => #[21,17,22][i]?.getD 0
      right := fun i => #[21,17,22][i]?.getD 0
      product := fun i => #[23,63,26][i]?.getD 0
      accumulator := fun i => #[11,23,64,65][i]?.getD 0 }
    root := 66
    inverse := 67 }
  powers := { base := 67, accumulator := fun i => #[2,67,68,69,70,71][i]?.getD 0 }
  three := 6
  scaledFifth := 72
  timesFirst := ![73,85,96]
  numerator := ![![74,79,82],![86,89,93],![97,100,103]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![69,11,11],![11,69,11],![11,11,69]]
  negativeDiagonal := ![![75,11,11],![11,75,11],![11,11,75]]
  block := ![![76,79,82],![86,90,93],![97,100,104]]
theorem pairBlock_2_0_check : pairBlock_2_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_2_0_check
def difference_2_0 : DifferenceRecipe where
  left := ![15,17,5]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![21,17,22]
theorem difference_2_0_check : difference_2_0.Check nodes := by decide
def halfInverse_2_0 : HalfInverseRecipe where
  distance := pairBlock_2_0.distance
  two := 8
  twice := 107
  inverse := 108
  negative := 109
theorem halfInverse_2_0_check : halfInverse_2_0.Check nodes := by
  constructor
  · exact pairBlock_2_0_check.distance
  all_goals decide
def pairBlock_2_1 : PairBlockRecipe where
  distance := {
    difference := ![112,114,22]
    squares := {
      left := fun i => #[112,114,22][i]?.getD 0
      right := fun i => #[112,114,22][i]?.getD 0
      product := fun i => #[115,116,26][i]?.getD 0
      accumulator := fun i => #[11,115,117,118][i]?.getD 0 }
    root := 119
    inverse := 120 }
  powers := { base := 120, accumulator := fun i => #[2,120,121,122,123,124][i]?.getD 0 }
  three := 6
  scaledFifth := 125
  timesFirst := ![126,141,155]
  numerator := ![![127,133,137],![142,146,151],![156,160,164]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![122,11,11],![11,122,11],![11,11,122]]
  negativeDiagonal := ![![128,11,11],![11,128,11],![11,11,128]]
  block := ![![129,133,137],![142,147,151],![156,160,165]]
theorem pairBlock_2_1_check : pairBlock_2_1.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_2_1_check
def difference_2_1 : DifferenceRecipe where
  left := ![15,17,5]
  right := ![15,16,5]
  negative := ![111,113,14]
  output := ![112,114,22]
theorem difference_2_1_check : difference_2_1.Check nodes := by decide
def halfInverse_2_1 : HalfInverseRecipe where
  distance := pairBlock_2_1.distance
  two := 8
  twice := 169
  inverse := 170
  negative := 171
theorem halfInverse_2_1_check : halfInverse_2_1.Check nodes := by
  constructor
  · exact pairBlock_2_1_check.distance
  all_goals decide
def pairBlock_3_0 : PairBlockRecipe where
  distance := {
    difference := ![174,11,175]
    squares := {
      left := fun i => #[174,11,175][i]?.getD 0
      right := fun i => #[174,11,175][i]?.getD 0
      product := fun i => #[176,11,177][i]?.getD 0
      accumulator := fun i => #[11,176,176,178][i]?.getD 0 }
    root := 179
    inverse := 180 }
  powers := { base := 180, accumulator := fun i => #[2,180,181,182,183,184][i]?.getD 0 }
  three := 6
  scaledFifth := 185
  timesFirst := ![186,11,197]
  numerator := ![![187,11,192],![11,11,11],![198,11,201]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![182,11,11],![11,182,11],![11,11,182]]
  negativeDiagonal := ![![188,11,11],![11,188,11],![11,11,188]]
  block := ![![189,11,192],![11,188,11],![198,11,202]]
theorem pairBlock_3_0_check : pairBlock_3_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_3_0_check
def difference_3_0 : DifferenceRecipe where
  left := ![0,11,14]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![174,11,175]
theorem difference_3_0_check : difference_3_0.Check nodes := by decide
def halfInverse_3_0 : HalfInverseRecipe where
  distance := pairBlock_3_0.distance
  two := 8
  twice := 205
  inverse := 206
  negative := 207
theorem halfInverse_3_0_check : halfInverse_3_0.Check nodes := by
  constructor
  · exact pairBlock_3_0_check.distance
  all_goals decide
def pairBlock_3_1 : PairBlockRecipe where
  distance := {
    difference := ![209,113,175]
    squares := {
      left := fun i => #[209,113,175][i]?.getD 0
      right := fun i => #[209,113,175][i]?.getD 0
      product := fun i => #[210,211,177][i]?.getD 0
      accumulator := fun i => #[11,210,212,213][i]?.getD 0 }
    root := 214
    inverse := 215 }
  powers := { base := 215, accumulator := fun i => #[2,215,216,217,218,219][i]?.getD 0 }
  three := 6
  scaledFifth := 220
  timesFirst := ![221,235,247]
  numerator := ![![222,228,231],![236,239,244],![248,252,255]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![217,11,11],![11,217,11],![11,11,217]]
  negativeDiagonal := ![![223,11,11],![11,223,11],![11,11,223]]
  block := ![![224,228,231],![236,240,244],![248,252,256]]
theorem pairBlock_3_1_check : pairBlock_3_1.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_3_1_check
def difference_3_1 : DifferenceRecipe where
  left := ![0,11,14]
  right := ![15,16,5]
  negative := ![111,113,14]
  output := ![209,113,175]
theorem difference_3_1_check : difference_3_1.Check nodes := by decide
def halfInverse_3_1 : HalfInverseRecipe where
  distance := pairBlock_3_1.distance
  two := 8
  twice := 260
  inverse := 261
  negative := 262
theorem halfInverse_3_1_check : halfInverse_3_1.Check nodes := by
  constructor
  · exact pairBlock_3_1_check.distance
  all_goals decide
def pairBlock_3_2 : PairBlockRecipe where
  distance := {
    difference := ![209,265,175]
    squares := {
      left := fun i => #[209,265,175][i]?.getD 0
      right := fun i => #[209,265,175][i]?.getD 0
      product := fun i => #[210,266,177][i]?.getD 0
      accumulator := fun i => #[11,210,267,268][i]?.getD 0 }
    root := 269
    inverse := 270 }
  powers := { base := 270, accumulator := fun i => #[2,270,271,272,273,274][i]?.getD 0 }
  three := 6
  scaledFifth := 275
  timesFirst := ![276,291,305]
  numerator := ![![277,283,287],![292,296,301],![306,310,314]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![272,11,11],![11,272,11],![11,11,272]]
  negativeDiagonal := ![![278,11,11],![11,278,11],![11,11,278]]
  block := ![![279,283,287],![292,297,301],![306,310,315]]
theorem pairBlock_3_2_check : pairBlock_3_2.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_3_2_check
def difference_3_2 : DifferenceRecipe where
  left := ![0,11,14]
  right := ![15,17,5]
  negative := ![111,265,14]
  output := ![209,265,175]
theorem difference_3_2_check : difference_3_2.Check nodes := by decide
def halfInverse_3_2 : HalfInverseRecipe where
  distance := pairBlock_3_2.distance
  two := 8
  twice := 319
  inverse := 320
  negative := 321
theorem halfInverse_3_2_check : halfInverse_3_2.Check nodes := by
  constructor
  · exact pairBlock_3_2_check.distance
  all_goals decide
def pairBlock_4_0 : PairBlockRecipe where
  distance := {
    difference := ![21,16,175]
    squares := {
      left := fun i => #[21,16,175][i]?.getD 0
      right := fun i => #[21,16,175][i]?.getD 0
      product := fun i => #[23,24,177][i]?.getD 0
      accumulator := fun i => #[11,23,25,324][i]?.getD 0 }
    root := 325
    inverse := 326 }
  powers := { base := 326, accumulator := fun i => #[2,326,327,328,329,330][i]?.getD 0 }
  three := 6
  scaledFifth := 331
  timesFirst := ![332,344,355]
  numerator := ![![333,338,341],![345,348,352],![356,359,362]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![328,11,11],![11,328,11],![11,11,328]]
  negativeDiagonal := ![![334,11,11],![11,334,11],![11,11,334]]
  block := ![![335,338,341],![345,349,352],![356,359,363]]
theorem pairBlock_4_0_check : pairBlock_4_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_4_0_check
def difference_4_0 : DifferenceRecipe where
  left := ![15,16,14]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![21,16,175]
theorem difference_4_0_check : difference_4_0.Check nodes := by decide
def halfInverse_4_0 : HalfInverseRecipe where
  distance := pairBlock_4_0.distance
  two := 8
  twice := 366
  inverse := 367
  negative := 368
theorem halfInverse_4_0_check : halfInverse_4_0.Check nodes := by
  constructor
  · exact pairBlock_4_0_check.distance
  all_goals decide
def pairBlock_4_1 : PairBlockRecipe where
  distance := {
    difference := ![112,370,175]
    squares := {
      left := fun i => #[112,370,175][i]?.getD 0
      right := fun i => #[112,370,175][i]?.getD 0
      product := fun i => #[115,371,177][i]?.getD 0
      accumulator := fun i => #[11,115,372,373][i]?.getD 0 }
    root := 374
    inverse := 375 }
  powers := { base := 375, accumulator := fun i => #[2,375,376,377,378,379][i]?.getD 0 }
  three := 6
  scaledFifth := 380
  timesFirst := ![381,396,410]
  numerator := ![![382,388,392],![397,401,406],![411,415,419]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![377,11,11],![11,377,11],![11,11,377]]
  negativeDiagonal := ![![383,11,11],![11,383,11],![11,11,383]]
  block := ![![384,388,392],![397,402,406],![411,415,420]]
theorem pairBlock_4_1_check : pairBlock_4_1.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_4_1_check
def difference_4_1 : DifferenceRecipe where
  left := ![15,16,14]
  right := ![15,16,5]
  negative := ![111,113,14]
  output := ![112,370,175]
theorem difference_4_1_check : difference_4_1.Check nodes := by decide
def halfInverse_4_1 : HalfInverseRecipe where
  distance := pairBlock_4_1.distance
  two := 8
  twice := 424
  inverse := 425
  negative := 426
theorem halfInverse_4_1_check : halfInverse_4_1.Check nodes := by
  constructor
  · exact pairBlock_4_1_check.distance
  all_goals decide
def pairBlock_4_2 : PairBlockRecipe where
  distance := {
    difference := ![112,429,175]
    squares := {
      left := fun i => #[112,429,175][i]?.getD 0
      right := fun i => #[112,429,175][i]?.getD 0
      product := fun i => #[115,430,177][i]?.getD 0
      accumulator := fun i => #[11,115,431,432][i]?.getD 0 }
    root := 433
    inverse := 434 }
  powers := { base := 434, accumulator := fun i => #[2,434,435,436,437,438][i]?.getD 0 }
  three := 6
  scaledFifth := 439
  timesFirst := ![440,455,469]
  numerator := ![![441,447,451],![456,460,465],![470,474,478]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![436,11,11],![11,436,11],![11,11,436]]
  negativeDiagonal := ![![442,11,11],![11,442,11],![11,11,442]]
  block := ![![443,447,451],![456,461,465],![470,474,479]]
theorem pairBlock_4_2_check : pairBlock_4_2.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_4_2_check
def difference_4_2 : DifferenceRecipe where
  left := ![15,16,14]
  right := ![15,17,5]
  negative := ![111,265,14]
  output := ![112,429,175]
theorem difference_4_2_check : difference_4_2.Check nodes := by decide
def halfInverse_4_2 : HalfInverseRecipe where
  distance := pairBlock_4_2.distance
  two := 8
  twice := 483
  inverse := 484
  negative := 485
theorem halfInverse_4_2_check : halfInverse_4_2.Check nodes := by
  constructor
  · exact pairBlock_4_2_check.distance
  all_goals decide
def pairBlock_4_3 : PairBlockRecipe where
  distance := {
    difference := ![21,16,489]
    squares := {
      left := fun i => #[21,16,489][i]?.getD 0
      right := fun i => #[21,16,489][i]?.getD 0
      product := fun i => #[23,24,490][i]?.getD 0
      accumulator := fun i => #[11,23,25,491][i]?.getD 0 }
    root := 492
    inverse := 493 }
  powers := { base := 493, accumulator := fun i => #[2,493,494,495,496,497][i]?.getD 0 }
  three := 6
  scaledFifth := 498
  timesFirst := ![499,514,528]
  numerator := ![![500,506,510],![515,519,524],![529,533,537]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![495,11,11],![11,495,11],![11,11,495]]
  negativeDiagonal := ![![501,11,11],![11,501,11],![11,11,501]]
  block := ![![502,506,510],![515,520,524],![529,533,538]]
theorem pairBlock_4_3_check : pairBlock_4_3.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_4_3_check
def difference_4_3 : DifferenceRecipe where
  left := ![15,16,14]
  right := ![0,11,14]
  negative := ![20,11,488]
  output := ![21,16,489]
theorem difference_4_3_check : difference_4_3.Check nodes := by decide
def halfInverse_4_3 : HalfInverseRecipe where
  distance := pairBlock_4_3.distance
  two := 8
  twice := 542
  inverse := 543
  negative := 544
theorem halfInverse_4_3_check : halfInverse_4_3.Check nodes := by
  constructor
  · exact pairBlock_4_3_check.distance
  all_goals decide
def pairBlock_5_0 : PairBlockRecipe where
  distance := {
    difference := ![21,17,175]
    squares := {
      left := fun i => #[21,17,175][i]?.getD 0
      right := fun i => #[21,17,175][i]?.getD 0
      product := fun i => #[23,63,177][i]?.getD 0
      accumulator := fun i => #[11,23,64,547][i]?.getD 0 }
    root := 548
    inverse := 549 }
  powers := { base := 549, accumulator := fun i => #[2,549,550,551,552,553][i]?.getD 0 }
  three := 6
  scaledFifth := 554
  timesFirst := ![555,567,578]
  numerator := ![![556,561,564],![568,571,575],![579,582,585]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![551,11,11],![11,551,11],![11,11,551]]
  negativeDiagonal := ![![557,11,11],![11,557,11],![11,11,557]]
  block := ![![558,561,564],![568,572,575],![579,582,586]]
theorem pairBlock_5_0_check : pairBlock_5_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_5_0_check
def difference_5_0 : DifferenceRecipe where
  left := ![15,17,14]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![21,17,175]
theorem difference_5_0_check : difference_5_0.Check nodes := by decide
def halfInverse_5_0 : HalfInverseRecipe where
  distance := pairBlock_5_0.distance
  two := 8
  twice := 589
  inverse := 590
  negative := 591
theorem halfInverse_5_0_check : halfInverse_5_0.Check nodes := by
  constructor
  · exact pairBlock_5_0_check.distance
  all_goals decide
def pairBlock_5_1 : PairBlockRecipe where
  distance := {
    difference := ![112,114,175]
    squares := {
      left := fun i => #[112,114,175][i]?.getD 0
      right := fun i => #[112,114,175][i]?.getD 0
      product := fun i => #[115,116,177][i]?.getD 0
      accumulator := fun i => #[11,115,117,593][i]?.getD 0 }
    root := 594
    inverse := 595 }
  powers := { base := 595, accumulator := fun i => #[2,595,596,597,598,599][i]?.getD 0 }
  three := 6
  scaledFifth := 600
  timesFirst := ![601,616,630]
  numerator := ![![602,608,612],![617,621,626],![631,635,639]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![597,11,11],![11,597,11],![11,11,597]]
  negativeDiagonal := ![![603,11,11],![11,603,11],![11,11,603]]
  block := ![![604,608,612],![617,622,626],![631,635,640]]
theorem pairBlock_5_1_check : pairBlock_5_1.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_5_1_check
def difference_5_1 : DifferenceRecipe where
  left := ![15,17,14]
  right := ![15,16,5]
  negative := ![111,113,14]
  output := ![112,114,175]
theorem difference_5_1_check : difference_5_1.Check nodes := by decide
def halfInverse_5_1 : HalfInverseRecipe where
  distance := pairBlock_5_1.distance
  two := 8
  twice := 644
  inverse := 645
  negative := 646
theorem halfInverse_5_1_check : halfInverse_5_1.Check nodes := by
  constructor
  · exact pairBlock_5_1_check.distance
  all_goals decide
def pairBlock_5_2 : PairBlockRecipe where
  distance := {
    difference := ![112,649,175]
    squares := {
      left := fun i => #[112,649,175][i]?.getD 0
      right := fun i => #[112,649,175][i]?.getD 0
      product := fun i => #[115,650,177][i]?.getD 0
      accumulator := fun i => #[11,115,651,652][i]?.getD 0 }
    root := 653
    inverse := 654 }
  powers := { base := 654, accumulator := fun i => #[2,654,655,656,657,658][i]?.getD 0 }
  three := 6
  scaledFifth := 659
  timesFirst := ![660,675,689]
  numerator := ![![661,667,671],![676,680,685],![690,694,698]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![656,11,11],![11,656,11],![11,11,656]]
  negativeDiagonal := ![![662,11,11],![11,662,11],![11,11,662]]
  block := ![![663,667,671],![676,681,685],![690,694,699]]
theorem pairBlock_5_2_check : pairBlock_5_2.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_5_2_check
def difference_5_2 : DifferenceRecipe where
  left := ![15,17,14]
  right := ![15,17,5]
  negative := ![111,265,14]
  output := ![112,649,175]
theorem difference_5_2_check : difference_5_2.Check nodes := by decide
def halfInverse_5_2 : HalfInverseRecipe where
  distance := pairBlock_5_2.distance
  two := 8
  twice := 703
  inverse := 704
  negative := 705
theorem halfInverse_5_2_check : halfInverse_5_2.Check nodes := by
  constructor
  · exact pairBlock_5_2_check.distance
  all_goals decide
def pairBlock_5_3 : PairBlockRecipe where
  distance := {
    difference := ![21,17,489]
    squares := {
      left := fun i => #[21,17,489][i]?.getD 0
      right := fun i => #[21,17,489][i]?.getD 0
      product := fun i => #[23,63,490][i]?.getD 0
      accumulator := fun i => #[11,23,64,708][i]?.getD 0 }
    root := 709
    inverse := 710 }
  powers := { base := 710, accumulator := fun i => #[2,710,711,712,713,714][i]?.getD 0 }
  three := 6
  scaledFifth := 715
  timesFirst := ![716,731,745]
  numerator := ![![717,723,727],![732,736,741],![746,750,754]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![712,11,11],![11,712,11],![11,11,712]]
  negativeDiagonal := ![![718,11,11],![11,718,11],![11,11,718]]
  block := ![![719,723,727],![732,737,741],![746,750,755]]
theorem pairBlock_5_3_check : pairBlock_5_3.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_5_3_check
def difference_5_3 : DifferenceRecipe where
  left := ![15,17,14]
  right := ![0,11,14]
  negative := ![20,11,488]
  output := ![21,17,489]
theorem difference_5_3_check : difference_5_3.Check nodes := by decide
def halfInverse_5_3 : HalfInverseRecipe where
  distance := pairBlock_5_3.distance
  two := 8
  twice := 759
  inverse := 760
  negative := 761
theorem halfInverse_5_3_check : halfInverse_5_3.Check nodes := by
  constructor
  · exact pairBlock_5_3_check.distance
  all_goals decide
def pairBlock_5_4 : PairBlockRecipe where
  distance := {
    difference := ![112,114,489]
    squares := {
      left := fun i => #[112,114,489][i]?.getD 0
      right := fun i => #[112,114,489][i]?.getD 0
      product := fun i => #[115,116,490][i]?.getD 0
      accumulator := fun i => #[11,115,117,764][i]?.getD 0 }
    root := 765
    inverse := 766 }
  powers := { base := 766, accumulator := fun i => #[2,766,767,768,769,770][i]?.getD 0 }
  three := 6
  scaledFifth := 771
  timesFirst := ![772,787,801]
  numerator := ![![773,779,783],![788,792,797],![802,806,810]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![768,11,11],![11,768,11],![11,11,768]]
  negativeDiagonal := ![![774,11,11],![11,774,11],![11,11,774]]
  block := ![![775,779,783],![788,793,797],![802,806,811]]
theorem pairBlock_5_4_check : pairBlock_5_4.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_5_4_check
def difference_5_4 : DifferenceRecipe where
  left := ![15,17,14]
  right := ![15,16,14]
  negative := ![111,113,488]
  output := ![112,114,489]
theorem difference_5_4_check : difference_5_4.Check nodes := by decide
def halfInverse_5_4 : HalfInverseRecipe where
  distance := pairBlock_5_4.distance
  two := 8
  twice := 815
  inverse := 816
  negative := 817
theorem halfInverse_5_4_check : halfInverse_5_4.Check nodes := by
  constructor
  · exact pairBlock_5_4_check.distance
  all_goals decide
def pairBlock_6_0 : PairBlockRecipe where
  distance := {
    difference := ![820,11,14]
    squares := {
      left := fun i => #[820,11,14][i]?.getD 0
      right := fun i => #[820,11,14][i]?.getD 0
      product := fun i => #[821,11,822][i]?.getD 0
      accumulator := fun i => #[11,821,821,823][i]?.getD 0 }
    root := 824
    inverse := 825 }
  powers := { base := 825, accumulator := fun i => #[2,825,826,827,828,829][i]?.getD 0 }
  three := 6
  scaledFifth := 830
  timesFirst := ![831,11,842]
  numerator := ![![832,11,837],![11,11,11],![843,11,846]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![827,11,11],![11,827,11],![11,11,827]]
  negativeDiagonal := ![![833,11,11],![11,833,11],![11,11,833]]
  block := ![![834,11,837],![11,833,11],![843,11,847]]
theorem pairBlock_6_0_check : pairBlock_6_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_6_0_check
def difference_6_0 : DifferenceRecipe where
  left := ![18,11,11]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![820,11,14]
theorem difference_6_0_check : difference_6_0.Check nodes := by decide
def halfInverse_6_0 : HalfInverseRecipe where
  distance := pairBlock_6_0.distance
  two := 8
  twice := 850
  inverse := 851
  negative := 852
theorem halfInverse_6_0_check : halfInverse_6_0.Check nodes := by
  constructor
  · exact pairBlock_6_0_check.distance
  all_goals decide
def pairBlock_6_1 : PairBlockRecipe where
  distance := {
    difference := ![854,113,14]
    squares := {
      left := fun i => #[854,113,14][i]?.getD 0
      right := fun i => #[854,113,14][i]?.getD 0
      product := fun i => #[855,211,822][i]?.getD 0
      accumulator := fun i => #[11,855,856,857][i]?.getD 0 }
    root := 858
    inverse := 859 }
  powers := { base := 859, accumulator := fun i => #[2,859,860,861,862,863][i]?.getD 0 }
  three := 6
  scaledFifth := 864
  timesFirst := ![865,879,891]
  numerator := ![![866,872,875],![880,883,888],![892,896,899]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![861,11,11],![11,861,11],![11,11,861]]
  negativeDiagonal := ![![867,11,11],![11,867,11],![11,11,867]]
  block := ![![868,872,875],![880,884,888],![892,896,900]]
theorem pairBlock_6_1_check : pairBlock_6_1.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_6_1_check
def difference_6_1 : DifferenceRecipe where
  left := ![18,11,11]
  right := ![15,16,5]
  negative := ![111,113,14]
  output := ![854,113,14]
theorem difference_6_1_check : difference_6_1.Check nodes := by decide
def halfInverse_6_1 : HalfInverseRecipe where
  distance := pairBlock_6_1.distance
  two := 8
  twice := 904
  inverse := 905
  negative := 906
theorem halfInverse_6_1_check : halfInverse_6_1.Check nodes := by
  constructor
  · exact pairBlock_6_1_check.distance
  all_goals decide
def pairBlock_6_2 : PairBlockRecipe where
  distance := {
    difference := ![854,265,14]
    squares := {
      left := fun i => #[854,265,14][i]?.getD 0
      right := fun i => #[854,265,14][i]?.getD 0
      product := fun i => #[855,266,822][i]?.getD 0
      accumulator := fun i => #[11,855,909,910][i]?.getD 0 }
    root := 911
    inverse := 912 }
  powers := { base := 912, accumulator := fun i => #[2,912,913,914,915,916][i]?.getD 0 }
  three := 6
  scaledFifth := 917
  timesFirst := ![918,933,947]
  numerator := ![![919,925,929],![934,938,943],![948,952,956]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![914,11,11],![11,914,11],![11,11,914]]
  negativeDiagonal := ![![920,11,11],![11,920,11],![11,11,920]]
  block := ![![921,925,929],![934,939,943],![948,952,957]]
theorem pairBlock_6_2_check : pairBlock_6_2.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_6_2_check
def difference_6_2 : DifferenceRecipe where
  left := ![18,11,11]
  right := ![15,17,5]
  negative := ![111,265,14]
  output := ![854,265,14]
theorem difference_6_2_check : difference_6_2.Check nodes := by decide
def halfInverse_6_2 : HalfInverseRecipe where
  distance := pairBlock_6_2.distance
  two := 8
  twice := 961
  inverse := 962
  negative := 963
theorem halfInverse_6_2_check : halfInverse_6_2.Check nodes := by
  constructor
  · exact pairBlock_6_2_check.distance
  all_goals decide
def pairBlock_6_3 : PairBlockRecipe where
  distance := {
    difference := ![820,11,488]
    squares := {
      left := fun i => #[820,11,488][i]?.getD 0
      right := fun i => #[820,11,488][i]?.getD 0
      product := fun i => #[821,11,966][i]?.getD 0
      accumulator := fun i => #[11,821,821,967][i]?.getD 0 }
    root := 968
    inverse := 969 }
  powers := { base := 969, accumulator := fun i => #[2,969,970,971,972,973][i]?.getD 0 }
  three := 6
  scaledFifth := 974
  timesFirst := ![975,11,989]
  numerator := ![![976,11,982],![11,11,11],![990,11,994]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![971,11,11],![11,971,11],![11,11,971]]
  negativeDiagonal := ![![977,11,11],![11,977,11],![11,11,977]]
  block := ![![978,11,982],![11,977,11],![990,11,995]]
theorem pairBlock_6_3_check : pairBlock_6_3.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_6_3_check
def difference_6_3 : DifferenceRecipe where
  left := ![18,11,11]
  right := ![0,11,14]
  negative := ![20,11,488]
  output := ![820,11,488]
theorem difference_6_3_check : difference_6_3.Check nodes := by decide
def halfInverse_6_3 : HalfInverseRecipe where
  distance := pairBlock_6_3.distance
  two := 8
  twice := 999
  inverse := 1000
  negative := 1001
theorem halfInverse_6_3_check : halfInverse_6_3.Check nodes := by
  constructor
  · exact pairBlock_6_3_check.distance
  all_goals decide
def pairBlock_6_4 : PairBlockRecipe where
  distance := {
    difference := ![854,113,488]
    squares := {
      left := fun i => #[854,113,488][i]?.getD 0
      right := fun i => #[854,113,488][i]?.getD 0
      product := fun i => #[855,211,966][i]?.getD 0
      accumulator := fun i => #[11,855,856,1004][i]?.getD 0 }
    root := 1005
    inverse := 1006 }
  powers := { base := 1006, accumulator := fun i => #[2,1006,1007,1008,1009,1010][i]?.getD 0 }
  three := 6
  scaledFifth := 1011
  timesFirst := ![1012,1027,1041]
  numerator := ![![1013,1019,1023],![1028,1032,1037],![1042,1046,1050]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1008,11,11],![11,1008,11],![11,11,1008]]
  negativeDiagonal := ![![1014,11,11],![11,1014,11],![11,11,1014]]
  block := ![![1015,1019,1023],![1028,1033,1037],![1042,1046,1051]]
theorem pairBlock_6_4_check : pairBlock_6_4.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_6_4_check
def difference_6_4 : DifferenceRecipe where
  left := ![18,11,11]
  right := ![15,16,14]
  negative := ![111,113,488]
  output := ![854,113,488]
theorem difference_6_4_check : difference_6_4.Check nodes := by decide
def halfInverse_6_4 : HalfInverseRecipe where
  distance := pairBlock_6_4.distance
  two := 8
  twice := 1055
  inverse := 1056
  negative := 1057
theorem halfInverse_6_4_check : halfInverse_6_4.Check nodes := by
  constructor
  · exact pairBlock_6_4_check.distance
  all_goals decide
def pairBlock_6_5 : PairBlockRecipe where
  distance := {
    difference := ![854,265,488]
    squares := {
      left := fun i => #[854,265,488][i]?.getD 0
      right := fun i => #[854,265,488][i]?.getD 0
      product := fun i => #[855,266,966][i]?.getD 0
      accumulator := fun i => #[11,855,909,1060][i]?.getD 0 }
    root := 1061
    inverse := 1062 }
  powers := { base := 1062, accumulator := fun i => #[2,1062,1063,1064,1065,1066][i]?.getD 0 }
  three := 6
  scaledFifth := 1067
  timesFirst := ![1068,1083,1097]
  numerator := ![![1069,1075,1079],![1084,1088,1093],![1098,1102,1106]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1064,11,11],![11,1064,11],![11,11,1064]]
  negativeDiagonal := ![![1070,11,11],![11,1070,11],![11,11,1070]]
  block := ![![1071,1075,1079],![1084,1089,1093],![1098,1102,1107]]
theorem pairBlock_6_5_check : pairBlock_6_5.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_6_5_check
def difference_6_5 : DifferenceRecipe where
  left := ![18,11,11]
  right := ![15,17,14]
  negative := ![111,265,488]
  output := ![854,265,488]
theorem difference_6_5_check : difference_6_5.Check nodes := by decide
def halfInverse_6_5 : HalfInverseRecipe where
  distance := pairBlock_6_5.distance
  two := 8
  twice := 1111
  inverse := 1112
  negative := 1113
theorem halfInverse_6_5_check : halfInverse_6_5.Check nodes := by
  constructor
  · exact pairBlock_6_5_check.distance
  all_goals decide
def pairBlock_7_0 : PairBlockRecipe where
  distance := {
    difference := ![1116,13,14]
    squares := {
      left := fun i => #[1116,13,14][i]?.getD 0
      right := fun i => #[1116,13,14][i]?.getD 0
      product := fun i => #[1117,1118,822][i]?.getD 0
      accumulator := fun i => #[11,1117,1119,1120][i]?.getD 0 }
    root := 1121
    inverse := 1122 }
  powers := { base := 1122, accumulator := fun i => #[2,1122,1123,1124,1125,1126][i]?.getD 0 }
  three := 6
  scaledFifth := 1127
  timesFirst := ![1128,1140,1151]
  numerator := ![![1129,1134,1137],![1141,1144,1148],![1152,1155,1158]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1124,11,11],![11,1124,11],![11,11,1124]]
  negativeDiagonal := ![![1130,11,11],![11,1130,11],![11,11,1130]]
  block := ![![1131,1134,1137],![1141,1145,1148],![1152,1155,1159]]
theorem pairBlock_7_0_check : pairBlock_7_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_7_0_check
def difference_7_0 : DifferenceRecipe where
  left := ![9,13,11]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![1116,13,14]
theorem difference_7_0_check : difference_7_0.Check nodes := by decide
def halfInverse_7_0 : HalfInverseRecipe where
  distance := pairBlock_7_0.distance
  two := 8
  twice := 1162
  inverse := 1163
  negative := 1164
theorem halfInverse_7_0_check : halfInverse_7_0.Check nodes := by
  constructor
  · exact pairBlock_7_0_check.distance
  all_goals decide
def pairBlock_7_1 : PairBlockRecipe where
  distance := {
    difference := ![1166,1167,14]
    squares := {
      left := fun i => #[1166,1167,14][i]?.getD 0
      right := fun i => #[1166,1167,14][i]?.getD 0
      product := fun i => #[1168,1169,822][i]?.getD 0
      accumulator := fun i => #[11,1168,1170,1171][i]?.getD 0 }
    root := 1172
    inverse := 1173 }
  powers := { base := 1173, accumulator := fun i => #[2,1173,1174,1175,1176,1177][i]?.getD 0 }
  three := 6
  scaledFifth := 1178
  timesFirst := ![1179,1194,1208]
  numerator := ![![1180,1186,1190],![1195,1199,1204],![1209,1213,1217]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1175,11,11],![11,1175,11],![11,11,1175]]
  negativeDiagonal := ![![1181,11,11],![11,1181,11],![11,11,1181]]
  block := ![![1182,1186,1190],![1195,1200,1204],![1209,1213,1218]]
theorem pairBlock_7_1_check : pairBlock_7_1.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_7_1_check
def difference_7_1 : DifferenceRecipe where
  left := ![9,13,11]
  right := ![15,16,5]
  negative := ![111,113,14]
  output := ![1166,1167,14]
theorem difference_7_1_check : difference_7_1.Check nodes := by decide
def halfInverse_7_1 : HalfInverseRecipe where
  distance := pairBlock_7_1.distance
  two := 8
  twice := 1222
  inverse := 1223
  negative := 1224
theorem halfInverse_7_1_check : halfInverse_7_1.Check nodes := by
  constructor
  · exact pairBlock_7_1_check.distance
  all_goals decide
def pairBlock_7_2 : PairBlockRecipe where
  distance := {
    difference := ![1166,1227,14]
    squares := {
      left := fun i => #[1166,1227,14][i]?.getD 0
      right := fun i => #[1166,1227,14][i]?.getD 0
      product := fun i => #[1168,1228,822][i]?.getD 0
      accumulator := fun i => #[11,1168,1229,1230][i]?.getD 0 }
    root := 1231
    inverse := 1232 }
  powers := { base := 1232, accumulator := fun i => #[2,1232,1233,1234,1235,1236][i]?.getD 0 }
  three := 6
  scaledFifth := 1237
  timesFirst := ![1238,1253,1267]
  numerator := ![![1239,1245,1249],![1254,1258,1263],![1268,1272,1276]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1234,11,11],![11,1234,11],![11,11,1234]]
  negativeDiagonal := ![![1240,11,11],![11,1240,11],![11,11,1240]]
  block := ![![1241,1245,1249],![1254,1259,1263],![1268,1272,1277]]
theorem pairBlock_7_2_check : pairBlock_7_2.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_7_2_check
def difference_7_2 : DifferenceRecipe where
  left := ![9,13,11]
  right := ![15,17,5]
  negative := ![111,265,14]
  output := ![1166,1227,14]
theorem difference_7_2_check : difference_7_2.Check nodes := by decide
def halfInverse_7_2 : HalfInverseRecipe where
  distance := pairBlock_7_2.distance
  two := 8
  twice := 1281
  inverse := 1282
  negative := 1283
theorem halfInverse_7_2_check : halfInverse_7_2.Check nodes := by
  constructor
  · exact pairBlock_7_2_check.distance
  all_goals decide
def pairBlock_7_3 : PairBlockRecipe where
  distance := {
    difference := ![1116,13,488]
    squares := {
      left := fun i => #[1116,13,488][i]?.getD 0
      right := fun i => #[1116,13,488][i]?.getD 0
      product := fun i => #[1117,1118,966][i]?.getD 0
      accumulator := fun i => #[11,1117,1119,1286][i]?.getD 0 }
    root := 1287
    inverse := 1288 }
  powers := { base := 1288, accumulator := fun i => #[2,1288,1289,1290,1291,1292][i]?.getD 0 }
  three := 6
  scaledFifth := 1293
  timesFirst := ![1294,1309,1323]
  numerator := ![![1295,1301,1305],![1310,1314,1319],![1324,1328,1332]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1290,11,11],![11,1290,11],![11,11,1290]]
  negativeDiagonal := ![![1296,11,11],![11,1296,11],![11,11,1296]]
  block := ![![1297,1301,1305],![1310,1315,1319],![1324,1328,1333]]
theorem pairBlock_7_3_check : pairBlock_7_3.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_7_3_check
def difference_7_3 : DifferenceRecipe where
  left := ![9,13,11]
  right := ![0,11,14]
  negative := ![20,11,488]
  output := ![1116,13,488]
theorem difference_7_3_check : difference_7_3.Check nodes := by decide
def halfInverse_7_3 : HalfInverseRecipe where
  distance := pairBlock_7_3.distance
  two := 8
  twice := 1337
  inverse := 1338
  negative := 1339
theorem halfInverse_7_3_check : halfInverse_7_3.Check nodes := by
  constructor
  · exact pairBlock_7_3_check.distance
  all_goals decide
def pairBlock_7_4 : PairBlockRecipe where
  distance := {
    difference := ![1166,1167,488]
    squares := {
      left := fun i => #[1166,1167,488][i]?.getD 0
      right := fun i => #[1166,1167,488][i]?.getD 0
      product := fun i => #[1168,1169,966][i]?.getD 0
      accumulator := fun i => #[11,1168,1170,1342][i]?.getD 0 }
    root := 1343
    inverse := 1344 }
  powers := { base := 1344, accumulator := fun i => #[2,1344,1345,1346,1347,1348][i]?.getD 0 }
  three := 6
  scaledFifth := 1349
  timesFirst := ![1350,1365,1379]
  numerator := ![![1351,1357,1361],![1366,1370,1375],![1380,1384,1388]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1346,11,11],![11,1346,11],![11,11,1346]]
  negativeDiagonal := ![![1352,11,11],![11,1352,11],![11,11,1352]]
  block := ![![1353,1357,1361],![1366,1371,1375],![1380,1384,1389]]
theorem pairBlock_7_4_check : pairBlock_7_4.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_7_4_check
def difference_7_4 : DifferenceRecipe where
  left := ![9,13,11]
  right := ![15,16,14]
  negative := ![111,113,488]
  output := ![1166,1167,488]
theorem difference_7_4_check : difference_7_4.Check nodes := by decide
def halfInverse_7_4 : HalfInverseRecipe where
  distance := pairBlock_7_4.distance
  two := 8
  twice := 1393
  inverse := 1394
  negative := 1395
theorem halfInverse_7_4_check : halfInverse_7_4.Check nodes := by
  constructor
  · exact pairBlock_7_4_check.distance
  all_goals decide
def pairBlock_7_5 : PairBlockRecipe where
  distance := {
    difference := ![1166,1227,488]
    squares := {
      left := fun i => #[1166,1227,488][i]?.getD 0
      right := fun i => #[1166,1227,488][i]?.getD 0
      product := fun i => #[1168,1228,966][i]?.getD 0
      accumulator := fun i => #[11,1168,1229,1398][i]?.getD 0 }
    root := 1399
    inverse := 1400 }
  powers := { base := 1400, accumulator := fun i => #[2,1400,1401,1402,1403,1404][i]?.getD 0 }
  three := 6
  scaledFifth := 1405
  timesFirst := ![1406,1421,1435]
  numerator := ![![1407,1413,1417],![1422,1426,1431],![1436,1440,1444]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1402,11,11],![11,1402,11],![11,11,1402]]
  negativeDiagonal := ![![1408,11,11],![11,1408,11],![11,11,1408]]
  block := ![![1409,1413,1417],![1422,1427,1431],![1436,1440,1445]]
theorem pairBlock_7_5_check : pairBlock_7_5.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_7_5_check
def difference_7_5 : DifferenceRecipe where
  left := ![9,13,11]
  right := ![15,17,14]
  negative := ![111,265,488]
  output := ![1166,1227,488]
theorem difference_7_5_check : difference_7_5.Check nodes := by decide
def halfInverse_7_5 : HalfInverseRecipe where
  distance := pairBlock_7_5.distance
  two := 8
  twice := 1449
  inverse := 1450
  negative := 1451
theorem halfInverse_7_5_check : halfInverse_7_5.Check nodes := by
  constructor
  · exact pairBlock_7_5_check.distance
  all_goals decide
def pairBlock_7_6 : PairBlockRecipe where
  distance := {
    difference := ![1454,13,11]
    squares := {
      left := fun i => #[1454,13,11][i]?.getD 0
      right := fun i => #[1454,13,11][i]?.getD 0
      product := fun i => #[1455,1118,11][i]?.getD 0
      accumulator := fun i => #[11,1455,1456,1456][i]?.getD 0 }
    root := 1457
    inverse := 1458 }
  powers := { base := 1458, accumulator := fun i => #[2,1458,1459,1460,1461,1462][i]?.getD 0 }
  three := 6
  scaledFifth := 1463
  timesFirst := ![1464,1475,11]
  numerator := ![![1465,1471,11],![1476,1480,11],![11,11,11]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1460,11,11],![11,1460,11],![11,11,1460]]
  negativeDiagonal := ![![1466,11,11],![11,1466,11],![11,11,1466]]
  block := ![![1467,1471,11],![1476,1481,11],![11,11,1466]]
theorem pairBlock_7_6_check : pairBlock_7_6.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_7_6_check
def difference_7_6 : DifferenceRecipe where
  left := ![9,13,11]
  right := ![18,11,11]
  negative := ![2,11,11]
  output := ![1454,13,11]
theorem difference_7_6_check : difference_7_6.Check nodes := by decide
def halfInverse_7_6 : HalfInverseRecipe where
  distance := pairBlock_7_6.distance
  two := 8
  twice := 1488
  inverse := 1489
  negative := 1490
theorem halfInverse_7_6_check : halfInverse_7_6.Check nodes := by
  constructor
  · exact pairBlock_7_6_check.distance
  all_goals decide
def pairBlock_8_0 : PairBlockRecipe where
  distance := {
    difference := ![1116,19,14]
    squares := {
      left := fun i => #[1116,19,14][i]?.getD 0
      right := fun i => #[1116,19,14][i]?.getD 0
      product := fun i => #[1117,1493,822][i]?.getD 0
      accumulator := fun i => #[11,1117,1494,1495][i]?.getD 0 }
    root := 1496
    inverse := 1497 }
  powers := { base := 1497, accumulator := fun i => #[2,1497,1498,1499,1500,1501][i]?.getD 0 }
  three := 6
  scaledFifth := 1502
  timesFirst := ![1503,1515,1526]
  numerator := ![![1504,1509,1512],![1516,1519,1523],![1527,1530,1533]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1499,11,11],![11,1499,11],![11,11,1499]]
  negativeDiagonal := ![![1505,11,11],![11,1505,11],![11,11,1505]]
  block := ![![1506,1509,1512],![1516,1520,1523],![1527,1530,1534]]
theorem pairBlock_8_0_check : pairBlock_8_0.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_0_check
def difference_8_0 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![0,11,5]
  negative := ![20,11,14]
  output := ![1116,19,14]
theorem difference_8_0_check : difference_8_0.Check nodes := by decide
def halfInverse_8_0 : HalfInverseRecipe where
  distance := pairBlock_8_0.distance
  two := 8
  twice := 1537
  inverse := 1538
  negative := 1539
theorem halfInverse_8_0_check : halfInverse_8_0.Check nodes := by
  constructor
  · exact pairBlock_8_0_check.distance
  all_goals decide
def pairBlock_8_1 : PairBlockRecipe where
  distance := {
    difference := ![1166,1541,14]
    squares := {
      left := fun i => #[1166,1541,14][i]?.getD 0
      right := fun i => #[1166,1541,14][i]?.getD 0
      product := fun i => #[1168,1542,822][i]?.getD 0
      accumulator := fun i => #[11,1168,1543,1544][i]?.getD 0 }
    root := 1545
    inverse := 1546 }
  powers := { base := 1546, accumulator := fun i => #[2,1546,1547,1548,1549,1550][i]?.getD 0 }
  three := 6
  scaledFifth := 1551
  timesFirst := ![1552,1567,1581]
  numerator := ![![1553,1559,1563],![1568,1572,1577],![1582,1586,1590]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1548,11,11],![11,1548,11],![11,11,1548]]
  negativeDiagonal := ![![1554,11,11],![11,1554,11],![11,11,1554]]
  block := ![![1555,1559,1563],![1568,1573,1577],![1582,1586,1591]]
theorem pairBlock_8_1_check : pairBlock_8_1.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_1_check
def difference_8_1 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![15,16,5]
  negative := ![111,113,14]
  output := ![1166,1541,14]
theorem difference_8_1_check : difference_8_1.Check nodes := by decide
def halfInverse_8_1 : HalfInverseRecipe where
  distance := pairBlock_8_1.distance
  two := 8
  twice := 1595
  inverse := 1596
  negative := 1597
theorem halfInverse_8_1_check : halfInverse_8_1.Check nodes := by
  constructor
  · exact pairBlock_8_1_check.distance
  all_goals decide
def pairBlock_8_2 : PairBlockRecipe where
  distance := {
    difference := ![1166,1600,14]
    squares := {
      left := fun i => #[1166,1600,14][i]?.getD 0
      right := fun i => #[1166,1600,14][i]?.getD 0
      product := fun i => #[1168,1601,822][i]?.getD 0
      accumulator := fun i => #[11,1168,1602,1603][i]?.getD 0 }
    root := 1604
    inverse := 1605 }
  powers := { base := 1605, accumulator := fun i => #[2,1605,1606,1607,1608,1609][i]?.getD 0 }
  three := 6
  scaledFifth := 1610
  timesFirst := ![1611,1626,1640]
  numerator := ![![1612,1618,1622],![1627,1631,1636],![1641,1645,1649]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1607,11,11],![11,1607,11],![11,11,1607]]
  negativeDiagonal := ![![1613,11,11],![11,1613,11],![11,11,1613]]
  block := ![![1614,1618,1622],![1627,1632,1636],![1641,1645,1650]]
theorem pairBlock_8_2_check : pairBlock_8_2.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_2_check
def difference_8_2 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![15,17,5]
  negative := ![111,265,14]
  output := ![1166,1600,14]
theorem difference_8_2_check : difference_8_2.Check nodes := by decide
def halfInverse_8_2 : HalfInverseRecipe where
  distance := pairBlock_8_2.distance
  two := 8
  twice := 1654
  inverse := 1655
  negative := 1656
theorem halfInverse_8_2_check : halfInverse_8_2.Check nodes := by
  constructor
  · exact pairBlock_8_2_check.distance
  all_goals decide
def pairBlock_8_3 : PairBlockRecipe where
  distance := {
    difference := ![1116,19,488]
    squares := {
      left := fun i => #[1116,19,488][i]?.getD 0
      right := fun i => #[1116,19,488][i]?.getD 0
      product := fun i => #[1117,1493,966][i]?.getD 0
      accumulator := fun i => #[11,1117,1494,1659][i]?.getD 0 }
    root := 1660
    inverse := 1661 }
  powers := { base := 1661, accumulator := fun i => #[2,1661,1662,1663,1664,1665][i]?.getD 0 }
  three := 6
  scaledFifth := 1666
  timesFirst := ![1667,1682,1696]
  numerator := ![![1668,1674,1678],![1683,1687,1692],![1697,1701,1705]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1663,11,11],![11,1663,11],![11,11,1663]]
  negativeDiagonal := ![![1669,11,11],![11,1669,11],![11,11,1669]]
  block := ![![1670,1674,1678],![1683,1688,1692],![1697,1701,1706]]
theorem pairBlock_8_3_check : pairBlock_8_3.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_3_check
def difference_8_3 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![0,11,14]
  negative := ![20,11,488]
  output := ![1116,19,488]
theorem difference_8_3_check : difference_8_3.Check nodes := by decide
def halfInverse_8_3 : HalfInverseRecipe where
  distance := pairBlock_8_3.distance
  two := 8
  twice := 1710
  inverse := 1711
  negative := 1712
theorem halfInverse_8_3_check : halfInverse_8_3.Check nodes := by
  constructor
  · exact pairBlock_8_3_check.distance
  all_goals decide
def pairBlock_8_4 : PairBlockRecipe where
  distance := {
    difference := ![1166,1541,488]
    squares := {
      left := fun i => #[1166,1541,488][i]?.getD 0
      right := fun i => #[1166,1541,488][i]?.getD 0
      product := fun i => #[1168,1542,966][i]?.getD 0
      accumulator := fun i => #[11,1168,1543,1715][i]?.getD 0 }
    root := 1716
    inverse := 1717 }
  powers := { base := 1717, accumulator := fun i => #[2,1717,1718,1719,1720,1721][i]?.getD 0 }
  three := 6
  scaledFifth := 1722
  timesFirst := ![1723,1738,1752]
  numerator := ![![1724,1730,1734],![1739,1743,1748],![1753,1757,1761]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1719,11,11],![11,1719,11],![11,11,1719]]
  negativeDiagonal := ![![1725,11,11],![11,1725,11],![11,11,1725]]
  block := ![![1726,1730,1734],![1739,1744,1748],![1753,1757,1762]]
theorem pairBlock_8_4_check : pairBlock_8_4.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_4_check
def difference_8_4 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![15,16,14]
  negative := ![111,113,488]
  output := ![1166,1541,488]
theorem difference_8_4_check : difference_8_4.Check nodes := by decide
def halfInverse_8_4 : HalfInverseRecipe where
  distance := pairBlock_8_4.distance
  two := 8
  twice := 1766
  inverse := 1767
  negative := 1768
theorem halfInverse_8_4_check : halfInverse_8_4.Check nodes := by
  constructor
  · exact pairBlock_8_4_check.distance
  all_goals decide
def pairBlock_8_5 : PairBlockRecipe where
  distance := {
    difference := ![1166,1600,488]
    squares := {
      left := fun i => #[1166,1600,488][i]?.getD 0
      right := fun i => #[1166,1600,488][i]?.getD 0
      product := fun i => #[1168,1601,966][i]?.getD 0
      accumulator := fun i => #[11,1168,1602,1771][i]?.getD 0 }
    root := 1772
    inverse := 1773 }
  powers := { base := 1773, accumulator := fun i => #[2,1773,1774,1775,1776,1777][i]?.getD 0 }
  three := 6
  scaledFifth := 1778
  timesFirst := ![1779,1794,1808]
  numerator := ![![1780,1786,1790],![1795,1799,1804],![1809,1813,1817]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1775,11,11],![11,1775,11],![11,11,1775]]
  negativeDiagonal := ![![1781,11,11],![11,1781,11],![11,11,1781]]
  block := ![![1782,1786,1790],![1795,1800,1804],![1809,1813,1818]]
theorem pairBlock_8_5_check : pairBlock_8_5.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_5_check
def difference_8_5 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![15,17,14]
  negative := ![111,265,488]
  output := ![1166,1600,488]
theorem difference_8_5_check : difference_8_5.Check nodes := by decide
def halfInverse_8_5 : HalfInverseRecipe where
  distance := pairBlock_8_5.distance
  two := 8
  twice := 1822
  inverse := 1823
  negative := 1824
theorem halfInverse_8_5_check : halfInverse_8_5.Check nodes := by
  constructor
  · exact pairBlock_8_5_check.distance
  all_goals decide
def pairBlock_8_6 : PairBlockRecipe where
  distance := {
    difference := ![1454,19,11]
    squares := {
      left := fun i => #[1454,19,11][i]?.getD 0
      right := fun i => #[1454,19,11][i]?.getD 0
      product := fun i => #[1455,1493,11][i]?.getD 0
      accumulator := fun i => #[11,1455,1827,1827][i]?.getD 0 }
    root := 1828
    inverse := 1829 }
  powers := { base := 1829, accumulator := fun i => #[2,1829,1830,1831,1832,1833][i]?.getD 0 }
  three := 6
  scaledFifth := 1834
  timesFirst := ![1835,1846,11]
  numerator := ![![1836,1842,11],![1847,1851,11],![11,11,11]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1831,11,11],![11,1831,11],![11,11,1831]]
  negativeDiagonal := ![![1837,11,11],![11,1837,11],![11,11,1837]]
  block := ![![1838,1842,11],![1847,1852,11],![11,11,1837]]
theorem pairBlock_8_6_check : pairBlock_8_6.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_6_check
def difference_8_6 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![18,11,11]
  negative := ![2,11,11]
  output := ![1454,19,11]
theorem difference_8_6_check : difference_8_6.Check nodes := by decide
def halfInverse_8_6 : HalfInverseRecipe where
  distance := pairBlock_8_6.distance
  two := 8
  twice := 1859
  inverse := 1860
  negative := 1861
theorem halfInverse_8_6_check : halfInverse_8_6.Check nodes := by
  constructor
  · exact pairBlock_8_6_check.distance
  all_goals decide
def pairBlock_8_7 : PairBlockRecipe where
  distance := {
    difference := ![11,1864,11]
    squares := {
      left := fun i => #[11,1864,11][i]?.getD 0
      right := fun i => #[11,1864,11][i]?.getD 0
      product := fun i => #[11,1865,11][i]?.getD 0
      accumulator := fun i => #[11,11,1865,1865][i]?.getD 0 }
    root := 1866
    inverse := 1867 }
  powers := { base := 1867, accumulator := fun i => #[2,1867,1868,1869,1870,1871][i]?.getD 0 }
  three := 6
  scaledFifth := 1872
  timesFirst := ![11,1877,11]
  numerator := ![![11,11,11],![11,1878,11],![11,11,11]]
  delta := ![![2,11,11],![11,2,11],![11,11,2]]
  diagonalTerm := ![![1869,11,11],![11,1869,11],![11,11,1869]]
  negativeDiagonal := ![![1873,11,11],![11,1873,11],![11,11,1873]]
  block := ![![1873,11,11],![11,1879,11],![11,11,1873]]
theorem pairBlock_8_7_check : pairBlock_8_7.Check nodes := by
  constructor <;> decide
#print axioms pairBlock_8_7_check
def difference_8_7 : DifferenceRecipe where
  left := ![9,19,11]
  right := ![9,13,11]
  negative := ![12,19,11]
  output := ![11,1864,11]
theorem difference_8_7_check : difference_8_7.Check nodes := by decide
def halfInverse_8_7 : HalfInverseRecipe where
  distance := pairBlock_8_7.distance
  two := 8
  twice := 1885
  inverse := 1886
  negative := 1887
theorem halfInverse_8_7_check : halfInverse_8_7.Check nodes := by
  constructor
  · exact pairBlock_8_7_check.distance
  all_goals decide
def pairRecipes : Fin 36 → PairBlockRecipe := ![pairBlock_1_0, pairBlock_2_0, pairBlock_2_1, pairBlock_3_0, pairBlock_3_1, pairBlock_3_2, pairBlock_4_0, pairBlock_4_1, pairBlock_4_2, pairBlock_4_3, pairBlock_5_0, pairBlock_5_1, pairBlock_5_2, pairBlock_5_3, pairBlock_5_4, pairBlock_6_0, pairBlock_6_1, pairBlock_6_2, pairBlock_6_3, pairBlock_6_4, pairBlock_6_5, pairBlock_7_0, pairBlock_7_1, pairBlock_7_2, pairBlock_7_3, pairBlock_7_4, pairBlock_7_5, pairBlock_7_6, pairBlock_8_0, pairBlock_8_1, pairBlock_8_2, pairBlock_8_3, pairBlock_8_4, pairBlock_8_5, pairBlock_8_6, pairBlock_8_7]
theorem pair_recipes_checked (k : Fin 36) : (pairRecipes k).Check nodes := by
  fin_cases k
  · exact pairBlock_1_0_check
  · exact pairBlock_2_0_check
  · exact pairBlock_2_1_check
  · exact pairBlock_3_0_check
  · exact pairBlock_3_1_check
  · exact pairBlock_3_2_check
  · exact pairBlock_4_0_check
  · exact pairBlock_4_1_check
  · exact pairBlock_4_2_check
  · exact pairBlock_4_3_check
  · exact pairBlock_5_0_check
  · exact pairBlock_5_1_check
  · exact pairBlock_5_2_check
  · exact pairBlock_5_3_check
  · exact pairBlock_5_4_check
  · exact pairBlock_6_0_check
  · exact pairBlock_6_1_check
  · exact pairBlock_6_2_check
  · exact pairBlock_6_3_check
  · exact pairBlock_6_4_check
  · exact pairBlock_6_5_check
  · exact pairBlock_7_0_check
  · exact pairBlock_7_1_check
  · exact pairBlock_7_2_check
  · exact pairBlock_7_3_check
  · exact pairBlock_7_4_check
  · exact pairBlock_7_5_check
  · exact pairBlock_7_6_check
  · exact pairBlock_8_0_check
  · exact pairBlock_8_1_check
  · exact pairBlock_8_2_check
  · exact pairBlock_8_3_check
  · exact pairBlock_8_4_check
  · exact pairBlock_8_5_check
  · exact pairBlock_8_6_check
  · exact pairBlock_8_7_check
theorem pair_blocks_sound (values : ℕ → ℝ) (k : Fin 36) (p q : R3)
    (hdiff : ∀ a : Fin 3, IntervalCircuit.value values nodes
      ((pairRecipes k).distance.difference a) = p a-q a) (a b : Fin 3) :
    IntervalCircuit.value values nodes ((pairRecipes k).block a b) =
      coulombPairBlock (p-q) a b :=
  (pairRecipes k).sound values nodes (pair_recipes_checked k) p q hdiff a b
#print axioms pair_recipes_checked
#print axioms pair_blocks_sound
def pairDifferences : Fin 36 → DifferenceRecipe := ![difference_1_0, difference_2_0, difference_2_1, difference_3_0, difference_3_1, difference_3_2, difference_4_0, difference_4_1, difference_4_2, difference_4_3, difference_5_0, difference_5_1, difference_5_2, difference_5_3, difference_5_4, difference_6_0, difference_6_1, difference_6_2, difference_6_3, difference_6_4, difference_6_5, difference_7_0, difference_7_1, difference_7_2, difference_7_3, difference_7_4, difference_7_5, difference_7_6, difference_8_0, difference_8_1, difference_8_2, difference_8_3, difference_8_4, difference_8_5, difference_8_6, difference_8_7]
def pairFirst : Fin 36 → Fin 9 := ![1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,6,6,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8]
def pairSecond : Fin 36 → Fin 9 := ![0,0,1,0,1,2,0,1,2,3,0,1,2,3,4,0,1,2,3,4,5,0,1,2,3,4,5,6,0,1,2,3,4,5,6,7]
theorem difference_recipes_checked (k : Fin 36) : (pairDifferences k).Check nodes := by
  fin_cases k
  · exact difference_1_0_check
  · exact difference_2_0_check
  · exact difference_2_1_check
  · exact difference_3_0_check
  · exact difference_3_1_check
  · exact difference_3_2_check
  · exact difference_4_0_check
  · exact difference_4_1_check
  · exact difference_4_2_check
  · exact difference_4_3_check
  · exact difference_5_0_check
  · exact difference_5_1_check
  · exact difference_5_2_check
  · exact difference_5_3_check
  · exact difference_5_4_check
  · exact difference_6_0_check
  · exact difference_6_1_check
  · exact difference_6_2_check
  · exact difference_6_3_check
  · exact difference_6_4_check
  · exact difference_6_5_check
  · exact difference_7_0_check
  · exact difference_7_1_check
  · exact difference_7_2_check
  · exact difference_7_3_check
  · exact difference_7_4_check
  · exact difference_7_5_check
  · exact difference_7_6_check
  · exact difference_8_0_check
  · exact difference_8_1_check
  · exact difference_8_2_check
  · exact difference_8_3_check
  · exact difference_8_4_check
  · exact difference_8_5_check
  · exact difference_8_6_check
  · exact difference_8_7_check
theorem coordinate_prefix_checked : CoordinateCheck nodes := by decide
theorem difference_left (k : Fin 36) (a : Fin 3) :
    (pairDifferences k).left a = pointIndices (pairFirst k) a := by
  fin_cases k <;> fin_cases a <;> rfl
theorem difference_right (k : Fin 36) (a : Fin 3) :
    (pairDifferences k).right a = pointIndices (pairSecond k) a := by
  fin_cases k <;> fin_cases a <;> rfl
theorem difference_output (k : Fin 36) (a : Fin 3) :
    (pairDifferences k).output a = (pairRecipes k).distance.difference a := by
  fin_cases k <;> fin_cases a <;> rfl
theorem pair_differences_candidate_sound (r : ℝ) (k : Fin 36) (a : Fin 3) :
    IntervalCircuit.value (parameterInputs r) nodes ((pairRecipes k).distance.difference a) =
      candidateAt r (pairFirst k) a-candidateAt r (pairSecond k) a := by
  rw [← difference_output]
  exact (pairDifferences k).candidate_sound r nodes coordinate_prefix_checked
    (difference_recipes_checked k) (pairFirst k) (pairSecond k)
    (difference_left k) (difference_right k) a
theorem pair_blocks_candidate_sound (r : ℝ) (k : Fin 36) (a b : Fin 3) :
    IntervalCircuit.value (parameterInputs r) nodes ((pairRecipes k).block a b) =
      coulombPairBlock (candidateAt r (pairFirst k)-candidateAt r (pairSecond k)) a b :=
  pair_blocks_sound _ k _ _ (pair_differences_candidate_sound r k) a b
#print axioms pair_blocks_candidate_sound
def halfInverseRecipes : Fin 36 → HalfInverseRecipe := ![halfInverse_1_0, halfInverse_2_0, halfInverse_2_1, halfInverse_3_0, halfInverse_3_1, halfInverse_3_2, halfInverse_4_0, halfInverse_4_1, halfInverse_4_2, halfInverse_4_3, halfInverse_5_0, halfInverse_5_1, halfInverse_5_2, halfInverse_5_3, halfInverse_5_4, halfInverse_6_0, halfInverse_6_1, halfInverse_6_2, halfInverse_6_3, halfInverse_6_4, halfInverse_6_5, halfInverse_7_0, halfInverse_7_1, halfInverse_7_2, halfInverse_7_3, halfInverse_7_4, halfInverse_7_5, halfInverse_7_6, halfInverse_8_0, halfInverse_8_1, halfInverse_8_2, halfInverse_8_3, halfInverse_8_4, halfInverse_8_5, halfInverse_8_6, halfInverse_8_7]
theorem half_inverse_recipes_checked (k : Fin 36) : (halfInverseRecipes k).Check nodes := by
  fin_cases k
  · exact halfInverse_1_0_check
  · exact halfInverse_2_0_check
  · exact halfInverse_2_1_check
  · exact halfInverse_3_0_check
  · exact halfInverse_3_1_check
  · exact halfInverse_3_2_check
  · exact halfInverse_4_0_check
  · exact halfInverse_4_1_check
  · exact halfInverse_4_2_check
  · exact halfInverse_4_3_check
  · exact halfInverse_5_0_check
  · exact halfInverse_5_1_check
  · exact halfInverse_5_2_check
  · exact halfInverse_5_3_check
  · exact halfInverse_5_4_check
  · exact halfInverse_6_0_check
  · exact halfInverse_6_1_check
  · exact halfInverse_6_2_check
  · exact halfInverse_6_3_check
  · exact halfInverse_6_4_check
  · exact halfInverse_6_5_check
  · exact halfInverse_7_0_check
  · exact halfInverse_7_1_check
  · exact halfInverse_7_2_check
  · exact halfInverse_7_3_check
  · exact halfInverse_7_4_check
  · exact halfInverse_7_5_check
  · exact halfInverse_7_6_check
  · exact halfInverse_8_0_check
  · exact halfInverse_8_1_check
  · exact halfInverse_8_2_check
  · exact halfInverse_8_3_check
  · exact halfInverse_8_4_check
  · exact halfInverse_8_5_check
  · exact halfInverse_8_6_check
  · exact halfInverse_8_7_check
theorem half_inverse_distance (k : Fin 36) :
    (halfInverseRecipes k).distance = (pairRecipes k).distance := by fin_cases k <;> rfl
theorem half_inverse_candidate_sound (r : ℝ) (k : Fin 36) :
    IntervalCircuit.value (parameterInputs r) nodes (halfInverseRecipes k).negative =
      -(‖candidateAt r (pairFirst k)-candidateAt r (pairSecond k)‖⁻¹/2) := by
  apply (halfInverseRecipes k).sound _ _ (half_inverse_recipes_checked k)
  intro a
  rw [half_inverse_distance]
  exact pair_differences_candidate_sound r k a
def pairIndex : Fin 9 → Fin 9 → Fin 36 := ![![0,0,1,3,6,10,15,21,28],![0,0,2,4,7,11,16,22,29],![1,2,0,5,8,12,17,23,30],![3,4,5,0,9,13,18,24,31],![6,7,8,9,0,14,19,25,32],![10,11,12,13,14,0,20,26,33],![15,16,17,18,19,20,0,27,34],![21,22,23,24,25,26,27,0,35],![28,29,30,31,32,33,34,35,0]]
theorem pair_endpoints (i j : Fin 9) (h : i ≠ j) :
    (pairFirst (pairIndex i j) = i ∧ pairSecond (pairIndex i j) = j) ∨
    (pairFirst (pairIndex i j) = j ∧ pairSecond (pairIndex i j) = i) := by
  revert i j
  decide
theorem unordered_pair_block_sound (r : ℝ) (i j : Fin 9) (h : i ≠ j) (a b : Fin 3) :
    IntervalCircuit.value (parameterInputs r) nodes ((pairRecipes (pairIndex i j)).block a b) =
      coulombPairBlock (candidateAt r i-candidateAt r j) a b := by
  rw [pair_blocks_candidate_sound]
  rcases pair_endpoints i j h with h | h
  · rw [h.1,h.2]
  · rw [h.1,h.2]
    have heq : candidateAt r j-candidateAt r i = -(candidateAt r i-candidateAt r j) := by abel
    rw [heq,coulombPairBlock_neg]
theorem unordered_half_inverse_sound (r : ℝ) (i j : Fin 9) (h : i ≠ j) :
    IntervalCircuit.value (parameterInputs r) nodes (halfInverseRecipes (pairIndex i j)).negative =
      -(‖candidateAt r i-candidateAt r j‖⁻¹/2) := by
  rw [half_inverse_candidate_sound]
  rcases pair_endpoints i j h with h | h
  · rw [h.1,h.2]
  · rw [h.1,h.2,norm_sub_rev]
#print axioms unordered_pair_block_sound
#print axioms unordered_half_inverse_sound
end ThomsonN9.Certificates.AmbientKernel
