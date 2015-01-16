#!/usr/bin/env python3

import sqlite3
import csv
import itertools
import logging
import logging.config
import sys
import re

def make_insert_query(table, ncols, ignore=False):
    """Create a generic INSERT query for a table"""
    space = "OR IGNORE" if ignore else ""
    ph = ",".join("?"*ncols)
    return "INSERT {} INTO {} VALUES ({})".format(space, table, ph)

def fix_nulls(row):
    """Change all NULL-meaning values to None"""
    new_row = []
    for x in row:
        if x == "" or x == "NA" or x == "NaN" or x == "-9": # danger if real -9
            new_row.append(None)
        else:
            new_row.append(x)
    return(new_row)

def import_refgene(cur, con, table="refGene"):
    refgene_query = make_insert_query(table, 16)
    skipped = 0
    with open("{}.txt".format(table)) as f:
        reader = csv.reader(f, delimiter="\t")
        for row in reader:
            try:
                cur.execute(refgene_query, fix_nulls(row))
            except sqlite3.IntegrityError:
                skipped += 1
        if skipped > 0:
            logging.warn("Skipped %d alternate alignments", skipped)
        con.commit()

def import_cpgs(cur, con):
    cpg_query = make_insert_query("CpG", 33)
    cpg_gene_query = make_insert_query("CpGGene", 4, ignore=True)
    with open("wgEncodeHaibMethyl450CpgIslandDetails.txt") as f:
        while not next(f).startswith("[Assay]"): pass
    
        reader = csv.reader(f)
        header = next(reader)
        ncol = len(header)
        bad_transcripts = 0
        for nrow, row in enumerate(reader, start=1):
            id = row[0]
            if not id.startswith("c"): continue
    
            cur.execute(cpg_query, fix_nulls(row))
            cpg_gene_values = [[]]
            for i in range(ncol):
                if header[i].startswith("UCSC_RefGene"):
                    cpg_gene_values.append(row[i].split(";"))
    
            cpg_gene_values = itertools.zip_longest(*cpg_gene_values, fillvalue=id)
            for v in cpg_gene_values:
                try:
                    cur.execute(cpg_gene_query, fix_nulls(v))
                except sqlite3.IntegrityError as e: 
                    bad_transcripts += 1
            if nrow % 1000 == 0:
                con.commit()
            
        if bad_transcripts > 0:
            msg = "%d CpGs reference an outdated transcript"
            logging.warn(msg, bad_transcripts)
        con.commit()

def import_methylation_metadata(cur, con):
    projid_query = make_insert_query("projectID", 1)
    meta_query = make_insert_query("methylationMeta", 29)
    with open("phenotype_740qc_finalFromLori.txt") as f:
        reader = csv.reader(f, delimiter="\t")
        next(reader) # skip header

        for row in reader:
            try:
                cur.execute(projid_query, (row[4],))
            except sqlite3.IntegrityError:
                print(row)
                raise
            cur.execute(meta_query, fix_nulls(row))
        con.commit()

def import_methylation(cur, con):
    query = make_insert_query("methylation", 3)
    with open("ill450kMeth_all_740_imputed.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for i, row in enumerate(reader):
            target = row.pop("TargetID")
            for sample, value in row.items():
                cur.execute(query, (sample, target, value))
            if i == 100:
                logging.warn("Stopping after 100 rows due to space constraints")
                break
        con.commit()

def import_expression(cur, con):
    projid_query = make_insert_query("projectID", 1, ignore=True)
    query = make_insert_query("expression", 5)
    with open("residual_gene_expression_expressed_genes_2FPKM100ind.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        skipped = set([])
        for i, row in enumerate(reader):
            projid, sample = row.pop("").split(":")
            cur.execute(projid_query, (projid,))
            for gene, value in row.items():
                gene_name, ensembl_id = gene.split(":")
                ensembl_id = re.sub("[.]\d+$", "", ensembl_id)
                try:
                    cur.execute(query, (sample, projid, gene_name, ensembl_id, value))
                except sqlite3.IntegrityError:
                    skipped.add(ensembl_id)
            if i == 100:
                logging.warn("Stopping after 100 rows due to space constraints")
                break
        if len(skipped) > 0:
            logging.warn("Skipped %d genes not in Ensembl gene list", len(skipped))
        con.commit()

def import_acetylation_peaks(cur, con):
    query = make_insert_query("acetylationPeaks", 4)
    with open("peakInfo.csv") as f:
        reader = csv.reader(f, delimiter="\t")
        next(reader) # skip header
        cur.executemany(query, reader)
    con.commit()

def import_acetylation(cur, con):
    projid_query = make_insert_query("projectID", 1, ignore=True)
    query = make_insert_query("acetylation", 3)
    
    with open("chipSeqResiduals.csv") as f:
        reader = csv.reader(f, delimiter="\t")
        header = next(reader)
        for projid in header:
            cur.execute(projid_query, (projid,))
        for i, row in enumerate(reader):
            peak = row.pop(0)
            values = itertools.zip_longest([peak], header, row, fillvalue=peak)
            cur.executemany(query, values)

            if i == 100:
                logging.warn("Stopping after 100 rows due to space constraints")
                break
    con.commit()

def import_phenotype(cur, con):
    projid_query = make_insert_query("projectID", 1, ignore=True)
    query = make_insert_query("phenotype", 47)
    
    with open("pheno_cov_n2963_092014_forPLINK.csv") as f:
        reader = csv.reader(f)
        header = next(reader)
        projid_idx = header.index("projid")
        pop_indices = [i for i, x in enumerate(header) if x == ""][::-1]
        for row in reader:
            cur.execute(projid_query, (row[projid_idx],))
            [row.pop(i) for i in pop_indices]
            cur.execute(query, fix_nulls(row))
    con.commit()

def import_techvars(cur, con):
    projid_query = make_insert_query("projectID", 1, ignore=True)
    query = make_insert_query("techvars", 47)
    
    with open("techvars_plus_phenotypes26SEP2014.txt") as f:
        reader = csv.reader(f, delimiter="\t")
        header = next(reader)
        projid_idx = header.index("projid")
        for row in reader:
            cur.execute(projid_query, (row[projid_idx],))
            cur.execute(query, fix_nulls(row))
    con.commit()
            
def main():
    logging.config.fileConfig("../logging.conf")
    
    logging.info("Connecting to database")
    con = sqlite3.connect("db.sqlite")
    cur = con.cursor()
    cur.execute("PRAGMA foreign_keys = ON")
    con.commit()
    
    logging.info("Importing refSeq genes")
    import_refgene(cur, con)

    logging.info("Importing Ensembl genes")
    import_refgene(cur, con, table="ensGene")
    
    logging.info("Importing CpGs")
    import_cpgs(cur, con)

    logging.info("Importing methylation metadata")
    import_methylation_metadata(cur, con)

    logging.info("Importing methylation data")
    import_methylation(cur, con)

    logging.info("Importing expression data")
    import_expression(cur, con)

    logging.info("Importing acetylation peaks")
    import_acetylation_peaks(cur, con)

    logging.info("Importing acetylation data")
    import_acetylation(cur, con)

    logging.info("Importing phenotypes")
    import_phenotype(cur, con)

    logging.info("Importing technical factors")
    import_techvars(cur, con)

    con.close()

if __name__ == "__main__":
    main()
