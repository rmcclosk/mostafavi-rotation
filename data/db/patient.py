#!/usr/bin/env python3

import sys
import csv
from _shared import fix_nulls

def main():
    writer = csv.writer(sys.stdout, delimiter="\t")
    with open("pheno_cov_n2963_092014_forPLINK.csv") as f:
        reader = csv.reader(f)
        header = next(reader) # skip header
        for row in reader:
            for i in range(len(header))[::-1]:
                if header[i] in ["", "FID", "IID"]:
                    row.pop(i)
                elif header[i].endswith("sqrt") and row[i] != "" and float(row[i]) == 0:
                    row[i] = None
            writer.writerow(fix_nulls(row))

if __name__ == "__main__":
    main()
