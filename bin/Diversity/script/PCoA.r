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
    'outfile1',   'p',    1,  "character",
    'outfile2',   'o',    1,  "character",
    'outfile3',   'O',    1,  "character"
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
    outfile1  p character PCoA_ellipse_$(method).pdf, PCoA结果图
    outfile2  o character PCoA_$(method).xls, PCoA结果图画图用的表格
    outfile3  O character PCoA_axis_$(method).xls, PCoA结果图各个轴的解释结果
    \n")
    q(status=1)
}
if (is.null(opt$infile)) {print_usage(para)}

infile = opt$infile # "merge.qiime.xls"
method = opt$method # "bray"
cmp = opt$cmp # cmp.list 要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合。
outfile1 = opt$outfile1 # "PCoA_ellipse.pdf"
outfile2 = opt$outfile2 # "PCoA.xls" 画图用的表格
outfile3 = opt$outfile3 # "PCoA_axis.xls" 各个轴的解释结果

library(vegan)
library(ape)
library(dplyr)
library(ggplot2)
library(ggsci)

# 读取物种丰度文件
dat = read.table(infile,sep="\t",stringsAsFactors = FALSE,quote = "",header=T,row.names=1)
data = t(dat)
bac <- vegdist(data , method = method) #选取某种计算方法得到距离矩阵
bac_pcoa <- pcoa(bac, correction = "none")
bac_pcoa$values #查看每一轴的解释量

# 获得前2轴的解释量：
x_label<-round(bac_pcoa$values$Relative_eig[1]*100,2)
y_label<-round(bac_pcoa$values$Relative_eig[2]*100,2)

bac_pcoa$vectors#查看绘图坐标

bac_PCo1  <- bac_pcoa$vectors[,1]
bac_PCo2  <- bac_pcoa$vectors[,2]
bac_pco <- data.frame(bac_PCo1,bac_PCo2) %>% as_tibble(rownames = "Sample")

# 读取分组文件
group = read.table( cmp , sep="\t" , header=T) 
bac_pco2 <- left_join(bac_pco, group, by = "Sample")  
group_name = group$Group[!duplicated(group$Group)]
group_num = length(group_name)
# 调用ggsci中的NATRUE和Lancet的配色，共19个。
colors = c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9))
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
  geom_hline(aes(yintercept=0),color="#d8d6d6",linetype=5)+
  geom_vline(aes(xintercept=0),color="#d8d6d6",linetype=5)+
  geom_point(aes(color = Group),shape = 19,size = 3.5)+
  scale_color_manual(values = group_color,
                     limits = group_name)+
  scale_fill_manual(values = group_color,
                     limits = group_name)+                
  stat_ellipse(aes(fill=Group),geom="polygon",level=0.95,alpha=0.2)+
  labs(x = paste0("PCoA1 ",x_label,"%"), y = paste0("PCoA2 ",y_label,"%"))+
  theme_bw() +
  main_theme
  
pdf(outfile1)
print(p)
dev.off()

# 表格1——画图用的表格
write.table(bac_pco2,file=outfile2,sep="\t",row.names=F)
# 表格2——各个轴的解释情况
values = data.frame(axis=rownames(bac_pcoa$values),bac_pcoa$values)
write.table(values,file=outfile3,sep="\t",row.names=F)
