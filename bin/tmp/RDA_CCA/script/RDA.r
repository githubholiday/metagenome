# 进行RDA分析
rda=rda(t(data),envir,scale = T)
# 合并rda数据和分组数据
rda.data=data.frame(rda$CCA$u[,1:2],group)

# rda.data <- merge(rda.data,group,by="Sample")
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

ggsave(filename = "RDA.env.plot.pdf",plot = plot2,device="pdf",width = 10,height = 8) 
write.table(rda.data,file="RDA.sample.coordinate.xls",sep="\t",row.names=F)
write.table(rda.env,file="RDA.env.coordinate.xls",sep="\t",row.names=F)