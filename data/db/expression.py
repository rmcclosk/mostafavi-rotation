#!/usr/bin/env python3

import psycopg2
import sys
import csv

def main():
    con = psycopg2.connect("dbname=cogdec user=rmcclosk")
    cur = con.cursor()
    writer = csv.writer(sys.stdout, delimiter="\t")
    with open("residual_gene_expression_expressed_genes_2FPKM100ind.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for i, row in enumerate(reader, start=1):
            patient_id = row.pop("").split(":")[0]
            cur.execute("SELECT * FROM patient WHERE id = %s", (patient_id,))
            if cur.fetchone() is None: continue

            for gene, value in row.items():
                gene_id = gene.split(":")[1].split(".")[0].replace("ENSG", "")
                writer.writerow((patient_id, gene_id, value))
    con.close()

if __name__ == "__main__":
    main()
