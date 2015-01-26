#!/usr/bin/env python3

import sys
import csv
from _shared import iter_gzip

def main():
    writer = csv.writer(sys.stdout, delimiter="\t")
    for row in iter_gzip("chromInfo.txt.gz"):
        try:
            chrom = int(row[0].replace("chr", ""))
        except ValueError:
            continue
        size = int(row[1])
        writer.writerow((chrom, size))

if __name__ == "__main__":
    main()
