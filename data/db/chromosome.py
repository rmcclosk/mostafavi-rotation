#!/usr/bin/env python3

import logging
import logging.config
from _shared import *

def main():
    cur, con = db_connect()
    logging.config.fileConfig("../logging.conf")
    logging.info("Importing chromosome information")

    query = make_insert_query("chromosome", 2)
    for row in iter_gzip("chromInfo.txt.gz"):
        try:
            chrom = int(row[0].replace("chr", ""))
        except ValueError:
            continue
        size = int(row[1])
        cur.execute(query, (chrom, size))
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
