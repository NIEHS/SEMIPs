load ("dataSEM/parsedNewDT.rda")
load ("dataSEM/new_t_scores_w_lev.rda")

endoVars <- c(colnames(dat),colnames(NewDT)) # Get variables
exoVars <- c(colnames(dat)) # Get variables

tabPanel("SEM", 
         br(),
         
         tabsetPanel(
             tabPanel("Model", 
                      fluidRow(
                          column(3, # Drop down menus
                                 selectInput("exo1",label="Choose a exogenous variable", choices=endoVars, selected="GATA2_act_FC13_P01"), 
                                 selectInput("exo2",label="Choose a exogenous variable", choices=endoVars, selected="PRG_act_FC13_P01"),
                                 selectInput("endo",label="Choose a endogenous variable", choices=endoVars, selected="SOX17_lev")),
                          column(5,div(style="display: inline-block;vertical-align:top;",verbatimTextOutput("semSummary")))),
                      column(4, # SEM Model image
                             div(style="display: inline-block;vertical-align:top;",imageOutput("semModel")))
             ),
             tabPanel("SEM Intro",includeMarkdown("instructions/SEMIntro.Rmd")) # Intro markdown file
             
         )
)



