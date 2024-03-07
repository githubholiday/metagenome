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
pca_analysis <- function(comm_input,parent_out_dir,label,coltmp)
{
	mk_subdir(parent_out_dir,"result")
	comm_counts <- comm_input[,-1]
	res_pca <- PCA(comm_counts,graph=FALSE)

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
	write.table(Var_contrib,"Varable_gene_contrib.xls",sep="\t",col.names=T,row.names=F,quote=F)

###+++++++++++++Individual(Sample) Coordinates on the principle components+++++++++++++++++++
	Sample <- rownames(res_pca$ind$coord)
	Sample_cor <- cbind(Sample,res_pca$ind$coord)
	write.table(Sample_cor,"Sample_coordinate.xls",sep="\t",col.names=T,row.names=F,quote=F)

######++++++++++++++++++Table Output End++++++++++++++++++++
	pdf("PCA_individual_dim1_dim2.pdf")
	#fviz_pca_ind(res_pca, label="none", habillage=comm_input$group,addEllipses=TRUE, ellipse.level=0.95)
	f <- factor(comm_input$group)
	if (label == "True")
	{
		pa <- fviz_pca_ind(res_pca, habillage=f)
	}else
	{
		pa <- fviz_pca_ind(res_pca, label="none", habillage=f)
	}
	print(pa)
	dev.off()

######++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	pdf("PCA_variable_dim1-dim2.pdf")
	select_var <- NULL
	if(ncol(comm_counts) >= 20){
		select_var <- list(contrib = 20)
	}
	#pb <-fviz_pca_var(res_pca,col.var="contrib",select.var=select_var)+scale_color_gradient2(low="white", mid="blue",high="red",midpoint=55)+theme_bw()
	pb <- fviz_pca_var(res_pca,col.var="contrib",select.var=select_var)+theme_bw()
	print(pb)
	dev.off()
############################++++++++3d plot+++++++++++++++++++++++++++++++++++++++++++++++

	col <- coltmp
#	col<-c("red","green","blue","black","#f58f98","#6f599c","#2a5caa","#00a6ac","#7fb80e","#1d953f","#df9464","#decb00","#f7acbc","#905a3d","#a3cf62","#45224a")
	sample<-rownames(comm_input)
	group<-comm_input$group
	tmpdata<-cbind(group,sample)
	groupCol<-cbind(unique(comm_input$group),col[1:length(unique(comm_input$group))])
	sampleCol<-merge(groupCol,tmpdata,by.x=1,by.y=1)
	col<-sampleCol$V2
	pdf("PCA.3d.pdf")
	dim1<-paste("Dim1(",round(res_pca$eig[1,2],2),"%)",sep="")
	dim2<-paste("Dim2(",round(res_pca$eig[2,2],2),"%)",sep="")
	dim3<-paste("Dim3(",round(res_pca$eig[3,2],2),"%)",sep="")
	scatterplot3d(res_pca$ind$coord[,1],res_pca$ind$coord[,2],res_pca$ind$coord[,3],color=col,pch=19,xlab=dim1,ylab=dim2,zlab=dim3,cex.symbols=1.5,cex.lab=1.5,cex.axis=1.2)
#	print(group)
#	print(unique(group))
#	legend("topright",pch=16,legend=as.character(unique(group)),bty = 'n',col = col[1:length(unique(comm_input$group))])
	legend("topright",pch=16,legend=as.character(unique(group)),bty = 'n',col = c("red","green","blue","black","#f58f98","#6f599c","#2a5caa","#00a6ac","#7fb80e","#1d953f","#df9464","#decb00","#f7acbc","#905a3d","#a3cf62","#45224a"))
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

	library(psych)
	library(reshape2)
	library(ggplot2)
	library(factoextra)

	### input file & read your rpkm table
	data <- read.table(input_file[1],header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE)
	group <- read.table(input_file[2],header=TRUE,sep="\t",row.names=1,stringsAsFactors=FALSE)
	comm_input <- t(data)

	## define the output dir
	out_dir <- input_file[3]
	
	## check and match the input files
	time=Sys.time()
	mess=paste(format(time),"- PCA - INFO - PCA Begins ... ... ")
	cat(mess,"\n")

	pca_analysis(comm_input,parent_out_dir,input_file[2],coltmp)
}

main_fun()
