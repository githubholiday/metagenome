#!/usr/bin/Rscript
#用于画KEGG注释结果的分类图
#input arguments
#===========================================================
library('getopt',lib.loc="/mnt/script")
spec <- matrix(c(
	'help',	'h',	0,	"logical",
	'infile',	'i',	1,	"character",
	'outfile',	'o',	1,	"character",
	'title',	't',	1,	"character",
	'xlabel',	'x',	1,	"character"
),byrow=TRUE,ncol=4)

opt <- getopt(spec,debug=TRUE)
#===========================================================
#usage
print_usage <- function(spec=NULL){
  cat(getopt(spec,usage=TRUE))
  cat("\n")
  cat("
	data format:
	data format like below:
	infile KEGG classificate result
	class	Group	Value	Percent
	A	Cell growth and death	355	4.70%
	B	Cell motility	167	2.21%
	A	Signaling molecules and interaction	87	1.15%
	B	Transport and catabolism	748	9.90%
	A	Membrane transport	124	1.64%

	Usage example:
	Rscript KEGG_classificate_plot.r --infile /annoroad/data1/bioinfo/PMO/jiahan/script/KEGG_classificate.xls --outfile /annoroad/data1/bioinfo/PMO/jiahan/script/KEGG_classificate.pdf --title \"KEGG Classification\" --xlabel \"Percent of Genes(%)\" 
		Options:
		--help		h	NULL		get this help
		--infile	i	character	the name of KEGG classificate result file [forced]
		--outfile	o	character	PDF file name [forced]
		--title		t	character	the title of picture [forced]
		--xlabel	x	character	the xlabel of picture [forced]
	\n")
	q(status=1)	
}
#===========================================================
if ( !is.null(opt$help) )	{ print_usage(spec) }
if ( is.null(opt$infile) )	{ cat("please give the name of KEGG classificate result file to plot...\n");print_usage(spec) }
if ( is.null(opt$outfile) )	{ cat("please give the name of picture...\n");print_usage( spec) }
if ( is.null(opt$title))	{ opt$title <- c("KEGG Classification") }
if ( is.null(opt$xlabel))	{ opt$xlabel <- c("Percent of Genes(%)") }
#===========================================================

data <- read.table(file=opt$infile,header=T,sep='\t',stringsAsFactors = FALSE,  check.names = FALSE,quote = "")
data <- data[order(data[,1]),]
data[,3:4] <- data.frame(lapply(data[,3:4], function(x) as.numeric(gsub("\\%", "", x))))
index <- duplicated(data[,1])
cla <- data[!index,1]
#color <-c("deeppink","yellow","green","cyan","purple","red","gold","skyblue","orange","hotpink") 
color <-c(rainbow(6))

if(length(cla)>10){
	for(i in 1:length(cla)){
		data[data[,1]==cla[i],5] <- colors()[i*4+30]
		color[i] <- colors()[i*4+30]
	}
}else{
	for(i in 1:length(cla)){
		data[data[,1] == cla[i],5] <- color[i]
	}
}
colnames(data) = c("first","second","num","percent","colour")

pdf(opt$outfile,width = 7, height = 8)

par(mar=c(5,17,5,6))
par(xpd=T)
x = max(data[,4])
barplot(data[,4],col=data[,5],horiz=T,main=opt$title,xlab=opt$xlabel,space=0.5)#,space=c(0.3,0.3))
start=0.6
for(i in 1:length(cla)){
	segments(x+5,start,x+5,start+1.5*length(which(data[,1]==cla[i]))-0.8,col=color[i],lwd=3,xpd = TRUE)
	text(x=x+6,y=start+0.75*length(which(data[,1]==cla[i])),labels=cla[i],xpd = TRUE,cex=0.9)
	start=start+1.5*length(which(data[,1]==cla[i]))
}
text(x=-0.6,y=seq(1,1+(dim(data)[1]-1)*1.5,by=1.5), labels = data[,2],xpd = TRUE,adj=1,cex=0.8)
text(x=data[,4]+0.3,y=seq(1,1+(dim(data)[1]-1)*1.5,by=1.5),labels=data[,3],xpd=TRUE,adj=0,cex=0.7)

dev.off();

