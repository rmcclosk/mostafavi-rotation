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
    patient_query = "SELECT * FROM patient WHERE id = %s"
    to_delete = []
    for sampid, projid in ids.items():
        cur.execute(patient_query, (projid,))
        if cur.fetchone() is None:
            to_delete.append(sampid)
    for sampid in to_delete:
        del ids[sampid]

    writer = csv.writer(sys.stdout, delimiter="\t")
    with open("ill450kMeth_all_740_imputed.txt") as f: 
        reader = csv.DictReader(f, delimiter="\t")
        for i, row in enumerate(reader, start=1):
            if i % 1000 == 0:
                sys.stderr.write("Done {}/420132 rows\n".format(i))
                sys.stderr.flush()
            target = row.pop("TargetID")
            cur.execute(cpg_query, (target,))
            try:
                chrom, position = cur.fetchone()
            except TypeError:
                sys.stderr.write("Liftover of CpG {} failed\n".format(target))
                sys.stderr.flush()
                continue
            for sample, value in row.items():
                try:
                    writer.writerow((ids[sample], chrom, position, value))
                except KeyError:
                    pass

if __name__ == "__main__":
    main()
