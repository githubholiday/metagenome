args <- commandArgs(TRUE)
if( length(args)!= 4){
    print("Rscript nmds.r <qiime_file> <sample_file> <outpdf> <method>")
    print("Example: Rscript nmds.r merge.qiime.xls sample.list out.pdf bray")
    print("qiime_file: 物种丰度表")
    print("sample_file: 样本和比较组对应关系表")
    print("outpdf: 输出的图片文件名称")
    print("method: 距离计算方法，默认为bray")
    q()
}


infile=args[1]
sample_cmp = args[2]
outpdf = args[3]
method= args[4]

######## 判断是否做该分析
cmp <- read.csv(sample_cmp,header=T,sep='\t',stringsAsFactors = FALSE,row.names=1,check.names = FALSE,quote = "")
cmp$name <- rownames(cmp)

if ( length(cmp$name) < 3){
    print("提示：样本数量少于4个，不做NMDS分析，退出")
    q()
}

library(vegan)
otu <- read.delim(infile,row.names = 1,sep = '\t', stringsAsFactors = FALSE,check.names = FALSE)
########进行转置，需要行为样本，列为物种
otu <- data.frame(t(otu))

bray_dis <- vegdist(otu, method =method )#按照方法计算距离
nmds_dis <- metaMDS(bray_dis, k=2)
nmds_dis$stress   #查看stress值
nmds_dis_site <- data.frame(nmds_dis$points)#样方得分
nmds_dis_species <- wascores(nmds_dis$points, otu)#物种得分

library(ggplot2)
nco=c('#004DA1','#F7CA18','#4ECDC4','#F9690E','#B35AA5','#7DCDF3','#0080CC','#F29F41','#DE6298','#C4EFF6','#C8F7C5','#FCECBB','#F9B7B2','#E7C3FC','#81CFE0','#BDC3C7','#EDC0D3','#E5EF64','#4ECDC4','#168D7C','#103652','#D2484C','#E79D01')
####添加分组信息
nmds_dis_site$name <- rownames(nmds_dis_site)

nmds_dis_site <- merge(nmds_dis_site, cmp, all=TRUE,by='name')
colnames(nmds_dis_site)[4] <- 'group'
#theme_classic()+ #定义经典背景
nco[1:length(unique(nmds_dis_site$group))]
p <- ggplot(data = nmds_dis_site, aes(MDS1, MDS2)) + #取MDS1和MDS2来绘图
    theme_classic()+ #定义经典背景
    ######颜色按分组填充，并设置点的形状和大小
    geom_point(aes(color = group), shape=19,size=3) +#颜色按分组填充
######添加置信椭圆,并添加颜色
    stat_ellipse(aes(fill = group,color=group),alpha = 0.2,geom = 'polygon',level = 0.95,show.legend = FALSE, linetype=2) +
    scale_color_manual(values = nco[1:length(unique(nmds_dis_site$group))+2]) +
    theme(legend.position = 'right') +
    geom_vline(xintercept = 0, lty='dashed',color = 'gray50', size = 0.5) +#中间竖线
    geom_hline(yintercept = 0,  lty='dashed',color = 'gray50', size = 0.5) +#中间横线
    labs(x = paste('NMDS1 (Stress = ', round(nmds_dis$stress, 4),')'), y = 'NMDS2')
pdf(outpdf)
print(p)
dev.off()

#geom_point(aes(color = group, shape=group),size=3) +#颜色按分组填充