#!/usr/bin/env Rscript

# do Bayes net learning on shared QTLs

library(RPostgreSQL)
library(Rgraphviz)
library(data.table)
library(bnlearn)
library(knitr)

set.seed(0)
source(file="best_qtls.R")

# functions for retrieving database results
get.dt <- function (queries)
    Reduce(f=function (d, q) rbind(d, setDT(dbGetQuery(con, q))), x=queries, init=NULL)
get.dt.pid <- function (query)
    setkey(get.dt(query), patient_id)

# blacklists for networks
blacklist <- data.frame(from=c("e", "m", "a"), to=rep("g", 3))
banlist <- matrix(c(1,2,3,4,4,4), ncol=2)

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

all.topologies <- function (net) {
    undir <- unique(t(apply(undirected.arcs(net), 1, sort)))
    if (nrow(undir) == 0)
        return (c(modelstring(net)))

    orig.net <- net 
    sapply(0:(2^nrow(undir)-1), function (directions) {
        net <- orig.net
        if (nrow(undir) == 0)
            return (data.table(topo=modelstring(net), times=1))
    
        tryCatch({ 
            directions <- as.logical(intToBits(directions))
            for (j in 1:nrow(undir)) {
                if (directions [j]) 
                    net <- set.arc(net, undir[j,1], undir[j,2])
                else
                    net <- set.arc(net, undir[j,2], undir[j,1])
            }   
            modelstring(net)
        }, error = function (e) {NULL})
    })  
}

topo.table <- function (nets) {
    topos <- sapply(nets, all.topologies)
    ntopos <- sapply(topos, length)
    topos <- data.table(topo=unlist(topos), times=rep(1/ntopos, ntopos))
    topos[,sum(times),topo]
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

################################################################################
# MAIN
################################################################################

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

    cat(paste0(gsub(" ", "", paste(row, collapse="-")), "\n"))
    print(topo.table(nets))
})
