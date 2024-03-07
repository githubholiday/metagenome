#!/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/miniconda3/envs/amplified_pipeline/bin/Rscript  
#作者：张阳
#邮箱：yangzhang@genome.cn
#时间：2023年11月28日 星期二 15时50分49秒
#版本：v0.0.1
#用途：

args<-commandArgs(TRUE)
otu <- args[1]
outfile <- args[2]
Xtitle <- args[3]
otu <- read.table(otu, sep="\t", header=T,stringsAsFactors=F)
otu <- as.data.frame(otu)
otu$Species <- factor(otu$Species,levels=otu$Species)

library(ggplot2)
library(reshape2)
library(ggsci)
colors <- c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))
title <- names(otu)[1]
otu_t <- melt(otu,id="Species")
names(otu_t) <- c("Species","Sample","Percent")

# 根据物种多少确定PDF宽 
spe_length = ceiling(length(unique(otu_t$Species))/10)
sam_length = length(unique(otu_t$Sample))
len <- length(unique(otu_t$Species))
figwidth = spe_length*3+sam_length*0.3


# 设置背景主题
main_theme = theme(panel.background=element_blank(),
                   panel.grid=element_blank(),
                #    axis.line.x=element_line(linewidth=0.5, colour="black"),
                #    axis.line.y=element_line(linewidth=0.5, colour="black"),
                   axis.ticks=element_line(color="black"),
                #    axis.ticks.x = element_blank()
                #    axis.text=element_text(color="black", size=12),
                   axis.text.x = element_text(angle = 90, hjust = 1),
                   legend.position="right",
                   legend.background=element_blank(),
                   legend.key=element_blank(),
                   legend.text= element_text(size=12),
                   text=element_text(family="sans", size=12),
                   plot.title=element_text(hjust = 0.5,vjust=0.5,size=12),
                   plot.subtitle=element_text(size=12))

# 绘图
this_color <- colors[1:len]
pdf(outfile,width=figwidth)
p <- ggplot(otu_t,aes(x=Sample,y=Percent*100,fill=Species))+
    #   geom_bar(stat="identity",position="fill")+
      geom_col(position = 'stack')+
      scale_y_continuous(expand=c(0,0))+
      labs(y='Absolute Abundance(%)',x=Xtitle)+
      guides(fill=guide_legend(title = title))+
      scale_fill_manual(values=this_color)+
      main_theme
print(p)
dev.off()