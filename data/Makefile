DBDIR=db
TABLES=chromosome patient gene module expression snp cpg genotype methylation acetylation eqtl meqtl aceqtl
CHRS=1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22

all: db eqtl

schema.png: schema.dot
	dot -Tpng $^ > $@

eqtl: $(patsubst %,SNPChrPosOnRef/chr%.bcp,$(CHRS))

db: $(patsubst %,$(DBDIR)/%.timestamp,$(TABLES))

$(DBDIR)/chromosome.timestamp: chromInfo.txt.gz
$(DBDIR)/patient.timestamp: pheno_cov_n2963_092014_forPLINK.csv techvars_plus_phenotypes26SEP2014.txt
$(DBDIR)/gene.timestamp: ensemblGenes.tsv
$(DBDIR)/snp.timestamp: SNPChrPosOnRef.bcp.gz
$(DBDIR)/cpg.timestamp: cpg.txt.gz
$(DBDIR)/methylation.timestamp: ill450kMeth_all_740_imputed.txt
$(DBDIR)/expression.timestamp: residual_gene_expression_expressed_genes_2FPKM100ind.txt IDmapping.txt
$(DBDIR)/acetylation.timestamp: chipSeqResiduals.csv.gz peakInfo.csv.gz 

$(DBDIR)/aceqtl.timestamp: $(DBDIR)/meqtl.timestamp $(DBDIR)/eqtl.timestamp
	./qvalue.R

$(DBDIR)/genotype.timestamp: transposed_1kG input $(DBDIR)/genotype.py $(DBDIR)/genotype.sql $(DBDIR)/genotype_post.sql
	psql < $(word 4, $^)
	$(foreach chr,$(CHRS),python3 -u $(word 3, $^) $(chr) | psql -c "COPY genotype_chr$(chr) FROM STDIN";)
	psql < $(word 5, $^)
	date > $@

%.timestamp: %.sql %.tsv
	psql < $(word 1,$^)
	date > $@

%.tsv: %.py
	mkfifo $@
	./$^ > $@ &

ill450kMeth_all_740_imputed.txt:
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$@ .

residual_gene_expression_expressed_genes_2FPKM100ind.txt IDmapping.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/expression_data/$@ .

chipSeqResiduals.csv.gz peakInfo.csv.gz:
	ln -s /broad/dejagerlab/hklein/exportSara/$@ .

pheno_cov_n2963_092014_forPLINK.csv techvars_plus_phenotypes26SEP2014.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/phenotype_data/$@ .

ensemblGenes.tsv:
	./genes.pl > $@

SNPChrPosOnRef/chr%.bcp: SNPChrPosOnRef.bcp.gz
	zcat $^ | grep ^[0-9]*$$'\t'$(patsubst SNPChrPosOnRef/chr%.bcp,%,$@)$$'\t' > $@

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

transposed_1kG:
	ln -s /broad/dejagerlab/cogdec/GWAS/ROSMAP/scripts/reformat_dosage_1kg_all_chrs/$@ .

input:
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20101123/$@ .
