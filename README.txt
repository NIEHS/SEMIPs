SignatureAnalysis production version 0.0.2

To run this program online visit this webpage:
https://2waybene.shinyapps.io/SignatureAnalysis/

To run this program locally please do the following:

1) Download and install R (https://www.r-project.org/)
2) Open the dependencies.R file and run the script. Please note any errors that may occur during running, 
please make sure to resolve those errors to make sure the dependencies are properly set up.

   If you are running the R 4.x.x, the "parallel" and "tools" have already been installed as base package.

3) Determine the directory of the SignatureAnalysis app on your computer. It will look something like this:

/Users/li11/myGit/

4) Copy, paste, and run the following line of code in your R command line, using the specific directory of 
the SignatureAnalysis app on your computer:

 shiny::runApp("/Users/li11/myGit/SEMIPs/")

5) The application should launch and be used interactively

In order to run "Bootstrap", the user needs to firstly run T-scores calculation. The Bootstrap is designed to 
provide "expirical distribution" of elimination with/without replacement through a bootstrap procedure.
Please see the paper "" for details.
