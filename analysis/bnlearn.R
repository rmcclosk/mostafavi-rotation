#!/usr/bin/env Rscript

# do Bayes net learning on shared QTLs

library(RPostgreSQL)
library(Rgraphviz)
library(data.table)
library(bnlearn)
library(deal)
library(knitr)

set.seed(0)

# connect to the database
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

# functions for retrieving database results
get.dt <- function (queries)
    Reduce(f=function (d, q) rbind(d, setDT(dbGetQuery(con, q))), x=queries, init=NULL)
get.dt.pid <- function (query)
    setkey(get.dt(query), patient_id)

# create views for best QTLs (lowest P-value) for each feature
view.cmd <- paste("CREATE TEMPORARY VIEW best_%sqtl_chr%d AS",
                  "SELECT DISTINCT ON (%s) * FROM %sqtl_chr%d",
                  "WHERE q_value < 0.05 ORDER BY %s, adj_p_value")
. <- sapply(1:22, function (chr) {
    dbGetQuery(con, sprintf(view.cmd, "e", chr, "gene_id", "e", chr, "gene_id"))
    dbGetQuery(con, sprintf(view.cmd, "ace", chr, "peak_centre", "ace", chr, "peak_centre"))
    dbGetQuery(con, sprintf(view.cmd, "me", chr, "cpg_position", "me", chr, "cpg_position"))
})

# query for selecting all matching QTLs
sel.cmd <- paste("SELECT e.chrom, e.position, e.gene_id, a.peak_centre, m.cpg_position,",
                 "e.q_value AS eq, m.q_value AS mq, a.q_value AS aq",
                 "FROM best_eqtl_chr%d e JOIN best_aceqtl_chr%d a",
                 "ON a.chrom = e.chrom AND e.position = a.snp_position",
                 "JOIN best_meqtl_chr%d m",
                 "ON m.chrom = e.chrom AND e.position = m.snp_position")

# queries for retrieving actual data
equery <- paste("SELECT patient_id, value AS e FROM expression_chr%d",
                "WHERE gene_id = %d ORDER BY patient_id")
aquery <- paste("SELECT patient_id, value AS a FROM acetylation_chr%d",
                "WHERE %d BETWEEN peak_start AND peak_end ORDER BY patient_id")
mquery <- paste("SELECT patient_id, value AS m FROM methylation_chr%d",
                "WHERE position = %d ORDER BY patient_id")
gquery <- paste("SELECT patient_id, value AS g FROM genotype_chr%d",
                "WHERE position = %d ORDER BY patient_id")

# blacklists for networks
blacklist <- data.frame(from=c("e", "m", "a"), to=rep("g", 3))
banlist <- matrix(c(1,2,3,4,4,4), ncol=2)

# utility functions
cart.merge <- function (x, y) merge(x, y, allow.cartesian=TRUE)
get.pc1 <- function (data, col.name) {
    data[,pca := prcomp(.SD[,2:ncol(data),with=FALSE])$x[,1]]
    data <- data[,c(1, ncol(data)), with=FALSE]
    setkey(setnames(data, "pca", col.name), patient_id)
}

# functions for manipulating graphs
arc.table <- function (bn.nets)
    table(as.data.frame(do.call(rbind, lapply(bn.nets, arcs))))

to.gv <- function (adjmat, title) {
    arcs <- sprintf('\t%s -> %s [penwidth=%f]',
                    rep(rownames(adjmat), ncol(adjmat)), 
                    rep(colnames(adjmat), each=nrow(adjmat)), 
                    ((adjmat-1)*4/max(adjmat-1))+1)
    paste("digraph {", 
          '\tgraph [K="1.5"];',
          '\tlabelloc="t";',
          sprintf('\tlabel="%s";', title),
          paste(arcs[adjmat > 0], collapse="\n"),
          "}\n",
          sep="\n")
}

# all the types of tests we can do
scores <- c("loglik-g", "aic-g", "bic-g", "bge")
tests <- c("cor", "zf", "mi-g", "mi-g-sh")
bnlearn.design <- data.frame(algo=rep(c("tabu", "gs"), each=16),
                             score.or.test=c(rep(scores, each=4), rep(tests, each=4)),
                             blacklist=ifelse(1:32 %% 4 < 2, "blacklist", "NULL"),
                             data=ifelse(1:32 %% 2 == 0, "best", "pca"),
                             stringsAsFactors=FALSE)
kable(bnlearn.design, format="markdown")
quit()

