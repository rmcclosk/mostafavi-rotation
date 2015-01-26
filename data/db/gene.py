#!/usr/bin/env python3

import sys
import csv
import logging
import logging.config
from _shared import iter_gzip

def main():
    logging.config.fileConfig("../logging.conf")

    gene_names = dict(iter_gzip("ensemblToGeneName.txt.gz"))
    rows = set([])
    for row in iter_gzip("ensGene.txt.gz"):
        try:
            chrom = int(row[2].replace("chr", ""))
        except ValueError:
            continue
        if chrom != 22: continue # DEBUG

        gene_id = row[12].replace("ENSG", "")
        gene_name = gene_names[row[1]]
        forward = "TRUE" if row[3] == "+" else "FALSE"
        rows.add((gene_id, gene_name, chrom, forward))
    csv.writer(sys.stdout, delimiter="\t").writerows(rows)

if __name__ == "__main__":
    main()
