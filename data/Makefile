CHRS=1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22

all: chromInfo.txt.gz \
	cpg.txt.gz \
	snp.txt \
	ensemblGenes.tsv \
	hg19ToHg38.over.chain.gz \
	wgEncodeHaibMethyl450CpgIslandDetails.txt.gz \
	snpArrayAffy6.txt.gz \
	pheno_cov_n2963_092014_forPLINK.csv \
	techvars_plus_phenotypes26SEP2014.txt \
	ill450kMeth_all_740_imputed.txt \
	residual_gene_expression_expressed_genes_2FPKM100ind.txt \
	chipSeqResiduals.csv.gz \
	peakInfo.csv.gz \
	peak.txt.gz \
	transposed_1kG \
	allrevcoded.csv \
	module_means_filtered_byphenotype.txt \
	ROSMAP_brain_rnaseq_best_eQTL.txt \
	sign_modules_celltypes_PC_Rosemary.txt

allrevcoded.csv:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/results/clustering/se_final_clusters/$@ .

ill450kMeth_all_740_imputed.txt:
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$@ .

residual_gene_expression_expressed_genes_2FPKM100ind.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/expression_data/$@ .

chipSeqResiduals.csv.gz peakInfo.csv.gz:
	ln -s /broad/dejagerlab/hklein/exportSara/$@ .

peak.txt.gz: hg19ToHg38.over.chain.gz peakInfo.csv.gz
	zcat $(word 2, $^) | tail -n +2 | tr -d '"' | awk '{print "chr"$$4"\t"$$2"\t"$$3"\t"$$1}' > tmp.bed
	liftOver tmp.bed $(word 1, $^) $(patsubst %.gz,%,$@) /dev/null
	rm tmp.bed
	gzip $(patsubst %.gz,%,$@)

pheno_cov_n2963_092014_forPLINK.csv techvars_plus_phenotypes26SEP2014.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/phenotype_data/$@ .

ensemblGenes.tsv:
	./ensemblGenes.pl > $@

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

snpArrayAffy6.txt.gz:
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/$@

snp.txt: hg19ToHg38.over.chain.gz snpArrayAffy6.txt.gz
	zcat $(word 2, $^) | cut -f 2-4,9 | grep -v [A-Z] > tmp.bed
	liftOver tmp.bed $(word 1, $^) $@ /dev/null
	rm tmp.bed

chromInfo.txt.gz:
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/$@

module_means_filtered_byphenotype.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/results/clustering/se_final_clusters/$@ .
	
ROSMAP_brain_rnaseq_best_eQTL.txt sign_modules_celltypes_PC_Rosemary.txt:
	echo "This file was emailed to me"
