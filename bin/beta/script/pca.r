# install and load multiple R packages
ipkg<- function(pkg){
	new_pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
	if (length(new_pkg) != 0){
		install.packages(new_pkg, dependencies=TRUE)
	}
	sapply(pkg, require, character.only=TRUE)
}

###PCA Analysis
pca_analysis <- function(fpkm,outdir,cmp,label,prefix){
	res_pca <- PCA(t(fpkm),graph=FALSE)
	time=Sys.time()
	mess=paste(format(time),"- PCA - INFO - PCA function Analysis finished ... ...")
	cat(mess,"\n")

###+++++++++++++PCA_summary Output++++++++++++++++++++++
	Comp <- rownames(res_pca$eig)
	summary_pca <- cbind(Comp,res_pca$eig)
	write.table(summary_pca,paste(prefix,"PCA_summary.xls",sep="_"),sep="\t",col.names=T,row.names=F,quote=F)
###+++++++++++++Dim Explanation for Variable(gene)++++++
	Variable <- rownames(res_pca$var$cos2)
	Var_exp <- cbind(Variable,res_pca$var$cos2)
	write.table(Var_exp,paste(prefix,"Variable_gene_cos2.xls",sep="_"),sep="\t",col.names=T,row.names=F,quote=F)

###+++++++++++++Variable Contribute for Dim ++++++++++++++
	Var_contrib <- cbind(Variable,res_pca$var$contrib)
	write.table(Var_contrib,paste(prefix,"Variable_gene_contrib.xls",sep="_"),sep="\t",col.names=T,row.names=F,quote=F)

###+++++++++++++Individual(Sample) Coordinates on the principle components+++++++++++++++++++
	Sample <- rownames(res_pca$ind$coord)
	Sample_cor <- cbind(Sample,res_pca$ind$coord)
	write.table(Sample_cor,paste(prefix,"PCA_coordinate.xls",sep="_"),sep="\t",col.names=T,row.names=F,quote=F)
######++++++++++++++++++Table Output End++++++++++++++++++++
	library(ggsci)
	coltmp <- c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))
	shape_all <- rep(c(15:18,3,4),30)
	len_group <-length(unique(cmp$Group))
	cmp$Group <- factor(cmp$Group,levels=unique(cmp$Group))
	group_color <- coltmp[1:len_group]
	group_name <- unique(cmp$Group)
	x_label <- round(res_pca$eig[1,2],2)
	y_label <- round(res_pca$eig[2,2],2)
#每组样本数量少于3个的时候，无法绘制圈图
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
	bac_pco2 = data.frame(res_pca$ind$coord)
	bac_pco2$Sample = rownames(bac_pco2)
	bac_pco2 = merge(bac_pco2,cmp,by="row.names")[,c("Dim.1","Dim.2","Group","Sample")]
	rownames(bac_pco2)=bac_pco2$Sample
	#print(bac_pco2)
	pa = ggplot(bac_pco2,aes(Dim.1,Dim.2)) +
	geom_hline(aes(yintercept=0),color="gray50",linetype=5,size=0.5)+
	geom_vline(aes(xintercept=0),color="gray50",linetype=5,size=0.5)+
	geom_point(aes(color = Group),size = 3.5)+
	stat_ellipse(aes(fill=Group),geom="polygon",level=0.95,alpha=0.2)+
	scale_fill_manual(values = group_color)+
	scale_color_manual(values = group_color)+
	labs(x = paste0("PCA1 ( ",x_label,"% )"), y = paste0("PCA2 ( ",y_label,"% )"))+
	theme_classic() +
	main_theme
	pdf(paste(prefix,"individual_dim1_dim2_ellipses.pdf",sep="_"))
	print(pa)
	dev.off()
