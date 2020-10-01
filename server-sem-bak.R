# Load T-Scores variables, SEM blank image
load ("dataSEM/parsedNewDT.rda") 
load ("dataSEM/new_t_scores_w_lev.rda")
Combined <- as.data.frame(c(dat,NewDT))
img <- readPNG("www/SEMBlank2.png")
img <- as.raster(img)

# User select variables
chosenExo1 <- reactive({    
  input$exo1
})

chosenExo2 <- reactive({    
  input$exo2
})

chosenEndo <- reactive({    
  input$endo
})

# Output lavaan sem
output$semSummary <- renderPrint({
  mod <- paste0(chosenEndo()," ~ ",chosenExo1()," + ", chosenExo2())
  mod.fit <<- sem(mod, data=Combined)
  summary(mod.fit)
})

# Create SEM model image
output$semModel <- renderImage ({
  # Values on SEM
  exo1endo <- parameterestimates(mod.fit)[1,7] # pvalue between exo1 and endo
  exo2endo <- parameterestimates(mod.fit)[2,7] # pvalue between exo2 and endo
  endosCor <- as.numeric(cor.test(Combined[,chosenExo1()],Combined[,chosenExo2()])$estimate) # correlation between endos
  endosPvalue <- cor.test(Combined[,chosenExo1()],Combined[,chosenExo2()])$p.value # pvalue between endos
  
  # Temp directory setup
  tmpdir <- tempdir()
  filePath <- paste0(tmpdir,"/myplot.png")
  
  # Plotting on png to save in temp directory
  png(file=filePath, bg="transparent",width=800, height=800,res=1000) # Start png
  par(mar=rep(0, 4),bg = 'white')
  plot(1:9.9,type='n',axes=FALSE,ann=FALSE)
  rasterImage(img, 1, 1, 9, 9)
  text(2.55,7.1,chosenExo1(),cex=.1)
  text(7.45,7.1,chosenExo2(),cex=.1)
  text(5,2.25,chosenEndo(),cex=.1)
  text(3,4.5,paste0("p = ",signif(exo1endo)),cex=.1)
  text(7.5,4.5,paste0("p = ",signif(exo2endo)),cex=.1)
  text(5,9.1,paste0("r = ",signif(endosCor),", (p = ",signif(endosPvalue),")"),cex=.1)
  dev.off() # End png
  
  # Retrieve created png
  list(
    src = filePath,
    contentType = "image/png")
  
},deleteFile = FALSE)