************************************
*** Partial Dentures & Mortality ***
************************************

*** Do-File 4x: Survival Analysis ***

****************************************************************

use "`path'/nhanes3_propensity.dta", clear

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
iri 410 435 11917 10640
* Cardiovascular
iri 130 141 11917 10640
* Cancer
iri 93 85 11917 10640

** NNT
* All-cause
ltable years death if(inAnalysis == 1) [w = fwt], by(partial)
di 1 / (0.8280 - 0.6944)
* Cardiovascular NNT
ltable years death_cvd if(inAnalysis == 1) [w = fwt], by(partial)
di 1 / (0.9559 - 0.8706)
* Cancer NNT
ltable years death_cancer if(inAnalysis == 1) [w = fwt], by(partial)
di 1 / (0.9412 - 0.9214)

** Median survival time
stsum if(inAnalysis == 1), by(partial)

* Figures

** KM survival
sts graph if(inAnalysis == 1), by(partial) ///
legend(order(1 "Non-RPD wearers" 2 "RPD wearers") size(small) ring(0)) ///
title("") ///
xtitle("Follow-up time (years)", size(small)) ///
ytitle("Survival probability", size(small)) ///
xlabel(0(5)35, labsize(small)) ///
ylabel(0(0.2)1, labsize(small) format(%03.2f)) ///
graphregion(color(white) margin(zero)) ///
aspectratio(0.8) ///
scheme(cleanplots)

graph save "Graph" "`path'\km_plot.gph", replace

****************************************************************