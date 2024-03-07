path=commandArgs(trailingOnly = F)
scriptdir=dirname(sub("--file=","",path[grep("--file",path)]))
source(paste(scriptdir,"/axis/axisnew.r",sep='/'))
#########################################function
barplotv1<-function(Input = NULL,
		Output = NULL, 
		Title = "BarplotV1",
		Ylab = "BARPLOT",
		Ymax = NULL,
		abline = NULL,
		beside = T)
{		
	if (file.exists(Input)){
		data = read.table(Input,header = TRUE,stringsAsFactors = FALSE, row.names = 1, check.names = FALSE,quote = "",sep="\t")
	} else {
		stop ("Please input files!")
	}
	library(RColorBrewer);
	n=c(brewer.pal(8,"Set2"),brewer.pal(8,"Accent"),brewer.pal(8,"Dark2"),brewer.pal(8,"Pastel1"),brewer.pal(8,"Pastel2"));
	pdf(NULL)
	srtbottom=max(strwidth(colnames(data),units="inches",cex=1.5,font=2))+0.1
	if(nrow(data)>1) strright=max(strwidth(rownames(data),units="inches",cex=1.5,font=2))+0.5 else strright =1
	graphics.off()
	unlink("Rplots.pdf")
	if(beside) figheight = srtbottom + 7 else figheight = srtbottom + 7
	if(beside) {
		if(nrow(data)<4) {
			figwidth=2+0.3*(ncol(data)*(nrow(data)+1)) + strright
		} else {
			figwidth=2+0.15*(ncol(data)*(nrow(data)+1)) + strright
		}
	} else { 
			figwidth = 2 + 0.3*(ncol(data)+1) + strright
		}
	pdf(Output,height = figheight,width = figwidth)
	par(font=2,font.axis=2,font.lab=2,cex.axis=1.5,cex.lab=1.5,cex.main=2,mai=c(srtbottom,1.2,1,strright))
	if (beside){
			colnames=colnames(data);
			colnames(data)=NULL;
			if(is.null(Ymax)) Ylim=c(0,max(data)*1.2) else Ylim=c(0,as.numeric(Ymax))
			barplot(
					as.matrix(data),
					beside = T,
					col = n[1:nrow(data)],
					ylab="",
					border='white',
					ylim = Ylim,
					main=Title,
					axes=F
				)
			xy<-par("usr")
			if(nrow(data)>1) legend(x=xy[2L]-xinch(0.1),y=xy[4L],rownames(data),bty="n",xpd=T,pch=22,col="black",cex=1.5,pt.cex=2,pt.bg=n[1:nrow(data)])
			axis<-axisnew(2,Ylim)
				print(axis)
			axis(2,at=axis,line=0.5)
			mtext(side=2,line=3.5,Ylab,cex=1.5)
			at = colMeans(barplot(as.matrix(data),beside = T,plot = F,ylim = Ylim))
			text(at,-yinch(0.1),colnames,xpd=T,srt=45,adj=1,cex=1.5)
			if(!is.null(abline)) abline(h=as.numeric(abline),col="red",lwd=2,lty="dashed");
	} else {
			colnames=colnames(data);
			colnames(data)=NULL;
			if(is.null(Ymax)) Ylim=c(0,max(colSums(data))*1.2) else Ylim=c(0,as.numeric(Ymax))
			barplot(
					as.matrix(data),
					beside = F,
					col = n[1:nrow(data)],
					ylab="",
					ylim=Ylim,
					border='white',
					main=Title,
					axes=F
					)
			xy<-par("usr")
			if(nrow(data)>1) legend(x=xy[2L]-xinch(0.1),y=xy[4L],rev(rownames(data)),bty="n",xpd=T,pch=22,pt.bg=rev(n[1:nrow(data)]),cex=1.5,pt.cex=2,col="black");
			axis<-axisnew(2,Ylim)
				print(100>100)
			axis(2,at=axis,line=0.5)
			mtext(side=2,line=3.5,Ylab,cex=2)
			at=barplot(as.matrix(data),beside = F,plot = F,ylim = Ylim);
			text(at,-yinch(0.1),colnames,xpd=T,srt=45,adj=1,cex=1.5);
			if(!is.null(abline)) abline(h=as.numeric(abline),col="red",lwd=2,lty="dashed");
	}
}
