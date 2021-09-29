##===========================================================================
##  Project: SEMIPs Structural Equation Modeling of In silico Perturbations
##  github: https://github.com/NIEHS/SEMIPs 
##  FileName: helpers.R
##  Author: Kevin Day
##  Comment: 
##      This File lists all R packages needed for this app
##      Once it is run, it will check whether installed properly, 
##      will install it if needed
##============================================================================

list.of.packages <- c("shiny",
                      "DT",
                      "readxl",
                      "tidyr",
                      "stringr",
                      "shinycssloaders",
                      "markdown",
                      "parallel",
                      "foreach",
                      "doParallel",
                      "bigstatsr", 
                      "tools",
                      "lavaan",
                      "png")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

for (i in list.of.packages)
{
  eval (parse(text=paste0("library(\"" ,i , "\")")))
}

# Reset if parallel connections on edelgene server didn't close properly (exited app during bootstrap)
if (nrow(showConnections()) > 38) { 
  pskill(Sys.getpid(), signal = SIGTERM)
}

##  The following are default data file to be loaded when the app is launched
Reference <- read_excel("Reference.xlsx") # Mouse to human reference table
allSig <- read_excel("allSig.xlsx") # All gene signature (high/low) table


