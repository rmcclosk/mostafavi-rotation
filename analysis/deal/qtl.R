#!/usr/bin/env Rscript

library(data.table)
library(deal)
library(mediation)

set.seed(0)

# find the best deal network for a data set by exhaustive search (put a warning
# if there is more than one equivalently good network)
# this will take a long time if there are more than a handful of nodes
best.net.exhaustive <- function (data, banlist=NULL) {
    sink("/dev/null")
    net <- network(data)
    prior <- jointprior(net)
    banlist(net) <- banlist
    net <- learn(net, data, prior)$nw
    all.nets <- nwfsort(networkfamily(data, net, prior)$nw)
    sink()

    relscores <- sapply(all.nets, "[[", "relscore")
    n.best <- sum(isTRUE(sapply(relscores, all.equal, 1)))
    if (n.best > 1)
        warning(sprintf("%d optimal networks found, returning first", n.best))
    all.nets[[1]]
}


# make an adjacency matrix out of a deal network
adjmat <- function (net) {
    do.call(cbind, lapply(nodes(net), function (n) {
        col <- setNames(rep(0, size(net)), names(nodes(net)))
        col[n[["parents"]]] <- 1
        col
    }))
}

# test whether the variable "med" mediates the effect of "treat" on "out".
# "med" is assumed to also be affected by "treat" (see this SO post:
# http://stats.stackexchange.com/questions/104692). All relationships are
# assumed to be linear, and variables must be continuous. Return a p-value.
mediation.p <- function (treat, med, out, data) {
    frm.med <- paste0(med, "~", treat)
    frm.out <- paste0(out, "~", med, "+", treat)
    med.fit <- lm(as.formula(frm.med), data)
    out.fit <- lm(as.formula(frm.out), data)
    med.out <- mediate(med.fit, out.fit, treat = treat, mediator = med,
                       robustSE = TRUE)
    med.out$d.avg.p
}

# get all the (partial) triangles in a deal network which have two edges
# outgoing from one node, ie. "o <- o -> o". Then do mediation analysis to
# check if there is support for the third edge in either direction. Finally
# compare this to what's actually in the graph.
mediation.support <- function (net, data) {
    mat <- adjmat(net)
    triples <- CJ(colnames(mat), colnames(mat), colnames(mat))
    triples <- triples[V1 != V2 & V1 != V3 & V2 != V3]
    triples <- triples[mat[cbind(V1, V2)] == 1 & mat[cbind(V1, V3)] == 1]
    triples[,topology := modelstring(net)]
    triples[,true.edge := mat[cbind(V2, V3)] == 1]
    new.data <- data[,lapply(.SD, rank)]
    triples[,p.value := mapply(mediation.p, V1, V2, V3, MoreArgs=list(data=new.data))]
}



bl <- matrix(c(2,3,4,1,1,1), ncol=2)

if (!file.exists("deal-mediation.tsv")) {
    d <- fread("qtls-best.tsv")
    d[,g := ordered(g, levels=c(0, 1, 2))]
    d <- d[,mediation.support(best.net.exhaustive(.SD), .SD), .SDcols=c("g", "a", "e", "m"), by="chrom,position"]
    write.table(d, "deal-mediation.tsv", col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
}

d <- fread("deal-mediation.tsv")
d[,vmin := pmin(V2, V3)][,vmax := pmax(V2, V3)]
d[,any.true := any(true.edge),"chrom,position,V1,vmin,vmax"]

# partition into true and false (ie. not present) edges
# discard edges in opposite direction to true edges
setkey(d, p.value)
d <- d[which(true.edge | (!any.true & !duplicated(cbind(chrom, position, vmin, vmax)))),]
d[,p.value := p.adjust(p.value, method="holm")]

setkey(d, chrom, position, V1, vmin, vmax)
true.edges <- d[which(true.edge),]
false.edges <- d[which(!any.true),]

summary(true.edges[,p.value])
summary(false.edges[,p.value])
false.edges[,sum(p.value < 0.05)]

quit()


sd <- d[,, with=FALSE]
net <- best.net.exhaustive(sd)
modelstring(net)
sd <- d[,g := as.numeric(g)]
mediation.support(best.net.exhaustive(sd), sd)
quit()


triples
apply(triples, 1, function (t) {
    if (mat[t[1], t[2]] == mat[t[1], t[3]] & mat[t[1], t[2]] == 1) {
        med.frm <- paste0(t[2], '~', t[1])
        out.frm <- paste0(t[3], '~', t[1], '+', t[2])
        fit1 <- lm(med.frm, d, 
    }
})

quit()

d[,topology := best.nets(.SD),by="chrom,position",.SDcols=c("g", "a", "e", "m")]
setkey(d, chrom, position)
unique(d)

quit()

tbl <- sort(table(nets[,V1]), TRUE)
tbl.best <- data.frame(topology=names(tbl), best=tbl)

d <- fread("qtls-pca.tsv")
d[,g := factor(g)]
nets <- d[,best.nets(.SD),"chrom,position",.SDcols=c("g", "a", "e", "m")]
tbl <- sort(table(nets[,V1]), TRUE)
tbl.pca <- data.frame(topology=names(tbl), pca=tbl)

tbl <- merge(tbl.best, tbl.pca, all=T)
tbl$pca[is.na(tbl$pca)] <- 0
tbl$best[is.na(tbl$best)] <- 0

tbl <- melt(tbl, id.vars=t("topology"), variable.name="data", value.name="count")
tbl$data <- factor(tbl$data, levels=c("best", "pca"))
tbl <- tbl[order(tbl$count),]
tbl$topology <- factor(tbl$topology, levels=unique(tbl$topology))

png("deal-qtl.png")
ggplot(tbl, aes(x=topology, y=count)) +
    geom_bar(stat="identity") +
    theme_bw() +
    theme(axis.text.x=element_text(angle = -90, hjust = 0)) +
    facet_wrap(~data) +
    coord_flip()
dev.off()
