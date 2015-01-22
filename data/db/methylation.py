#!/usr/bin/env python3

import csv
import sqlite3
import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing methylation data")
    query = make_insert_query("methylation", 3)

    ids = {}
    with open("phenotype_740qc_finalFromLori.txt") as g:
        reader = csv.DictReader(g, delimiter="\t")
        for row in reader:
            ids[row["Sample_ID"]] = row["projid"]

    with open("ill450kMeth_all_740_imputed.txt") as f: 
        reader = csv.DictReader(f, delimiter="\t")
        for i, row in enumerate(reader, start=1):
            target = row.pop("TargetID")
            for sample, value in row.items():
                try:
                    cur.execute(query, (ids[sample], target, value))
                except sqlite3.IntegrityError:
                    continue
            if i % 1000 == 0:
                logging.info("Done {} rows".format(i))
                con.commit()
        con.commit()
    con.close()

if __name__ == "__main__":
    main()
