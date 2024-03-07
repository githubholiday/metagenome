args <- commandArgs(TRUE)
    if (length(args) != 3){
                print("Example : phyfile taxfile outpdf")
                q()
        }

library(phyloseq)
library(ggplot2)
otumat <- read.csv(args[1],sep="\t",row.names=1)
taxmat <- read.csv(args[2],sep="\t",row.names=1)
OTU = otu_table(otumat, taxa_are_rows = TRUE)
TAX = tax_table(taxmat)
colnames(TAX) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
rownames(TAX) <- rownames(otumat)
physeq = phyloseq(OTU, TAX)
alpha_meas = c("Observed", "Chao1", "ACE", "Shannon", "Simpson", "InvSimpson")
pdf(args[3],w=12,h=12)
plot_richness(physeq, measures=alpha_meas)
dev.off()

