#!/usr/bin/env python3

import sys
import csv
from _shared import iter_gzip

def main():
    peaks = {}
    r = iter_gzip("peakInfo.csv.gz", skip=1)
    for row in r:
        peaks[row[0]] = (row[3], row[1], row[2])
    
    r = iter_gzip("chipSeqResiduals.csv.gz", skip=1)
    header = next(r)
    writer = csv.writer(sys.stdout, delimiter="\t")
    for row in r:
        chr, start, end = peaks[row.pop(0)]
        for j, value in enumerate(row):
            writer.writerow((header[j], chr, start, end, value))

if __name__ == "__main__":
    main()
