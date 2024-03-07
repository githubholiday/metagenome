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
otu_cca_test_axis
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
#merged2<-merge(map,otu,by="row.names",all.x=TRUE)

#ggplot2 作图
# 以下这种方式会画出来每一个样本,但是为了和RDA保持一致，所以这里就不用了。
# p   <-  ggplot(otu_cca_forward_pr.site, aes(CCA1, CCA2)) +
#         geom_point(size=1,aes(color = group,shape = group)) +
#         stat_ellipse(aes(color = group), level = 0.95, show.legend = FALSE, linetype = 2) +
#         scale_color_manual(values = group_color) +
#         labs(x = cca1_exp, y = cca2_exp) +
#         geom_vline(xintercept = 0, color = 'gray', size = 0.5) + 
#         geom_hline(yintercept = 0, color = 'gray', size = 0.5) +
#         geom_segment(data = otu_cca_forward_pr.env, aes(x = 0, y = 0, xend = CCA1, yend = CCA2), arrow = arrow(length = unit(0.2, 'cm')), size = 0.3, color = 'blue') +
#         geom_text(data = otu_cca_forward_pr.env, aes(CCA1 * 1.2, CCA2 * 1.2, label = name), color = 'blue', size = 3) +
#         geom_label_repel(aes(label = name, color = group), size = 3, box.padding = unit(0, 'lines'), show.legend = FALSE) +
#         theme(panel.grid.major = element_line(color = 'gray', size = 0.1), panel.background = element_rect(color = 'black', fill = 'transparent'), 
#             legend.title = element_blank(), legend.key = element_rect(fill = 'transparent'), plot.title = element_text(hjust = 0.5)) 

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

ggsave("cca2.pdf", plot, width = 5.5, height = 5.5)
write.table(otu_cca_forward_pr.site,file="CCA.sample.coordinate.xls",sep="\t",row.names=F)
write.table(otu_cca_forward_pr.env,file="CCA.env.coordinate.xls",sep="\t",row.names=F)