library(data.table)

scale.rank <- function (x) scale(rank(x))

read.snpspos <- function (snpspos.file) {
    snpspos <- fread(snpspos.file, drop=3)
    setnames(snpspos, colnames(snpspos), c("snp.chr", "snp.pos", "snp"))
    snpspos[,snp.chr := as.integer(sub("chr", "", snp.chr))]
    snpspos[,snp := as.integer(sub("rs", "", snp))]
    setcolorder(snpspos, c("snp", "snp.chr", "snp.pos"))
    setkey(snpspos, snp)
}

read.genotype.patient <- function (snp.file) {
    patient <- fread(snp.file, select=1)
    setnames(patient, "V1", "patient.id")
    patient[,patient.id := as.integer(gsub("[A-Z]", "", patient.id))]
    setkey(patient, patient.id)
}

do.matrix.eqtl <- function (snp.file, gene, genepos, snpspos, patient) {
    # get SNP IDs from file
    snp.ids <- strsplit(readLines(snp.file, n=1), " ")[[1]]
    snp.ids <- as.integer(ifelse(grepl("rs", snp.ids), gsub("rs", "", snp.ids), NA))
    cur.snpspos <- snpspos[snp.ids,]
    keeps <- cur.snpspos[,which(!is.na(snp.chr))]
    if (length(keeps) == 0) return (NULL);

    cur.snpspos <- cur.snpspos[keeps,]
    
    # read SNP values, and reduce to common patients
    snps <- fread(snp.file, select=c(1, 1+keeps))
    setnames(snps, "V1", "patient.id")
    snps[,patient.id := as.integer(gsub("[A-Z]", "", patient.id))]
    setkey(snps, patient.id)
    snps <- unique(snps)[patient,][,patient.id := NULL]
    
    # make a SlicedData object
    snps <- snps[,lapply(.SD, scale.rank)]
    snps <- t(as.matrix(snps))
    dimnames(snps) <- list(cur.snpspos[,snp], patient[,patient.id])
    snps <- SlicedData$new()$CreateFromMatrix(snps)

    setDF(cur.snpspos)
    # run Matrix eqTL
    Matrix_eQTL_main(
        snps = snps, 
        gene = gene, 
        cvrt = SlicedData$new(),
        output_file_name = "/dev/null",
        pvOutputThreshold = 0,
        useModel = modelLINEAR,
        errorCovariance = numeric(), 
        verbose = FALSE, 
        output_file_name.cis = cis.outfile,
        pvOutputThreshold.cis = 1,
        snpspos = cur.snpspos, 
        genepos = genepos,
        cisDist = 1000000,
        pvalue.hist = FALSE,
        min.pv.by.genesnp = FALSE,
        noFDRsaveMemory = TRUE)
    
    res <- fread(cis.outfile)
    setnames(res, c("SNP", "gene"), c("snp", "feature"))
    res[,"t-stat" := NULL, with=FALSE]
}
