BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
include $(config)
cutf=1000
queue=sci.q,nassci.q
top?=10

HELP:
	@echo Description: 此脚本用于宏基因组基因功能注释
	@echo Usage :
	@echo make -f makefile cuts= indir= outdir= NR
	@echo 
	@echo [参数说明] :
	@echo cuts       : [必选]样本名称
	@echo input      : [必选]输出目录
	@echo outir      : [必选]输入文件，ccs.fa
	@echo genomeSize : [必选]预估基因组大小
	@echo 
	@echo [Version]:
	@echo v1.0.0 2020-02-13 by 'zhangyue' [yuezhang\@genome.cn];
	@echo 再一次输入用法：

##### 新版从这里开始
COG_Stat:
	echo "######## single sample COG annotation START at `date` #########"
	$(PYTHON3) ${script}/get_anno_count.py -a ${anno_file} -c ${count_file} -o ${cog_count_out} -col ${col}
	${CSVTK} -t join -f 1 -k $ ${cog_anno} > ${cog_count_anno_out}
	echo "######## single sample COG annotation END at `date` #########"


PHI_Stat:
	echo "######## single sample PHI annotation start at `date` ########"
	mkdir -p $(outdir)
	$(PERL) -i.bak2 -F'\t' -alne 'if(!/Gene_ID/){$$F[2]=(split(/\|/,$$F[1]))[-1];$$F[1]=(split(/\|/,$$F[1]))[0]};print "$$F[0]\t$$F[1]\t$$F[2]"' $(anno_file)
	sed -i '1a #Gene\tSubject_ID\tAffection'  $(anno_file)
	$(PYTHON3) ${script}/get_anno_count.py -a $(anno_file)  -col 2 -c $(count_file) -o $(phi_count_anno_out)
	echo "######## single sample PHI annotation end at `date` ########"

ARDB_Stat:
	echo "######## ARDB_Stat start at `date` ########"
	mkdir -p $(outdir)
	$(PYTHON3) ${script}/get_anno_count.py -a $(anno_file) -c ${count_file} -o ${ardb_count_out} -col ${col}
	$(CSVTK) -t join -f 2,1 $(ardb_count_out) $(ardb_db) > $(ardb_count_anno_out)
	echo "######## ARDB_Stat end at `date` ########"

#####比对模块
CAZy:
	echo "########  CAZY annotation start at `date` ########" 
	mkdir -p $(outdir)
	$(HMMSCAN) -E 10 --domtblout $(outdir)/CAZyme.dbCAN.txt -o $(outdir)/CAZyme.dbCAN $(DB) $(infa)
	sh $(BIN)/script/CAZy/hmmscan-parser.sh $(outdir)/CAZyme.dbCAN.txt > $(outdir)/CAZyme.annot
	awk '$$5<1e-15&&$$10>0.35' $(outdir)/CAZyme.annot > $(outdir)/CAZyme.annot.stringent
	$(PERL) $(BIN)/script/CAZy/CAZy_stat.pl $(outdir)/CAZyme.annot.stringent $(outdir)/Gene_All.cazy.num $(outdir)/Gene_All.cazy.xls
	echo "######## CAZY annotation end at `date` ########"

CAZy_Stat:
	echo "######## single sample CAZY annotation start at `date` ########"
	mkdir -p $(outdir)
	$(PYTHON3) ${script}/get_anno_count.py -a ${anno_file} -c ${count_file} -o ${outdir}/${prefix}.xls -col ${col}
	echo "######## single sample CAZY annotation end at `date` ########"



#####KEGG 
.PHONY:KOBAS_Anno
KOBAS_Anno:
	echo "######## KOBAS_Anno  start at `date` ########"
	mkdir -p $(outdir)
	$(PYTHON3) ${annotate_py} -i $(infile) -t blastout:tab -s ko -o $(outfile) -n 6 -k $(kobas_home) -v $(blast_home)
	echo "######## KOBAS_Anno  end at `date` ########"

.PHONY:KEGG_Format
KEGG_Format:
	echo "######## KOBAS_Anno  start at `date` ########"
	$(PYTHON3) $(script)/kegg_format.py -i $(anno_file) -o $(pathway_out) -k $(kegg_out)
	$(PYTHON3) ${script}/get_anno_count.py -a $(kegg_out) -c ${count_file} -o ${kegg_count_out} -col ${col}
	$(CSVTK) -t join -f 1 -k${kegg_count_out} ${pathway_out} > ${outfile}
	echo "######## KOBAS_Anno  end at `date` ########"


###fa split
split_fa:
	echo "######## KOBAS_Anno  start at `date` ########"
	$(PERL) $(script)/fastaDeal_v2.pl -cutf $(number) $(infa) -outdir $(outdir) -filename $(prefix)
	echo "######## KOBAS_Anno  end at `date` ########"


outdir=$(dir $(abspath $(firstword $(outfile))))
.PHONY:Dimonad_Blastp
Diamonad_Blastp:
	echo "######## Diamond blastp start  start at `date` ########"
	mkdir -p ${outdir}
	${DIAMOND} blastp -d ${DB} -q ${infa} -o ${outfile} -e 1e-5 -k 1 -f 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle --max-target-seqs 1 --threads ${cpu}
	echo "######## Diamond blastp start  end at `date` ########"