library(ggpubr)
library(rstatix)
library(doBy)
library(ggplot2)
library(ggsci)
library(stringr)
colors=c(pal_aaas("default", alpha = 0.8)(10),pal_lancet("lanonc", alpha = 0.8)(9),pal_nejm("default", alpha = 0.8)(8),pal_jama("default", alpha = 0.8)(7),pal_jco("default", alpha = 0.8)(10))

draw = function(name,outdir,colors,data,group_name){
  p = ggplot(data, aes(x=Group, y=value,color=Group)) + 
  geom_boxplot()+
  #stat_compare_means(label = "p.signif", label.x = 1.5)+
  stat_compare_means(method='anova')+
  scale_color_manual(values=colors)+
  labs(x="Group", y = "")+
  ggtitle(str_wrap(name,20))+
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


data <- read.table(count_file, sep = '\t', header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, quote="")
group <- read.table(group_file, sep = '\t', header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
cmplist <- read.table(cmp_file, sep = '\t',stringsAsFactors = FALSE, check.names = FALSE)
check_cmp(cmplist)
result <- NULL
for (i in 1:nrow(cmplist)){
    group_name <- cmplist[i,1]
    newgroup <- group[group$Group %in% strsplit(cmplist[i,2]," ")[[1]],]
    for (n in 1:nrow(data)) {
        data_id <- data[n,1]
        data_n <- data.frame(t(data[n,2:ncol(data)]))
        names(data_n)[1] <- 'value'
        data_n$Sample <- rownames(data_n)
        data_n <- merge(data_n, newgroup, by = 'Sample')
        data_n$Group <- factor(data_n$Group)
        stat.test <- compare_means(value~Group,data_n,group_by="Group",method = "anova")
        p_value <- format(stat.test$p,scientific=F)
        all_group <- c()
        if (!is.na(p_value) & p_value < 0.05 ) {
            stat <- summaryBy(value~Group, data_n, FUN = c(mean, sd))
            for (i in 1:nrow(stat)){
                all_group = c(all_group,round(stat[i,2],2),round(stat[i,3],2))
            }
            result <- rbind(result, c(data_id,all_group,p_value))
        }
    }
    result <- data.frame(result)
    name = c()
    if ( dim(result)[1] > 0 ){
        for (i in 1:nrow(stat)){
            name = c(name,paste(as.character(stat[i,1]),c("mean","sd"),sep = "."))
        }
        names(result) <- c('Name', name ,'p_value')
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
        result$p_adjust <- format(p.adjust(result$p_value, method = 'BH'),digits=4,scientific=TRUE) #推荐加个 p 值校正的过程
        result$p_value <- format(as.numeric(result$p_value),digits=4,scientific=TRUE)
        write.table(result, paste(outdir,"/ANOVA_",group_name,".xls",sep=""), sep = '\t', row.names = FALSE, quote = FALSE)
        result <- NULL
    }else{
        print(paste("group : ",group_name," has no significant species! so there is no outfile"))
    }
}
