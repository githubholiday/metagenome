BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))/

ifdef config
	include $(config)
else 
	include $(BIN)/config/config.txt
endif
out_prefix=$(outdir)/$(prefix)
mod=$(BIN)/config/MetaGeneMark_v1.mod
cpu=4
seqkit_seq_para=200
HELP:
	@echo Description: 此脚本用于宏基因组基因预测和长度分布统计
	@echo Usage :
	@echo make -f makefile config= protein_fasta= nucleotide_fasta= out_gff= input= Gene
	@echo make -f makefile config= input= output= cd-hit
	@echo make -f makefile config= input= output= gene_stat
	@echo 
	@echo [参数说明] :
	@echo protein_fasta   : [必选]预测的蛋白序列
	@echo nucleotide_fasta: [必选]预测的核酸序列
	@echo out_gff         : [必选]输出gff文件
	@echo input           : [必选]出入文件，fa格式
	@echo 
	@echo [Version]:
	@echo v1.0.0 2020-02-12 by 'zhangyue' [yuezhang\@genome.cn];

MMSEQS2:
	echo MMSEQS2 start at `date`
	[ -s $(outdir) ] || mkdir -p $(outdir)
	cat $(indir)/*/*.nucleotide.filter.fasta >$(outdir)/all.nucleotide.fasta
	$(MMSEQ2) easy-cluster $(outdir)/all.nucleotide.fasta $(out_prefix).nucleotide $(outdir)/tmp $(mmseq2_para)
	echo MMSEQS2 end at `date`



Alignment_gene:
	echo Alignment_gene start at `date`
	[ -s $(outdir) ] || mkdir -p $(outdir)
	$(BWA) mem $(ref) $(R1) $(R2) -t 8 | $(SAMTOOLS) view -bS - > $(outdir)/$(sample).bam && echo "done!"
	$(SAMTOOLS) sort $(samtools_sort_para) $(outdir)/$(sample).bam -o $(outdir)/$(sample).sort.bam && $(SAMTOOLS) flagstat $(outdir)/$(sample).sort.bam > $(outdir)/$(sample).stat.xls && echo "done!"
	echo Alignment_gene finished at `date`


Gene:
	echo Gene start at `date`
	[ -s $(outdir) ] || mkdir -p $(outdir)
	cp $(MGM)/gm_key_64 /home/$(user)/.gm_key
	$(MGM)/gmhmmp $(gmhmmp_parematers) -m $(mod) -A $(protein_fasta) -D $(nucleotide_fasta) -o $(out_gff) $(assemble_fa)
	echo Gene end at `date`

GeneFilter:
	echo Gene filter start at `date`
	$(Seqkit) seq -m $(gene_min_len) -g $(nucleotide_fasta) >$(outdir)/tmp
	$(PYTHON3) $(BIN)/script/change_fa_id.py -i $(outdir)/tmp -o $(outdir)/$(sample).nucleotide.filter.fasta -n $(outdir)/$(sample).orf_stat.xls -s $(sample)
	rm $(outdir)/tmp
	echo Gene filter end at `date`

cd-hit:
	echo cd-hit start at `date`
	[ -s $(outdir) ] || mkdir -p $(outdir)
	cat $(indir)/*/*.nucleotide.filter.fasta >$(outdir)/all.nucleotide.fasta
	$(cd-hit) $(cd-hit_parematers) -i $(outdir)/all.nucleotide.fasta -o $(out_prefix).nucleotide.fa
	echo cd-hit end at `date`



GetORF :
	echo GetORF start at `date`
	cd $(outdir) && $(LongOrfs) -t $(input)
	cd $(outdir) && $(Predict) --cpu $(cpu) -t $(input)
	cp $(outdir)/nucleotide.fa.transdecoder.pep $(outdir)/transdecoder.pep
	echo GetORF end at `date`

PB_Index:
	echo Index start at `date`
	[ -s $(pb_index_file) ] && rm -rf $(pb_index_file) || echo pb index file is not exists
	$(PBMM2) index $(contigs_fa) $(pb_index_file)
	echo Index end at `date`

cds2aa :
	echo cd-hit start at `date`
	$(PERL) $(BIN)/script/cds2aa.pl $(input) >$(output)
	echo cd-hit end at `date`

gene_stat:
	echo gene_stat start at `date`
	[ -s $(outdir) ]||mkdir -p $(outdir)
	$(PYTHON3) $(BIN)/script/gene_stat.py -i $(input) -o $(out_prefix).stat -p $(out_prefix).pdf
	$(PYTHON3) $(BIN)/script/FastaTools.v2.py -i $(input) -fa -stats -o $(out_prefix).nucleotide.stat.xls -od $(out_prefix).nucleotide.length.xls
	$(RSCRIPT) $(BIN)/script/draw_plot.R $(out_prefix).nucleotide.length.xls $(out_prefix).nucleotide Length GC%
	echo gene_stat end at `date`

stat_all:
	echo all sample stat start at `date`
	$(PYTHON3) $(BIN)/script/stat_all.py -i $(input) -o $(output)
	echo all sample end at `date`

stat_orf:
	echo orf stat start at `date`
	$(PYTHON3) $(BIN)/script/stat_orf.py -i $(input) -o $(output)
	echo orf stat end at `date`
