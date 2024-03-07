#!/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/miniconda3/envs/amplified_pipeline/bin/Rscript
#作者：张阳
#邮箱：yangzhang@genome.cn
#时间：2023年05月05日 星期五 15时43分09秒
#版本：v0.0.1
#用途：用于绘制Network结果
library('getopt')
para<- matrix(c(
    'help',    'h',    0,  "logical",
    'threshold',   't',    1,  "character",
    'infile',   'i',    1,  "character",
    'outfile1',   'p',    1,  "character",
    'outfile2',   'o',    1,  "character"
),byrow=TRUE,ncol=4)
opt <- getopt(para,debug=FALSE)
print_usage <- function(para=NULL){
    cat(getopt(para,usage=TRUE))
    cat("
    Options:
    help    h   NULL        get this help
    infile  i   character   merge.qiime.xls , 物种丰度文件，列为样本，行为物种名称，值为丰度
    threshold  t   character   阈值 , 默认0.6, 可以进行调整
    outfile1  p character Network.edge.csv, 网络图的边结果
    outfile2  o character Network.pdf, 网络图
    \n")
    q(status=1)
}
if (is.null(opt$infile)) {print_usage(para)}

infile = opt$infile # "merge.qiime.xls" 物种丰度文件
outfile1 = opt$outfile1 # "Network.edge.csv" 网络图的边结果
outfile2 = opt$outfile2 # "Network.pdf" 网络图
threshold = opt$threshold # 绘图之前进行阈值筛选

library(reshape2)
library(igraph)
data = read.table( infile ,sep="\t",stringsAsFactors = FALSE , quote = "" , header=T , row.names=1 )
data = t(data)
cor = cor(data,method="pearson")
cor_long = melt(cor , stringsAsFactors=F) # id.vars="name", 
cor_long$Var1 = as.character(cor_long$Var1)
cor_long$Var2 = as.character(cor_long$Var2)
cor_long = cor_long[which(cor_long[,1] < cor_long[,2]),]
cor_long = cor_long[which(abs(cor_long[,3]) > threshold),] #默认筛选了相关性系数大于0.6的部分，可以通过threshold调整
colnames(cor_long)=c("Source","Target","Weight")
write.table(cor_long,file=outfile1,sep=",",quote=F,row.names=F)
# 该文件可以用来导入Gephi进行后续手动调整绘图。
edges = cor_long
sum_data = as.data.frame(apply(data,2,sum))
sum_data$size = apply(sum_data,1,function(x) 100*x/sum(sum_data))
colnames(sum_data) = c("number","size")
nodes = data.frame("label" = rownames(sum_data))
net_pc = graph_from_data_frame(d=edges,vertices=nodes,directed=F)
# 绘图时的圈的顺序就是nodes的顺序；绘图时的边的顺序就是edges的顺序，所以映射时需要跟nodes和edges的顺序一致。
tmp = data
tmp[tmp>0] = 1
tmp_data = as.data.frame(apply(tmp,2,sum))
tmp_data$size = apply(tmp_data,1,function(x) 100*x/sum(tmp_data))
colnames(tmp_data) = c("number","size")
pdf(outfile2)
 plot(net_pc,
     edge.width = abs(5*(edges$Weight)),  # 边的粗细
     edge.color = "#cde394",  # 边的颜色 
     edge.curved=.5, # 边的弯曲度
     vertex.color = "#fcb857",  # 圈的颜色
     vertex.size = tmp_data$size, # 圈的大小
     vertex.frame.color = "white",  # 圈的框的颜色
     vertex.label.color = "black",  # 圈上细胞类型文字的颜色
     layout = layout.circle)
dev.off()
