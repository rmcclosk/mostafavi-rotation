#!/usr/bin/env python3

import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing SNPs")
    query = make_insert_query("snp", 6)
    values = []
    nt = ['A', 'C', 'G', 'T']
    for i, row in enumerate(iter_gzip("snp141Common.txt.gz"), start=1):
        if i % 10000 == 0:
            logging.info("Done {} rows".format(i))
            cur.executemany(query, values)
            con.commit()
            values = []

        try:
            chrom = int(row[1].replace("chr", ""))
        except ValueError:
            continue
        try:
            ref, alt = row[9].split("/")
        except ValueError:
            continue
        if not (ref in nt and alt in nt): continue

        rsid = row[4]
        pos = row[2]
        forward = row[6] == "+"
        values.append((rsid, chrom, pos, forward, ref, alt))

    logging.info("Importing {} SNPs".format(len(values)))
    cur.executemany(query, values)
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
