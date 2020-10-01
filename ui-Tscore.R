tabPanel("T Scores", br(),
        downloadButton("downloadData", "Download T-Scores"),br(), br(), 
         DT::dataTableOutput("tTable")%>% withSpinner(type=8,color="#FF3333"))