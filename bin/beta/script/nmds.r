args <- commandArgs(TRUE)
if( length(args)!= 5){
    print("Rscript nmds.r <qiime_file> <cmp_file> <outdir> <prefix> <method>")
    print("Example: Rscript nmds.r merge.qiime.xls cmp.list out.pdf bray")
    print("qiime_file: 物种丰度表")
    print("cmp_file: 样本和比较组对应关系表，要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合。")
    print("outdir: 输出路径")
    print("prefix: 输出结果前缀")
    print("method: 距离计算方法，默认为bray")
    q()
}


infile=args[1]
sample_cmp = args[2]
outdir = args[3]
prefix = args[4]
method= args[5]

######## 判断是否做该分析
cmp <- read.csv(sample_cmp,header=T,sep='\t',stringsAsFactors = FALSE,check.names = FALSE)
rownames(cmp) <- cmp$Sample

if ( length(cmp$Sample) < 4){
    print("提示：样本数量少于4个，不做NMDS分析，退出")
    q()
}

library(vegan)
otu <- read.delim(infile,row.names = 1,header=T,sep = '\t', stringsAsFactors = FALSE,check.names = FALSE)
otu <- otu[,rownames(cmp)]
########进行转置，需要行为样本，列为物种
otu <- data.frame(t(otu))

bray_dis <- vegdist(otu, method =method )#按照方法计算距离
nmds_dis <- metaMDS(bray_dis, k=2)
nmds_dis$stress   #查看stress值
nmds_dis_site <- data.frame(nmds_dis$points)#样方得分
nmds_dis_species <- wascores(nmds_dis$points, otu)#物种得分

library(ggplot2)
library(ggsci)
colors=c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))
####添加分组信息
nmds_dis_site$Sample <- rownames(nmds_dis_site)
nmds_dis_site <- merge(nmds_dis_site, cmp, all=TRUE,by='Sample')
colnames(nmds_dis_site)[4] <- 'Group'
group_name = cmp$Group[!duplicated(cmp$Group)]
group_num = length(group_name)
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
p <- ggplot(data = nmds_dis_site, aes(MDS1, MDS2)) + #取MDS1和MDS2来绘图
  geom_hline(aes(yintercept=0),color="#d8d6d6",linetype=5,size=0.5)+
  geom_vline(aes(xintercept=0),color="#d8d6d6",linetype=5,size=0.5)+
  geom_point(aes(color = Group),shape = 19,size = 3.5)+
  scale_color_manual(values = group_color,
                     limits = group_name)+
  scale_fill_manual(values = group_color,
                     limits = group_name)+                
  stat_ellipse(aes(fill=Group),geom="polygon",level=0.95,alpha=0.2)+
  labs(x = paste('NMDS1 (Stress = ', round(nmds_dis$stress, 4),')'), y = 'NMDS2') +
  theme_classic() +
  main_theme

# 保存
ggsave(p,file=paste(outdir,"/",prefix,"_NMDS_",method,".pdf",sep=""))

# 表格1——画图用的表格
colnames(nmds_dis_site)=c("Sample","NMDS1","NMDS2","Group")
write.table(nmds_dis_site,file=paste(outdir,"/",prefix,"_NMDS_",method,".coordinate.xls",sep=""),sep="\t",row.names=F,quote=F)

