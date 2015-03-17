#!/usr/bin/env Rscript

# Assess the overlap between QTLs identified after PC removal.

library(data.table)
library(ggplot2)

data.types <- c("e", "ace", "me")
data.labels <- c("expression", "acetylation", "methylation")
keep.cols <- c("feature", "q.value", paste0("q.value.PC", 1:20))

files <- sprintf("../primary/%sQTL/best.tsv", data.types)
data <- lapply(files, function (x) setnames(fread(x), "q.value", "q.value.PC0"))

pc.data <- rbindlist(lapply(1:length(data.types), function (i) {
    rbindlist(lapply(1:20, function (x) {
        prev.col <- paste0("q.value.PC", x-1)
        cur.col <- paste0("q.value.PC", x)
        d <- data[[i]]
    
        f.prev <- d[which(d[[prev.col]] < 0.05), unique(feature)]
        f.cur <- d[which(d[[cur.col]] < 0.05), unique(feature)]
        data.table(pc.rm=x,
                   difference=c("found", "dropped"),
                   qtls=c(length(setdiff(f.cur, f.prev)),
                          length(setdiff(f.prev, f.cur))),
                   data.type=data.labels[i])
    }))
}))

p <- ggplot(pc.data, aes(x=pc.rm, y=qtls, color=difference)) +
     geom_point() +
     geom_line() +
     theme_bw() +
     facet_grid(data.type~., scales="free") +
     xlab("PCs removed") +
     ylab("significant features")

png("pca_overlap.png")
print(p)
dev.off()

pdf("pca_overlap.pdf")
print(p)
dev.off()
