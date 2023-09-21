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



GO:
	echo GO annotation start at `date`
	mkdir -p $(outdir)
	$(BLASTP) -query $(infa) -db $(UNIPROT) $(BLAST_PAREMATERS) -out $(outdir)/Gene_All.uniprot.aln
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.uniprot.aln 1 $(outdir)/Gene_All.uniprot.xls
	$(PYTHON3) $(BIN)/script/GO/anno.py -i $(outdir)/Gene_All.uniprot.xls -a $(SPORTDB) -o $(outdir)/Gene_All.anno
	$(PERL) $(BIN)/script/GO/stat_gene_go.pl $(outdir)/Gene_All.anno >$(outdir)/Gene_All.GO.xls
	echo GO annotation end at `date`

GO_Diamond:
	echo GO annotation start at `date`
	mkdir -p $(outdir)
	$(DIAMOND) blastp -q $(infa) --db $(UNIPROT) $(Diamond_blastp) -o $(outdir)/Gene_All.uniprot.aln
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.uniprot.aln 1 $(outdir)/Gene_All.uniprot.xls
	$(PYTHON3) $(BIN)/script/GO/anno.py -i $(outdir)/Gene_All.uniprot.xls -a $(SPORTDB) -o $(outdir)/Gene_All.anno
	$(PERL) $(BIN)/script/GO/stat_gene_go.pl $(outdir)/Gene_All.anno >$(outdir)/Gene_All.GO.xls
	echo GO annotation end at `date`

GO_Stat:
	echo single sample GO annotation start at `date`
	[ -s $(outdir) ] || mkdir -p $(outdir)
	$(PYTHON3) $(BIN)/script/extract_single_annotation.py -i $(input) -a $(annotation_all) -o $(annotation_sample)
	cat $(annotation_sample)|sed 's/|/_/g' >$(outdir)/go.tmp
	cut -f1 $(annotation_sample)|sed 's/|/_/g'|sed 1d >$(outdir)/up.list
	touch $(outdir)/down.list
	$(PYTHON3) $(BIN)/script/GO/go_with_gene.py -c $(GO_DB)/go.class -p $(GO_DB)/go.path -s $(GO_DB)/go.alias -g $(outdir)/go.tmp -i $(outdir)/up.list -o $(outdir)/$(sample)
	$(PYTHON3) $(BIN)/script/GO/go_up_down.py -p $(GO_DB)/go.path -i $(outdir)/$(sample).go_with_gene -u $(outdir)/up.list -d $(outdir)/down.list -o $(outdir)/$(sample).gotmp
	$(PYTHON3) $(BIN)/script/GO/UpDownGenes_GoEnrichment.py -f $(outdir)/$(sample).gotmp.xls -o $(outdir) -s $(sample)
	cut -f 1,2,4 $(outdir)/$(sample).gotmp.xls >$(outdir)/$(sample).gene_go.xls
	sed -i 's/Ontology\tTerm_name\tUp_Percent/Class\tGO_term\tPercentage/' $(outdir)/$(sample).gene_go.xls
	less $(annotation_all) |cut -f 1,2 |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo single sample GO annotation end at `date`

.PHONY:Fa_Deal
Fa_Deal:
	echo Fa deal start at `date`
	$(PERL) $(faDeal) -cutf $(cutf) $(infa) -outdir $(outdir)
	echo Fa deal end at `date`

.PHONY:swissprot_blastp
swissprot_blastp:
	echo blastp start at `date`
	mkdir -p $(outdir)
	#$(DIAMOND) blastp -q $(infa) --db $(uniprot) $(Diamond_blastp) -o  $(outdir)/$(cuts).out
	$(BLASTP) -query $(infa) -db $(uniprot) $(BLAST_PAREMATERS) -out $(outdir)/$(cuts).out
	echo blastp end at `date`

