#!/usr/bin/env python3

import sqlite3
import csv
import itertools

con = sqlite3.connect("db.sqlite")
cur = con.cursor()
cur.execute("PRAGMA foreign_keys = ON")

def make_insert_query(table, ncols):
    return "INSERT OR IGNORE INTO {} VALUES ({})".format(table, ",".join("?"*ncols))

# import genes
refgene_query = make_insert_query("refGene", 16)
with open("refGene.txt") as f:
    reader = csv.reader(f, delimiter="\t")
    cur.executemany(refgene_query, reader)
    con.commit()

# import CpGs
cpg_query = make_insert_query("CpG", 30)
cpg_gene_query = make_insert_query("CpGGene", 4)

with open("wgEncodeHaibMethyl450CpgIslandDetails.txt") as f:
    while not next(f).startswith("[Assay]"): pass

    reader = csv.reader(f)
    header = next(reader)
    ncol = len(header)
    for row in reader:
        id = row[0]
        if not id.startswith("c"): continue

        cpg_values = []
        cpg_gene_values = [[]]
        for i in range(ncol):
            if not header[i].startswith("UCSC_RefGene"):
                cpg_values.append(row[i])
            else:
                cpg_gene_values.append(row[i].split(";"))
        cur.execute(cpg_query, cpg_values)

        cpg_gene_values = itertools.zip_longest(*cpg_gene_values, fillvalue=id)
        for v in cpg_gene_values:
            try:
                cur.execute(cpg_gene_query, v)
            except sqlite3.IntegrityError: # old transcript not in refGene
                pass
    con.commit()
con.close()
