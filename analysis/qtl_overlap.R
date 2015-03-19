#!/usr/bin/env Rscript

# Find overlapping QTLs using a pi_0 approach.

library(data.table)
library(qvalue)
library(knitr)
library(VennDiagram)
library(RColorBrewer)

data.types <- c("e", "ace", "me")
best.file <- "../primary/%sQTL/best.tsv"
data.file <- "../primary/%sQTL/chr%d.tsv"

# read all QTL associations, and filter only significant ones
keep.cols <- c("snp", "snp.chr", "feature", "q.value.PC10")
best <- sapply(data.types, function (x) {
    data <- fread(sprintf(best.file, x), select=keep.cols)
    setnames(data, "q.value.PC10", "q.value")

    setkey(data, feature, "q.value")
    data <- data[q.value < 0.05,]
    data[, .SD[1], by=feature]
}, simplify=FALSE, USE.NAMES=TRUE)

# all pairs of data types
overlap <- apply(expand.grid(data.types, data.types), 1, function (x) {

    if (x[1] == x[2])
        return (best[[x[1]]][,snp])

    # go through chromosomes one at a time
    unlist(sapply(3:22, function (chr) {
        # get significant QTLs for chromosome, for first data type
        qtls <- best[[x[1]]][snp.chr == chr,]
        setkey(qtls, snp)
        
        # read all associations, for second data type
        keep.cols <- c("snp", "p.value.PC10")
        data <- fread(sprintf(data.file, x[2], chr), select=keep.cols)
        setnames(data, "p.value.PC10", "p.value")
        setkey(data, snp)
        data <- merge(data, qtls)
        gc()

        if (nrow(data) == 0)
            return (c())
        
        # correct P-values for number of features tested per SNP
        data <- data[, min(p.adjust(p.value, method="holm")), snp]
        data[, q.value := qvalue(V1)$qvalue]
        
        # return the significant QTLs in the second data type
        data[q.value < 0.05, snp]
    }))
})

qtl.names <- paste0(data.types, "QTLs")
names(overlap) <- rep(qtl.names, length(qtl.names))

overlap.size <- matrix(sapply(overlap, length), nrow=length(data.types))
dimnames(overlap.size) <- list(qtl.names, qtl.names)
cat(kable(overlap.size, "markdown"), file="qtl_overlap.md", sep="\n")

do.venn <- function (sets) {
    # http://stackoverflow.com/questions/24748170/finding-all-possible-combinations-of-vector-intersections
    combos <- Reduce(c, lapply(1:length(sets), function(x) combn(1:length(sets), x, simplify=FALSE) ))
    venn.args <- lapply(lapply(combos, function(x) {
        if (length(x) > 1) 
            Reduce(intersect, sets[x]) 
        else
            sets[[x]] 
    }), length)
    if (length(sets) == 3) {
        tmp <- venn.args[[5]]
        venn.args[[5]] <- venn.args[[6]]
        venn.args[[6]] <- tmp
    }
    print(venn.args)
    venn.args[["category"]] <- names(sets)
    venn.args[["fill"]] <- brewer.pal(length(sets), "Set2")
    venn.args[["cex"]] = 1.5
    venn.args[["cat.cex"]] = 1.5
    venn.args[["ind"]] = FALSE
    venn.args[["margin"]] = 0.05

    venn.names <- c("single", "pairwise", "triple", "quad", "quintuple")
    venn.funs <- paste0("draw.", venn.names, ".venn")
    do.call(match.fun(venn.funs[length(sets)]), venn.args)
}

png("eqtl_venn.png")
grid.draw(do.venn(list(overlap[[1]], overlap[[4]], overlap[[7]])))
dev.off()

png("aceqtl_venn.png")
grid.draw(do.venn(list(overlap[[2]], overlap[[5]], overlap[[8]])))
dev.off()

png("meqtl_venn.png")
grid.draw(do.venn(list(overlap[[3]], overlap[[6]], overlap[[9]])))
dev.off()
