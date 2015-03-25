#!/usr/bin/env Rscript

# Find overlapping QTLs using pi_1.

library(data.table)
library(qvalue)
library(knitr)
library(VennDiagram)
library(pheatmap)
library(rolasized)
library(tikzDevice)

sol <- solarized.Colours(variant = "srgb")

data.types <- c("e", "ace", "me")
best.file <- "../primary/%sQTL/best.tsv"
data.file <- "../primary/%sQTL/chr%d.tsv"

if (file.exists("qtl_overlap.Rdata")) {
    load("qtl_overlap.Rdata")
} else {
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
        unlist(sapply(1:22, function (chr) {
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
    names(overlap) <- rep(qtl.names, each=length(qtl.names))
    
    save(overlap, file="qtl_overlap.Rdata")
}

overlap.size <- matrix(sapply(overlap, length), nrow=length(data.types))
dimnames(overlap.size) <- list(qtl.names, qtl.names)
cat(kable(overlap.size, "markdown"), file="qtl_overlap.md", sep="\n")

overlap.prop <- round(overlap.size*100/diag(overlap.size))

png("qtl_overlap.png")
pheatmap(overlap.prop, cluster_rows=FALSE, cluster_cols=FALSE, 
         legend=FALSE, fontsize=18, fontsize_number=18, 
         display_numbers=TRUE,
         color=colorRampPalette(c(sol$base2, sol$orange))(100),
         number_format="%.0f %%")
dev.off()

tikz("qtl_overlap.tex", width=2.5, height=2.5, fg=sol$base00, bg=sol$base3)
pheatmap(round(overlap.prop), cluster_rows=FALSE, cluster_cols=FALSE, 
         legend=FALSE, display_numbers=TRUE,
         color=colorRampPalette(c(sol$base2, sol$orange))(100),
         number_format="%.0f \\%%")
dev.off()

venn.colors <- c(sol$red, sol$blue, sol$green, sol$violet, sol$orange, sol$yellow, sol$cyan, sol$magenta)
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
    venn.args[["fill"]] <- head(venn.colors, length(sets))
    venn.args[["cex"]] = 1.5
    venn.args[["cat.cex"]] = 1.5
    venn.args[["ind"]] = FALSE
    venn.args[["margin"]] = 0.05
    venn.args[["lwd"]] = 0

    venn.names <- c("single", "pairwise", "triple", "quad", "quintuple")
    venn.funs <- paste0("draw.", venn.names, ".venn")
    do.call(match.fun(venn.funs[length(sets)]), venn.args)
}

png("eqtl_venn.png", width=240, height=240)
sets <- list(overlap[[1]], overlap[[4]], overlap[[7]])
names(sets) <- names(overlap)[c(1,4,7)]
grid.draw(do.venn(sets))
dev.off()

png("aceqtl_venn.png", width=240, height=240)
sets <- list(overlap[[2]], overlap[[5]], overlap[[8]])
names(sets) <- names(overlap)[c(2,5,8)]
grid.draw(do.venn(sets))
dev.off()

png("meqtl_venn.png", width=240, height=240)
sets <- list(overlap[[3]], overlap[[6]], overlap[[9]])
names(sets) <- names(overlap)[c(3,6,9)]
grid.draw(do.venn(sets))
dev.off()