#	pdf(paste(prefix,"PCA_individual_dim1_dim2.pdf",sep="_"))
#	if (label == "True")
#	{
#		pa1 <- fviz_pca_ind(res_pca,  mean.point=FALSE, habillage = cmp$Group, palette = coltmp[1:len_group],labelsize=3, legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
#	}else{
#		pa1 <- fviz_pca_ind(res_pca, label="none", mean.point=FALSE, habillage = cmp$Group, palette = coltmp[1:len_group],  legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
#}
#	print(pa1)
#	dev.off()
######++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	pdf(paste(prefix,"PCA_variable_dim1_dim2.pdf",sep="_"))
	select_var <- NULL
	if(ncol(t(fpkm)) >= 20){
		select_var <- list(contrib = 20)
	}
	#pb <-fviz_pca_var(res_pca,col.var="contrib",select.var=select_var)+scale_color_gradient2(low="white", mid="blue",high="red",midpoint=55)+theme_bw()
	pb <- fviz_pca_var(res_pca,col.var="contrib",select.var=select_var)+theme_bw()
	print(pb)
	dev.off()

	pdf(paste(prefix,"PCA_variable_dim1_dim2_cos2.pdf",sep="_"))
	pbb <- fviz_pca_var(res_pca,col.var="cos2",select.var = list(cos2 = 10))
	print(pbb)
	dev.off()
############################++++++++3d plot+++++++++++++++++++++++++++++++++++++++++++++++

	shapes = seq(len_group)
	shapes <- shapes[as.numeric(cmp$Group)]
	scatterplot3d(res_pca$ind$coord[,1:3], pch = shapes)
	colors <- coltmp[1:len_group]
	colors <- colors[as.numeric(cmp$Group)]

	pdf(paste(prefix,"PCA.3d.pdf",sep="_"))
	dim1<-paste("Dim1(",round(res_pca$eig[1,2],2),"%)",sep="")
	dim2<-paste("Dim2(",round(res_pca$eig[2,2],2),"%)",sep="")
	dim3<-paste("Dim3(",round(res_pca$eig[3,2],2),"%)",sep="")
	s3d<-scatterplot3d(res_pca$ind$coord[,1:3],color=colors,pch=16,xlab=dim1,ylab=dim2,zlab=dim3,cex.symbols=1.0,cex.lab=1.0,cex.axis=0.8)
	if (label == "True")
	{
		s3d.coords <- s3d$xyz.convert(res_pca$ind$coord[,1:3])
		text(s3d.coords$x, s3d.coords$y, labels = rownames(res_pca$ind$coord),pos = 2, offset = 0.5, cex = 0.6)
	}
	legend("right",pch=16,pt.cex=1.2,legend = levels(cmp$Group),bty = 'n',col =  coltmp[1:len_group], cex = 0.6,inset=0.08,ncol=1)
	dev.off()
############################++++++++++++++++3d plot End+++++++++++++++++++++++++++++++++++

	time=Sys.time()
	mess=paste(format(time),"- PCA - INFO - PCA Plot finished ... ...")
	cat(mess,"\n ")
}

###Main Function

## input arguments
args <- commandArgs(trailingOnly=TRUE)
fpkm <- args[1]
cmp <- args[2]
outdir <- args[3]
label <- args[4]
prefix <- args[5]

#input file & read your rpkm table
fpkm <- read.table(fpkm,header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE,quote="")
cmp <- read.table(cmp,header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE,quote="")
if (dim(cmp)[1]<4){
	print("该比较组合中总样本数少于4个，因此不进行pca分析")
	q()
}
fpkm = fpkm[,rownames(cmp)]
if(! file.exists(outdir))
{
	dir.create(outdir)
}
setwd(outdir)
time=Sys.time()
mess=paste(format(time),"- PCA - INFO - PCA Begins ... ... ")
cat(mess,"\n")
library("ade4")
library("adegraphics")
library("FactoMineR")
library("factoextra")
library("devtools")
library("scatterplot3d")
pca_analysis(fpkm,outdir,cmp,label,prefix)

