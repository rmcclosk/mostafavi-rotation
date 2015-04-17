#!/usr/bin/env Rscript

# use information-geometric causal inference to check out phenotype
# relationships

source(file=file.path("utils", "causal.R"))
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

vars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
data <- read.delim(file.path("data", "patients.tsv"))
data <- data[,vars]
data[which(data == 0, arr.ind=TRUE)] <- NA
data <- na.omit(data)

x <- range01(data$tangles_sqrt)
y <- range01(data$amyloid_sqrt)
z <- range01(-data$globcog_random_slope)

causes.infogeo(x, y)
causes.infogeo(y, z)
causes.infogeo(x, z)
