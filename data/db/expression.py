#!/usr/bin/env python3

import psycopg2
import csv
import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing expression data")
    query = "INSERT INTO expression (patient_id, gene_id, value) VALUES (%s,%s,%s)"
    values = []
    with open("residual_gene_expression_expressed_genes_2FPKM100ind.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for i, row in enumerate(reader, start=1):
            patient_id = row.pop("").split(":")[0]
            for gene, value in row.items():
                gene_id = gene.split(":")[1].split(".")[0]
                values.append((patient_id, gene_id, value))
            if i % 100 == 0:
                logging.info("Done {} rows".format(i))
                cur.executemany(query, values)
                con.commit()
                values = []
        cur.executemany(query, values)
        con.commit()
    con.close()

if __name__ == "__main__":
    main()
