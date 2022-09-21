##########################
### RPD Mortality GLRT ###
##########################

##########################

# Preamble

library(haven)

##########################

# Loading in data

## Specifying file path
path <- "insert/path/to/data"

## Main analysis NHANES data
nhanes <- read_dta(paste0(path, "/nhanes3_cleaned.dta"))

## Sensitivity analysis NHANES data
nhanes_sens <- read_dta(paste0(path, "/nhanes3_sens_cleaned.dta"))

##########################

# Specifying covariates

categorical_main <- c("age", "sex", "ethnicity", "education", "work",
                      "smoking", "insurance", "bmi", "health",
                      "arthritis", "cancer", "chronic", "chf", "diab", "emphysema", "myocard")

daily_living <- c("personal", "routine", "movement")

categorical_sens <- append(categorical_main, daily_living)


continuous <- c("income", "alcohol", "activity",
                "cholesterol", "hdl", "triglyceride", "crp", "hba1c",
                "systolic", "diastolic", "teeth")

##########################

runGLRT <- function(data, analysis) {
  
  if (analysis == "main") {
    
    for (i in seq_along(categorical_main)) {
      
      var <- categorical_main[i]
      formula <- paste0("partial ~ as.factor(", var, ")")
      model <- as.formula(formula)
      
      logistic <- glm(formula = model, family = "binomial",
                      data = subset(data, inAnalysis == 1))
      
      resid_dev <- logistic$deviance
      null_dev <- logistic$null.deviance
      difference <- null_dev - resid_dev
      pval <- pchisq(q = difference, df = 1, lower.tail = F)
      
      print(paste0(var, " - pval: ", round(pval, 3)))
      
    }
    
    for (i in seq_along(continuous)) {
      
      var <- continuous[i]
      formula <- paste0("partial ~ ", var)
      model <- as.formula(formula)
      
      logistic <- glm(formula = model, family = "binomial",
                      data = subset(data, inAnalysis == 1))
      
      resid_dev <- logistic$deviance
      null_dev <- logistic$null.deviance
      difference <- null_dev - resid_dev
      pval <- pchisq(q = difference, df = 1, lower.tail = F)
      
      print(paste0(var, " - pval: ", round(pval, 3)))
      
    }
    
  }
  
  else if (analysis == "sensitivity") {
    
    for (i in seq_along(categorical_sens)) {
      
      var <- categorical_sens[i]
      formula <- paste0("partial ~ as.factor(", var, ")")
      model <- as.formula(formula)
      
      logistic <- glm(formula = model, family = "binomial",
                      data = subset(data, inAnalysis == 1))
      
      resid_dev <- logistic$deviance
      null_dev <- logistic$null.deviance
      difference <- null_dev - resid_dev
      pval <- pchisq(q = difference, df = 1, lower.tail = F)
      
      print(paste0(var, " - pval: ", round(pval, 3)))
      
    }
    
    for (i in seq_along(continuous)) {
      
      var <- continuous[i]
      formula <- paste0("partial ~ ", var)
      model <- as.formula(formula)
      
      logistic <- glm(formula = model, family = "binomial",
                      data = subset(data, inAnalysis == 1))
      
      resid_dev <- logistic$deviance
      null_dev <- logistic$null.deviance
      difference <- null_dev - resid_dev
      pval <- pchisq(q = difference, df = 1, lower.tail = F)
      
      print(paste0(var, " - pval: ", round(pval, 3)))
      
    }
    
  }
  
}

##########################

# Main analysis GLRT
runGLRT(data = nhanes, analysis = "main")

# Sensitivity analysis GLRT
runGLRT(data = nhanes, analysis = "sensitivity")

##########################