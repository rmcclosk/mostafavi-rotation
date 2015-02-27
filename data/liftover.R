liftover <- function (chr, pos) {
    bed <- data.table(chr=paste0("chr", chr), start=pos, end=pos+1, id=1:length(chr))
    setkey(bed, id)

    infile <- tempfile()
    outfile <- tempfile()
    failfile <- tempfile()
    write.table(bed, infile, col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t")
    system2("liftOver", c(infile, "hg19ToHg38.over.chain.gz", outfile, failfile))

    new.bed <- fread(outfile)
    setkey(bed, id)
    setnames(new.bed, c("V1", "V2", "V3", "V4"), c("chr", "start", "end", "id"))
    setkey(new.bed, id)

    unlink(infile)
    unlink(outfile)
    unlink(failfile)
    
    bed <- bed[,"id", with=FALSE]
    new.bed <- new.bed[bed]
    new.bed[,chr := as.integer(sub("chr", "", chr))]
    new.bed[,c("id", "end") := NULL]
    setnames(new.bed, "chr", "pos")
}
