#!/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/miniconda3/envs/amplified_pipeline/bin/Rscript
#作者：张阳
#邮箱：yangzhang@genome.cn
#时间：2023年05月05日 星期五 15时43分09秒
#版本：v0.0.1
#用途：用于绘制PCoA结果
library('getopt')
para<- matrix(c(
    'help',    'h',    0,  "logical",
    'infile',   'i',    1,  "character",
    'method',   'm',    1,  "character",
    'cmp',   'c',    1,  "character",
    'prefix',   'p',    1,  "character",
    'outdir',   'o',    1,  "character"
),byrow=TRUE,ncol=4)
opt <- getopt(para,debug=FALSE)
print_usage <- function(para=NULL){
    cat(getopt(para,usage=TRUE))
    cat("
    Options:
    help    h   NULL        get this help
    infile  i   character   merge.qiime.xls , 物种丰度文件，列为样本，行为物种名称，值为丰度
    method  m character 计算距离矩阵的方法，可选有：manhattan,euclidean,canberra,bray,kulczynski,jaccard,gower,altGower,morisita,horn,mountford,raup,binomial,chao,cao,mahalanobis。具体可以查看vegan包的说明（函数为vegdist）
    cmp  c character cmp.list,要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合。
    outdir   o character outdir,结果输出目录,输出：图，坐标文件，特征值文件。
    \n")
    q(status=1)
}
if (is.null(opt$infile)) {print_usage(para)}

infile = opt$infile # "merge.qiime.xls"
method = opt$method # "bray"
cmp = opt$cmp # cmp.list 要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合。
outdir = opt$outdir # 
prefix = opt$prefix

library(vegan)
library(ape)
library(dplyr)
library(ggplot2)
library(ggsci)

# 读取分组文件
group = read.table( cmp , sep="\t" , header=T) 
rownames(group) = group$Sample
if ( length(group$Sample ) < 4){
    print("提示：样本数量少于4个，不做PCoA分析，退出")
    q()
}

# 读取物种丰度文件
dat = read.table(infile,sep="\t",stringsAsFactors = FALSE,quote = "",header=T,row.names=1)
dat = dat[,rownames(group)]
data = t(dat)

bac <- vegdist(data , method = method) #选取某种计算方法得到距离矩阵
bac_pcoa <- pcoa(bac, correction = "none")
#bac_pcoa$values #查看每一轴的解释量

# 获得前2轴的解释量：
x_label<-round(bac_pcoa$values$Relative_eig[1]*100,2)
y_label<-round(bac_pcoa$values$Relative_eig[2]*100,2)

#bac_pcoa$vectors#查看绘图坐标

bac_PCo1  <- bac_pcoa$vectors[,1]
bac_PCo2  <- bac_pcoa$vectors[,2]
bac_pco <- data.frame(bac_PCo1,bac_PCo2) %>% as_tibble(rownames = "Sample")



bac_pco2 <- left_join(bac_pco, group, by = "Sample")  
group_name = group$Group[!duplicated(group$Group)]
group_num = length(group_name)
# 调用ggsci中的NATRUE和Lancet的配色，共19个。
colors = c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))
group_color = colors[1:group_num]
# 设置背景主题
main_theme = theme(panel.background=element_blank(),
                   panel.grid=element_blank(),
                   axis.line.x=element_line(size=0.5, colour="black"),
                   axis.line.y=element_line(size=0.5, colour="black"),
                   axis.ticks=element_line(color="black"),
                   axis.text=element_text(color="black", size=12),
                   legend.position="right",
                   legend.background=element_blank(),
                   legend.key=element_blank(),
                   legend.text= element_text(size=12),
                   text=element_text(family="sans", size=12),
                   plot.title=element_text(hjust = 0.5,vjust=0.5,size=12),
                   plot.subtitle=element_text(size=12))
# 绘图
p = ggplot(bac_pco2,aes(bac_PCo1,bac_PCo2)) +
  geom_hline(aes(yintercept=0),color="#d8d6d6",linetype=5,size=0.5)+
  geom_vline(aes(xintercept=0),color="#d8d6d6",linetype=5,size=0.5)+
  geom_point(aes(color = Group),shape = 19,size = 3.5)+
  scale_color_manual(values = group_color,
                     limits = group_name)+
  scale_fill_manual(values = group_color,
                     limits = group_name)+                
  stat_ellipse(aes(fill=Group),geom="polygon",level=0.95,alpha=0.2)+
  labs(x = paste0("PCoA1 ( ",x_label,"% )"), y = paste0("PCoA2 ( ",y_label,"% )"))+
  theme_classic() +
  main_theme
  
pdf(paste(outdir,"/",prefix,"_PCoA_",method,".pdf",sep=""))
print(p)
dev.off()

# 表格1——画图用的表格
colnames(bac_pco2) = c("Sample","Dim.1","Dim.2","Group")
write.table(bac_pco2,file=paste(outdir,"/",prefix,"_PCoA_",method,".coordinate.xls",sep=""),sep="\t",row.names=F,quote=F)

# 表格2——各个轴的解释情况
values = data.frame(Axis=rownames(bac_pcoa$values),bac_pcoa$values)
values = values[,c(1,2,3,5)]
values[,3] = values[,3]*100
values[,4] = values[,4]*100
colnames(values)=c("Axis","eigenvalue","percentage of variance","cumulative percentage of variance")
write.table(values,file=paste(outdir,"/",prefix,"_PCoA_",method,".summary.xls",sep=""),sep="\t",row.names=F,quote=F)
