#!/usr/bin/env python3

import csv
import logging
import logging.config
from _shared import *


def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing phenotype data")
    query = make_insert_query("patient", 45)
    with open("pheno_cov_n2963_092014_forPLINK.csv") as f:
        reader = csv.reader(f)
        header = next(reader) # skip header
        for row in reader:
            for i in range(len(header))[::-1]:
                if header[i] in ["", "FID", "IID"]:
                    row.pop(i)
                elif header[i].endswith("sqrt") and row[i] != "" and float(row[i]) == 0:
                    row[i] = None
            cur.execute(query, fix_nulls(row))
        con.commit()
    con.close()

if __name__ == "__main__":
    main()
