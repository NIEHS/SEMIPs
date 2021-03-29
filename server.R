options(warn=-1) # Hide warnings
options(shiny.maxRequestSize=300*1024^2) # Change max file input size
source("helpers.R")

# source("helper_02.R")

function(input, output) {
  # Global values environment for storing input & processed variables
  globalValues <- reactiveValues(
       MasterSig=data.frame(),
       MasterArray=data.frame(),
       VanillaSig=data.frame(),
       VanillaArray=data.frame(),
       subset=data.frame(),
       directory=character(),
       fileNames=character()
  )

  # Correspond to tabs
  source("server-Tscore.R",local = TRUE)
  source("server-bootstrap.R",local = TRUE)
  source("server-sem.R",local = TRUE)
  
}
