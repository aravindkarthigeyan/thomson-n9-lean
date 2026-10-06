/-
Reviewer probe (not part of L1).  Restates the L1 final theorem from scratch, with the constants typed
directly from the JSON strings of near-sharp-d10-reduced-D60.json (SHA-256 9816ae66...8781) and with
fully qualified Codex / Mathlib names, and closes it with `ThomsonN9.Claude.L1.reduced_pair_bound`.
Also re-derives the theorem directly from Codex's frozen `factored_certificate_pair_bound`, and prints
axioms and the Codex definitions as loaded from the (possibly stale) .olean files.
-/
import ClaudeL1.Main

namespace ReviewL1

/-- JSON `minorant`, verbatim strings, increasing powers -/
def revCoeff : Fin 21 → ℚ := ![
  ((88388347648061560556856655743446139267869993323783089228271 : ℚ) / 125000000000000000000000000000000000000000000000000000000000),
  ((353553391002992679057951021238410079717959688415550742463939 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((265165023759905707176443640685155051872159795334516183711231 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((44194148011550832135029545246680709916538642088711886234969 : ℚ) / 200000000000000000000000000000000000000000000000000000000000),
  ((193349871054210491422533027593842653584409712389014923333331 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((34803856829645678218661261542559263362323154679171506507433 : ℚ) / 200000000000000000000000000000000000000000000000000000000000),
  ((159521258540197170003924058686077429544050775786531400766959 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((37019065518776030335638133211500566923765828638158312415087 : ℚ) / 250000000000000000000000000000000000000000000000000000000000),
  ((138650917045337529083923943803748987887627525790710227988207 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((130930475867629871646087062517375279486376449919295242640313 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((62731331294707332846884799507048763018688143688926522999587 : ℚ) / 500000000000000000000000000000000000000000000000000000000000),
  ((61232877832829999924297234779027353493925821204708481750863 : ℚ) / 500000000000000000000000000000000000000000000000000000000000),
  ((59558744788900529184941899878943821855024900825346710096037 : ℚ) / 500000000000000000000000000000000000000000000000000000000000),
  ((13636371800189505434628987223308272693867274197200279035457 : ℚ) / 125000000000000000000000000000000000000000000000000000000000),
  ((17549025218660694650577621642834013992676357191932643302621 : ℚ) / 200000000000000000000000000000000000000000000000000000000000),
  ((14575931725502323914309958269091662563973581477642815238899 : ℚ) / 250000000000000000000000000000000000000000000000000000000000),
  ((30414367072057078333101491208526929933960982075987860266821 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((11837525365352536542641094128827406409093862393529532431301 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000),
  ((1606606755599575080910231813468605339703740460958905331763 : ℚ) / 500000000000000000000000000000000000000000000000000000000000),
  ((135265134821882684183257859495311186194514827225086802621 : ℚ) / 250000000000000000000000000000000000000000000000000000000000),
  ((42485597615822124143597997671065886880426449763731598771 : ℚ) / 1000000000000000000000000000000000000000000000000000000000000)]

/-- JSON `raw_energy` -/
def revRaw : ℚ := ((5151997306253966312815140454752098805728382727295351889952429 : ℚ) / 200000000000000000000000000000000000000000000000000000000000)

/-- JSON `certified_energy` -/
def revCert : ℚ := ((6439996632817457891018925568440123507160478409119189861841504125078455595750859198505353468311884324138829869147618634763507 : ℚ) / 250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)

/-- JSON `maximum_inner_product` -/
def revCap : ℚ := ((5593 : ℚ) / 10000)

noncomputable def revH (t : ℝ) : ℝ := ∑ i : Fin 21, (revCoeff i : ℝ) * t ^ (i : ℕ)

theorem rev_coeff : revCoeff = ThomsonN9.Claude.L1.hNewCoeff := by
  funext i
  fin_cases i <;> norm_num [revCoeff, ThomsonN9.Claude.L1.hNewCoeff]

theorem rev_raw : revRaw = ThomsonN9.Claude.L1.rawEnergyReduced := by
  norm_num [revRaw, ThomsonN9.Claude.L1.rawEnergyReduced]

theorem rev_cert : revCert = ThomsonN9.Claude.L1.certifiedEnergyReduced := by
  norm_num [revCert, ThomsonN9.Claude.L1.certifiedEnergyReduced]

theorem rev_H : revH = ThomsonN9.Claude.L1.hNew := by
  funext t
  simp only [revH, ThomsonN9.Claude.L1.hNew, rev_coeff]

/-- the L1 theorem, restated independently -/
theorem review_final (x : ThomsonN9.Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hM : ∀ i j, i ≠ j → inner ℝ (x i) (x j) ≤ ((revCap : ℚ) : ℝ)) :
    ((revCert : ℚ) : ℝ) ≤ ThomsonN9.pairSum (fun i j => revH (inner ℝ (x i) (x j))) := by
  have hM' : ∀ i j, i ≠ j → inner ℝ (x i) (x j) ≤ 5593 / 10000 := by
    intro i j hij
    have := hM i j hij
    norm_num [revCap] at this
    linarith
  rw [rev_cert, rev_H]
  exact ThomsonN9.Claude.L1.reduced_pair_bound x hx hM'

/-- direct instantiation of Codex's frozen interface with the JSON e_new and h_new -/
theorem review_codex_instance (x : ThomsonN9.Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hM : ∀ i j, i ≠ j → inner ℝ (x i) (x j) ≤ 5593 / 10000) :
    ((revRaw : ℚ) : ℝ) - 36 * (∑ b, |ThomsonN9.Claude.L1.resCoeff b|) ≤
      ThomsonN9.pairSum (fun i j => revH (inner ℝ (x i) (x j))) := by
  rw [rev_raw, rev_H]
  exact ThomsonN9.SDP.factored_certificate_pair_bound
    ThomsonN9.Claude.L1.famB ThomsonN9.Claude.L1.famP ThomsonN9.Claude.L1.famDeg
    ThomsonN9.Claude.L1.sosWeight ThomsonN9.Claude.L1.sosSquare
    ThomsonN9.Claude.L1.resCoeff ThomsonN9.Claude.L1.resExp
    ThomsonN9.Claude.L1.hNew ((ThomsonN9.Claude.L1.rawEnergyReduced : ℚ) : ℝ) (5593 / 10000)
    (fun u v t hd s => ThomsonN9.Claude.L1.sosWeight_nonneg hd s)
    ThomsonN9.Claude.L1.l1_hidentity x hx hM

/-- residual l1 vs L_new = (raw - certified)/36, with the JSON values -/
theorem review_l1 :
    ∑ b, |ThomsonN9.Claude.L1.resCoeff b| ≤ (((revRaw : ℚ) : ℝ) - ((revCert : ℚ) : ℝ)) / 36 := by
  rw [rev_raw, rev_cert]
  exact ThomsonN9.Claude.L1.res_l1_le

example : (revRaw - revCert) / 36 =
    (599032124921544404249140801494646531688115675861170130852381365236493 : ℚ) / (9 * 10 ^ 123) := by
  norm_num [revRaw, revCert]

example : ThomsonN9.Claude.L1.Data.kblocks.length = 10 := ThomsonN9.Claude.L1.kblocks_length
example : ThomsonN9.Claude.L1.Data.SOS.allTerms.length = 859 := by decide +kernel

end ReviewL1

set_option pp.fullNames true in
#check @ThomsonN9.Claude.L1.reduced_pair_bound
set_option pp.fullNames true in
#check @ThomsonN9.SDP.factored_certificate_pair_bound
#print ThomsonN9.SDP.TripleDomain
#print ThomsonN9.SDP.domainWeight
#print ThomsonN9.SDP.correctedFactorKernel
#print ThomsonN9.SDP.rootedFactorKernel
#print ThomsonN9.SDP.factorWeight
#print ThomsonN9.SDP.threePointKernel
#print ThomsonN9.SDP.circleKernel
#print ThomsonN9.SDP.edgeSymmetrize
#print ThomsonN9.pairSum
#print ThomsonN9.Configuration
#print axioms ReviewL1.review_final
#print axioms ReviewL1.review_codex_instance
#print axioms ReviewL1.review_l1
#print axioms ThomsonN9.Claude.L1.reduced_pair_bound
#print axioms ThomsonN9.Claude.L1.l1_hidentity
#print axioms ThomsonN9.Claude.L1.kernel_block_identity
#print axioms ThomsonN9.Claude.L1.kernel_total_identity
#print axioms ThomsonN9.Claude.L1.sosWeight_nonneg
#print axioms ThomsonN9.Claude.L1.correctedFactorKernel_eq
#print axioms ThomsonN9.Claude.L1.res_l1_le
#print axioms ThomsonN9.Claude.L1.Data.ktotal_ok
#print axioms ThomsonN9.Claude.L1.Data.asm_ok
#print axioms ThomsonN9.Claude.L1.Data.SOS.sos_total
#print axioms ThomsonN9.SDP.factored_certificate_pair_bound
