dat <- NULL

if (file.exists("dataSEM/sampleDAT.txt")){
  dt <- read.table ("dataSEM/sampleDAT.txt", sep="\t", header = TRUE )
  dat <- as.data.frame(dt[,-1])
  rownames(dat) <- dt[,1]
}else{
  load ("dataSEM/parsedNewDT.rda")
  load ("dataSEM/new_t_scores_w_lev.rda")
  dat <- as.data.frame(c(dat,NewDT))
}


endoVars <- c(colnames(dat)) # Get variables


tabPanel("SEM", 
         br(),
         
         tabsetPanel(
           tabPanel("Model", 
                    fluidRow(
                      column(3, # Drop down menus
                             selectInput("exo1",label="Choose a exogenous variable", choices=endoVars, selected="GATA2_act_FC13_P01"), 
                             selectInput("exo2",label="Choose a exogenous variable", choices=endoVars, selected="PRG_act_FC13_P01"),
                             selectInput("endo",label="Choose a endogenous variable", choices=endoVars, selected="SOX17_lev"),
                             downloadButton("semdownload", "Download Zip",
                                            style="font-weight: bold;color: #000000; background-color: #F17F2B; border-color: #aea79f")),
                      column(5,div(style="display: inline-block;vertical-align:top;",verbatimTextOutput("semSummary")))),
                    column(4, # SEM Model image
                           div(style="display: inline-block;vertical-align:top;",imageOutput("semModel")))
           ),
           tabPanel("SEM Intro",includeMarkdown("instructions/SEMIntro.Rmd")) # Intro markdown file
           
         )
)        




