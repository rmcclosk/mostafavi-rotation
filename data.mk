# This is the Makefile that creates everything in the data/ directory

SHELL=/bin/bash

data: $(addprefix data/,cpg.txt \
	snp.txt \
	ensemblGenes.tsv \
	pheno_cov_n2963_092014_forPLINK.csv \
	techvars_plus_phenotypes26SEP2014.txt \
	ill450kMeth_all_740_imputed.txt \
	residual_gene_expression_expressed_genes_2FPKM100ind.txt \
	chipSeqResiduals.csv \
	peak.txt \
	transposed_1kG \
	allrevcoded.csv \
	module_means_filtered_byphenotype.txt \
	ROSMAP_brain_rnaseq_best_eQTL.txt \
	sign_modules_celltypes_PC_Rosemary.txt \
	phenotype_740qc_finalFromLori.txt \
	genotype_manifest.tsv \
	patients.tsv)

data/allrevcoded.csv:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/results/clustering/se_final_clusters/$(notdir $@) $@

data/ill450kMeth_all_740_imputed.txt:
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$(notdir $@) $@

data/residual_gene_expression_expressed_genes_2FPKM100ind.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/expression_data/$(notdir $@) $@

data/chipSeqResiduals.csv:
	cp /broad/dejagerlab/hklein/exportChIPSeq/$(notdir $@).gz $@.gz
	gunzip $@.gz

data/peak.txt: data/hg19ToHg38.over.chain.gz /broad/dejagerlab/hklein/exportChIPSeq/peakInfo.csv.gz
	liftOver <(zcat $(word 2, $^) | tail -n +2 | tr -d '"' | awk '{print "chr"$$4"\t"$$2"\t"$$3"\t"$$1}') $(word 1, $^) $@ /dev/null
	sed -i '/[XYK]/d' $@

data/pheno_cov_n2963_092014_forPLINK.csv data/techvars_plus_phenotypes26SEP2014.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/phenotype_data/$(notdir $@) $@

data/ensemblGenes.tsv:
	scripts/ensemblGenes.pl > $@

data/cpg.txt: data/hg19ToHg38.over.chain.gz
	liftOver <(wget -O - ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeHaibMethyl450/supplemental/wgEncodeHaibMethyl450CpgIslandDetails.txt | tail -n +9 | grep '^[c]' | awk -F ',' '{print "chr"$$12"\t"$$13"\t"$$13+1"\t"$$1}') $(word 1, $^) $@ /dev/null
	sed -i -e '/[XYK]/d' -e '/random/d' $@

data/transposed_1kG:
	ln -s /broad/dejagerlab/cogdec/GWAS/ROSMAP/scripts/reformat_dosage_1kg_all_chrs/$(notdir $@) $@

data/snp.txt: data/hg19ToHg38.over.chain.gz
	liftOver <(wget -O - ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/snpArrayAffy6.txt.gz | zcat | cut -f 2-4,9 | sort -n -k 4,5 | uniq) $(word 1, $^) $@ /dev/null
	sed -i -e '/[A-Z]/d' -e '/unknown/d' data/snp.txt

data/module_means_filtered_byphenotype.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/results/clustering/se_final_clusters/$(notdir $@) $@
	
data/ROSMAP_brain_rnaseq_best_eQTL.txt data/sign_modules_celltypes_PC_Rosemary.txt:
	@echo "This file was emailed to me: $@"

data/phenotype_740qc_finalFromLori.txt:
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$(notdir $@) $@

data/hg19ToHg38.over.chain.gz:
	wget http://hgdownload.cse.ucsc.edu/gbdb/hg19/liftOver/$(notdir $@) -O $@

data/genotype_manifest.tsv: scripts/genotype_manifest.R
	$^ > $@

data/patients.tsv: scripts/patients.R
	$^ > $@

.INTERMEDIATE: data/hg19ToHg38.over.chain.gz
