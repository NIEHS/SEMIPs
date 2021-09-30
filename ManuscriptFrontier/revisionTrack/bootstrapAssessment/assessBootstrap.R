setwd("~/myGit/SEMIPs/ManuscriptFrontier/revisionTrack/bootstrapAssessment/")

base <- read.csv ("b100/Index7.csv")
rownames(t(base))

t(base)[1]

simu100 <- read.csv ("b100/Random_Index1_38.csv")
#simu200 <- read.csv ("b200/Random_Index1_38.csv")
simu500 <- read.csv ("b500/Random_Index1_38.csv")
#simu700 <- read.csv ("b700/Random_Index1_38.csv")
simu1000 <- read.csv ("b1000/Random_Index1_38.csv")



simu100 <- read.csv ("b100/Random_Index7_171.csv")
#simu200 <- read.csv ("b200/Random_Index7_171.csv")
simu500 <- read.csv ("b500/Random_Index7_171.csv")
#simu700 <- read.csv ("b700/Random_Index7_171.csv")
simu1000 <- read.csv ("b1000/Random_Index7_171.csv")


simu100 <- read.csv ("woB100/Random_Index1_55.csv")
simu500 <- read.csv ("woB500/Random_Index1_55.csv")
simu1000 <- read.csv ("woB1000/Random_Index1_55.csv")

simu100 <- read.csv ("woB100/Random_Index7_222.csv")
simu500 <- read.csv ("woB500/Random_Index7_222.csv")
simu1000 <- read.csv ("woB1000/Random_Index7_222.csv")


dim(simu100)
plot (t(base),  as.numeric(t(simu100[2,-1])))
simu100[,2]

dat100 <- as.numeric(simu100[,2])
#dat <- as.numeric(simu200[,2])
dat500 <- as.numeric(simu500[,2])
#dat <- as.numeric(simu700[,2])
dat1000 <- as.numeric(simu1000[,2])



getDensity <- function (dat)
{
  myhist <- hist(dat)
  multiplier <- myhist$counts / myhist$density
  mydensity <- density(dat)
  mydensity$y <- mydensity$y * multiplier[1]
  return(mydensity)
}

b100.den <- getDensity (as.numeric(simu100[,2]))
#b200.den <- getDensity (as.numeric(simu200[,2]))
b500.den <- getDensity (as.numeric(simu500[,2]))
#b700.den <- getDensity (as.numeric(simu700[,2]))

options(device="quartz")

plot(myhist)

lines(mydensity)
lines(b100.den)
#lines(b200.den)
lines(b500.den)
#lines(b700.den)
abline (v=t(base)[1])


hist(dat)
myhist <- hist(dat, density=20, breaks=20, prob=TRUE, 
     xlab="x-variable", ylim=c(0, 2), 
     main="normal curve over histogram")

m<-mean(dat)
std<-sqrt(var(dat))
curve(dnorm(x, mean=m, sd=std), 
      col="darkblue", lwd=2, add=TRUE, yaxt="n")



myPar <- par()

png("bootstrap_comp.png",  width = 780, height = 480,)
par(mfrow = c(1, 3)) # Create a 2 x 2 plotting matrix


my_data <- dat100
qqnorm(my_data, pch = 1, frame = FALSE,  main = "100 bootstrap")
qqline(my_data, col = "steelblue", lwd = 2)

my_data <- dat500
qqnorm(my_data, pch = 1, frame = FALSE, main = "500 bootstrap")
qqline(my_data, col = "steelblue", lwd = 2)

my_data <- dat1000
qqnorm(my_data, pch = 1, frame = FALSE, main = "1000 bootstrap")
qqline(my_data, col = "steelblue", lwd = 2)

par(myPar)
dev.off()
