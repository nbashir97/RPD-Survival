************************************
*** Partial Dentures & Mortality ***
************************************

*** Do-File 8: Sensitivity Analysis - Survival Analysis ***

****************************************************************

use "`path'/nhanes3_sens_propensity.dta", clear

** Survival analysis **

** Convert months to years
generate years = permth_int / 12

** Stset the data (choose according to cause of death)
* All-cause
stset years [pweight = ipw], id(SEQN) failure(death == 1) 
* Cardiovascular
stset years [pweight = ipw], id(SEQN) failure(death_cvd == 1) 
* Cancer
stset years [pweight = ipw], id(SEQN) failure(death_cancer == 1)

** Mortality rate
stptime if(inAnalysis == 1), by(partial)
strate partial if(inAnalysis == 1), per(1000)

** Mortality rate difference
* All-cause
iri 361 386 8910 7756
* Cardiovascular
iri 108 130 8910 7756
* Cancer
iri 74 73 8910 7756

** NNT
* All-cause
ltable years death if(inAnalysis == 1) [w = fwt], by(partial)
di 1 / (0.8043 - 0.6475)
* Cardiovascular NNT
ltable years death_cvd if(inAnalysis == 1) [w = fwt], by(partial)
di 1 / (0.9588 - 0.8411)
* Cancer NNT
ltable years death_cancer if(inAnalysis == 1) [w = fwt], by(partial)
di 1 / (0.9359 - 0.9102)

** Median survival time
stsum if(inAnalysis == 1), by(partial)

****************************************************************