#!/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/miniconda3/envs/amplified_pipeline/bin/Rscript
#作者：张阳
#邮箱：yangzhang@genome.cn
#时间：2023年05月10日 星期三 15时43分09秒
#版本：v0.0.1
#用途：用于anosim分析，判断分组合理性
library(getopt)
para<- matrix(c(
    'help',    'h',    0,  "logical",
    'infile',   'i',    1,  "character",
    'group',   'g',    1,  "character",
    'cmp',   'c',    1,  "character",
    'type',   't',    1,  "numeric",
    'outdir',   'o',    1,  "character"
),byrow=TRUE,ncol=4)
opt <- getopt(para,debug=FALSE)
print_usage <- function(para=NULL){
    cat(getopt(para,usage=TRUE))
    cat("
    Options:
    help    h   NULL        get this help
    infile  i   character   merge.qiime.xls , 物种丰度文件，列为样本，行为物种名称，值为丰度
    group  g character cmp.list,要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合
    cmp   c  character cmp.txt,要求提供分组名称，如果是两两比较的，每行为一个比较组合，如A tab B；如果是三个及以上的，需要提供格式如下Group1 tab A B C D,不同的组需要用空格分开，组名和比较组合名字之间用tab分开
    type   t   numeric   [2|3|4...]2代表是两两比较，3及以上是多组比较
    outdir  o character , 结果输出路径
    \n")
    q(status=1)
}
if (is.null(opt$infile)) {print_usage(para)}
library(vegan)
library(ggplot2)
library(dplyr)
library(ggsci)
# Anosim分析函数
anosim_analysis <- function(data,group,name,group_size){
	anosim=anosim(data, group, permutations=999)
	summary(anosim)
	result=paste("R=",round(anosim$statistic,3),"    p.value=", round(anosim$signif,3))
	mycol=colors[1:(group_size+1)]
	par(mar=c(5,5,5,5))
	pdf(paste(outdir,"/anosim.",name,".pdf",sep='') , width=10 , height=8)
	boxplot(anosim$dis.rank~anosim$class.vec, pch="+", col=mycol, range=1, boxwex=0.5, notch=TRUE, xlab = "" , ylab="Bray-Curtis Rank", main="Bray-Curtis Anosim", sub=result)
	dev.off()
	out_data = c(name,round(anosim$statistic,3), round(anosim$signif,3))
	return(out_data)
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
colors = c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))
infile = opt$infile # "merge.qiime.xls"
outdir = opt$outdir # 
group = opt$group # group.list 要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合。
cmp = opt$cmp
type = opt$type
# 读取物种丰度文件
c = read.table(infile , sep = "\t", quote = "",header=T,row.names=1)
dat = t(c)
# 读取分组文件
group = read.table( group , sep="\t" , header=T) 
print(group)
rownames(group)=group$Sample
cmplist = read.table(cmp, sep = '\t',stringsAsFactors = FALSE, check.names = FALSE)
print(cmplist)
print(class(cmplist))
cmp <- cmplist
na_flag <- apply(is.na(cmp), 2, sum)
cmp <- cmp[,which(na_flag == 0)]
print(cmp)
print(class(cmp))
if (length(dim(cmp)) < 2){
	print("your cmp file has no groups,so exit")
	q()
}
out_data=c("group","R","p.value")
if (type == 2){
	for (i in 1:nrow(cmplist)){
		name = paste(cmplist[i,1],cmplist[i,2],sep="-")
		this_group = group[group$Group %in% cmplist[i,],]
		this_data = dat[rownames(dat) %in% this_group$Sample,]
		this_group = as.factor(merge(this_data,this_group,by="row.names",sort=F)[,"Group"])
		group_size = 2
		print(this_group)
		out_data = rbind(out_data,anosim_analysis(this_data,this_group,name,2))
	}
}else{
	for (i in 1:nrow(cmplist)){
		print(cmplist[i,])
		if (length(cmplist[i,]) < 2){
			print("your cmp file has no groups,so exit")
			q()
			}
		name = cmplist[i,1]
		this_group = group[group$Group %in% strsplit(cmplist[i,2]," ")[[1]],]
		this_data = dat[rownames(dat) %in% this_group$Sample,]
		this_group = as.factor(merge(this_data,this_group,by="row.names",sort=F)[,"Group"])
		group_size = length(this_group[!duplicated(this_group)])
		out_data = rbind(out_data,anosim_analysis(this_data,this_group,name,group_size))
	}
}
write.table(out_data,file=paste(outdir,"/anosim.stat.",type,".xls",sep=''),sep="\t",row.names=F,col.names=F,quote=F)