.PHONY:swissprot
swissprot:
	echo SWISSPROT annotation start at `date`
	ls $(indir)/*.out > $(outdir)/blast_list
	$(PERL) $(BIN)/script/KEGG/choose_blast_m8.pl -i $(outdir)/blast_list -o $(outdir)/ncbi_blast_prot.out
	cut -f1,2,13 $(outdir)/ncbi_blast_prot.out > $(outdir)/Gene_All.swissprot.xls
	sed -i "1i Gene_ID\tSubject_ID\tAnnotation" $(outdir)/Gene_All.swissprot.xls
	echo SWISSPROT annotation end at `date`

SwissProt_Stat:
	echo SWISSPROT stat start at `date`
	mkdir -p $(outdir)
	$(CSVTK) -t join $(annotation_all) $(input) |cut -f 1,2,3 > $(annotation_sample)
	less $(annotation_all) |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo SWISSPROT stat end at `date`


.PHONY:KEGG_Diamond
KEGG_Diamond:
	echo KEGG_Diamond  start at `date`
	mkdir -p $(outdir)
	$(DIAMOND) blastx --db $(diamond_db) -q $(infa) -o $(outdir)/$(cuts).txt
	echo KEGG_Diamond  end at `date`

.PHONY:KOBAS_Anno
KOBAS_Anno:
	echo KOBAS_Anno  start at `date`
	mkdir -p $(outdir)
	python ${BIN}/script/KEGG/kobas-3.0/scripts/annotate.py -i $(indir)/$(cuts).txt -t blastout:tab -s ko -o $(outdir)/$(cuts).out -n 6 -k $(kobas_home) -v $(blast_home)
	echo KOBAS_Anno  end at `date`

.PHONY:KOBAS_format
KOBAS_format:
	echo KOBAS_format  start at `date`
	$(PYTHON3) $(BIN)/script/kegg_format.py -i $(input) -o $(outdir)/Gene_All.pathway.xls -k $(outdir)/Gene_All.KEGG.xls
	echo KOBAS_format  end at `date`


.PHONY:KEGG_Stat
KEGG_Stat:
	echo KEGG Stat start at `date`
	mkdir -p $(outdir)
	$(CSVTK) -t join $(annotation_all) $(input) | cut -f 1,2 > $(annotation_sample)
	$(CSVTK) -t join $(pathway_all) $(input) | cut -f 1,2,3,4 > $(pathway_sample)
	#$(PYTHON3) $(BIN)/script/extract_single_annotation.py -i $(input) -a $(annotation_all) -o $(annotation_sample)
	#$(PYTHON3) $(BIN)/script/extract_single_annotation.py -i $(input) -a $(pathway_all) -o $(pathway_sample)
	$(PYTHON3) $(BIN)/script/kegg_addclass.py -i $(pathway_sample) -e $(annotation_sample) -d $(outdir)/$(sample).KEGG_classificate.xls -l $(BIN)/script/ko.list
	cut -f 1,3,4,5 $(outdir)/$(sample).KEGG_classificate.xls >$(outdir)/$(sample).KEGG_classificate.xls.tmp
	$(Rscript) $(BIN)/script/KEGG_classificate_plot.r --infile $(outdir)/$(sample).KEGG_classificate.xls.tmp --outfile $(outdir)/$(sample).KEGG_classificate.pdf --title "KEGG Classification" --xlabel "Percent of Genes(%)"
	$(CONVERT) $(outdir)/$(sample).KEGG_classificate.pdf $(outdir)/$(sample).KEGG_classificate.png
	less $(annotation_all) |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo KEGG Stat end at `date`

EggNOG:
	echo EGG annotation start at `date`
	mkdir -p $(outdir)
	#$(DIAMOND) blastp -q $(infa) --db $(EGGNOG) $(Diamond_blastp) -o $(outdir)/Gene_All.eggNOG.aln
	$(BLASTP) -query $(infa) -db $(EGGNOG) $(BLAST_PAREMATERS) -out $(outdir)/Gene_All.eggNOG.aln
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.eggNOG.aln 1 $(outdir)/Gene_All.eggNOG.xls
	echo EGG annotation end at `date`

EggNOG_blastp:
	echo EGG blastp start at `date`
	$(BLASTP) -query $(infa) -db $(EGGNOG) $(BLAST_PAREMATERS) -out $(outdir)/$(cuts).aln
	echo EGG blastp end at `date`
EggNOG_anno:
	echo EGG anno start at `date`
	cat $(indir)/*.aln > $(outdir)/Gene_All.eggNOG.aln
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.eggNOG.aln 1 $(outdir)/Gene_All.eggNOG.xls
	echo EGG anno end at `date`

EggNOG_Stat:
	echo EggNOG Stat start at `date`
	mkdir -p $(outdir)
	$(CSVTK) -t join $(annotation_all) $(input) | cut -f 1,2,3 > $(annotation_sample)
	less $(annotation_all) |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo EggNOG Stat end at `date`

PHI:
	echo PHI annotation start at `date`
	mkdir -p $(outdir)
	#$(DIAMOND) blastp -q $(infa) --db $(PHIDB) $(Diamond_blastp) -o $(outdir)/Gene_All.phi.aln
	$(BLASTP) -query $(infa) -db $(PHIDB) $(BLAST_PAREMATERS) -out $(outdir)/Gene_All.phi.aln 
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.phi.aln 1 $(outdir)/Gene_All.phi.xls
	$(PERL) -i.bak2 -F'\t' -alne 'if(!/Gene_ID/){$$F[2]=(split(/\|/,$$F[1]))[-1];$$F[1]=(split(/\|/,$$F[1]))[0]};print "$$F[0]\t$$F[1]\t$$F[2]"' $(outdir)/Gene_All.phi.xls
	sed -i 's/Gene_ID\tSubject_ID\tAnnotation/Gene_ID\tSubject_ID\tAffection/' $(outdir)/Gene_All.phi.xls
	echo PHI annotation end at `date`

COG_Stat:
	echo "######## single sample COG annotation START at `date` #########"
	$(PYTHON3) ${script}/get_anno_count.py -a ${anno_file} -c ${count_file} -o ${outdir}/${prefix}.xls -col ${col}
	${CSVTK} -t join -f 1 -k ${outdir}/${prefix}.xls ${cog_anno} > ${outdir}/${prefix}.cog.xls
	echo "######## single sample COG annotation END at `date` #########"


PHI_Stat:
	echo single sample PHI annotation start at `date`
	mkdir -p $(outdir)
	$(PERL) -i.bak2 -F'\t' -alne 'if(!/Gene_ID/){$$F[2]=(split(/\|/,$$F[1]))[-1];$$F[1]=(split(/\|/,$$F[1]))[0]};print "$$F[0]\t$$F[1]\t$$F[2]"' $(anno_file)
	sed -i '1a #Gene\tSubject_ID\tAffection'  $(anno_file)
	$(PYTHON3) ${script}/get_anno_count.py -a $(anno_file)  -c $(count_file) -o $(outdir)/${prefix}.xls

	$(CSVTK) -t join $(annotation_all) $(input) |cut -f 1,2,3 > $(annotation_sample)
	#$(PYTHON3) $(BIN)/script/extract_single_annotation.py -i $(input) -a $(annotation_all) -o $(annotation_sample)
	$(PYTHON3) $(BIN)/script/PHI/phi_stat.py -i $(annotation_sample) -o $(annotation_sample).count
	$(Rscript) $(BIN)/script/class_number.r $(annotation_sample).count $(outdir)/$(sample).phiclass.pdf "PHI Function Classification"
	$(CONVERT) $(outdir)/$(sample).phiclass.pdf $(outdir)/$(sample).phiclass.png
	less $(annotation_all) |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo single sample PHI annotation end at `date`



COG:
	echo COG annotation start at `date`
	mkdir -p $(outdir)
	$(BLASTP) -query $(infa) -db $(COGDB) $(BLAST_PAREMATERS) -out $(outdir)/Gene_All.cog.aln  
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.cog.aln 1 $(outdir)/Gene_All.cog
	$(PERL) $(BIN)/script/COG/cog_parser_m8.pl $(outdir)/Gene_All.cog
	$(PERL) $(BIN)/script/COG/cog_catalog.pl $(outdir)/Gene_All.cog.xls $(outdir)/Gene_All.cog.catalog $(outdir)/Gene_All.class.catalog $(outdir)/Gene_All.all.catalog
	echo COG annotation end at `date`

COG_Diamond:
	echo COG annotation start at `date`
	mkdir -p $(outdir)
	$(DIAMOND) blastp -q $(infa) --db $(COGDB) $(Diamond_blastp) -o $(outdir)/Gene_All.cog.aln  
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.cog.aln 1 $(outdir)/Gene_All.cog
	$(CSVTK) -t -f "Subject_ID;Subject_ID" join $(outdir)/Gene_All.cog $(COGAnno) > $(outdir)/Gene_All.cog.xls
	echo COG annotation end at `date`

COG_Stat:
	echo single sample COG annotation start at `date`
	mkdir -p $(outdir)
	$(CSVTK) -t join $(annotation_all) $(input) |cut -f 1,2,4-7 > $(annotation_sample)
	$(PERL) $(BIN)/script/COG/cog_catalog.pl $(annotation_sample) $(outdir)/$(sample).cog.catalog $(outdir)/$(sample).class.catalog $(outdir)/$(sample).all.catalog
	$(PERL) $(BIN)/script/COG/draw_cog_r.pl $(outdir)/$(sample).class.catalog $(outdir)/$(sample).cogclass
	$(Rscript) $(outdir)/$(sample).cogclass.R $(outdir)/$(sample).cogclass.out
	$(CONVERT) -density 98 $(outdir)/$(sample).cogclass.pdf $(outdir)/$(sample).cogclass.png
	less $(annotation_all) |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo single sample COG annotation end at `date`

ARDB:
	echo ARDB annotation start at `date`
	mkdir -p $(outdir)
	#$(DIAMOND) blastp -q $(infa) --db $(ARDB) $(Diamond_blastp) -o $(outdir)/Gene_All.ardb.aln
	$(BLASTP) -query $(infa) -db $(ARDB) $(BLAST_PAREMATERS) -out $(outdir)/Gene_All.ardb.aln
	$(PERL) $(BIN)/script/get_bestblast.pl $(outdir)/Gene_All.ardb.aln 1 $(outdir)/Gene_All.ardb.xls.tmp
	#$(PERL) -i.bak2 -F'\t'  -alne '$$F[2]=~s/$$F[1] //;print "$$F[0]\t$$F[1]\t$$F[2]"' $(outdir)/Gene_All.ardb.xls.tmp
	#$(PERL) $(BIN)/script/ARDB/add_id2antibiotic.pl $(outdir)/Gene_All.ardb.xls.tmp $(outdir)/Gene_All.ardb.xls
	$(PYTHON3) $(BIN)/script/ARDB/ardb_file_deal.py -d $(BIN)/script/ARDB/id2antibiotic.xls -a $(outdir)/Gene_All.ardb.xls.tmp -o $(outdir)/Gene_All.ardb.xls
	echo ARDB annotation end at `date`

ardb_Stat:
	echo single sample annotation start at `date`
	mkdir -p $(outdir)
	$(CSVTK) -t join $(annotation_all) $(input) |cut -f 1,2,3,4 > $(annotation_sample)
	less $(annotation_all) |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo single sample annotation end at `date`




Cazy_Stat:
	echo single sample CAZY annotation start at `date`
	mkdir -p $(outdir)
	$(CSVTK) -t join $(annotation_all) $(input) |cut -f 1,2,3 > $(annotation_sample)
	#$(PYTHON3) $(BIN)/script/extract_single_annotation.py -i $(input) -a $(annotation_all) -o $(annotation_sample)
	$(PYTHON3) $(BIN)/script/CAZy/cazy_cla.py -i $(annotation_sample) -o $(outdir)/$(sample).cazy.num.xls
	$(Rscript) $(BIN)/script/class_number.r $(outdir)/$(sample).cazy.num.xls $(outdir)/$(sample).cazyclass.pdf "CAZy Function Classification"
	$(CONVERT) $(outdir)/$(sample).cazyclass.pdf $(outdir)/$(sample).cazyclass.png
	less $(annotation_all) |head -2 | $(TRANSPOSE) > $(annotation_all).example
	echo single sample CAZY annotation end at `date`

Anno_Stat:
	echo Anno_Stat start at `date`
	mkdir -p $(outdir)
	$(PYTHON3) $(BIN)/script/stat_database.py -i $(input) -o $(outdir)/Anno_database_stat.xls -d cog,swissprot,phi,ardb,cazy,eggNOG,go,kegg,pathway -f $(fasta)
	echo Anno_Stat end at `date`

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
	$(PYTHON3) ${script}/get_anno_count.py -a $(anno_file)  -c $(count_file) -o $(phi_count_anno_out)
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