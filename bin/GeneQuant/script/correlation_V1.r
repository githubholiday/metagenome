args = commandArgs('T')
### args1 total fpkm/rpkm
### args2 output cor.xls
### args3 output cluster.pdf
### args4 method for correlation test, default spearman
### args5 filter criteriia : both 0 or one of cmp greater than max, default 1000
#data = read.table(args[1], row.names = 1, sep = "\t", colClasses = "character",header=T,check.names=F)
val = array()
method = 'spearman'
max = 1000
if (length(args) >= 3) {
	axis_title = args[3]
}
if (length(args) == 4) {
	max = as.numeric(args[4])
}

data = read.table(args[1], row.names = 1, sep = "\t", header=T,check.names=F)
data = data[which(rowSums(data)!=0),]
mm = ncol(data)
corr = matrix(nrow = mm,ncol=mm)
names=colnames(data)
for ( i in 1:mm){
	for (j in 1:mm){
		cmp_data = cbind(data[,i],data[,j])
		#cmp_data = tmp_data[which(rowSums(tmp_data)!=0),]
		#cmp_data = cmp_data[which(cmp_data[,1] <= max),]
		#cmp_data = cmp_data[which(cmp_data[,2] <= max),]
		corr[i,j] = cor(cmp_data[,1],cmp_data[,2],method=method)
		#write.table(cmp_data,file=paste(names[i],"_vs_",names[j],".cor.xls",sep=""), quote = FALSE, sep = "\t",row.names = TRUE,col.names = TRUE)
#        corr[i,j] = cor(as.numeric(revise[,i]),as.numeric(revise[,j]),method=method)
   }
}
row.names(corr) = colnames(data)
colnames(corr) = colnames(data)

write.table(corr, file=args[2] , sep="\t" , quote=FALSE)

#if (mm >2) { 
#d <- dist(corr,method = "euclidean")
#fit <- hclust(d, method="complete")
#print(str(fit))
#pdf(args[3],w=8,h=6)
#plot(fit,xlab='Samples',ylab='Distant')
#dev.off()
#}
