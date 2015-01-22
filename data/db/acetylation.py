#!/usr/bin/env python3

import sqlite3
import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing acetylation data")
    query = make_insert_query("acetylation", 5)

    peaks = {}
    r = iter_gzip("peakInfo.csv.gz", skip=1)
    for row in r:
        peaks[row[0]] = (row[3], row[1], row[2])
    
    r = iter_gzip("chipSeqResiduals.csv.gz", skip=1)
    header = next(r)
    for i, row in enumerate(r, start=1):
        chr, start, end = peaks[row.pop(0)]
        for j, value in enumerate(row):
            try:
                cur.execute(query, (header[j], chr, start, end, value))
            except sqlite3.IntegrityError:
                continue
        if i % 10000 == 0:
            logging.info("Done {} rows".format(i))
            con.commit()
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
