library(ggplot2)
library(ggsci)
colors=c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))

draw = function(titles,name,outdir,group_len,data){
	for (i in titles){
	p = ggplot(data, aes(x=Group, y=data[,i],color=Group)) + 
  geom_boxplot(outlier.color="red", outlier.size=2)+
 # geom_boxplot(outlier.color="red", outlier.shape=7,outlier.size=6)+ # 此参数会让离群值的点外面有个方框带×
  scale_color_manual(values=colors[1:group_len])+
  labs(title=i,x="Group", y = "")+
  #geom_dotplot(binaxis='y', stackdir='center', stackratio=1.5, dotsize=0.6)+ # 此参数可以正常标记离群值，但由于是横向排布而非抖动，导致有时候很丑
  #geom_jitter(shape=16, position = position_jitter(0.2)) + # 此参数会抖动，点的绘制比较好看，但是会无法正常标记离群值，只能标记出来所在的行
  theme_classic()
main_theme = theme(panel.background=element_blank(),
                   panel.grid=element_blank(),
                   axis.line.x=element_line(size=0.5, colour="black"),
                   axis.line.y=element_line(size=0.5, colour="black"),
                   axis.ticks=element_line(color="black"),
                   axis.text=element_text(color="black", size=24),
                   legend.position="right",
                   legend.background=element_blank(),
                   legend.key=element_blank(),
                   legend.text= element_text(size=24),
                   text=element_text(family="sans", size=24),
                   plot.title=element_text(hjust = 0.5,vjust=0.5,size=24),
                   plot.subtitle=element_text(size=12))
	p = p + main_theme
	ggsave(p,file=paste(outdir,"/boxplot_",i,"_",name,".pdf",sep=""),width=8,height=8)
	}
}

fun.outlier <- function(x,time.iqr=1.5) {
  x <- x[!is.na(x)]
  outlier.low <- quantile(x,probs=c(0.25))-IQR(x)*time.iqr
  outlier.high <- quantile(x,probs=c(0.75))+IQR(x)*time.iqr
  x <- x[which(x<=outlier.high & x>=outlier.low)]
  x
}


args <- commandArgs(TRUE)
infile <- args[1]
group <- args[2]
cmp <- args[3]
outdir <- args[4]
type <- args[5]

dat <- read.table(infile,header=T,sep="\t")
group <- read.table(group,header=T,sep="\t")
cmp <- read.table(cmp,sep="\t")
print(dim(cmp))
na_flag <- apply(is.na(cmp), 2, sum)
cmp <- cmp[,which(na_flag == 0)]
print(cmp)
print(class(cmp))
if (length(dim(cmp)) < 2){
	print("your cmp file has no groups,so exit")
	q()
}
titles = c("ACE","Chao1","Pielou","Shannon","Simpson")
if (type == 2){
	for (i in 1:nrow(cmp)){
		name <- paste(cmp[i,1],cmp[i,2],sep="_")
		group_new <- group[group$Group %in% cmp[i,],]
#		print(group_new)
		data <- merge(group_new,dat,by="Sample")
		data$Group <- as.factor(data$Group)
		group_len <- 2
#		print(data)
		draw(titles,name,outdir,group_len,data)
		}
}else if (type == 3){
	for (i in 1:nrow(cmp)){
		name <- cmp[i,1]
		tmp <- strsplit(cmp[i,2]," ")[[1]]
		group_new <- group[group$Group %in% tmp,]
#		print(group_new)
		data <- merge(group_new,dat,by="Sample")
		data$Group <- as.factor(data$Group)
		group_len <- length(unique(data$Group))
#		print(data)
		draw(titles,name,outdir,group_len,data)
	}
}
# 去除离群值计算均值
group_name <- unique(group$Group)
dat2 <- data.frame(matrix(1:2,nrow=length(group_name),ncol=5))
rownames(dat2) <- group_name
colnames(dat2) <- titles
all_dat <- merge(group,dat,by="Sample")
for (i in group_name){
	for (j in titles){
		tmp <- all_dat[all_dat$Group %in% i,j]
		tmp <- fun.outlier(tmp)
		dat2[i,j] <- round(mean(tmp),3)
	}
}
dat2$Group=rownames(dat2)
dat2=dat2[,c(6,1:5)]
print(dat2)
write.table(dat2,file=paste(outdir,"/boxplot_mean.xls",sep=""),row.names=F,quote=F,sep="\t")
