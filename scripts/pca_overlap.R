#!/usr/bin/env Rscript

# Assess the overlap between QTLs identified after PC removal.

library(data.table)
library(ggplot2)
library(reshape2)

keeps <- c("feature", "q.value")
files <- sprintf(file.path("results", "%sQTL", "PC%%d.best.tsv"), c("e", "ace", "me"))
files <- lapply(files, sprintf, 0:20)

data <- lapply(files, lapply, fread, select=keeps)
data <- lapply(data, lapply, setkey, feature, q.value)
data <- lapply(data, lapply, setkey, feature)
data <- lapply(data, lapply, unique)
data <- lapply(data, lapply, "[", i=q.value < 0.05, j=feature)
names(data) <- c("genes", "peaks", "CpGs")

found <- lapply(data, function (x) sapply(mapply(setdiff, tail(x, -1), head(x, -1), SIMPLIFY=FALSE), length))
dropped <- lapply(data, function (x) sapply(mapply(setdiff, head(x, -1), tail(x, -1), SIMPLIFY=FALSE), length))
data <- list(found, dropped)
data <- lapply(data, as.data.frame)
data <- mapply(cbind, data, difference=c("found", "dropped"), SIMPLIFY=FALSE)
data <- lapply(data, cbind, pc.rm=1:20)
data <- as.data.frame(do.call(rbind, data))
data <- melt(data, id.vars=c("pc.rm", "difference"), variable.name="data.type", value.name="qtls")

pdf(file.path("plots", "pca_overlap.pdf"))
ggplot(data, aes(x=pc.rm, y=qtls, color=difference)) +
     geom_point() +
     geom_line() +
     theme_bw() +
     facet_grid(data.type~., scales="free") +
     xlab("PCs removed") +
     ylab("significant features")
dev.off()
