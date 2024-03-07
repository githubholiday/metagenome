#!/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/miniconda3/envs/amplified_pipeline/bin/Rscript
#作者：张阳
#邮箱：yangzhang@genome.cn
#时间：2023年05月05日 星期五 15时43分09秒
#版本：v0.0.1
#用途：用于RDA/CCA分析，给到结果图和对应坐标文件
library('getopt')
para<- matrix(c(
    'help',    'h',    0,  "logical",
    'infile',   'i',    1,  "character",
    'envir',   'e',    1,  "character",
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
    envir  e   character   environment.xls , 环境因子测量结果文件，客户提供，列为样本，行为环境因子，值为测量值。环境因子包括ph,N含量,P含量等
    cmp  c character cmp.list,要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合
    outfile1  p character RDA_CCA.coordinate.pdf, RDA/CCA结果图，根据DCA的结果进行选择，只出一种图，会在图里标明是RDA或者CCA
    outfile2  o character RDA_CCA.coordinate.sample.xls, RDA/CCA结果图中样本的坐标
    outfile3  O character RDA_CCA.coordinate.env.xls, RDA/CCA结果图中环境因子的坐标
    \n")
    q(status=1)
}
if (is.null(opt$infile)) {print_usage(para)}

library(ggrepel)  #用于 geom_label_repel() 添加标签
library(ggplot2)
library(vegan)
library(ggsci)

# 一、准备RDA和CCA分析各自的函数

`RDA_analysis` <- function(data,group,envir){
    # 进行RDA分析
    rda=rda(t(data),envir,scale = T)
    # 合并rda数据和分组数据
    rda.data=data.frame(rda$CCA$u[,1:2],group)
    # 提取物种得分
    rda.spe=data.frame(rda$CCA$v[,1:2])
    rda.env = as.data.frame(rda$CCA$biplot[,1:2])
    rda.env$factor = rownames(rda.env)
    ## 计算轴标签，等于轴特征值/所有轴的特征值之和
    rda1 =round(rda$CCA$eig[1]/sum(rda$CCA$eig)*100,2) #第一轴标签
    rda2 =round(rda$CCA$eig[2]/sum(rda$CCA$eig)*100,2) #第二轴标签
    ## 绘制RDA图-带阴影散点图
    plot = ggplot(data=rda.data,aes(RDA1,RDA2,color=Group)) + 
            geom_point(size=3,shape=16) + # 绘制点图并设定大小 
            scale_color_manual(values = group_color)+
            scale_fill_manual(values = group_color)+
            labs(title = "RDA plot",x=paste("RDA1",rda1," %"),y=paste("RDA2",rda2," %"))+
            geom_vline(xintercept = 0,lty="dashed")+
            geom_hline(yintercept = 0,lty="dashed")+ #图中虚线
            theme(axis.title = element_text(family = "serif", face = "bold", size = 18,colour = "black"))+
            theme(axis.text = element_text(family = "serif", face = "bold", size = 16,color="black"))+
            stat_ellipse(data=rda.data,level=0.95,linetype = 2,size=0.8,show.legend = T) + # 置信区间
            theme_bw()
    ### 添加环境因子数据
    plot2 = plot + theme(panel.grid=element_blank())+
            geom_hline(yintercept = 0)+geom_vline(xintercept = 0)+
            geom_segment(data=rda.env,aes(x=0,y=0,xend=rda.env[,1],yend=rda.env[,2]),colour="black",size=1,arrow=arrow(angle = 35,length=unit(0.3,"cm")))+
            geom_text(data=rda.env,aes(x=rda.env[,1],y=rda.env[,2],label=factor),size=3.5,colour="black", hjust=(1-sign(rda.env[,1]))/2,angle=(180/pi)*atan(rda.env[,2]/rda.env[,1]))+
            theme(legend.position = "right") 

    ggsave(filename = outfile1,plot = plot2,device="pdf",width = 10,height = 8) 
    write.table(rda.data,file=outfile2,sep="\t",row.names=F)
    write.table(rda.env,file=outfile3,sep="\t",row.names=F)
}

`CCA_analysis` <- function(data,group,envir){
    # CCA分析
    otu = t(data)
    otu_cca <- cca(otu~., envir)
    coef(otu_cca)
    ##R2 校正
    #RsquareAdj() 提取 R2，详情 ?RsquareAdj() 
    r2 <- RsquareAdj(otu_cca)
    otu_cca_noadj <- r2$r.squared   #原始 R2
    otu_cca_adj <- r2$adj.r.squared #校正后的 R2

    #关于约束轴承载的特征值或解释率，应当在 R2 校正后重新计算
    otu_cca_exp_adj <- otu_cca_adj * otu_cca$CCA$eig/sum(otu_cca$CCA$eig)
    otu_cca_eig_adj <- otu_cca_exp_adj * otu_cca$tot.chi
    ##置换检验
    #所有约束轴的置换检验，即全局检验，基于 999 次置换，详情 ?anova.cca
    otu_cca_test <- anova.cca(otu_cca, permutations = 999)

    #各约束轴逐一检验，基于 999 次置换
    otu_cca_test_axis <- anova.cca(otu_cca, by = 'axis', permutations = 999)

    #p 值校正（Bonferroni 为例）
    otu_cca_test_axis$`Pr(>F)` <- p.adjust(otu_cca_test_axis$`Pr(>F)`, method = 'bonferroni')
    print(otu_cca_test_axis)
    print("需要关注上面的结果，如果Pr列小于1的CCA少于2个维度，则后面ordiR2step步骤的报错很可能是因为这个原因！！！然后解决方法是手动判断DCA1的Axis Lengths，看是否可以选择RDA分析。如果对解决方法不太理解，可以通读一下脚本。")
    # 这个时候需要注意的是很有可能没有足够的cca解释轴。所以需要打印出来看一下。我在测试的时候发现我的DCA的结果是1.7。按理说应该使用的RDA，但是我为了用cca分析，凑合用一下。结果就出不来结果。
    ##变量选择
    #计算方差膨胀因子，详情 ?vif.cca
    vif.cca(otu_cca)

    #前向选择，这里以 ordiR2step() 的方法为例，基于 999 次置换检验，详情 ?ordiR2step
    otu_cca_forward_pr <- ordiR2step(cca(otu~1, envir), scope = formula(otu_cca), R2scope = TRUE, direction = 'forward', permutations = 999)
    #以上述前向选择后的简约模型 otu_cca_forward_pr 为例作图展示前两轴

    #计算校正 R2 后的约束轴解释率
    exp_adj <- RsquareAdj(otu_cca_forward_pr)$adj.r.squared * otu_cca_forward_pr$CCA$eig/sum(otu_cca_forward_pr$CCA$eig)
    cca1_exp <- paste('CCA1:', round(exp_adj[1]*100, 2), '%')
    cca2_exp <- paste('CCA2:', round(exp_adj[2]*100, 2), '%')
    #下面是 ggplot2 方法
    #提取样方和环境因子排序坐标，前两轴，I 型标尺
    otu_cca_forward_pr.scaling1 <- summary(otu_cca_forward_pr, scaling = 1)
    otu_cca_forward_pr.site <- data.frame(otu_cca_forward_pr.scaling1$sites)[1:2]
    otu_cca_forward_pr.env <- data.frame(otu_cca_forward_pr.scaling1$biplot)[1:2]

    #添加分组
    otu_cca_forward_pr.env$factor <- rownames(otu_cca_forward_pr.env)
    #读取分组文件按
    otu_cca_forward_pr.site$Sample <- rownames(otu_cca_forward_pr.site)
    otu_cca_forward_pr.site$Group <- group$Group
    plot = ggplot(otu_cca_forward_pr.site, aes(CCA1, CCA2, color=Group)) + 
            geom_point(size=3,shape=16) + # 绘制点图并设定大小 
            scale_color_manual(values = group_color)+
            scale_fill_manual(values = group_color)+
            labs(title = "CCA plot", x = cca1_exp, y = cca2_exp)+
            geom_vline(xintercept = 0,lty="dashed")+
            geom_hline(yintercept = 0,lty="dashed")+ #图中虚线
            theme(axis.title = element_text(family = "serif", face = "bold", size = 18,colour = "black"))+
            theme(axis.text = element_text(family = "serif", face = "bold", size = 16,color="black"))+
            stat_ellipse(data=otu_cca_forward_pr.site,level=0.95,linetype = 2,size=0.8,show.legend = T) + # 置信区间
            theme_bw() + 
            theme(panel.grid=element_blank())+
            geom_hline(yintercept = 0)+geom_vline(xintercept = 0)+
            geom_segment(data=otu_cca_forward_pr.env,aes(x=0,y=0,xend=otu_cca_forward_pr.env[,1],yend=otu_cca_forward_pr.env[,2]),colour="black",size=1,arrow=arrow(angle = 35,length=unit(0.3,"cm")))+
            geom_text(data=otu_cca_forward_pr.env,aes(x=otu_cca_forward_pr.env[,1],y=otu_cca_forward_pr.env[,2],label=factor),size=3.5,colour="black", hjust=(1-sign(otu_cca_forward_pr.env[,1]))/2,angle=(180/pi)*atan(otu_cca_forward_pr.env[,2]/otu_cca_forward_pr.env[,1]))+
            theme(legend.position = "right")

    ggsave(filename = outfile1,plot = plot,device="pdf",width = 10,height = 8)
    write.table(otu_cca_forward_pr.site,file=outfile2,sep="\t",row.names=F)
    write.table(otu_cca_forward_pr.env,file=outfile3,sep="\t",row.names=F)
}

# 二、开始分析
infile = opt$infile # "merge.qiime.xls" 物种丰度结果，流程产生
envir = opt$envir # "environment.xls" 环境因子测量结果，需要客户提供
cmp = opt$cmp # cmp.list 要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合。
outfile1 = opt$outfile1 # "RDA_CCA.coordinate.pdf"
outfile2 = opt$outfile2 # "RDA_CCA.coordinate.sample.xls"
outfile3 = opt$outfile3 # "RDA_CCA.coordinate.env.xls"

# 读取分组文件
group = read.table( cmp , sep="\t" , header=T) 
# 环境因子
envir = read.table( envir ,sep="\t",stringsAsFactors = FALSE,quote = "",header=T,row.names=1)
# 读取物种组成丰度表
data = read.table( infile , sep="\t",stringsAsFactors = FALSE,quote = "",header=T,row.names=1)

# 直接进行DCA分析
result = decorana(t(data))

# 对DCA结果进行判断
# 如果DCA1的Axis Lengths>4.0,就应选CCA（基于单峰模型，典范对应分析)；如果在3.0-4.0之间，选RDA和CCA均可；如果小于3.0, RDA的结果会更合理（基于线性模型，冗余分析）。
# 注意：物种数据的量纲不同时不适合做单峰模型排序；有空样方出现的数据要采用单峰分析，需要把空样方剔除。
axlen <- apply(result$rproj, 2, function(z) diff(range(z)))
axlen = as.data.frame(axlen)
print("接下来根据[1,1]位置的数值判断后续方法：> 4.0为CCA；其他选择RDA。")
axlen
if (axlen[1,1] < 4.0) {
    method = "CCA"
}else {
    method = "RDA"
}

## 颜色标签，调用ggsci中的NATRUE和Lancet的配色，共19个。
group_name = group$Group[!duplicated(group$Group)]
group_num = length(group_name)
colors = c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9))
group_color = colors[1:group_num]
group_color

if (method == "RDA"){
    RDA_analysis(data,group,envir)
} else {
    CCA_analysis(data,group,envir)
}
