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

mk_subdir <- function(parent_out_dir, result_dir)
{
	setwd(parent_out_dir)
	if(file.exists(result_dir))
	{
		unlink(result_dir, recursive=TRUE)
	}
	new_dir <- file.path(parent_out_dir,result_dir)
	dir.create(new_dir)
	setwd(new_dir)
}
###PCA Analysis
pca_analysis <- function(fpkm,parent_out_dir,cmp,label)
{
	mk_subdir(parent_out_dir,"PCA_analysis")
	res_pca <- PCA(t(fpkm),graph=FALSE)

	time=Sys.time()
	mess=paste(format(time),"- PCA - INFO - PCA function Analysis finished ... ...")
	cat(mess,"\n")

###+++++++++++++PCA_summary Output++++++++++++++++++++++
	Comp <- rownames(res_pca$eig)
	summary_pca <- cbind(Comp,res_pca$eig)
	write.table(summary_pca,"PCA_summary.xls",sep="\t",col.names=T,row.names=F,quote=F)

###+++++++++++++Dim Explanation for Variable(gene)++++++
	Variable <- rownames(res_pca$var$cos2)
	Var_exp <- cbind(Variable,res_pca$var$cos2)
	write.table(Var_exp,"Variable_gene_cos2.xls",sep="\t",col.names=T,row.names=F,quote=F)

###+++++++++++++Variable Contribute for Dim ++++++++++++++
	Var_contrib <- cbind(Variable,res_pca$var$contrib)
	write.table(Var_contrib,"Variable_gene_contrib.xls",sep="\t",col.names=T,row.names=F,quote=F)

###+++++++++++++Individual(Sample) Coordinates on the principle components+++++++++++++++++++
	Sample <- rownames(res_pca$ind$coord)
	Sample_cor <- cbind(Sample,res_pca$ind$coord)
	write.table(Sample_cor,"Sample_coordinate.xls",sep="\t",col.names=T,row.names=F,quote=F)
######++++++++++++++++++Table Output End++++++++++++++++++++



	coltmp <- c("red","darkgreen","blue","black","chocolate","brown","darkorange","deeppink","deepskyblue1","lawngreen","yellow","grey","tomato","purple","grey","gold","cyan","darkmagenta","darkred")
#shape_all <- c(c(15:25),c(1:14))
	shape_all <- rep(c(15:18,3,4),30)
	len_group <-length(unique(cmp$group))

	cmp$group <- factor(cmp$group,levels=unique(cmp$group))
    print(cmp$group)
	pdf("PCA_individual_dim1_dim2.pdf")
	#fviz_pca_ind(res_pca, label="none", habillage=comm_input$group,addEllipses=TRUE, ellipse.level=0.95)
#	f <- factor(comm_input$group)
	if (label == "True")
	{
	#pa <- fviz_pca_ind(res_pca, geom.ind = "point", habillage = cmp$group, palette = coltmp[1:len_group],  legend.title = "Groups") + scale_shape_manual(values=seq(len_group))
		pa <- fviz_pca_ind(res_pca, geom.ind = "point", habillage = cmp$group, palette = coltmp[1:len_group],labelsize=3, legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
	}else
	{
		pa <- fviz_pca_ind(res_pca, label="none", geom.ind = "point", habillage = cmp$group, palette = coltmp[1:len_group],  legend.title = "Groups") + scale_shape_manual(values=shape_all[1:len_group])
	}
	print(pa)
	dev.off()
######++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	pdf("PCA_variable_dim1_dim2.pdf")
	select_var <- NULL
	if(ncol(t(fpkm)) >= 20){
		select_var <- list(contrib = 20)
	}
	#pb <-fviz_pca_var(res_pca,col.var="contrib",select.var=select_var)+scale_color_gradient2(low="white", mid="blue",high="red",midpoint=55)+theme_bw()
	pb <- fviz_pca_var(res_pca,col.var="contrib",select.var=select_var)+theme_bw()
	print(pb)
	dev.off()
############################++++++++3d plot+++++++++++++++++++++++++++++++++++++++++++++++

	shapes = seq(len_group)
	shapes <- shapes[as.numeric(cmp$group)]
	scatterplot3d(res_pca$ind$coord[,1:3], pch = shapes)
	colors <- coltmp[1:len_group]
	colors <- colors[as.numeric(cmp$group)]

#	col <- coltmp
#	col<-c("red","green","blue","black","#f58f98","#6f599c","#2a5caa","#00a6ac","#7fb80e","#1d953f","#df9464","#decb00","#f7acbc","#905a3d","#a3cf62","#45224a")
#	sample<-rownames(comm_input)
#	group<-comm_input$group
#	tmpdata<-cbind(group,sample)
#	groupCol<-cbind(unique(comm_input$group),col[1:length(unique(comm_input$group))])
#	sampleCol<-merge(groupCol,tmpdata,by.x=1,by.y=1)
#	col<-sampleCol$V2
	pdf("PCA.3d.pdf")
	dim1<-paste("Dim1(",round(res_pca$eig[1,2],2),"%)",sep="")
	dim2<-paste("Dim2(",round(res_pca$eig[2,2],2),"%)",sep="")
	dim3<-paste("Dim3(",round(res_pca$eig[3,2],2),"%)",sep="")
	s3d<-scatterplot3d(res_pca$ind$coord[,1:3],color=colors,pch=16,xlab=dim1,ylab=dim2,zlab=dim3,cex.symbols=1.0,cex.lab=1.0,cex.axis=0.8)
	if (label == "True")
	{
		s3d.coords <- s3d$xyz.convert(res_pca$ind$coord[,1:3])
		text(s3d.coords$x, s3d.coords$y, labels = rownames(res_pca$ind$coord),pos = 2, offset = 0.5, cex = 0.6)
	}
#	print(group)
#	print(unique(group))
#	legend("topright",pch=16,legend=as.character(unique(group)),bty = 'n',col = col[1:length(unique(comm_input$group))])
	legend("right",pch=16,pt.cex=1.2,legend = levels(cmp$group),bty = 'n',col =  coltmp[1:len_group], cex = 0.6,inset=0.08,ncol=1)
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
	library("scatterplot3d")
	#input file & read your rpkm table
	fpkm <- read.table(input_file[1],header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE)
	cmp <- read.table(input_file[2],header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE)
    cmp$name <- rownames(cmp)

    if ( length(cmp$name) < 5){
        print("提示：样本数量少于5个，不做PCA分析，退出")
        q()
    }


	## define the output dir
	#parent_out_dir <- getwd()
	#if(length(input_file) == 3)
	#{
	parent_out_dir <- input_file[3]
	#}
	if(! file.exists(parent_out_dir))
	{
		dir.create(parent_out_dir)
	}
	setwd(parent_out_dir)
	#$parent_out_dir <- getwd()
	#print(parent_out_dir)
	## check and match the input files
	time=Sys.time()
	mess=paste(format(time),"- PCA - INFO - PCA Begins ... ... ")
	cat(mess,"\n")
	pca_analysis(fpkm,parent_out_dir,cmp,input_file[4])
}

main_fun()
