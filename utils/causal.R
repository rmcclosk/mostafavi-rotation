#!/usr/bin/env Rscript

# various causal inference tests

library(mediation)
source(file=file.path("utils", "cit.R"))

# Janzing, Dominik, et al. "Justifying Information-Geometric Causal Inference." arXiv preprint arXiv:1402.2499 (2014).
# Definition 1.
# This returns TRUE if X causes Y, **given that either X causes Y or Y causes
# X**. This is only valid if X and Y are both in the range [0, 1], and the
# relationship between the two of them is monotonically increasing.
causes.infogeo <- function (x, y) {
    stopifnot(all(0 <= x & x <= 1))
    stopifnot(all(0 <= y & y <= 1))
    stopifnot(coef(lm(y~x))[2] > 0)
    lhs <- sum(log(abs(diff(y[order(x)]))/abs(diff(x[order(x)]))))
    rhs <- sum(log(abs(diff(x[order(y)]))/abs(diff(y[order(y)]))))
    lhs < rhs
}

# Tingley, Dustin, et al. "Mediation: R package for causal mediation analysis." (2014).
# Given that the variance in both out.var and med.var are partially due to
# cause.var, this returns an object describing the proportion of the variance
# of out.var which is due to the mediating effect of med.var. See the mediation package
# documentation for details of the object.
mediates <- function (cause.var, med.var, out.var, data) {
    med.fit <- lm(as.formula(paste0(med.var, "~", cause.var)), data)
    out.fit <- lm(as.formula(paste0(out.var, "~", cause.var, "+", med.var)), data)
    mediate(med.fit, out.fit, treat=cause.var, mediator=med.var,
            control.value=0, treat.value=2, robustSE=TRUE)
}
