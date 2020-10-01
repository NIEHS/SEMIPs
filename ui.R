options(warn=-1)
source("helpers.R")

fluidPage(
           
  titlePanel("Signature Analysis"),
  
  
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(width=4,
      div(style="display: inline-block;vertical-align:top; width: 275px;",fileInput("fileSignature","Upload the signature file")), # Sig file input
      div(style="display: inline-block;vertical-align:top; width: 10px;",HTML("<br>")),
      div(style="display: inline-block;vertical-align:top; width: 100px;",radioButtons("radioGene", label="Gene Type",choices = list("Mouse" = 1, "Human" = 2),selected = 1)), # Mouse/Human choice
      br(),
      conditionalPanel("output.sigUploaded",div(style = 'height: 200px;margin: auto; overflow-y: scroll',DT::dataTableOutput("Sig",width = "100%"))), # Display sig only after input
      br(),
      div(style="display: inline-block;vertical-align:top; width: 275px;",fileInput("fileArray","Upload the human microarray file")), # Array file input
      br(),
      conditionalPanel("output.arrayUploaded",div(style = 'overflow-x: scroll',DT::dataTableOutput("Array",width = "100%"))), # Display array only after input
      br(),
      actionButton("goButton", "Go!",
                   style="font-weight: bold; color: #00FF08; background-color: #aea79f; border-color: #aea79f")
      
      
    
  ),
  tagList(
  mainPanel(
  navbarPage( # Theme and tabs
    
    theme = "bootstrap.min.cerulean.css",
    title = "Tabs:",
      
      source("ui-Tscore.R",local=TRUE)$value,
      source("ui-bootstrap.R",local=TRUE)$value,
      source("ui-sem.R",local=TRUE)$value,
      source("ui-instructions.R",local=TRUE)$value
    
      
    )
  ) #end navbarpage
) #end taglist
)
)
