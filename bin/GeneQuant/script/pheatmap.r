args <- commandArgs(TRUE)
	if (length(args) != 8){
		print("Rscript pheatmap.r <InFile <OutFile> <cluster:none/rows/cols/both> <display_numbers(T/F)> <height> <width> <Title(default:NULL)><cmp.list>")
			print("Example : /annoroad/bioinfo/PMO/zhaohm/bin/R-3.0.1/bin/Rscript pheatmap.r pheatmapTest.txt pheatmapTestCluster_both.pdf both T 8 8 Test cmp.list")
			q()
	}
	
	library(pheatmap)
	library(RColorBrewer);
d<-read.table(args[1],header=T,stringsAsFactors=FALSE, row.names = 1,check.names=FALSE)

##auto size-linwenwen
if (args[5]=="auto"){
	args[5]<-length(rownames(d))
	if (as.numeric(args[5])<6){args[5]<-6}
}
if (args[6]=="auto"){
	args[6]<-length(colnames(d))
	if (as.numeric(args[6])<6){args[6]<-6}
}

print(c(args[5],args[6]))
	pdf(args[2],h=as.numeric(args[5]),w=as.numeric(args[6]))
	par(font=2,font.axis=2,font.lab=2)
	if(args[7]=="NULL") main = "" else main = args[7]
	if (args[3] == "none"){
		group<-read.table(args[8],header=T,sep="\t",stringsAsFactors=FALSE,check.names=FALSE)
		rownames(group)<-group$Sample
		tmp <- merge(d,group,by="row.names")
		annotation_c <- data.frame(tmp[,"Group"])
		rownames(annotation_c)<-tmp$Sample
		colnames(annotation_c)<-"Group"
		pheatmap(as.matrix(d),
				display_numbers = args[4],
				color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(100),
				scale="none",
				cluster_rows = F,
				cluster_cols=F,
				main =main,
				fontsize_row=20,
				fontsize_col=20,
				fontsize_number=18,
				legend=T,
				border_color = "grey",
				number_format = "%.2f",
				annotation_col = annotation_c,
				)
}else if (args[3] == "rows"){
	pheatmap(as.matrix(d),
			display_numbers = args[4],
			color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(100),
			scale="none",
			cluster_rows = T,
			clustering_distance_rows="euclidean",
			clustering_method="complete",
			cluster_cols=F,
			main =main,
			fontsize_row=20,
			fontsize_col=20,
			fontsize_number=18,
			legend=T,
			show_rownames = F,
			border_color = "grey",
			number_format = "%.2f",
			)
}else if (args[3] == "cols"){
	pheatmap(as.matrix(d),
			display_numbers = args[4],
			color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(100),
			scale="none",
			cluster_rows = F,
			clustering_distance_cols="euclidean",
			clustering_method="complete",
			cluster_cols=T,
			show_colnames = F,
			main =main,
			fontsize_row=20,
			fontsize_col=20,
			fontsize_number=18,
			legend=T,
			border_color = "grey",
			number_format = "%.2f",
			)
} else {
	pheatmap(as.matrix(d),
			display_numbers = args[4],
			color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(100),
			scale="none",
			cluster_rows = T,
			clustering_distance_cols="euclidean",
			clustering_method="complete",
			cluster_cols=T,
			main =main,
			fontsize_row=20,
			fontsize_col=20,
			show_colnames = T,
			show_rownames = F,
			fontsize_number=18,
			legend=T,
			border_color = "grey",
			number_format = "%.2f",
			)
}
dev.off()
