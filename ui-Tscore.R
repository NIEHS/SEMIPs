##===========================================================================
##  Project: SEMIPs Structural Equation Modeling of In silico Perturbations
##  github: https://github.com/NIEHS/SEMIPs 
##  FileName: ui-Tscores.R
##  Author: Kevin Day
##  Comment: 
##      This is the front end UI for Tscores calculation
##============================================================================
tabPanel("T Scores", br(),
        downloadButton("downloadData", "Download T-Scores"),br(), br(), 
         DT::dataTableOutput("tTable")%>% withSpinner(type=8,color="#FF3333"))