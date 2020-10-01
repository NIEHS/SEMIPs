checkRadioGene <- reactive({  # Mouse/Human select
  input$radioGene
})


# Reactive display sig table
output$sigUploaded <- reactive({  
  return(!is.null(input$fileSignature))
})
outputOptions(output, 'sigUploaded', suspendWhenHidden=FALSE)

# Reactive display array table
output$arrayUploaded <- reactive({  
  return(!is.null(input$fileArray))
})
outputOptions(output, 'arrayUploaded', suspendWhenHidden=FALSE)


# Sig file table display
output$Sig <- renderDataTable({   
  req(inFileS <- input$fileSignature)
  Signatures <- read_excel(inFileS$datapath)
  Signatures <- as.data.frame(Signatures)
  globalValues$VanillaSig <- Signatures
  datatable(Signatures,rownames = FALSE,
            options = list(scroller = TRUE,scrollX = T,paging=FALSE,dom='t'))  # options = list(pageLength = -1,dom = 't') 
})

# Array file table display
output$Array <- renderDataTable({ 
  req(inFileA <- input$fileArray)
  HumanArray <- read_excel(inFileA$datapath)
  HumanArray <- as.data.frame(HumanArray)
  globalValues$VanillaArray <- HumanArray
  datatable(HumanArray,rownames = FALSE,
            options = list(scroller = TRUE,scrollX = T,paging=TRUE,pageLength =5,bLengthChange=0, bFilter=0))  # options = list(pageLength = -1,dom = 't') 
})




# T-Score calculations tscores()
tscores <- eventReactive(input$goButton,{   
  req(inFileS <- input$fileSignature)
  req(inFileA <- input$fileArray)
  
  Signatures <- as.data.frame(globalValues$VanillaSig) 
  HumanArray <- as.data.frame(globalValues$VanillaArray)
  HumanArray[3:ncol(HumanArray)] <- t(apply(HumanArray[3:ncol(HumanArray)],1,function(y)y-median(y))) #Normalize


  # Look for row gene duplicates in array, keep only the one with highest stdv
  dup <- duplicated(HumanArray[,1]) 
  if (any(dup)){
    HumanArray$Stdev <- apply(HumanArray[3:ncol(HumanArray)],1,sd)
    HumanArray <- HumanArray[order(HumanArray$Stdev, decreasing=TRUE),]
    HumanArray <- HumanArray[!duplicated(HumanArray[,1]),]
    HumanArray <- HumanArray[1:ncol(HumanArray)-1]
    
  }
  
  # Mouse gene convert to human gene
  if(checkRadioGene()==1){
    x <- vector(mode="character", length=nrow(Signatures))
    for(i in 1:length(x)){
      a <- which(Reference$Mouse==Signatures[i,1])
      if (identical(a, integer(0))){ 
        x[i]<-"?"
      }
      else{
        x[i]=Reference[a,2]
      }
    }
    Signatures$Human <- as.character(x)
    Signatures <- Signatures[c(3,2)] # Keeping only human
  }
  else{
    colnames(Signatures)[1]<-"Human"
  }
  
  # Cleaning and storing for bootstrap tab
  Signatures$Human[Signatures$Human == "?"] <- NA
  Signatures <- Signatures[!duplicated(Signatures$Human),]
  Signatures <- Signatures[!is.na(Signatures$Human),]
  globalValues$MasterSig <- Signatures
  globalValues$MasterArray <- HumanArray
  SigInfo <- as.data.frame(table(Signatures$Human)) # frequency table
  colnames(SigInfo)[1]<-"Human"
  
  # extract signatures of relevants
  a <- Signatures[!duplicated(Signatures[,c('Human')]),]
  a<-na.omit(a)
  a<-a[order(a$Human),]
  SigInfo$Signature <- a$Signature
  
  # not case sensitive
  colnames(HumanArray)[1:2]<-c("GENE_SYMBOL","Probe")
  HumanArray$GENE_SYMBOL <- toupper(HumanArray$GENE_SYMBOL) 
  SigInfo$Human <- toupper(SigInfo$Human)
  
  # Finding overlap
  overlap <- intersect(HumanArray$GENE_SYMBOL,SigInfo$Human)
  SigInfo <- SigInfo[SigInfo$Human %in% overlap,] # get rid of non-overlaps
  HumanArray <- HumanArray[HumanArray$GENE_SYMBOL %in% overlap,]
  HumanArray<-HumanArray[order(HumanArray$GENE_SYMBOL),]
  final <- merge(SigInfo, HumanArray, by.x="Human", by.y="GENE_SYMBOL")
  final[c(5:length(final))] <- lapply(final[c(5:length(final))], as.numeric)
  
  # Separating high and low genes
  HighLow <- split(final, final$Signature)
  High <- HighLow$High
  Low <- HighLow$Low

  # Dumping T-Scores into matrix
  TScores <- matrix(0,nrow=3,ncol=length(High)-5+1)
  for(i in 1:dim(TScores)[2]){
    TScores[1,i]<- colnames(High)[i+4]
    TScores[2,i]<- t.test(High[i+4],Low[i+4], alternative="two.sided", paired =FALSE, var.equal=TRUE)$p.value
    TScores[3,i]<- t.test(High[i+4],Low[i+4], alternative="two.sided", paired =FALSE, var.equal=TRUE)$statistic
  }
  TScores <- as.data.frame(t(as.data.frame(TScores)))
  TScores[,2] <- as.numeric(as.character(TScores[,2]))
  TScores[,3] <- as.numeric(as.character(TScores[,3]))
  colnames(TScores) <- c("Variable","p-value", "T-score") 
  TScores # Storing table into variables tscores()
})



# T-Scores table display
output$tTable <- renderDataTable({ 
  req(tscores())
  a<-tscores()
  a[2:3]<-signif(a[2:3],7) # Sig figs
  datatable(a,rownames = FALSE)  # options = list(pageLength = -1,dom = 't') 
})

# T-Scores table download
output$downloadData <- downloadHandler(
  filename = function() { 
    paste("tscores", ".csv", sep = "")
  },
  content = function(file) {
    write.csv(tscores(), file, row.names = FALSE)
  }
)
