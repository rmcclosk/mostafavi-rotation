#!/usr/bin/env Rscript

# Plot summary statistics about the data.

library(ggplot2)
library(reshape2)

source(file=file.path("utils", "load_data.R"))

patients <- load.patients()
data <- list(load.edata(patients), load.adata(patients), load.mdata(patients))
names(data) <- c("expression", "acetylation", "methylation")

data <- lapply(data, apply, 1, summary)
data <- lapply(data, t)
data <- lapply(data, as.data.frame)
data <- mapply(cbind, data, patient=lapply(data, rownames), SIMPLIFY=FALSE)
data <- lapply(data, melt, id.vars="patient", variable.name="statistic")
data <- mapply(cbind, data, data.type=names(data), SIMPLIFY=FALSE)
data <- do.call(rbind, data)

p <- ggplot(data, aes(x=patient, y=value, color=statistic, group=statistic)) +
    geom_line() +
    facet_grid(data.type~., scales="free") +
    theme_bw() +
    theme(axis.ticks = element_blank(), 
          axis.text.x = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank())

pdf(file.path("plots", "summary.pdf"))
print(p)
dev.off()

png(file.path("plots", "summary.png"))
print(p)
dev.off()
