# Miscellanous functions which are used in multiple places.

# remove the top n principal components from a data matrix
rm.pcs <- function (data, n) {
    if (n == 0) return (data)
    s <- svd(data, nu=n, nv=n)
    if (n != 1)
        res <- data - s$u %*% diag(s$d[1:n]) %*% t(s$v)
    else
        res <- data - s$u %*% s$d[1] %*% t(s$v)
    dimnames(res) <- dimnames(data)
    res
}

# remove the top n principal components from a data matrix, given the SVD
rm.pcs.2 <- function (data, data.svd, n) {
    if (n == 0) {
        data
    } else if (n == 1) {
        data - data.svd$u[,1,drop=FALSE] %*% data.svd$d[1] %*% t(data.svd$v[,1,drop=FALSE])
    } else {
        data - data.svd$u[,1:n] %*% diag(data.svd$d[1:n]) %*% t(data.svd$v[,1:n])
    }
}

# remove only the nth principal component from a data matrix, given the SVD
rm.pcs.3 <- function (data, data.svd, n) {
    if (n == 0)
        data
    else
        res <- data - data.svd$u[,n,drop=FALSE] %*% data.svd$d[n] %*% t(data.svd$v[,n,drop=FALSE])
}

# scale and rank the columns of a matrix
scale.rank <- function (x) {
    names <- dimnames(x)
    x <- apply(x, 2, function (col) scale(rank(col)))
    dimnames(x) <- names
    x
} 

# get the minimum distance from each element of y to any element of x
# http://stackoverflow.com/questions/1628383/finding-the-minimum-difference-between-each-element-of-one-vector-and-another-ve
min.dist <- function (x, y) {
    sorted.x <- sort.int(x, method="quick")
    myfun <- stepfun(sorted.x, 0:length(x))
        
    indices <- pmin(pmax(1, myfun(y)), length(sorted.x) - 1)
    pmin(abs(y - sorted.x[indices]), abs(y - sorted.x[indices + 1]))
}

# get the median and IQR of a vector, for display in a table
median.iqr <- function (x) {
    sprintf("%.2g [%.2g-%.2g]", median(x), quantile(x, 0.25), quantile(x, 0.75))
}
