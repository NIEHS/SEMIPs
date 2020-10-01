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

tabPanel("CustomSEM", 
         
         br(),
         
         fluidRow(
           
           div(style="display: inline-block;vertical-align:top; width: 275px;",fileInput("fileSubset","User provided file for SEM")), # Subset file input
           div(style="display: inline-block;vertical-align:top; width: 30px;",HTML("<br>")),
           
           
           br(),
           br(),

          fluidRow(
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
         actionButton("goButton", "Run SEM",
                      style="font-weight: bold; color: #00FF08; background-color: #aea79f; border-color: #aea79f"),
         br()
)
)

