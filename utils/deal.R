# some functions common to multiple deal analyses

library(deal)

best.nets.exhaustive <- function (data, banlist=NULL) {
    net <- network(data)
    prior <- jointprior(net)
    banlist(net) <- banlist
    net <- learn(net, data, prior)$nw
    all.nets <- networkfamily(data, net, prior)
    all.nets <- nwfsort(all.nets$nw)
    
    scores <- sapply(all.nets, "[[", "score")
    relscores <- sapply(all.nets, "[[", "relscore")
    all.nets[sapply(relscores, all.equal, 1) == "TRUE"]
}

best.net.heuristic <- function (data) {
    net <- network(data)
    prior <- jointprior(net)
    net <- learn(net, data, prior)$nw
    search <- autosearch(net, data, prior, trace=TRUE)
    heuristic(search$nw, data, prior, restart=2, degree=10, trace=TRUE,
              trylist=search$trylist)$nw
}
