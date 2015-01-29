#!/usr/bin/env python3

import psycopg2
import sys
import csv
import re

def main():
    con = psycopg2.connect("dbname=cogdec user=rmcclosk")
    cur = con.cursor()
    writer = csv.writer(sys.stdout, delimiter="\t")
    gene_ptn = re.compile(".*:ENSG(?P<geneid>\d+)")
    gene_query = "SELECT * FROM gene WHERE id = %s"
    with open("residual_gene_expression_expressed_genes_2FPKM100ind.txt") as f:
        reader = csv.reader(f, delimiter="\t")
        header = next(reader)[1:]
        gene_ids = [gene_ptn.match(gene).group("geneid") for gene in header]
        for i, gene in enumerate(gene_ids):
            cur.execute(gene_query, (gene,))
            if cur.fetchone() is None: gene_ids[i] = None

        for row in reader:
            patient_id = row.pop(0).split(":")[0]
            cur.execute("SELECT * FROM patient WHERE id = %s", (patient_id,))
            if cur.fetchone() is None: continue

            for i, value in enumerate(row):
                if gene_ids[i] is not None:
                    writer.writerow((patient_id, gene_ids[i], value))
    con.close()

if __name__ == "__main__":
    main()
