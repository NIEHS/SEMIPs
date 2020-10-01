# Number of bootstrap runs (ex: 1000)
bootnum <- reactive({  
  input$bootNum
})
bootChoice <- reactive({  
  input$radio
})

# Subset file reactive display
output$Subset <- renderDataTable({ 
  req(inFileSS <- input$fileSubset)
  subset <- read_excel(inFileSS$datapath)
  subset <- as.data.frame(subset)
  globalValues$subset <- subset
  datatable(subset,rownames = FALSE,
            options = list(scroller = TRUE,scrollX = T,paging=TRUE,pageLength =5,bLengthChange=0, bFilter=0))
})

# fs() are path names to the T-scores files created below 
fs <- eventReactive(input$goButton2, {

  req(inFileSS <- input$fileSubset)
  
  withProgress(message = 'Calculating T-Scores',value=0,{

      subset <- as.data.frame(globalValues$subset) 
  
  # Requires sig and array files to already be uploaded
  req(MasterSig <- globalValues$MasterSig)
  req(MasterArray <- globalValues$MasterArray)
  req(inFileS <- input$fileSignature) 
  req(inFileA <- input$fileArray)
  
  colnames(MasterSig)[1] <- "Gene"
  colnames(MasterArray)[1]<-"Gene"
  
  files <- c() # Path names vector
  tmpdir <- tempdir() # Set up temp directory, mainly to bypass server. Can change 

  if  (as.numeric(bootChoice()) == 1)
  {
    allSig <- read_excel("allSig.xlsx") # Read again to avoid parallel scoping issues
    Exclude <- read_excel("ExcludeHuman.xlsx") # Pool of GATA2, PGR, SOX17 genes
    names(Exclude) <- c("Gene")
  
  # Going through subset file
    print(system.time({ # Debug time
    
      for (reg in 1:nrow(subset)){ # Each row of file
        incProgress(1/(nrow(subset)+1),detail = paste(reg-1,"out of",nrow(subset),"done")) # Progress bar
        cName <- subset[reg,1] #Regulator name
        stringVec <- unlist(strsplit(subset[reg,ncol(subset)], ","))
        stringVec <- gsub(" ", "", stringVec,fixed=TRUE)
        stringVec <- unique(stringVec) # Parse regulator genes
        Removed <- MasterSig[!toupper(MasterSig$Gene) %in% toupper(stringVec),] # Remove subset genes from sig list (used in parallel part below)
        TScores1 <- matrix(0,nrow=1,ncol=length(MasterArray)-2) # Matrix to dump Tscores
    
        # Cleaning (probably unnecessary) & same T-Score process
        a <-Removed[!duplicated(Removed[,1]),]
        colnames(a)[1]<-"Human"
        a$Human[a$Human == "?"] <- NA
        a<-na.omit(a)
        a<-a[order(a$Human),]
    
        a$Human <- toupper(a$Human)
        MasterArray$Gene <- toupper(MasterArray$Gene)
        overlap <- intersect(a$Human,MasterArray$Gene)
        a <- a[a$Human %in% overlap,] # get rid of non-overlaps
        ArrayDummy <- MasterArray[MasterArray$Gene %in% overlap,]
        ArrayDummy<-ArrayDummy[order(ArrayDummy$Gene),]
    
        final <- merge(a, ArrayDummy, by.x="Human", by.y="Gene")
        final[4:length(final)] <- lapply(final[4:length(final)], as.numeric)
        HighLow <- split(final, final$Signature)
        High <- HighLow$High
        Low <- HighLow$Low
    
        for(j in 1:ncol(TScores1)){
            TScores1[1,j]<- t.test(High[j+3],Low[j+3], alternative="two.sided", paired =FALSE, var.equal=TRUE)$statistic
        }
        colnames(TScores1) <- colnames(final)[4:ncol(final)]
        filePath <- paste0(tmpdir,"/",cName,".csv") # Write path for later retrieval
        files <-c(files,filePath)
        write.csv(TScores1,filePath,row.names=F) # Writing csv in tmp dir
    # BOOTSTRAP / PARALLEL
    
        targetNumber <- length(stringVec) # Number of molecules in regulator
        actualNumber <- sum(toupper(MasterSig$Gene) %in% toupper(stringVec),na.rm=TRUE) # Number of molecules actually found (e.g. 30 out of 34)
    
        # Parallel setup and minimizing crashing (probably not optimal)
        TScores <- FBM(as.numeric(bootnum()),length(MasterArray)-1) # Filebacked Big Matrices to avoid parallel problems

        numCores <- detectCores()/2 
        cl <<- parallel::makeCluster(numCores)
        on.exit(stopCluster(cl))
        on.exit(stopImplicitCluster())
        on.exit(registerDoSEQ())
        doParallel::registerDoParallel(cl)
    
         tempParallel <- foreach(i = 1:nrow(TScores), .combine = 'c') %dopar% {  # Dummy variable to do parallel upon
      
            set.seed(1+i*100+reg) # Seed is 1 + current bootstrap run * 100 + current regulator row number
      
            diffArray <- MasterArray[!toupper(MasterArray$Gene) %in% toupper(Exclude$Gene),] # Excluding the pooled genes from array
            addRandoms <- sample.int(nrow(diffArray),actualNumber) # Choosing random number of array genes to be included
      
            # Arranging sig list with removed regulator genes
            a <-Removed
            colnames(a)[1]<-"Human"
            a$Human[a$Human == "?"] <- NA
            a<-na.omit(a)
            a<-a[order(a$Human),]
      
            a$Human <- toupper(a$Human)
            MasterArray$Gene <- toupper(MasterArray$Gene)
      
            overlap <- intersect(a$Human,MasterArray$Gene) 
            a <- a[a$Human %in% overlap,] # get rid of non-overlaps
            ArrayDummy <- MasterArray[MasterArray$Gene %in% overlap,]
            ArrayDummy<-ArrayDummy[order(ArrayDummy$Gene),]
      
            final <- merge(a, ArrayDummy, by.x="Human", by.y="Gene")
      
             # Adding the new array genes to the list
            newGenes <- diffArray[addRandoms,]
            bootAdd <- merge(allSig,newGenes,by.x="Gene",by.y="Gene",all.y=TRUE)
            colnames(bootAdd) <- colnames(final)
            final <- rbind(final,bootAdd)
      
            # Doing T-Scores
            final[4:length(final)] <- lapply(final[4:length(final)], as.numeric) 
            HighLow <- split(final, final$Signature)
            High <- HighLow$High
            Low <- HighLow$Low
            for(j in 1:(ncol(TScores)-1)){
                TScores[i,j+1]<- t.test(High[j+3],Low[j+3], alternative="two.sided", paired =FALSE, var.equal=TRUE)$statistic
            }
            NULL # Returning NULL to dummy parallel variables
          } # End of dummy parallel
         stopCluster(cl)
          # Cleaning and converting FBM to dataframe
          TScores <- TScores[]
          # Row names
          TScores[,1]<-sapply(1:nrow(TScores),function(i) paste0("Random_",cName,"_",targetNumber,"_",str_pad(i, 4, pad = "0")))
          colnames(TScores)[2:ncol(TScores)] <- colnames(final)[4:ncol(final)]
          colnames(TScores)[1] <- "Run"

          filePath <- paste0(tmpdir,"/Random_",cName,"_",targetNumber,".csv") # Write path for later retrieval
          files <-c(files,filePath)
          write.csv(TScores,filePath,row.names=F) # Writing csv in tmp dir
      } 
    })) #System.time  
  } ## end of choice 1
  
  if  (as.numeric(bootChoice()) == 2)
  {
    print(system.time({
      for (reg in 1:nrow(subset)){
        incProgress(1/(nrow(subset)+1),detail = paste(reg-1,"out of",nrow(subset),"done"))
        
        cName <- subset[reg,1]
        stringVec <- unlist(strsplit(subset[reg,5], ","))
        stringVec <- gsub(" ", "", stringVec,fixed=TRUE)
        Removed <- MasterSig[!MasterSig$Gene %in% stringVec,]
        
        TScores1 <- matrix(0,nrow=1,ncol=length(MasterArray)-2)
        
        a <-Removed[!duplicated(Removed[,1]),]
        colnames(a)[1]<-"Human"
        a$Human[a$Human == "?"] <- NA
        a<-na.omit(a)
        a<-a[order(a$Human),]
        
        a$Human <- toupper(a$Human)
        MasterArray$Gene <- toupper(MasterArray$Gene)
        
        overlap <- intersect(a$Human,MasterArray$Gene)
        a <- a[a$Human %in% overlap,] # get rid of non-overlaps
        ArrayDummy <- MasterArray[MasterArray$Gene %in% overlap,]
        ArrayDummy<-ArrayDummy[order(ArrayDummy$Gene),]
        
        final <- merge(a, ArrayDummy, by.x="Human", by.y="Gene")
        final[4:length(final)] <- lapply(final[4:length(final)], as.numeric)
        
        HighLow <- split(final, final$Signature)
        High <- HighLow$High
        Low <- HighLow$Low
        
        for(j in 1:ncol(TScores1)){
          TScores1[1,j]<- t.test(High[j+3],Low[j+3], alternative="two.sided", paired =FALSE, var.equal=TRUE)$statistic
        }
        colnames(TScores1) <- colnames(final)[4:ncol(final)]
        filePath <- paste0(tmpdir,"/",cName,".csv")
        files <-c(files,filePath)
        write.csv(TScores1,filePath,row.names=F)
        
        
        
        targetNumber <- length(stringVec)
        TScores <- FBM(as.numeric(bootnum()),length(MasterArray)-1)
        numCores <- detectCores()/2
        cl <<- parallel::makeCluster(numCores)
        on.exit(stopCluster(cl))
        on.exit(stopImplicitCluster())
        on.exit(registerDoSEQ())
        doParallel::registerDoParallel(cl)
        
        tmp3 <- foreach(i = 1:nrow(TScores), .combine = 'c') %dopar% {
          # TScores[i,1] <- paste0("Random_",cName,"_",targetNumber,"_",str_pad(i, 4, pad = "0")) #Random_34_0001
          
          set.seed(1+i*100+reg)
          eliminateRandoms <- sample.int(nrow(MasterSig),targetNumber)
          
          subSet <- MasterSig[-eliminateRandoms,] 
          
          
          a <-subSet[!duplicated(subSet[,1]),] 
          colnames(a)[1]<-"Human"
          a$Human[a$Human == "?"] <- NA
          a<-na.omit(a)
          a<-a[order(a$Human),]
          
          a$Human <- toupper(a$Human)
          MasterArray$Gene <- toupper(MasterArray$Gene)
          
          overlap <- intersect(a$Human,MasterArray$Gene) 
          a <- a[a$Human %in% overlap,] # get rid of non-overlaps
          ArrayDummy <- MasterArray[MasterArray$Gene %in% overlap,]
          ArrayDummy<-ArrayDummy[order(ArrayDummy$Gene),]
          
          final <- merge(a, ArrayDummy, by.x="Human", by.y="Gene")
          final[4:length(final)] <- lapply(final[4:length(final)], as.numeric) 
          
          HighLow <- split(final, final$Signature)
          High <- HighLow$High
          Low <- HighLow$Low
          
          for(j in 1:(ncol(TScores)-1)){
            TScores[i,j+1]<- t.test(High[j+3],Low[j+3], alternative="two.sided", paired =FALSE, var.equal=TRUE)$statistic
          }
          NULL
        }
        # parallel::stopCluster(cl)
        # registerDoSEQ()
        # invisible(gc); remove(nCores); remove(nThreads); remove(cluster); 
        
        stopCluster(cl)  ## Modify by JYL, 10/23/19
        ## to return CPUs back to the server  
        
        TScores <- TScores[]
        
        TScores[,1]<-sapply(1:nrow(TScores),function(i) paste0("Random_",cName,"_",targetNumber,"_",str_pad(i, 4, pad = "0")))
        
        
        colnames(TScores)[2:ncol(TScores)] <- colnames(final)[4:ncol(final)]
        colnames(TScores)[1] <- "Run"
        #csvName <- paste0("Random_",cName,"_",targetNumber,".csv") #
        #filePath <- paste0(tmpdir,"/",csvName) #
        filePath <- paste0(tmpdir,"/Random_",cName,"_",targetNumber,".csv")
        files <-c(files,filePath)
        write.csv(TScores,filePath,row.names=F)
        #write.csv(TScores,csvName,row.names=F) #
        
      }
    })) #System.time  
    
    
  } ## end of choice 1
  globalValues$fileNames <- files
  incProgress(1/(nrow(subset)+1),detail=paste(reg-1,"out of",nrow(subset),"done"))
  }) # withprogress

  files  # Storing file paths into fs()
})
# End fs()

# Display all created files
output$foo <- renderText({ 
  paths <- paste0(fs(),'<br/>')
  paths <- paste(paths,collapse = '')
  HTML(paste0("<b>Click <font color=\"#ff6600\">Download Zip</font></b><br/><u>Calculated files:</u><br/>",paths)
    )
  })

# Retrieve all created files from temp directory, zip them into zip file for download
output$bootdownload <- downloadHandler( 
  filename = function() {
    paste("output", "zip", sep=".")
  },
  content = function(fname){
    zip(zipfile=fname,files=fs())
  }
  ,
  contentType = "application/zip"
)
