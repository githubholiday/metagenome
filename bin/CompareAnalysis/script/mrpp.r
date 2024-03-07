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


#mrpp分析函数
mrpp_analysis <- function(otu_table, group, name, distance_method){
  mrpp_all <- mrpp(otu_table, group, 
                   permutations = 999, 
                   distance = distance_method)
  name <- name
  A <- round(mrpp_all$A,3)
  ObservedDelta <- round(mrpp_all$delta,3)
  ExpectedDelta <- round(mrpp_all$`E.delta`,3)
  p.value <- mrpp_all$Pvalue
  result <- c(name,A,ObservedDelta,ExpectedDelta,p.value)
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
out_data <- c("group", "A", "ObservedDelta", "ExpectedDelta", "p.value")

if (type == 2){
	for (i in 1:nrow(cmplist)){
		name = paste(cmplist[i,1],cmplist[i,2],sep="-")
		this_group = group[group$Group %in% cmplist[i,],]
		this_data = otu_table[rownames(otu_table) %in% this_group$Sample,]
        this_group = as.factor(this_group$Group)
		out_data = rbind(out_data,mrpp_analysis(this_data,this_group,name,distance_method))
	}
}else{
	for (i in 1:nrow(cmplist)){
		name = cmplist[i,1]
		this_group = group[group$Group %in% strsplit(cmplist[i,2]," ")[[1]],]
		this_data = otu_table[rownames(otu_table) %in% this_group$Sample,]
        this_group = as.factor(this_group$Group)
		out_data = rbind(out_data,mrpp_analysis(this_data,this_group,name,distance_method))
	}
}

data <- as.data.frame(out_data)[2:nrow(out_data),]
colnames(data) <- out_data[1,]
data$p.adjust <- p.adjust(data$p.value,method=adjust_method)
write.table(data, file=paste(outdir,"/mrpp.stat.",type,".xls",sep=''),row.names=F,sep="\t",quote=F,col.names=T)
