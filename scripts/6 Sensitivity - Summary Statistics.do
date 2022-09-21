************************************
*** Partial Dentures & Mortality ***
************************************

*** Do-File 6: Sensitivty Analysis - Summary Statistics ***

****************************************************************

local path "insert/path/to/data"
use "`path'/nhanes3_sens_cleaned.dta", clear

** Baseline summary statistics **

tab partial if(inAnalysis == 1)

* Categorical variables

local cat_vars age sex ethnicity education work smoking insurance bmi health arthritis cancer chronic chf diab emphysema myocard personal routine movement

foreach var of varlist `cat_vars' {
	tab `var' partial if(inAnalysis == 1)
	xi: pbalchk partial i.`var' if(inAnalysis == 1)
}

* Continuous variables

local cont_vars income alcohol activity cholesterol hdl triglyceride crp hba1c systolic diastolic teeth

foreach var of varlist `cont_vars' {
	stddiff `var' if(inAnalysis == 1), by(partial)
} 

****************************************************************
