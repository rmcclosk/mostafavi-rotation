#!/usr/bin/env Rscript

# Bayesian network on phenotypes with the deal package.

library(deal)
library(RPostgreSQL)

nice.dim <- function (n) {
    w <- round(sqrt(n))
    while (n %% w != 0) w <- w+1
    w
}

set.seed(0)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")
vars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope", "pathoAD", "pmAD")
query <- paste("SELECT id, ", paste(vars, collapse=", "), "FROM patient WHERE",
               paste(vars, collapse=" IS NOT NULL AND "), "IS NOT NULL")
p.data <- dbGetQuery(con, query)
dbDisconnect(con)

p.data$pathoad <- factor(p.data$pathoad, levels=c(TRUE, FALSE))
p.data$pmad <- factor(p.data$pmad, levels=c(TRUE, FALSE))

e.data <- read.table("../data/module_means_filtered_byphenotype.txt", header=T)
e.data$id <- as.integer(sapply(strsplit(rownames(e.data), ":"), "[[", 1))

data <- merge(e.data, p.data)
data$id <- NULL

out.data <- data
out.data$pathoad <- as.integer(out.data$pathoad)-1
out.data$pmad <- as.integer(out.data$pmad)-1
write.table(out.data, "modules-genes.tsv", row.names=F, sep="\t", quote=F)

net <- network(data)
prior <- jointprior(net)
net <- learn(net, data, prior)$nw
search <- autosearch(net, data, prior,trace=TRUE)
best.net <- heuristic(search$nw, data, prior, restart=2, degree=10,
                      trace=TRUE, trylist=search$trylist)$nw

savenet(best.net, file("deal-genes.net"))
quit()
png("deal-genes.png", width=480, height=480)
par(mar=c(0, 0, 0, 0))
plot(best.net)
dev.off()
