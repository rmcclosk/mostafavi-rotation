#!/usr/bin/env python3

import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing SNPs")
    query = make_insert_query("snp", 6)
    for i, row in enumerate(iter_gzip("snp141Common.txt.gz"), start=1):
        if i % 10000 == 0:
            logging.info("Done {} rows".format(i))
            con.commit()
        try:
            chrom = int(row[1].replace("chr", ""))
        except ValueError:
            continue
        if row[2] != row[3]: continue # indel
        try:
            ref, alt = row[9].split("/")
        except ValueError:
            continue

        rsid = row[4]
        pos = row[2]
        forward = 1 if row[6] == "+" else 0
        cur.execute(query, (rsid, chrom, pos, forward, ref, alt))
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
