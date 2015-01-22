#!/usr/bin/env python3

import logging
import logging.config
import glob
import re
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    logging.info("Importing genotype data")
    query = make_insert_query("genotype", 4)
    for chr in range(1, 22):
        dosage_files = glob.glob("combined_core/chr{}.dosage.*.gz".format(chr))
        for dosage_file in dosage_files:
            r = iter_gzip(dosage_file, delim=" ")
            header = next(r)[3:]
            for i, id in enumerate(header):
                try:
                    id = re.search("\d{8}", id).group()
                    header[i] = None if id in header else id
                except AttributeError:
                    header[i] = None

            for row in r:
                snp, ref, alt = row[:3]
                try:
                    if snp.startswith("rs"):
                        cur.execute("SELECT chrom, position FROM snp WHERE rsid = ?", (rsid,))
                        chr, pos = cur.fetchone()
                    else:
                        chr, pos = snp.replace("chr", "").split(":")
                        chr = int(chr)
                except (TypeError, ValueError):
                    continue
               
                for i, value in enumerate(row[3:]):
                    if header[i] is None: continue
                    cur.execute(query, (header[i], rsid, value))
            logging.info("Finished file {}".format(dosage_file))
            con.commit()
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
