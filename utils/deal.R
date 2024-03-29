# some functions common to multiple deal analyses

library(deal)
library(Rgraphviz)
library(graph)

# remove a node from model strings representing networks
rm.node <- function (strings, node) {
    strings <- gsub(sprintf("|%s]", node), "]", strings, fixed=TRUE)
    strings <- gsub(sprintf(":%s", node), "", strings, fixed=TRUE)
    strings <- gsub(sprintf("[%s]", node), "", strings, fixed=TRUE)
    gsub(sprintf("\\[%s\\|[[:alnum:]:]*\\]", node), "", strings)
}

# find the best deal network by exhaustive search
best.nets.exhaustive <- function (data) {

    cont.only <- !any(lapply(data, class) == "factor")

    # hack so it works with continuous-only data
    # add a dummy factor with one level
    if (cont.only) {
        dummy <- tail(make.unique(c(colnames(data), "dummy")), 1)
        data[,dummy] <- factor(1)
    }
    
    # run the network
    all.nets <- nwfsort(unique(getnetwork(networkfamily(data)), equi=TRUE))
    scores <- sapply(all.nets, "[[", "relscore")

    # if it was continuous only data, remove the dummy factor
    if (cont.only) {
        data[,dummy] <- NULL
        empty.net <- network(data)

        strings <- rm.node(sapply(all.nets, modelstring), dummy)
        all.nets <- lapply(strings, as.network, empty.net)
    }

    all.nets[sapply(scores, all.equal, 1) == "TRUE"]
}

# find the best deal network by a heuristic
best.net.heuristic <- function (data) {
    net <- network(data)
    prior <- jointprior(net)
    net <- learn(net, data, prior)$nw
    search <- autosearch(net, data, prior, trace=TRUE)
    heuristic(search$nw, data, prior, restart=2, degree=10, trace=TRUE,
              trylist=search$trylist)$nw
}

plot.net.graphviz <- function (net, engine="dot", edge.attrs=list(), node.attrs=list(), graph.attrs=list()) {
    parents <- sapply(net$nodes, "[[", "parents")
    node.names <- sapply(net$nodes, "[[", "name")

    to.nodes <- rep(names(parents), lapply(parents, length))
    from.nodes <- node.names[unlist(parents)]
    edges <- data.frame(from=from.nodes, to=to.nodes, stringsAsFactors=FALSE)
    edges <- tapply(edges$to, edges$from, list, simplify=FALSE)
    edges <- lapply(edges, setNames, "edges")

    leaves <- setdiff(node.names, names(edges))
    edges <- c(edges, sapply(leaves, function (x) NULL, simplify=FALSE, USE.NAMES=TRUE))
    g <- graphNEL(node.names, edges, "directed")
    plot(g, engine, attrs=list(edge=edge.attrs, node=node.attrs, graph=graph.attrs))
}
