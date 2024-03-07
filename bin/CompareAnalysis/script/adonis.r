#!/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/miniconda3/envs/amplified_pipeline/bin/Rscript
#作者：张阳
#邮箱：yangzhang@genome.cn
#时间：2023年11月09日 星期四 15时50分49秒
#版本：v0.0.1
#用途：
args<-commandArgs(TRUE)
library(vegan)
otu <- args[1]
group <- args[2]
cmp <- args[3]
outdir <- args[4]
type <- args[5]
distance_method <- "bray"
adjust_method <- "fdr"

adonis_analysis <- function(otu_table,group,name,adjust_method = "fdr",distance_method = "bray"){
	ad <- adonis(otu_table ~ Group,data = group,permutations = 999,method=distance_method)
	name <- name
	SumsOfSqs <- round(ad$aov.tab$SumsOfSqs[1],3)
	MeanSqs <- round(ad$aov.tab$MeanSqs[1],3)
	F.Model <- round(ad$aov.tab$F.Model[1],3)
	R2 <- round(ad$aov.tab$R2[1],3)
	p.value <- round(ad$aov.tab$"Pr(>F)"[1],3)
  result <- c(name,SumsOfSqs,MeanSqs,F.Model,R2,p.value)
	return(result)
}
check_cmp <- function(cmp){
	na_flag <- apply(is.na(cmp), 2, sum)
	cmp <- cmp[,which(na_flag == 0)]
	print(cmp)
	print(class(cmp))
	if (length(dim(cmp)) < 2){
		print("your cmp file has no groups,so exit")
		q()
	}
}
otu <- read.csv(otu,header=T,sep="\t",row.names=1,quote="",stringsAsFactors = FALSE, check.names = FALSE)
otu_table <- t(otu)
group = read.table(group,header=T,sep="\t",stringsAsFactors = FALSE, check.names = FALSE)
cmplist <- read.table(cmp, sep = '\t',stringsAsFactors = FALSE, check.names = FALSE)
check_cmp(cmplist)
out_data=c("group","SumsOfSqs","MeanSqs","F.Model","R2","p.value")
if (type == 2){
	for (i in 1:nrow(cmplist)){
		name = paste(cmplist[i,1],cmplist[i,2],sep="-")
		this_group = group[group$Group %in% cmplist[i,],]
		this_data = otu_table[rownames(otu_table) %in% this_group$Sample,]
		out_data = rbind(out_data,adonis_analysis(this_data,this_group,name,adjust_method,distance_method))
	}
}else{
	for (i in 1:nrow(cmplist)){
		name = cmplist[i,1]
		this_group = group[group$Group %in% strsplit(cmplist[i,2]," ")[[1]],]
		this_data = otu_table[rownames(otu_table) %in% this_group$Sample,]
		out_data = rbind(out_data,adonis_analysis(this_data,this_group,name,adjust_method,distance_method))
	}
}
# 单独的p值校正完结果跟p值一样，必须得给一串p值才能起到校正作用
data <- as.data.frame(out_data)[2:nrow(out_data),]
colnames(data) <- out_data[1,]
data$p.adjust <- p.adjust(data$p.value,method=adjust_method)
write.table(data, file=paste(outdir,"/adonis.stat.",type,".xls",sep=''),row.names=F,sep="\t",quote=F,col.names=T)
