#!/usr/bin/env Rscript

# make a manifest of which SNPs are in which files

library(data.table)

snp.files <- Sys.glob(paste0("transposed_1kG/chr", 1:22, "/chr", 1:22, "*trans.txt"))

pb <- txtProgressBar(0, length(snp.files), style=3)

manifest <- rbindlist(lapply(snp.files, function (f) {
    snps <- strsplit(readLines(f, n=1), " ")[[1]]
    idx <- grep("rs", snps)
    if (length(idx) == 0) return (NULL)
    snps <- as.integer(sub("rs", "", snps[idx]))
    res <- data.table(file=f, snp=snps, column=idx)
    setTxtProgressBar(pb, getTxtProgressBar(pb)+1)
    res
}))

write.table(manifest, "genotype_manifest.tsv", col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
close(pb)
