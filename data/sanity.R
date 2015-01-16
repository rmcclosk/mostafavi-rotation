#!/usr/bin/env Rscript

options(stringsAsFactors = FALSE)
f <- list("phenotype_740qc_finalFromLori.txt",
          "techvars_plus_phenotypes26SEP2014.txt",
          "pheno_cov_n2963_092014_forPLINK.csv")
d <- list(read.delim(f[[1]], na.strings=c("", "NA", "NaN", "-9")),
          read.delim(f[[2]], na.strings=c("", "NA", "NaN", "-9")),
          read.csv(f[[3]], na.strings=c("", "NA", "NaN", "-9")))

. <- apply(combn(1:3, 2), 2, function (pair) {

    d1 <- d[[pair[1]]]
    d2 <- d[[pair[2]]]
    f1 <- f[[pair[1]]]
    f2 <- f[[pair[2]]]
    
    d12 <- merge(d1, d2, by=c("projid"))
    cols <- intersect(colnames(d1), colnames(d2))
    cols <- cols[cols != "projid"]
    
    print(paste0(strsplit(f1, "_")[[1]][1], "_", strsplit(f2, "_")[[1]][1], ".pdf"))
    pdf(paste0(strsplit(f1, "_")[[1]][1], "_", strsplit(f2, "_")[[1]][1], ".pdf"))
    . <- sapply(cols, function (c) {
        cx <- paste0(c, ".x")
        cy <- paste0(c, ".y")
        sst <- d12[which(d12[,cy] != d12[,cx]), c("projid", cy, cx)]
        cat(c, nrow(sst), "\n")
        if (nrow(sst) > 0 & (nrow(sst) < 10 | class(d12[,cx]) != "numeric")) {
            print(sst)
        } else if (nrow(sst) > 10) {
            plot(d12[,cx], d12[,cy], main=c, xlab=f1, ylab=f2)
            abline(a=0, b=1)
        }
    })
    dev.off()
})
