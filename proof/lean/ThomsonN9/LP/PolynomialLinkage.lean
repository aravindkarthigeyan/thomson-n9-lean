import ThomsonN9.LP.Covariance
import ThomsonN9.Bernstein.Checker

namespace ThomsonN9.LPLinkage

theorem legendreKernel_recurrence (k : Nat) (t : Real) :
    legendreKernel (k+2) t =
      ((2*(k : Real)+3)/((k : Real)+2))*t*legendreKernel (k+1) t -
      (((k : Real)+1)/((k : Real)+2))*legendreKernel k t := by
  unfold legendreKernel Delsarte.Sphere.gegenbauerReal
  rw [Delsarte.gegenbauerPoly_add_two]
  simp only [map_sub, map_mul, Polynomial.aeval_C, Polynomial.aeval_X, eq_ratCast]
  push_cast
  ring

theorem legendre_horner_0 (t : Real) :
    legendreKernel 0 t =
      Bernstein.polyEval [1] t / 1 := by
  simp [legendreKernel_zero, Bernstein.polyEval]

theorem legendre_horner_1 (t : Real) :
    legendreKernel 1 t =
      Bernstein.polyEval [0, 1] t / 1 := by
  simp [legendreKernel_one, Bernstein.polyEval]

theorem legendre_horner_2 (t : Real) :
    legendreKernel 2 t =
      Bernstein.polyEval [-1, 0, 3] t / 2 := by
  rw [show 2 = 0+2 from rfl, legendreKernel_recurrence]
  rw [show 0+1 = 1 from rfl, legendre_horner_1, legendre_horner_0]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_3 (t : Real) :
    legendreKernel 3 t =
      Bernstein.polyEval [0, -3, 0, 5] t / 2 := by
  rw [show 3 = 1+2 from rfl, legendreKernel_recurrence]
  rw [show 1+1 = 2 from rfl, legendre_horner_2, legendre_horner_1]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_4 (t : Real) :
    legendreKernel 4 t =
      Bernstein.polyEval [3, 0, -30, 0, 35] t / 8 := by
  rw [show 4 = 2+2 from rfl, legendreKernel_recurrence]
  rw [show 2+1 = 3 from rfl, legendre_horner_3, legendre_horner_2]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_5 (t : Real) :
    legendreKernel 5 t =
      Bernstein.polyEval [0, 15, 0, -70, 0, 63] t / 8 := by
  rw [show 5 = 3+2 from rfl, legendreKernel_recurrence]
  rw [show 3+1 = 4 from rfl, legendre_horner_4, legendre_horner_3]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_6 (t : Real) :
    legendreKernel 6 t =
      Bernstein.polyEval [-5, 0, 105, 0, -315, 0, 231] t / 16 := by
  rw [show 6 = 4+2 from rfl, legendreKernel_recurrence]
  rw [show 4+1 = 5 from rfl, legendre_horner_5, legendre_horner_4]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_7 (t : Real) :
    legendreKernel 7 t =
      Bernstein.polyEval [0, -35, 0, 315, 0, -693, 0, 429] t / 16 := by
  rw [show 7 = 5+2 from rfl, legendreKernel_recurrence]
  rw [show 5+1 = 6 from rfl, legendre_horner_6, legendre_horner_5]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_8 (t : Real) :
    legendreKernel 8 t =
      Bernstein.polyEval [35, 0, -1260, 0, 6930, 0, -12012, 0, 6435] t / 128 := by
  rw [show 8 = 6+2 from rfl, legendreKernel_recurrence]
  rw [show 6+1 = 7 from rfl, legendre_horner_7, legendre_horner_6]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_9 (t : Real) :
    legendreKernel 9 t =
      Bernstein.polyEval [0, 315, 0, -4620, 0, 18018, 0, -25740, 0, 12155] t / 128 := by
  rw [show 9 = 7+2 from rfl, legendreKernel_recurrence]
  rw [show 7+1 = 8 from rfl, legendre_horner_8, legendre_horner_7]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_10 (t : Real) :
    legendreKernel 10 t =
      Bernstein.polyEval [-63, 0, 3465, 0, -30030, 0, 90090, 0, -109395, 0, 46189] t / 256 := by
  rw [show 10 = 8+2 from rfl, legendreKernel_recurrence]
  rw [show 8+1 = 9 from rfl, legendre_horner_9, legendre_horner_8]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_11 (t : Real) :
    legendreKernel 11 t =
      Bernstein.polyEval [0, -693, 0, 15015, 0, -90090, 0, 218790, 0, -230945, 0, 88179] t / 256 := by
  rw [show 11 = 9+2 from rfl, legendreKernel_recurrence]
  rw [show 9+1 = 10 from rfl, legendre_horner_10, legendre_horner_9]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_12 (t : Real) :
    legendreKernel 12 t =
      Bernstein.polyEval [231, 0, -18018, 0, 225225, 0, -1021020, 0, 2078505, 0, -1939938, 0, 676039] t / 1024 := by
  rw [show 12 = 10+2 from rfl, legendreKernel_recurrence]
  rw [show 10+1 = 11 from rfl, legendre_horner_11, legendre_horner_10]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_13 (t : Real) :
    legendreKernel 13 t =
      Bernstein.polyEval [0, 3003, 0, -90090, 0, 765765, 0, -2771340, 0, 4849845, 0, -4056234, 0, 1300075] t / 1024 := by
  rw [show 13 = 11+2 from rfl, legendreKernel_recurrence]
  rw [show 11+1 = 12 from rfl, legendre_horner_12, legendre_horner_11]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_14 (t : Real) :
    legendreKernel 14 t =
      Bernstein.polyEval [-429, 0, 45045, 0, -765765, 0, 4849845, 0, -14549535, 0, 22309287, 0, -16900975, 0, 5014575] t / 2048 := by
  rw [show 14 = 12+2 from rfl, legendreKernel_recurrence]
  rw [show 12+1 = 13 from rfl, legendre_horner_13, legendre_horner_12]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_15 (t : Real) :
    legendreKernel 15 t =
      Bernstein.polyEval [0, -6435, 0, 255255, 0, -2909907, 0, 14549535, 0, -37182145, 0, 50702925, 0, -35102025, 0, 9694845] t / 2048 := by
  rw [show 15 = 13+2 from rfl, legendreKernel_recurrence]
  rw [show 13+1 = 14 from rfl, legendre_horner_14, legendre_horner_13]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_16 (t : Real) :
    legendreKernel 16 t =
      Bernstein.polyEval [6435, 0, -875160, 0, 19399380, 0, -162954792, 0, 669278610, 0, -1487285800, 0, 1825305300, 0, -1163381400, 0, 300540195] t / 32768 := by
  rw [show 16 = 14+2 from rfl, legendreKernel_recurrence]
  rw [show 14+1 = 15 from rfl, legendre_horner_15, legendre_horner_14]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_17 (t : Real) :
    legendreKernel 17 t =
      Bernstein.polyEval [0, 109395, 0, -5542680, 0, 81477396, 0, -535422888, 0, 1859107250, 0, -3650610600, 0, 4071834900, 0, -2404321560, 0, 583401555] t / 32768 := by
  rw [show 17 = 15+2 from rfl, legendreKernel_recurrence]
  rw [show 15+1 = 16 from rfl, legendre_horner_16, legendre_horner_15]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_18 (t : Real) :
    legendreKernel 18 t =
      Bernstein.polyEval [-12155, 0, 2078505, 0, -58198140, 0, 624660036, 0, -3346393050, 0, 10039179150, 0, -17644617900, 0, 18032411700, 0, -9917826435, 0, 2268783825] t / 65536 := by
  rw [show 18 = 16+2 from rfl, legendreKernel_recurrence]
  rw [show 16+1 = 17 from rfl, legendre_horner_17, legendre_horner_16]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_19 (t : Real) :
    legendreKernel 19 t =
      Bernstein.polyEval [0, -230945, 0, 14549535, 0, -267711444, 0, 2230928700, 0, -10039179150, 0, 26466926850, 0, -42075627300, 0, 39671305740, 0, -20419054425, 0, 4418157975] t / 65536 := by
  rw [show 19 = 17+2 from rfl, legendreKernel_recurrence]
  rw [show 17+1 = 18 from rfl, legendre_horner_18, legendre_horner_17]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_20 (t : Real) :
    legendreKernel 20 t =
      Bernstein.polyEval [46189, 0, -9699690, 0, 334639305, 0, -4461857400, 0, 30117537450, 0, -116454478140, 0, 273491577450, 0, -396713057400, 0, 347123925225, 0, -167890003050, 0, 34461632205] t / 262144 := by
  rw [show 20 = 18+2 from rfl, legendreKernel_recurrence]
  rw [show 18+1 = 19 from rfl, legendre_horner_19, legendre_horner_18]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_21 (t : Real) :
    legendreKernel 21 t =
      Bernstein.polyEval [0, 969969, 0, -74364290, 0, 1673196525, 0, -17210021400, 0, 97045398450, 0, -328189892940, 0, 694247850450, 0, -925663800600, 0, 755505013725, 0, -344616322050, 0, 67282234305] t / 262144 := by
  rw [show 21 = 19+2 from rfl, legendreKernel_recurrence]
  rw [show 19+1 = 20 from rfl, legendre_horner_20, legendre_horner_19]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_22 (t : Real) :
    legendreKernel 22 t =
      Bernstein.polyEval [-88179, 0, 22309287, 0, -929553625, 0, 15058768725, 0, -124772655150, 0, 601681470390, 0, -1805044411170, 0, 3471239252250, 0, -4281195077775, 0, 3273855059475, 0, -1412926920405, 0, 263012370465] t / 524288 := by
  rw [show 22 = 20+2 from rfl, legendreKernel_recurrence]
  rw [show 20+1 = 21 from rfl, legendre_horner_21, legendre_horner_20]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_23 (t : Real) :
    legendreKernel 23 t =
      Bernstein.polyEval [0, -2028117, 0, 185910725, 0, -5019589575, 0, 62386327575, 0, -429772478850, 0, 1805044411170, 0, -4859734953150, 0, 8562390155550, 0, -9821565178425, 0, 7064634602025, 0, -2893136075115, 0, 514589420475] t / 524288 := by
  rw [show 23 = 21+2 from rfl, legendreKernel_recurrence]
  rw [show 21+1 = 22 from rfl, legendre_horner_22, legendre_horner_21]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_24 (t : Real) :
    legendreKernel 24 t =
      Bernstein.polyEval [676039, 0, -202811700, 0, 10039179150, 0, -194090796900, 0, 1933976154825, 0, -11345993441640, 0, 42117702927300, 0, -102748681866600, 0, 166966608033225, 0, -178970743251300, 0, 121511715154830, 0, -47342226683700, 0, 8061900920775] t / 4194304 := by
  rw [show 24 = 22+2 from rfl, legendreKernel_recurrence]
  rw [show 22+1 = 23 from rfl, legendre_horner_23, legendre_horner_22]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_25 (t : Real) :
    legendreKernel 25 t =
      Bernstein.polyEval [0, 16900975, 0, -1825305300, 0, 58227239070, 0, -859544957700, 0, 7091245901025, 0, -36100888223400, 0, 119873462177700, 0, -267146572853160, 0, 402684172315425, 0, -405039050516100, 0, 260382246760350, 0, -96742811049300, 0, 15801325804719] t / 4194304 := by
  rw [show 25 = 23+2 from rfl, legendreKernel_recurrence]
  rw [show 23+1 = 24 from rfl, legendre_horner_24, legendre_horner_23]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_26 (t : Real) :
    legendreKernel 26 t =
      Bernstein.polyEval [-1300075, 0, 456326325, 0, -26466926850, 0, 601681470390, 0, -7091245901025, 0, 49638721307175, 0, -222622144044300, 0, 667866432132900, 0, -1369126185872445, 0, 1923935489951475, 0, -1822675727322450, 0, 1112542327066950, 0, -395033145117975, 0, 61989816618513] t / 8388608 := by
  rw [show 26 = 24+2 from rfl, legendreKernel_recurrence]
  rw [show 24+1 = 25 from rfl, legendre_horner_25, legendre_horner_24]
  norm_num [Bernstein.polyEval]
  ring

