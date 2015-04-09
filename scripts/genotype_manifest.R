#!/usr/bin/env Rscript

# make a manifest of which SNPs are in which files

library(data.table)

snp.files <- Sys.glob(paste0("data/transposed_1kG/chr", 1:22, "/chr", 1:22, ".*trans.txt"))

pb <- txtProgressBar(0, length(snp.files), style=3, file=stderr())

manifest <- rbindlist(lapply(snp.files, function (f) {
    snps <- strsplit(readLines(f, n=1), " ")[[1]]
    res <- data.table(file=f, snp=snps, column=1:length(snps))
    setTxtProgressBar(pb, getTxtProgressBar(pb)+1)
    res
}))

write.table(manifest, stdout(), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
close(pb)
