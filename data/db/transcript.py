#!/usr/bin/env python3

import sys
import csv
from _shared import iter_gzip

def main():
    for row in iter_gzip("ensGene.txt.gz"):
        try:
            chrom = int(row[2].replace("chr", ""))
        except ValueError:
            continue
        if chrom != 22: continue # DEBUG

        writer = csv.writer(sys.stdout, delimiter="\t")
        gene_id = row[12].replace("ENSG", "")
        transcript_id = row[1].replace("ENST", "")
        cds_start, cds_end = row[6:8] if row[6] != row[7] else ["\\N", "\\N"]
        writer.writerow((transcript_id, gene_id, cds_start, cds_end, chrom))

if __name__ == "__main__":
    main()
