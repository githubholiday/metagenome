##this script is used to draw x,y plot 

argv=commandArgs(T)
file=argv[1]
output=argv[2]
xlab=argv[3]
ylab=argv[4]
#id=argv[5]
#xx=as.integer(argv[5])
#print(xx)

data = read.table(file,sep="\t",header=TRUE)
#xx = quantile(max(data[,2]))
#if (length(argv)!=5){
#	xx = quantile((sort(data[,2])),0.75)
#}else{
#	xx = as.integer(argv[5])
#}
if (max(data[,2]) > 2000){
	xx = 2000
}else{
	xx = max(data[,2])
}
pdf(paste(output,"gc_length.pdf",sep='_'),w=8,h=6)
plot(data[,2],data[,3],xlim=c(0,xx),ylim=c(10,90),pch='.',col='red',bty='l',xlab=xlab,ylab=ylab, main="GC_Content_Distribution")
dev.off()
png(paste(output,"gc_length.png",sep='_'),w=800,h=600)
plot(data[,2],data[,3],xlim=c(0,xx),ylim=c(10,90),pch='.',col='red',bty='l',xlab=xlab,ylab=ylab, main="GC_Content_Distribution")
dev.off()

dd=c()
for (i in c(1:length(data[,2]))) {
	if (data[i,2] >xx){
		 dd[i]=xx
	}else{
		dd[i]= data[i,2]
	}
}
head(dd)
pdf(paste(output,"length_dis.pdf",sep="_"),w=8,h=6)
hist(dd,breaks=100,xlim=c(0,xx),xlab=xlab,main="Genome_Length_Distribution",col='skyblue',border='black')
#hist(dd,xlim=c(0,xx),breaks=seq(0,xx,100),xlab=xlab,main="Genome_Length_Distribution",col='blue')
dev.off()
png(paste(output,"length_dis.png",sep="_"),w=800,h=600)
hist(dd,breaks=100,xlim=c(0,xx),xlab=xlab,main="Genome_Length_Distribution",col='blue',border='black')
#hist(dd,xlim=c(0,xx),breaks=seq(0,xx,100),xlab=xlab,main="Genome_Length_Distribution",col='blue')
dev.off()
