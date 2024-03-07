library(ggpubr)
library(rstatix)
library(doBy)
library(ggplot2)
library(ggsci)
colors=c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))

draw = function(name,outdir,colors,data,group_name){
  p = ggplot(data, aes(x=Group, y=value,color=Group)) + 
  geom_boxplot()+
  #stat_compare_means(label = "p.signif", label.x = 1.5)+
  stat_compare_means(method='wilcox.test')+
  scale_color_manual(values=colors)+
  labs(title=name,x="Group", y = "")+
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
                   plot.title=element_text(hjust = 0.5,vjust=0.5,size=10),
                   plot.subtitle=element_text(size=12))
  p = p + main_theme
  outpath = paste(outdir,group_name,sep="/")
    if(! file.exists(outpath)){
        dir.create(outpath)
    }
  ggsave(p,file=paste(outpath,"/boxplot_",group_name,"_",name,".pdf",sep=""),width=8,height=8)
}

check_cmp <- function(cmp){
    na_flag <- apply(is.na(cmp), 2, sum)
    cmp <- cmp[,which(na_flag == 0)]
    print(cmp)
    print(class(cmp))
    if (length(dim(cmp)) < 2){
        print("your cmp file has no groups,so exit")
        q()
    }
}

args<-commandArgs(TRUE)
count_file <- args[1]
group_file <- args[2]
cmp_file <- args[3]
outdir <- args[4]

# row.names = 1会导致后续结果中的物种名字中的|变为.，为了保持一致，所以就不用这个参数了。
#data <- read.table(count_file, sep = '\t', row.names = 1, header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, quote="")
data <- read.csv(count_file, sep = '\t', header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
group <- read.table(group_file, sep = '\t', header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
cmplist <- read.table(cmp_file, sep = '\t',stringsAsFactors = FALSE, check.names = FALSE)
check_cmp(cmplist)

for (i in 1:nrow(cmplist)){
    group_name <- paste(cmplist[i,1],cmplist[i,2],sep="_")
    newgroup <- group[group$Group %in% cmplist[i,],]
    result <- NULL
    for (n in 1:nrow(data)) {
        data_id <- data[n,1]
        data_n <- data.frame(t(data[n,2:ncol(data)]))
        names(data_n)[1] <- 'value'
        data_n$Sample <- rownames(data_n)
        data_n <- merge(data_n, newgroup, by = 'Sample')
        data_n$Group <- factor(data_n$Group)
        data_n$value <- as.numeric(data_n$value)
        if (sum(data_n$value) > 0){
        stat.test <- compare_means(value~Group,data_n,group_by="Group",method = "wilcox.test")
        p_value <- format(stat.test$p,scientific=F)
        #if (!is.na(p_value) & (length(p_value)==1)){
        if (length(p_value)==1){
            if (p_value < 0.05) {
            stat <- summaryBy(value~Group, data_n, FUN = c(mean, sd))
            result <- rbind(result, c(data_id, round(stat[1,2],2), round(stat[1,3],2), round(stat[2,2],2), round(stat[2,3],2), p_value))
  #          draw(data_id,outdir,colors[1:2],data_n,group_name)
            }
          }
        }
    }
    result <- data.frame(result)
    if ( dim(result)[1] > 0 ){
        names(result) <- c('Name', paste( rep(c(stat[1,1],stat[2,1]),each=2) , c("mean","sd") , sep="."), 'p_value')
        result$p_adjust <- p.adjust(result$p_value, method = 'BH') #推荐加个 p 值校正的过程
        result <- result[order(result$p_value),]
        top_species <- result$Name[1:min(10,nrow(result))]
        for (i in top_species){
            data_i <- data.frame(t(data[which(data[,1]==i),2:ncol(data)]))
            names(data_i) <- 'value'
            data_i$Sample <- rownames(data_i)
            data_i <- merge(data_i, newgroup, by='Sample')
            data_i$Group <- factor(data_i$Group)
            i <- gsub("\\/|\\(|\\)| |'|\\|",".",i)
            draw(i,outdir,colors[1:length(unique(data_i$Group))],data_i,group_name)
        }
        result$p_value <- format(as.numeric(result$p_value),digits=4,scientific=T)
        result$p_adjust <- format(as.numeric(result$p_adjust),digits=4,scientific=T)
        write.table(result, paste(outdir,"/wilcox_",group_name,".xls",sep=""),  sep = '\t', row.names = FALSE, quote = FALSE)
    }else{
        print(paste("group : ",group_name," has no significant species! so there is no outfile"))
    }
}