theorem legendre_horner_27 (t : Real) :
    legendreKernel 27 t =
      Bernstein.polyEval [0, -35102025, 0, 4411154475, 0, -164094946470, 0, 2836498360410, 0, -27577067392875, 0, 166966608033225, 0, -667866432132900, 0, 1825501581163260, 0, -3463083881912655, 0, 4556689318306125, 0, -4079321865912150, 0, 2370198870707850, 0, -805867616040669, 0, 121683714103007] t / 8388608 := by
  rw [show 27 = 25+2 from rfl, legendreKernel_recurrence]
  rw [show 25+1 = 26 from rfl, legendre_horner_26, legendre_horner_25]
  norm_num [Bernstein.polyEval]
  ring

def covarianceNumerators : List Int := [721982573342717, 359875788443776, 306019504896234, 296511124364160, 109633128880275, -280934108155008, -497003517590580, 173911590762624, 1011757160809395, 0, -944306683422102, 0, 329076571495581, 0, 0, 0, 0]
def covarianceDenominator : Int := 1024000000000000

theorem covariance_horner_eq (t : Real) :
    Bernstein.polyEval covarianceNumerators t / covarianceDenominator =
      (161484410321/200000000000 : Real) + (116052895813/250000000000 : Real)*legendreKernel 1 t + (6404422103/31250000000 : Real)*legendreKernel 2 t + (8242861449/125000000000 : Real)*legendreKernel 3 t + (3167096277/500000000000 : Real)*legendreKernel 7 t + (486771579/1000000000000 : Real)*legendreKernel 12 t := by
  rw [legendre_horner_1, legendre_horner_2, legendre_horner_3, legendre_horner_7, legendre_horner_12]
  norm_num [covarianceNumerators, covarianceDenominator, Bernstein.polyEval]
  ring

