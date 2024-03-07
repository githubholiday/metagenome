args <- commandArgs(TRUE)
    if (length(args) != 2){
                print("Example : Rscript draw_heat.r expre.xls heatmap.pdf")
                q()
        }

library(pheatmap)
data <- read.csv(args[1],sep='\t',header=T,row.names=1)
#log_data <- log2(data)
#anno <- read.table(args[2],header=T,sep='\t',stringsAsFactors = FALSE,row.names=1,check.names = FALSE,quote = "")
pdf(args[2],w=12,h=12)
#pheatmap::pheatmap(log_data,color=colorRampPalette(c("blue","white","red"))(100), cluster_cols = FALSE,treeheight_row=10, treeheight_col=10,cluster_rows = T,cluster_columns = FALSE,annotation_row = anno)
pheatmap::pheatmap(data,color=colorRampPalette(c("navy", "white", "firebrick3"))(100),cluster_cols = T,cluster_rows = T)
dev.off()
