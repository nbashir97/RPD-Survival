###############################
### RPD Mortality AFT Model ###
###############################

###############################

# Preamble

library(haven)
library(tidyverse)
library(survival)
library(SurvRegCensCov)

###############################

# Loading in data

## Specifying file path
path <- "insert/path/to/data"

## Main analysis NHANES data
nhanes <- read_dta(paste0(path, "/nhanes3_propensity.dta")) %>%
  mutate(years = permth_int / 12, 
         age_recode = replace(age, age == 3, 0)) %>%
  filter(inAnalysis == 1)

## Sensitivity analysis NHANES data
nhanes_sens <- read_dta(paste0(path, "/nhanes3_propensity.dta")) %>%
  mutate(years = permth_int / 12,
         age_recode = replace(age, age == 3, 0)) %>%
  filter(inAnalysis == 1)

###############################

# Defining function to fit AFT model and return coefficients

fitAFT <- function(data, event, analysis) {
  
  if (analysis == "main") {
    
    survModel <- survreg(formula = Surv(time = years, event = get(paste(event))) ~ partial + as.factor(age_recode) + as.factor(sex) + 
                           as.factor(ethnicity) + income + as.factor(education) + as.factor(work) +
                           as.factor(smoking) + alcohol + activity + as.factor(insurance) +
                           cholesterol + hdl + triglyceride + crp + hba1c +
                           as.factor(bmi) + systolic + diastolic +
                           as.factor(health) + as.factor(arthritis) + as.factor(cancer) + as.factor(chronic) +
                           as.factor(chf) + as.factor(diab) + as.factor(emphysema) + as.factor(myocard) +
                           teeth,
                         data = data, weights = data$ipw, dist = "weibull")
    
  }
  
  else if (analysis == "sensitivity") {
    
    survModel <- survreg(formula = Surv(time = years, event = get(paste(event))) ~ partial + as.factor(age_recode) + as.factor(sex) + 
                           as.factor(ethnicity) + income + as.factor(education) + as.factor(work) +
                           as.factor(smoking) + alcohol + activity + as.factor(insurance) +
                           cholesterol + hdl + triglyceride + crp + hba1c +
                           as.factor(bmi) + systolic + diastolic +
                           as.factor(health) + as.factor(arthritis) + as.factor(cancer) + as.factor(chronic) +
                           as.factor(chf) + as.factor(diab) + as.factor(emphysema) + as.factor(myocard) +
                           as.factor(personal) + as.factor(routine) + as.factor(movement) +
                           teeth,
                         data = data, weights = data$ipw, dist = "weibull")
    
  }

  
  aftModel <- ConvertWeibull(model = survModel, conf.level = 0.95)
  aftModel$ETR
  
}

###############################



deaths <- c("death", "death_cvd", "death_cancer")

# Main analysis

for (death in deaths) {
  print(fitAFT(data = nhanes_sens, event = death, analysis = "main"))
}

# Sensitivity analysis

for (death in deaths) {
  print(fitAFT(data = nhanes, event = death, analysis = "sensitivity"))
}

###############################