def separationNumerators : List Int := [5919815272554396720, 2971499435933987775, 2486908273640924304, 2083894186361718675, -411561194918073200, -12806775597104351478, 17235270889478481840, 308245816481544833034, -168471623375778396960, -3449222389545755697875, 844916724044847950496, 21939845624108594316225, -2555437792672563486688, -89222051258574585264900, 4919532186704099580000, 245085532319210514924060, -6067423030268389482000, -465494167074957782300055, 4639794081969944898000, 612598947031319244121125, -2002437445902818324400, -548421914485181037594150, 372748095990567913200, 318648306044749456625850, 0, -108340424055214815252789, 0, 16359095370160641619367, 0, 0, 0, 0, 0]
def separationDenominator : Int := 8388608000000000000

theorem separation_horner_eq (t : Real) :
    Bernstein.polyEval separationNumerators t / separationDenominator =
      (201511290409/250000000000 : Real) + (230016480181/500000000000 : Real)*legendreKernel 1 t + (200888085899/1000000000000 : Real)*legendreKernel 2 t + (63087598053/1000000000000 : Real)*legendreKernel 3 t + (2838858731/500000000000 : Real)*legendreKernel 7 t + (490951549/1000000000000 : Real)*legendreKernel 12 t + (21702641/40000000000 : Real)*legendreKernel 17 t + (17715331/200000000000 : Real)*legendreKernel 22 t + (134439481/1000000000000 : Real)*legendreKernel 27 t := by
  rw [legendre_horner_1, legendre_horner_2, legendre_horner_3, legendre_horner_7, legendre_horner_12, legendre_horner_17, legendre_horner_22, legendre_horner_27]
  norm_num [separationNumerators, separationDenominator, Bernstein.polyEval]
  ring

end ThomsonN9.LPLinkage
