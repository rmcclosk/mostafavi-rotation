DBDIR=db
TABLES=chromosome patient gene module expression snp cpg genotype methylation acetylation

all: db

schema.png: schema.dot
	dot -Tpng $^ > $@

schema.dot: draw_schema.py $(patsubst %,$(DBDIR)/%.sql,$(TABLES))
	cat $(wordlist 2,$(words $^),$^) | ./$(firstword $^) > $@

db: $(patsubst %,$(DBDIR)/%.timestamp,$(TABLES))

$(DBDIR)/chromosome.timestamp: chromInfo.txt.gz
$(DBDIR)/patient.timestamp: pheno_cov_n2963_092014_forPLINK.csv techvars_plus_phenotypes26SEP2014.txt
$(DBDIR)/gene.timestamp: ensemblGenes.txt.gz
$(DBDIR)/snp.timestamp: SNPChrPosOnRef.bcp.gz
$(DBDIR)/cpg.timestamp: cpg.txt.gz
$(DBDIR)/methylation.timestamp: ill450kMeth_all_740_imputed.txt phenotype_740qc_finalFromLori.txt
$(DBDIR)/expression.timestamp: residual_gene_expression_expressed_genes_2FPKM100ind.txt IDmapping.txt
$(DBDIR)/acetylation.timestamp: chipSeqResiduals.csv.gz peakInfo.csv.gz 
$(DBDIR)/genotype.timestamp: affy omni

%.timestamp: %.py %.sql %.tsv
	./$(word 1,$^) > $(patsubst %.timestamp,%.tsv,$@) &
	psql < $(word 2,$^)
	date > $@

%.tsv: 
	mkfifo $@

ill450kMeth_all_740_imputed.txt phenotype_740qc_finalFromLori.txt: 
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$@ .

residual_gene_expression_expressed_genes_2FPKM100ind.txt IDmapping.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/expression_data/$@ .

chipSeqResiduals.csv.gz peakInfo.csv.gz:
	ln -s /broad/dejagerlab/hklein/exportSara/$@ .

pheno_cov_n2963_092014_forPLINK.csv techvars_plus_phenotypes26SEP2014.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/phenotype_data/$@ .

ensemblGenes.txt.gz:
	./genes.pl > $(patsubst %.gz,%,$@)
	gzip $(patsubst %.gz,%,$@)

SNPChrPosOnRef.bcp.gz:
	wget -O $@ -nd -r -A '*_$(patsubst %.bcp.gz,%,$@)_*.bcp.gz' ftp://ftp.ncbi.nih.gov/snp/database/organism_data/human_9606/

cpg.txt.gz: hg19ToHg38.over.chain.gz wgEncodeHaibMethyl450CpgIslandDetails.txt.gz
	zcat $(word 2, $^) | tail -n +9 | grep '^[c]' | awk -F ',' '{print "chr"$$12"\t"$$13"\t"$$13+1"\t"$$1}' > tmp.bed
	liftOver tmp.bed $(word 1, $^) $(patsubst %.gz,%,$@) /dev/null
	rm tmp.bed
	gzip $(patsubst %.gz,%,$@)

hg19ToHg38.over.chain.gz:
	wget http://hgdownload.cse.ucsc.edu/gbdb/hg19/liftOver/$@

wgEncodeHaibMethyl450CpgIslandDetails.txt.gz:
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeHaibMethyl450/supplemental/$(patsubst %.gz,%,$@)
	gzip $(patsubst %.gz,%,$@)
