#!/usr/bin/env python3

import sys
import csv
from _shared import iter_gzip

def main():
    writer = csv.writer(sys.stdout, delimiter="\t")
    for row in iter_gzip("cpg.txt.gz"):
        chr, start, end, cpg = row
        try:
            writer.writerow((cpg, int(chr.replace("chr", "")), start))
        except ValueError:
            continue

if __name__ == "__main__":
    main()
