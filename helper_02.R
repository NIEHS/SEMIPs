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

Reference <- read_excel("Reference.xlsx") # Mouse to human reference table
allSig <- read_excel("allSig.xlsx") # All gene signature (high/low) table
