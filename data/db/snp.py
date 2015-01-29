#!/usr/bin/env python3

import sys
import csv
import os
from _shared import iter_gzip

def main():
    writer = csv.writer(sys.stdout, delimiter="\t")
    for i, row in enumerate(iter_gzip("SNPChrPosOnRef.bcp.gz"), start=1):
        if i % 10000 == 0:
            sys.stderr.write("Done {} rows\n".format(i))
        try:
            writer.writerow(list(map(int, row[:3])))
        except ValueError:
            pass

if __name__ == "__main__":
    main()
