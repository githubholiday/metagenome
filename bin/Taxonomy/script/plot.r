path=commandArgs(trailingOnly = F)
scriptdir=dirname(sub("--file=","",path[grep("--file",path)]))
args = commandArgs(T)
source(paste(scriptdir,'barplot/barplot.r',sep='/'))

barplotv1(Input=args[1],Output=args[2],beside=F,Ymax=100,Ylab="Relative abundance(%)",Title="Microbial community barplot")

dev.off()
