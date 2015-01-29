#!/usr/bin/env python3

import sys
import csv

def main():
    ids = {}
    with open("phenotype_740qc_finalFromLori.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            ids[row["Sample_ID"]] = row["projid"]

    with open("ill450kMeth_all_740_imputed.txt") as f: 
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            target = row.pop("TargetID")
            for sample, value in row.items():
                writer.writerow((ids[sample], target, value))

if __name__ == "__main__":
    main()
