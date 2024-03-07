# install and load multiple R packages
ipkg<- function(pkg)
{
	new_pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
	if (length(new_pkg) != 0)
	{
		install.packages(new_pkg, dependencies=TRUE)
	}
	sapply(pkg, require, character.only=TRUE)
}

###PCA Analysis
pca_analysis <- function(fpkm,parent_out_dir,cmp,label,prefix)
{
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
	write.table(Sample_cor,paste(prefix,"Sample_coordinate.xls",sep="_"),sep="\t",col.names=T,row.names=F,quote=F)
######++++++++++++++++++Table Output End++++++++++++++++++++


	library(ggsci)
	coltmp <- c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))
#	coltmp <- c("red","darkgreen","blue","black","chocolate","brown","darkorange","deeppink","deepskyblue1","lawngreen","yellow","grey","tomato","purple","grey","gold","cyan","darkmagenta","darkred")
	shape_all <- rep(c(15:18,3,4),30)
	len_group <-length(unique(cmp$Group))
	print(len_group)
	print(coltmp[1:len_group])
	cmp$Group <- factor(cmp$Group,levels=unique(cmp$Group))
#因为每组样本数量少于3个的时候，无法绘制圈图
	pdf("PCA_individual_dim1_dim2_ellipses.pdf")
	if (label == "True")
	{
		pa <- fviz_pca_ind(res_pca, geom.ind = "point", habillage = cmp$Group, addEllipses = TRUE, palette = coltmp[1:len_group],labelsize=3, legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
	}else
	{
		pa <- fviz_pca_ind(res_pca, label="none", geom.ind = "point", habillage = cmp$Group, addEllipses = TRUE,palette = coltmp[1:len_group],  legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
	}
	print(pa)
	dev.off()
	pdf(paste(prefix,"PCA_individual_dim1_dim2.pdf",sep="_"))
	if (label == "True")
	{
		pa1 <- fviz_pca_ind(res_pca,  mean.point=FALSE, habillage = cmp$Group, palette = coltmp[1:len_group],labelsize=3, legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
	}else{
		pa1 <- fviz_pca_ind(res_pca, label="none", mean.point=FALSE, habillage = cmp$Group, palette = coltmp[1:len_group],  legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
}
	print(pa1)
	dev.off()
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
main_fun <- function()
{
	## input arguments
	input_file <- commandArgs(trailingOnly=TRUE)

	time=Sys.time()
	mess=paste(format(time),"- PCA - INFO - Your input arguments are imported. ")
	cat(mess,"\n")
	library("ade4")
	library("adegraphics")
	library("FactoMineR")
	library("factoextra")
	library("devtools")
	library("scatterplot3d")
	#input file & read your rpkm table
	fpkm <- read.table(input_file[1],header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE)
	cmp <- read.table(input_file[2],header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE)
	if (dim(cmp)[1]<6){
		print("该比较组合中每组样本数量少于3个，因此不进行pca分析")
		q()
	}
	fpkm = fpkm[,rownames(cmp)]
	parent_out_dir <- input_file[3]
	if(! file.exists(parent_out_dir))
	{
		dir.create(parent_out_dir)
	}
	setwd(parent_out_dir)
	time=Sys.time()
	mess=paste(format(time),"- PCA - INFO - PCA Begins ... ... ")
	cat(mess,"\n")
	pca_analysis(fpkm,parent_out_dir,cmp,input_file[4],input_file[5])
}

main_fun()