################################################################################
# MAIN
################################################################################

# retrieve all QTLs which are common to all three feature types
qtls <- get.dt(sapply(1:22, function (chr) sprintf(sel.cmd, chr, chr, chr)))
#qtls <- get.dt(sapply(1:1, function (chr) sprintf(sel.cmd, chr, chr, chr)))

# retrieve data for all features associated with QTLs
edata <- qtls[,get.dt(sprintf(equery, chrom, gene_id)), "chrom,position,gene_id"]
mdata <- qtls[,get.dt(sprintf(mquery, chrom, cpg_position)), "chrom,position,cpg_position"]
adata <- qtls[,get.dt(sprintf(aquery, chrom, peak_centre)), "chrom,position,peak_centre"]
gdata <- qtls[,get.dt(sprintf(gquery, chrom, position)), "chrom,position"]

invisible(dbDisconnect(con))

# merge the data into one table
. <- sapply(list(edata, mdata, adata, gdata), setkey, chrom, position, patient_id)
data <- Reduce(cart.merge, list(edata, adata, mdata, gdata))
data[,g := as.numeric(g)]

# reincorporate the q-values
. <- sapply(list(data, qtls), setkey, chrom, position, gene_id, peak_centre, cpg_position)
data <- data[qtls]

# method 1: take the best feature of each type for each QTL
setkey(data, chrom, position, eq, aq, mq, gene_id, peak_centre, cpg_position)
npat <- data[,length(unique(patient_id))]
best.data <- data[,.SD[1:npat], "chrom,position"][,c("chrom", "position", "e", "a", "m", "g"), with=FALSE]

# method 2: take the PCA of all features for each QTL
# not the best...
setkey(data, chrom, position, gene_id, patient_id)
edata <- unique(data)[,get.pc1(dcast.data.table(.SD, patient_id~gene_id, value.var="e"), "e"), by="chrom,position"]

setkey(data, chrom, position, peak_centre, patient_id)
adata <- unique(data)[,get.pc1(dcast.data.table(.SD, patient_id~peak_centre, value.var="a"), "a"), by="chrom,position"]

setkey(data, chrom, position, cpg_position, patient_id)
mdata <- unique(data)[,get.pc1(dcast.data.table(.SD, patient_id~cpg_position, value.var="m"), "m"), by="chrom,position"]

. <- sapply(list(edata, mdata, adata), setkey, chrom, position, patient_id)
pca.data <- Reduce(merge, list(edata, adata, mdata, gdata))[,patient_id := NULL]

setDF(best.data)
setDF(pca.data)
pca.data$g <- as.numeric(pca.data$g)

data <- list(best=best.data, pca=pca.data)

# make bnlearn networks in several ways
apply(bnlearn.design, 1, function (row) {
    net.data <- data[[row["data"]]]
    indices <- list(group=interaction(net.data[,1],net.data[,2],drop=TRUE))
    do.by <- function (...)
        by(net.data[,-c(1,2)], indices, match.fun(row["algo"]), 
           blacklist=eval(parse(text=row["blacklist"])), ...)
    if (row["algo"] == "tabu")
        nets <- do.by(score=row["score.or.test"])
    else
        nets <- do.by(test=row["score.or.test"])

    fn <- paste0(gsub(" ", "", paste(row, collapse="-")), ".dot")
    title <- paste("bnlearn", row[4], row[1], row[2],
                   ifelse(row[3] == "blacklist", "blacklist", "no blacklist"), 
                   sep=", ")
    cat(to.gv(arc.table(nets), title), file=file.path("bnlearn", fn))
})

quit()
make.deal.net <- function (data, banlist=NULL) {
    net <- network(data)
    if (!is.null(banlist))
        banlist(net) <- banlist
    prior <- jointprior(net)
    net <- learn(net, data, prior)$nw
    all.nets <- networkfamily(data, net, prior)
    nwfsort(all.nets$nw)[[1]]
}
data$g <- ordered(data$g, levels=0:2)
deal.net <- make.deal.net(data, banlist)
deal.net.2 <- make.deal.net(data)

png("qtl.png")
par(mfrow=c(2,2), mar=c(0, 0, 1, 0))
plot(bn.net, main="bnlearn with blacklist")
plot(deal.net, main="deal with blacklist", showban=FALSE)
plot(bn.net.2, main="bnlearn without blacklist")
plot(deal.net.2, main="deal without blacklist", showban=FALSE)
dev.off()
