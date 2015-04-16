#!/usr/bin/env Rscript

# Bayesian network on gene modules with the deal package.

library(data.table)
library(deal)

source(file=file.path("utils", "deal.R"))
set.seed(0)

cvars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
dvars <- c("pathoAD", "pmAD")
p.data <- read.table(file.path("data", "patients.tsv"), header=TRUE)
p.data <- p.data[,c("projid", cvars, dvars)]

p.data[which(p.data[,cvars] == 0, arr.ind=TRUE)] <- NA
p.data[,dvars] <- lapply(p.data[,dvars], ordered, levels=c(0, 1))
p.data <- na.omit(p.data)

e.data <- fread(file.path("data", "module_means_filtered_byphenotype.txt"))
e.data[,V1 := as.integer(sub(":.*", "", V1))]
setnames(e.data, "V1", "projid")
setDF(e.data)

data <- merge(e.data, p.data)
data$projid <- NULL

best.net <- best.net.heuristic(data)

savenet(best.net, file(file.path("results", "deal_modules.net")))

png(file.path("plots", "deal_modules.png"))
par(mar=c(0, 0, 0, 0))
plot(best.net)
dev.off()
