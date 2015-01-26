#!/usr/bin/env python3

import csv
import sys
import itertools
from _shared import iter_gzip

def main():
    writer = csv.writer(sys.stdout, delimiter="\t")
    for row in iter_gzip("ensGene.txt.gz"):
        try:
            chrom = int(row[2].replace("chr", ""))
        except ValueError:
            continue
        if chrom != 22: continue # DEBUG

        transcript_id = int(row[1].replace("ENST", ""))
        exon_starts = row[9].rstrip(",").split(",")
        exon_ends = row[10].rstrip(",").split(",")
        for start, end in itertools.zip_longest(exon_starts, exon_ends):
            writer.writerow((transcript_id, start, end, chrom))

if __name__ == "__main__":
    main()
