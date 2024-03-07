#!/annoroad/data1/bioinfo/PMO/yaomengcheng/Anaconda3/bin/Rscript
#作者：张阳
#邮箱：yangzhang@genome.cn
#时间：2023年11月14日 星期二 10时35分30秒
#版本：v0.0.1
#用途：
args<-commandArgs(TRUE)
count_file <- args[1] # 丰度文件，行为物种名，列为样本
group_file <- args[2] # 样本和组合名的文件，Sample\tGroup
cmp_file <- args[3] # 比较组合文件，只能是两两比较的，每一行用\t分隔两个比较组，不区分先后
outfile <- args[4] #输出结果文件
data <- read.table(count_file, sep = '\t', row.names = 1, header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, quote="")
newdata <- as.data.frame(lapply(data, function(x) x / sum(x)))
rownames(newdata) <- rownames(data)
newdata <- t(newdata)
group <- read.table(group_file, sep = '\t', header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
rownames(group) <- group$Sample
#cmplist <- combn(group$Group[!duplicated(group$Group)],2) # 全部两两比较
cmplist <- read.table(cmp_file, sep = '\t',stringsAsFactors = FALSE, check.names = FALSE)
cmplist <- t(cmplist)
for (i in 1:ncol(cmplist)){
	newgroup <- group[group$Group %in% cmplist[,i],]
	dat <- merge(newgroup,newdata,by="row.names") # 合并时会按照group的样本来合并，newdata是全的，group是本次分析提供的分组和样本
	dat$Group <- as.factor(dat$Group)
	if (i == 1){
		pvalue <- t(newdata)[,1:2] # 提供一个数据框，用来后续填写pvalue和qvalue，nrow=物种数，ncol=2
		colnames(pvalue) <- paste(cmplist[1,i],"_",cmplist[2,i],".",c("pvalue","qvalue"),sep="")
	# data列名：Row.names Sample Group d_Bacteria ...
		for (i in 4:ncol(dat)) {
			t <- t.test(dat[,i]~dat[,3])
			pvalue[i-3,1] <- t$p.value
		}
		pvalue[,2] <- p.adjust(pvalue[,1], method="BH", n=nrow(pvalue))
	}else{
		newp <- t(newdata)[,1:2]
		colnames(newp) <- paste(cmplist[1,i],"_",cmplist[2,i],".",c("pvalue","qvalue"),sep="")
		for (i in 4:ncol(dat)) {
			t <- t.test(dat[,i]~dat[,3])
			newp[i-3,1] <- t$p.value
		}
		newp[,2]=p.adjust(newp[,1], method="BH", n=nrow(newp))
		pvalue <- cbind(pvalue,newp)
	}
}
pvalue <- data.frame(pvalue)
pvalue <- cbind(Species=rownames(pvalue),pvalue)
write.table(pvalue,outfile,quote=F,sep="\t",row.names=F)
