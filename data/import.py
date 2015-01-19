#!/usr/bin/env python3

import sqlite3
import csv
import itertools
import logging
import logging.config
import sys
import re
import subprocess
import tempfile

def make_insert_query(table, ncols, ignore=True):
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

def import_chrominfo(cur, con):
    query = make_insert_query("chromosome", 2)
    with open("chromInfo.txt") as f:
        reader = csv.reader(f, delimiter="\t")
        for row in reader:
            try:
                row[0] = int(row[0].replace("chr", ""))
                cur.execute(query, row[:2])
            except ValueError:
                continue
        con.commit()

def import_ensgene(cur, con):
    gene_query = make_insert_query("gene", 6)
    transcript_query = make_insert_query("transcript", 2)
    exon_query = make_insert_query("exon", 3)

    cmd = ["join", "-1", "2", "-2", "1", "-t", "\t", "ensGene.txt", "ensemblToGeneName.txt"]
    tmpfile = tempfile.TemporaryFile("w+")
    try:
        subprocess.Popen(cmd, stdout=tmpfile).communicate()
        tmpfile.seek(0)
        reader = csv.reader(tmpfile, delimiter="\t")
        for nrow, row in enumerate(reader, start=1):
            try:
                chrom = int(row[2].replace("chr", ""))
            except ValueError:
                continue
            gene_id = row[12]
            gene_name = row[-1]
            forward = 1 if row[3] == "+" else 0
            if row[6] != row[7]:
                cds_start, cds_end = row[6:8]
            else:
                cds_start, cds_end = [None, None]
            cur.execute(gene_query, (gene_id, gene_name, chrom, forward, cds_start, cds_end))
    
            transcript_id = row[0]
            cur.execute(transcript_query, (transcript_id, gene_id))
    
            exon_starts = row[9].rstrip(",").split(",")
            exon_ends = row[10].rstrip(",").split(",")
            for start, end in itertools.zip_longest(exon_starts, exon_ends):
                cur.execute(exon_query, (transcript_id, start, end))

            if nrow % 1000 == 0:
                con.commit()
        con.commit()
    finally:
        tmpfile.close()

def import_cpgs(cur, con):
    cpg_query = make_insert_query("cpg", 4)
    with open("wgEncodeHaibMethyl450CpgIslandDetails.txt") as f:
        while not next(f).startswith("[Assay]"): pass
    
        reader = csv.reader(f)
        header = next(reader)
        ncol = len(header)
        for nrow, row in enumerate(reader, start=1):
            id = row[0]
            if not id.startswith("c"): continue

            try:
                chrom = int(row[11])
            except ValueError:
                continue

            pos = row[12]
            forward = 0 if row[16] == "F" else 1
            cur.execute(cpg_query, (id, chrom, pos, forward))
            if nrow % 1000 == 0:
                con.commit()
        con.commit()

def import_phenotype(cur, con):
    # FID,IID,projid,globcog_random_slope,cog_ep_random_slope,parksc_bv,gaitsc_bv,bradysc_bv,rigidsc_bv,tremsc_bv,parksc_lv,gaitsc_lv,bradysc_lv,rigidsc_lv,tremsc_lv,cog_ep_lv,globcog_lv,age_bl,age_death,educ,msex,apoe_genotype,dlbany,arteriol_scler,ci_num2_gct,ci_num2_mct,pmAD,pathoAD,studyn,np_sqrt,nft_sqrt,gpath_sqrt,tangles_sqrt,amyloid_sqrt,apoe4n,pkyrs_bl,,,EV1,EV2,EV3,EV4,EV5,EV6,EV7,EV8,EV9,EV10,aa_av_3
    query = make_insert_query("patient", 45)
    with open("pheno_cov_n2963_092014_forPLINK.csv") as f:
        reader = csv.reader(f)
        next(reader) # skip header
        for row in reader:
            row.pop(37)
            row.pop(36)
            values = fix_nulls(row[2:])
            row[29] = None if float(row[29]) == 0 else row[29]
            row[30] = None if float(row[30]) == 0 else row[30]
            cur.execute(query, fix_nulls(row[2:]))
        con.commit()

def import_methylation(cur, con):
    query = make_insert_query("methylation", 3)

    ids = {}
    with open("phenotype_740qc_finalFromLori.txt") as g:
        reader = csv.DictReader(g, delimiter="\t")
        for row in reader:
            ids[row["Sample_ID"]] = row["projid"]

    with open("ill450kMeth_all_740_imputed.txt") as f: 
        reader = csv.DictReader(f, delimiter="\t")
        for i, row in enumerate(reader):
            target = row.pop("TargetID")
            for sample, value in row.items():
                try:
                    cur.execute(query, (ids[sample], target, value))
                except sqlite3.IntegrityError:
                    continue
            if i == 100:
                logging.warn("Stopping after 100 rows due to space constraints")
                break
        con.commit()

def import_expression(cur, con):
    query = make_insert_query("expression", 3)
    with open("residual_gene_expression_expressed_genes_2FPKM100ind.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            patient_id = row.pop("").split(":")[0]
            for gene, value in row.items():
                gene_id = gene.split(":")[1].split(".")[0]
                try:
                    cur.execute(query, (patient_id, gene_id, value))
                except sqlite3.IntegrityError:
                    continue
        con.commit()

def import_acetylation(cur, con):
    query = make_insert_query("acetylation", 5)

    peaks = {}
    with open("peakInfo.csv") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            peaks[row["Peak"]] = (row["Chr"], row["Start"], row["End"])
    
    with open("chipSeqResiduals.csv") as f:
        reader = csv.reader(f, delimiter="\t")
        header = next(reader)
        for row in reader:
            chr, start, end = peaks[row.pop(0)]
            for i, value in enumerate(row):
                try:
                    cur.execute(query, (header[i], chr, start, end, value))
                except sqlite3.IntegrityError:
                    continue
        con.commit()

def main():
    logging.config.fileConfig("../logging.conf")
    
    logging.info("Connecting to database")
    con = sqlite3.connect("db.sqlite")
    cur = con.cursor()
    cur.execute("PRAGMA foreign_keys = ON")
    con.commit()

    logging.info("Importing chromosome information")
    import_chrominfo(cur, con)
    
    logging.info("Importing Ensembl genes")
    import_ensgene(cur, con)
   
    logging.info("Importing CpGs")
    import_cpgs(cur, con)

    logging.info("Importing phenotypes")
    import_phenotype(cur, con)

    logging.info("Importing methylation")
    import_methylation(cur, con)

    logging.info("Importing expression")
    import_expression(cur, con)

    logging.info("Importing acetylation")
    import_acetylation(cur, con)

    con.close()

if __name__ == "__main__":
    main()
