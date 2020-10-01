# Packages
library(shiny)
library(DT)
library(readxl)
library(tidyr)
library(stringr)
library(shinycssloaders)
library(markdown)
library(parallel)
library(foreach)
library(doParallel)
library(bigstatsr) #FBM for parallel
library(tools)
library(lavaan)
library(png)

# install.packages(c("shiny", "DT", "readxl", "tidyr", "stringr", "shinycssloaders", "markdown", "parallel", "foreach", "doParallel", "bigstatsr", "tools", "lavaan", "png"))

# Reset if parallel connections on edelgene server didn't close properly (exited app during bootstrap)
if (nrow(showConnections()) > 38) { 
	pskill(Sys.getpid(), signal = SIGTERM)
}

Reference <- read_excel("Reference.xlsx") # Mouse to human reference table
allSig <- read_excel("allSig.xlsx") # All gene signature (high/low) table