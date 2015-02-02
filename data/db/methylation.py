#!/usr/bin/env python3

import sys
import csv
import psycopg2

def main():
    ids = {}
    con = psycopg2.connect("dbname=cogdec user=rmcclosk")
    cur = con.cursor()

    cpg_query = "SELECT chrom, position FROM cpg WHERE id = %s"
    with open("phenotype_740qc_finalFromLori.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            ids[row["Sample_ID"]] = row["projid"]

    with open("ill450kMeth_all_740_imputed.txt") as f: 
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            target = row.pop("TargetID")
            cur.execute(cpg_query, (target,))
            chrom, position = cur.fetchone()
            for sample, value in row.items():
                writer.writerow((ids[sample], chrom, position, value))

if __name__ == "__main__":
    main()
