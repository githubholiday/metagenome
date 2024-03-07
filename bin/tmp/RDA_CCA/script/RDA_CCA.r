# 环境因子
envir = read.table("environment.xls",sep="\t",stringsAsFactors = FALSE,quote = "",header=T,row.names=1)
# 读取物种组成丰度表
data = read.table("merge.qiime.xls",sep="\t",stringsAsFactors = FALSE,quote = "",header=T,row.names=1)
# 直接进行DCA分析
result = decorana(t(data))

# 对DCA结果进行判断
# 如果DCA1的Axis Lengths>4.0,就应选CCA（基于单峰模型，典范对应分析)；如果在3.0-4.0之间，选RDA和CCA均可；如果小于3.0, RDA的结果会更合理（基于线性模型，冗余分析）。注意：物种数据的量纲不同时不适合做单峰模型排序；有空样方出现的数据要采用单峰分析，需要把空样方剔除。
axlen <- apply(result$rproj, 2, function(z) diff(range(z)))
axlen = as.data.frame(axlen)
if (axlen[1,1] > 4.0) {
    method = "CCA"
}else {
    method = "RDA"
}
if (method == "RDA"){
    # 进行RDA分析
    rda=rda(t(data),envir,scale = T)
    rda.data=data.frame(rda$CCA$u[,1:2],envir)
    rda.spe=data.frame(rda$CCA$v[,1:2])
    rda.env <- rda$CCA$biplot[,1:2]
    rda.env = as.data.frame(rda.env)
    ## 计算轴标签，等于轴特征值/所有轴的特征值之和
    rda1 =round(rda$CCA$eig[1]/sum(rda$CCA$eig)*100,2) #第一轴标签
    rda2 =round(rda$CCA$eig[2]/sum(rda$CCA$eig)*100,2) #第二轴标签

    ## 绘制RDA图-带阴影散点图
    plot=ggplot(data=rda.data,aes(RDA1,RDA2))+  scale_color_manual(values=c("red","blue","green","black","grey","darkgreen"))+
    labs(title = "RDA plot",x=paste("RDA1",rda1," %"),y=paste("RDA2",rda2," %"))+
    theme_bw()+
    theme(axis.title = element_text(family = "serif", face = "bold", size = 18,colour = "black"))+
    theme(axis.text = element_text(family = "serif", face = "bold", size = 16,color="black"))
    ### 添加环境因子数据
    plot2 =plot+theme(panel.grid=element_blank())+
    geom_hline(yintercept = 0)+geom_vline(xintercept = 0)+
    geom_segment(data=rda.env,aes(x=0,y=0,xend=rda.env[,1],yend=rda.env[,2]),colour="black",size=1,
                    arrow=arrow(angle = 35,length=unit(0.3,"cm")))+
    geom_text(data=rda.env,aes(x=rda.env[,1],y=rda.env[,2],label=rownames(rda.env)),size=3.5,
                colour="black", hjust=(1-sign(rda.env[,1]))/2,angle=(180/pi)*atan(rda.env[,2]/rda.env[,1]))+
    theme(legend.position = "top") 
    ggsave(filename = "RDA.env.plot.pdf",plot = plot2,device="pdf",width = 10,height = 8) 

} elseif (method == "CCA"){
    # CCA分析
    otu = t(data)
    env = envir
    otu_cca <- cca(otu~., env)
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
    otu_cca_test_axis
    # 这个时候需要注意的是很有可能没有足够的cca解释轴。所以需要打印出来看一下。我在测试的时候发现我的DCA的结果是1.7。按理说应该使用的RDA，但是我为了用cca分析，凑合用一下。结果就出不来结果。
    ##变量选择
    #计算方差膨胀因子，详情 ?vif.cca
    vif.cca(otu_cca)

    #前向选择，这里以 ordiR2step() 的方法为例，基于 999 次置换检验，详情 ?ordiR2step
    otu_cca_forward_pr <- ordiR2step(cca(otu~1, env), scope = formula(otu_cca), R2scope = TRUE, direction = 'forward', permutations = 999)
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
    otu_cca_forward_pr.env$name <- rownames(otu_cca_forward_pr.env)
    #读取分组文件按
    map<- read.delim('group.txt', row.names = 1, sep = '\t')
    otu_cca_forward_pr.site$name <- rownames(otu_cca_forward_pr.site)
    otu_cca_forward_pr.site$group <- map$group
    #merged2<-merge(map,otu,by="row.names",all.x=TRUE)

    #ggplot2 作图
    library(ggrepel)    #用于 geom_label_repel() 添加标签

    color=c( "#3C5488B2","#00A087B2", 
            "#F39B7FB2","#91D1C2B2", 
            "#8491B4B2", "#DC0000B2", 
            "#7E6148B2","yellow", 
            "darkolivegreen1", "lightskyblue", 
            "darkgreen", "deeppink", "khaki2", 
            "firebrick", "brown1", "darkorange1", 
            "cyan1", "royalblue4", "darksalmon", 
            "darkgoldenrod1", "darkseagreen", "darkorchid")

    p <- ggplot(otu_cca_forward_pr.site, aes(CCA1, CCA2)) +
    geom_point(size=1,aes(color = group,shape = group)) +
    stat_ellipse(aes(color = group), level = 0.95, show.legend = FALSE, linetype = 2) +
    scale_color_manual(values = color[1:length(unique(map$group))]) +
    theme(panel.grid.major = element_line(color = 'gray', size = 0.1), panel.background = element_rect(color = 'black', fill = 'transparent'), 
        legend.title = element_blank(), legend.key = element_rect(fill = 'transparent'), plot.title = element_text(hjust = 0.5)) + 
    labs(x = cca1_exp, y = cca2_exp) +
    geom_vline(xintercept = 0, color = 'gray', size = 0.5) + 
    geom_hline(yintercept = 0, color = 'gray', size = 0.5) +
    geom_segment(data = otu_cca_forward_pr.env, aes(x = 0, y = 0, xend = CCA1, yend = CCA2), arrow = arrow(length = unit(0.2, 'cm')), size = 0.3, color = 'blue') +
    geom_text(data = otu_cca_forward_pr.env, aes(CCA1 * 1.2, CCA2 * 1.2, label = name), color = 'blue', size = 3) +
    geom_label_repel(aes(label = name, color = group), size = 3, box.padding = unit(0, 'lines'), show.legend = FALSE)

    p
    ggsave("cca.pdf", p, width = 5.5, height = 5.5)

}
