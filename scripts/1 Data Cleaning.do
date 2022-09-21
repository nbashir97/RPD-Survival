************************************
*** Partial Dentures & Mortality ***
************************************

*** Do-File 1: Data Cleaning ***

local path "insert/path/to/data"
use "`path'/nhanes3.dta", clear

****************************************************************

** Sociodemographics **

* Age
generate age = 1 if(HSAGEIR >= 18 & HSAGEIR < 30)
replace age = 2 if(HSAGEIR >= 30 & HSAGEIR < 40)
replace age = 3 if(HSAGEIR >= 40 & HSAGEIR < 50)
replace age = 4 if(HSAGEIR >= 50 & HSAGEIR < 60)
replace age = 5 if(HSAGEIR >= 60 & HSAGEIR < 70)
replace age = 6 if(HSAGEIR >= 70)
replace age = . if missing(HSAGEIR)

label define age_lab 1 "18-29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "≥70"
label values age age_lab

* Sex
generate sex = HSSEX

label define sex_lab 1 "Male" 2 "Female"
label values sex sex_lab

* Ethnicity
generate ethnicity = DMARETHN

label define eth_lab 1 "White" 2 "Black" 3 "MexAm" 4 "Other"
label values ethnicity eth_lab

* Income
generate income = DMPPIR
replace income = . if missing(DMPPIR)
replace income = . if(DMPPIR == 888888)

* Education
generate education = 1 if(HFA8R < 12)
replace education = 2 if(HFA8R == 12)
replace education = 3 if(HFA8R > 12)
replace education = . if(HFA8R == 88 | HFA8R == 99 | HFA8R == .)

label define educ_lab 1 "Below" 2 "HighSchool" 3 "More"
label values education educ_lab

* Occupation
generate work = 1 if(HAS1 == 1 | HAS2 == 1)
replace work = 2 if(HAS2 == 2)

label define work_lab 1 "Works" 2 "NoWork"
label values work work_lab

****************************************************************

** Behavioural and insurance **

* Smoking
generate smoking = 1 if(HAR1 == 2)
replace smoking = 2 if(HAR1 == 1 & HAR3 == 2)
replace smoking = 3 if(HAR1 == 1 & HAR3 == 1)

label define smk_lab 1 "Never" 2 "Former" 3 "Current"
label values smoking smk_lab

* Alcohol
recode MAPE3S(888 = .)
recode MAPE3S(999 = .)

generate alcohol = MAPE4 / (365 / MAPE3S)
replace alcohol = 0 if(MAPE1 == 2)
replace alcohol = 0 if(MAPE2 == 2)

* Physical activity
foreach var of varlist HAT3S HAT7S HAT9S HAT20S HAT22S HAT24S HAT26S {
	replace `var' = . if(`var' == 8888 | `var' == 9998 | `var' == 9999) 
}

foreach i in 3 7 9 {
	local j = `i' - 1
	replace HAT`i'S = 0 if(HAT`j' == 2)
}

foreach i in 20 22 24 26 {
	local j = `i' - 1
	replace HAT`i'S = 0 if(HAT`j'MET < 6)
	replace HAT`i'S = . if(HAT`j'MET > 12)
}

foreach var of varlist HAT20S HAT22S HAT24S HAT26S {
	replace `var' = 0 if(HAT18 == 2)
}

egen activity = rowtotal(HAT3S HAT7S HAT9S HAT20S HAT22S HAT24S HAT26S), missing

foreach var of varlist HAT3S HAT7S HAT9S HAT20S HAT22S HAT24S HAT26S {
	replace activity = . if missing(`var') 
}

* Insurance
generate insurance = 1 if(HFB13 == 1)
replace insurance = 2 if(HFB13 == 2)

label define ins_lab 1 "Insured" 2 "Uninsured"
label values insurance ins_lab

****************************************************************

** Laboratory **

* Total cholesterol
generate cholesterol = TCP
replace cholesterol = . if(TCP == 888)

* HDL cholesterol
generate hdl = HDP
replace hdl = . if(HDP == 888)

* Triglycerides
generate triglyceride = TGP
replace triglyceride = . if(TGP == 8888)

* C-reactive protein
generate crp = CRP
replace crp = . if(CRP == 88888)

