args <- commandArgs(TRUE)
    if (length(args) != 2){
                print("Example : Rscript draw_heat.r expre.xls heatmap.pdf")
                q()
        }

library(pheatmap)
data <- read.csv(args[1],sep='\t',header=T,row.names=1)
data[data==0]=0.0001
widthcell = min(280%/%dim(data)[2],20)
heightcell = min(315%/%dim(data)[1],15)
log_data <- log10(data)
pdf(args[2])
pheatmap::pheatmap(log_data,color=colorRampPalette(c("white","yellow","red"))(100),treeheight_row=50, treeheight_col=50,cluster_rows = T,cluster_columns = T,cellwidth = widthcell, cellheight = heightcell)
dev.off()
