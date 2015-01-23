#!/usr/bin/env python3

import psycopg2
import itertools
import logging
import logging.config
from _shared import *

def main():
    logging.config.fileConfig("../logging.conf")
    cur, con = db_connect()
    gene_query = make_insert_query("gene", 4)
    transcript_query = make_insert_query("transcript", 4)
    exon_query = "INSERT INTO exon (transcript_id, exon_start, exon_end) VALUES (%s,%s,%s)"

    gene_names = dict(iter_gzip("ensemblToGeneName.txt.gz"))

    gene_params = set([])
    transcript_params = set([])
    exon_params = set([])

    for row in iter_gzip("ensGene.txt.gz"):
        try:
            chrom = int(row[2].replace("chr", ""))
        except ValueError:
            continue

        gene_id = row[12]
        transcript_id = row[1]
        gene_name = gene_names[transcript_id]
        forward = row[3] == "+"
        cds_start, cds_end = row[6:8] if row[6] != row[7] else [None, None]
        exon_starts = row[9].rstrip(",").split(",")
        exon_ends = row[10].rstrip(",").split(",")

        gene_params.add((gene_id, gene_name, chrom, forward))

        transcript_params.add((transcript_id, gene_id, cds_start, cds_end))
        for start, end in itertools.zip_longest(exon_starts, exon_ends):
            exon_params.add((transcript_id, start, end))

    logging.info("Inserting {} genes".format(len(gene_params)))
    cur.executemany(gene_query, gene_params)
    con.commit()

    logging.info("Inserting {} transcripts".format(len(transcript_params)))
    cur.executemany(transcript_query, transcript_params)
    con.commit()

    logging.info("Inserting {} exons".format(len(exon_params)))
    cur.executemany(exon_query, exon_params)
    con.commit()
    con.close()

if __name__ == "__main__":
    main()