* Glycated hemoglobin
generate hba1c = GHP if(GHP != 8888)
replace hba1c = . if(GHP == 8888)

****************************************************************

** General health status **

* BMI
generate bmi = 1 if(BMPBMI < 18.5)
replace bmi = 2 if(BMPBMI >= 18.5 & BMPBMI < 25)
replace bmi = 3 if(BMPBMI >= 25 & BMPBMI != .)
replace bmi = . if(BMPBMI == 8888)

label define bmi_lab 1 "Under" 2 "Normal" 3 "Over"
label values bmi bmi_lab

* Systolic BP
generate systolic = HAZMNK1R
replace systolic = . if(HAZNOK1R == 1 | HAZNOK1R == 2 | HAZNOK1R == 88 | HAZNOK1R == .)

* Diastolic BP
generate diastolic = HAZMNK5R
replace systolic = . if(HAZNOK5R == 1 | HAZNOK5R == 2 | HAZNOK5R == 88 | HAZNOK5R == .)

* Self-reported health
generate health = HAB1 if(HAB1 >= 1 & HAB1 <= 5)

label define health_lab 1 "Excellent" 2 "Vgood" 3 "Good" 4 "Fair" 5 "Poor"
label values health health_lab

* Medical conditions
generate arthritis = HAC1A if(HAC1A != 8 & HAC1A != 9)
generate chronic = HAC1F if(HAC1F != 8 & HAC1F != 9)
generate cancer = HAC1O if(HAC1O != 8 & HAC1O != 9)
generate chf = HAC1C if(HAC1C != 8 & HAC1C != 9)
generate diab = HAD1 if(HAD1 != 8 & HAD1 != 9)
replace diab = 0 if(HAD4 == 2)
generate emphysema = HAC1G if(HAC1G != 8 & HAC1G != 9)
generate myocard = HAF10 if(HAF10 != 8 & HAF10 != 9)

foreach var of varlist icd9code_* {
	replace arthritis = 1 if(`var' == "714.0" | `var' == "715.00" | `var' == "716.66")
	replace chronic = 1 if(`var' == "491.9")
	replace cancer = 1 if(`var' == "149.0" | `var' == "153.3" | `var' == "174.9" | `var' == "185" | `var' == "189.0" | `var' == "193" | `var' == "199.1" | `var' == "208.9")
	replace chf = 1 if(`var' == "428.0")
	replace diab = 1 if(`var' == "250.0" | `var' == "250.9")
	replace emphysema = 1 if(`var' == "492.8")
	replace myocard = 1 if(`var' == "410.9")
}

label define med_lab 0 "No" 1 "Yes"

foreach var of varlist arthritis-myocard {
	replace `var' = 0 if(`var' == 2)
	label values `var' med_lab
}

****************************************************************

** Oral health **

* Number of teeth

egen teeth = anycount(DEPCT1-DEPCT28), values(0 5 7 8 9)

* Partial denture status

generate edentulous = 1 if(DEPEDENT == 1 | DEPEDENT == 2)
replace edentulous = 1 if(DEPUPTYP == 1 | DEPLPTYP == 1)
replace edentulous = 1 if(teeth == 0)

generate partial = 1 if(DEPUPTYP == 2 | DEPLPTYP == 2)
recode partial(. = 0)

label define dent_lab 0 "No" 1 "Yes"
label values partial dent_lab

****************************************************************

** Mortality **

generate death = mortstat

generate death_cvd = 1 if(death == 1 & ucod_leading == 1)
replace death_cvd = 0 if((death == 0) | (death == 1 & ucod_leading != 1))

generate death_cancer = 1 if(death == 1 & ucod_leading == 2)
replace death_cancer = 0 if((death == 0) | (death == 1 & ucod_leading != 2))

****************************************************************

** Creating subpopulations for analyses **

* Counting numbers dropped for manuscript

generate inAnalysis = 1
replace inAnalysis = . if missing(age)
replace inAnalysis = . if(teeth >= 20)
replace inAnalysis = . if(edentulous == 1)
replace inAnalysis = . if(eligstat != 1)

foreach var of varlist age-myocard {
	replace inAnalysis = . if missing(`var')
}

****************************************************************

keep age-inAnalysis SEQN eligstat permth_int

save "`path'/nhanes3_cleaned.dta", replace
