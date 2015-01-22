#!/usr/bin/env python3

import itertools
import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    gene_query = make_insert_query("gene", 6)
    transcript_query = make_insert_query("transcript", 2)
    exon_query = make_insert_query("exon", 3)

    gene_names = dict(iter_gzip("ensemblToGeneName.txt.gz"))

    for i, row in enumerate(iter_gzip("ensGene.txt.gz"), start=1):
        try:
            chrom = int(row[2].replace("chr", ""))
        except ValueError:
            continue

        gene_id = row[12]
        transcript_id = row[1]
        gene_name = gene_names[transcript_id]
        forward = 1 if row[3] == "+" else 0
        cds_start, cds_end = row[6:8] if row[6] != row[7] else [None, None]
        exon_starts = row[9].rstrip(",").split(",")
        exon_ends = row[10].rstrip(",").split(",")

        cur.execute(gene_query, (gene_id, gene_name, chrom, forward, cds_start, cds_end))
        cur.execute(transcript_query, (transcript_id, gene_id))
        for start, end in itertools.zip_longest(exon_starts, exon_ends):
            cur.execute(exon_query, (transcript_id, start, end))

        if i % 10000 == 0:
            logging.info("Done {} rows".format(i))
            con.commit()
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
