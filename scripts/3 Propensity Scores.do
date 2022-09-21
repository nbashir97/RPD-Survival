************************************
*** Partial Dentures & Mortality ***
************************************

*** Do-File 3: Propensity Score Weighting ***

****************************************************************

local path "insert/path/to/data"
use "`path'/nhanes3_cleaned.dta", clear

** IPW weighted sample **

* Generating IPW weights

logistic partial i.age i.sex i.ethnicity i.education i.work i.smoking i.insurance i.bmi i.health i.arthritis i.cancer i.chronic i.chf i.diab i.emphysema i.myocard income alcohol activity cholesterol hdl triglyceride crp hba1c systolic diastolic teeth if(inAnalysis == 1)

predict double ps
generate double ipw = 1.partial/ps + 0.partial/(1-ps)

sum ipw if(inAnalysis == 1), mean
qui replace ipw = ipw/r(mean)

* Convert pweights to fweights for later use
generate fwt = round(100 * ipw, 1)

save "`path'/nhanes3_propensity.dta", replace

* Specifying weights

svyset [pweight = ipw]
svy, subpop(if inAnalysis == 1): tabulate partial, count format(%11.3g)

* Categorical variables

local cat_vars age sex ethnicity education work smoking insurance bmi health arthritis cancer chronic chf diab emphysema myocard

foreach var of varlist `cat_vars' {
	svy, subpop(if inAnalysis == 1): tabulate `var' partial, count format(%11.3g)
	xi: pbalchk partial i.`var' if(inAnalysis == 1), wt(ipw)
} 

* Continuous variables

local cont_vars income alcohol activity cholesterol hdl triglyceride crp hba1c systolic diastolic teeth

foreach var of varlist `cont_vars' {
	qui svy, subpop(if inAnalysis == 1): mean `var', over(partial)
	estat sd
	pbalchk partial `var' if(inAnalysis == 1), wt(ipw)
} 

****************************************************************
