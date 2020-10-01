##===================================================
##  dynamicUI_02.R
##  jianying li
##  https://mastering-shiny.org/action-dynamic.html
##===================================================

parameter_tabs <- tabsetPanel(
  id = "params",
  type = "hidden",
  tabPanel("normal",
           numericInput("mean", "mean", value = 1),
           numericInput("sd", "standard deviation", min = 0, value = 1)
  ),
  tabPanel("uniform", 
           numericInput("min", "min", value = 0),
           numericInput("max", "max", value = 1)
  ),
  tabPanel("exponential",
           numericInput("rate", "rate", value = 1, min = 0),
  )
)

tabPanel("SEM", 
         
         br(),
         
         fluidRow(
           
           div(style="display: inline-block;vertical-align:top; width: 275px;",fileInput("fileSubset","User provided file for SEM")), # Subset file input
           div(style="display: inline-block;vertical-align:top; width: 30px;",HTML("<br>")),
           
           
           br(),
           actionButton("goButton", "Run SEM",
                        style="font-weight: bold; color: #00FF08; background-color: #aea79f; border-color: #aea79f"),
           br(),
           br(),
           tabsetPanel(
             tabPanel("Model", 
                      fluidRow(
                        #column(3, # Drop down menus
                         #      selectInput("exo1",label="Choose a exogenous variable", choices=endoVars, selected="GATA2_act_FC13_P01"), 
                        #       selectInput("exo2",label="Choose a exogenous variable", choices=endoVars, selected="PRG_act_FC13_P01"),
                        #       selectInput("endo",label="Choose a endogenous variable", choices=endoVars, selected="SOX17_lev")),
                        #column(5,div(style="display: inline-block;vertical-align:top;",verbatimTextOutput("semSummary")))),
                      #column(4, # SEM Model image
                       #      div(style="display: inline-block;vertical-align:top;",imageOutput("semModel")))
                      
                        column(3,
                            selectInput("dist", "Distribution", 
                                    choices = c("normal", "uniform", "exponential")
                            ),
                            numericInput("n", "Number of samples", value = 100),
                            parameter_tabs,
                        ),
                        column(4,
                            plotOutput("hist")
                        )
              ),
             tabPanel("SEM Intro",includeMarkdown("instructions/SEMIntro.Rmd")) # Intro markdown file
           )
         )
)
)

