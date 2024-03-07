args <- commandArgs(TRUE)
#    if (length(args) != 3){
#                print("Example : inputfile out.pdf type")
#                q()
#        }
library(ggplot2)
data <- read.csv(args[1],sep='\t',header=T)
pdf(args[2])
if (args[3] == "1"){
data$Genome_size <- data$Genome.size..bp./1000
ggplot(data,aes(x=Completeness,y=Contamination,size=Genome_size,fill=Bin.Id))+geom_point(shape=21,colour="black")+scale_size_area(max_size=10)+theme_bw()+labs(color="Genome bin",size="Bin size(kb)")
}else{
data$ContigLengths = data$ContigLengths/1000
ggplot(data,aes(x=ContigGC,y=ContigDepths,size=ContigLengths,fill=Bin))+
      geom_point(shape=21,colour="black")+
      scale_size_area(max_size=10)+
      theme_bw()+labs(color="Genome bin",size="Contig size(kb)")
}
dev.off()

