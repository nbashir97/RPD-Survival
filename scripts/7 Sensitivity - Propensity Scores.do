************************************
*** Partial Dentures & Mortality ***
************************************

*** Do-File 7: Sensitivity Analysis - Propensity Score Weighting ***

****************************************************************

local path "insert/path/to/data"
use "`path'/nhanes3_sens_cleaned.dta", clear

** IPW weighted sample **

* Generating IPW weights

generate loghdl = log(hdl)

logistic partial i.age i.sex i.ethnicity i.education i.work i.smoking i.insurance i.bmi i.health i.arthritis i.cancer i.chronic i.chf i.diab i.emphysema i.myocard i.personal i.routine i.movement income alcohol activity cholesterol loghdl triglyceride crp hba1c systolic diastolic teeth if(inAnalysis == 1)

predict double ps
generate double ipw = 1.partial/ps + 0.partial/(1-ps)

sum ipw if(inAnalysis == 1), mean
qui replace ipw = ipw/r(mean)

* Convert pweights to fweights for later use
generate fwt = round(100 * ipw, 1)

save "`path'/nhanes3_sens_propensity.dta", replace

* Specifying weights

svyset [pweight = ipw]
svy, subpop(if inAnalysis == 1): tabulate partial, count format(%11.3g)

* Categorical variables

local cat_vars age sex ethnicity education work smoking insurance bmi health arthritis cancer chronic chf diab emphysema myocard personal routine movement

foreach var of varlist `cat_vars' {
	svy, subpop(if inAnalysis == 1): tabulate `var' partial, count format(%11.3g)
	xi: pbalchk partial i.`var' if(inAnalysis == 1), wt(ipw)
} 

* Continuous variables

local cont_vars income alcohol activity cholesterol loghdl triglyceride crp hba1c systolic diastolic teeth

foreach var of varlist `cont_vars' {
	qui svy, subpop(if inAnalysis == 1): mean `var', over(partial)
	estat sd
	pbalchk partial `var' if(inAnalysis == 1), wt(ipw)
} 

****************************************************************
