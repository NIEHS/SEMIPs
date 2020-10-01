tabPanel("Bootstrap",
         fluidRow(
           
           div(style="display: inline-block;vertical-align:top; width: 275px;",fileInput("fileSubset","Upload the subset file")), # Subset file input
           div(style="display: inline-block;vertical-align:top; width: 30px;",HTML("<br>")),
           radioButtons("radio", label = h3("Bootstrap selections"),
                        choices = list("Elimination with replacement" = 1, "Elimination without replacement" = 2), 
                        selected = 1),
           div(style="display: inline-block;vertical-align:top; width: 30px;",HTML("<br>")),
           div(style="display: inline-block;vertical-align:middle; width: 130px;",numericInput("bootNum","Enter number of random bootstraps",value=1000)), #Default 1000
           div(style="display: inline-block;vertical-align:middle; width: 30px;",HTML("<br>")),
           actionButton("goButton2", "Go!",
                        style="font-weight: bold;color: #000000; background-color: #00FF08; border-color: #aea79f"), # Go button
           div(style="display: inline-block;vertical-align:top; width: 30px;",HTML("<br>")),
           downloadButton("bootdownload", "Download Zip",
                          style="font-weight: bold;color: #000000; background-color: #F17F2B; border-color: #aea79f") # Download zip button
           ,
           htmlOutput("foo"), # All files created display
           div(style = 'margin: auto',DT::dataTableOutput("Subset",width = "100%")) # Render subset table
         )
)