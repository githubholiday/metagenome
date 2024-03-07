args = commandArgs(T)
if (length(args) != 4){
	print("Rscript boxplot.r <InFile> <OutFile>   <Samples  in separate col(T/F)> <Main> <Ylab>");
	print(" Rscript boxplot.r boxplotMatrix.txt boxplotTest1.pdf 'RPKM Distribution' RPKM")
	q()
}

library(RColorBrewer)
	#n <- c(brewer.pal(8,"Set2"),brewer.pal(8,"Accent"));
	#n <- c(brewer.pal(8,"Set2"),brewer.pal(9,'Set1'),brewer.pal(8,"Accent"),brewer.pal(12,'Set3'),brewer.pal(12,'Paired'),brewer.pal(8,'Dark2'),brewer.pal(5,'Pastel1'),brewer.pal(3,'BrBG'),brewer.pal(6,'Spectral'),brewer.pal(9,'OrRd'))
	n=rep(c('#004DA1','#F7CA18','#4ECDC4','#F9690E','#B35AA5','#7DCDF3','#0080CC','#F29F41','#DE6298','#C4EFF6','#C8F7C5','#FCECBB','#F9B7B2','#E7C3FC','#81CFE0','#BDC3C7','#EDC0D3','#E5EF64','#4ECDC4','#168D7C','#103652','#D2484C','#E79D01'),200)
	d <- read.table(args[1],header=T,check.names = FALSE,quote = "",sep="\t")
	strbottom=max(strwidth(d[,1],units="inches",cex=1.5,font=2))+0.3
	graphics.off()
	unlink("Rplots.pdf")
	dim <- length(unique(d[,1]))
	if ( dim < 10 ){
		figwidth = 7
	}else {
	figwidth = dim*0.5
	}

	pdf( args[2] , w=figwidth , h=8 )
	par( font=2 , font.axis=2 , font.lab=2 , mai=c(strbottom , 1 , 1 , 1 ))
	# boxplot在绘图时会自动sort，所以添加一个sort即可。
	sortpos <- sort(unique(d[,1]))
	pos <- c(1:length(sortpos))
	y <- boxplot(d[,2]~d[,1] , outline=F , plot=F)
	Ylim <- c( min(y$stats) , max(y$stats) )
	boxplot(d[,2]~d[,1],pos=pos , names="", col=n[1:dim] , outline=F , ylim=Ylim , main=args[3] , ylab=args[4] , axes=F , cex.lab=1.5 , cex.main=2 , font=2)
	axis(2,cex.axis=1.5)
	box()
	axis(1,at=1:length(sortpos),labels=sortpos,las=2,adj=1,cex.axis=1.5,font=2)
	dev.off()
