#!/usr/bin/env python3

import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing CpGs")
    query = make_insert_query("cpg", 4)

    r = iter_gzip("wgEncodeHaibMethyl450CpgIslandDetails.txt.gz", ",", 8)
    for i, row in enumerate(r, start=1):
        id = row[0]
        if not id.startswith("c"): continue

        try:
            chrom = int(row[11])
        except ValueError:
            continue

        pos = row[12]
        forward = 0 if row[16] == "F" else 1
        cur.execute(query, (id, chrom, pos, forward))
        if i % 10000 == 0:
            logging.info("Done {} rows".format(i))
            con.commit()
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
