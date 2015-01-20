#!/usr/bin/env python3

import psycopg2
import csv
import itertools
import logging
import logging.config
import gzip
import codecs
import glob
import re

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

def iter_gzip(fn, delim="\t", skip=0):
    with gzip.open(fn, "r") as f:
        c = codecs.iterdecode(f, "utf-8")
        reader = csv.reader(c, delimiter=delim)
        for i in range(skip):
            next(reader)
        for row in reader:
            yield(row)

def import_chrominfo(cur, con):
    query = make_insert_query("chromosome", 2)
    for row in iter_gzip("chromInfo.txt.gz"):
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

def import_cpgs(cur, con):
    cpg_query = make_insert_query("cpg", 4)

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
        cur.execute(cpg_query, (id, chrom, pos, forward))
        if i % 10000 == 0:
            logging.info("Done {} rows".format(i))
            con.commit()
    con.commit()

def import_phenotype(cur, con):
    query = make_insert_query("patient", 45)
    with open("pheno_cov_n2963_092014_forPLINK.csv") as f:
        reader = csv.reader(f)
        header = next(reader) # skip header
        for row in reader:
            for i in range(len(header))[::-1]:
                if header[i] in ["", "FID", "IID"]:
                    row.pop(i)
                elif header[i].endswith("sqrt") and row[i] != "" and float(row[i]) == 0:
                    row[i] = None
            cur.execute(query, fix_nulls(row))
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
        for i, row in enumerate(reader, start=1):
            target = row.pop("TargetID")
            for sample, value in row.items():
                try:
                    cur.execute(query, (ids[sample], target, value))
                except sqlite3.IntegrityError:
                    continue
            if i % 1000 == 0:
                logging.info("Done {} rows".format(i))
                con.commit()
        con.commit()

def import_expression(cur, con):
    query = make_insert_query("expression", 3)
    with open("residual_gene_expression_expressed_genes_2FPKM100ind.txt") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for i, row in enumerate(reader, start=1):
            patient_id = row.pop("").split(":")[0]
            for gene, value in row.items():
                gene_id = gene.split(":")[1].split(".")[0]
                try:
                    cur.execute(query, (patient_id, gene_id, value))
                except sqlite3.IntegrityError:
                    continue
            if i % 10000 == 0:
                logging.info("Done {} rows".format(i))
                con.commit()
        con.commit()

def import_acetylation(cur, con):
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

def import_snp(cur, con):
    query = make_insert_query("snp", 6)
    for row in iter_gzip("snpArrayAffy6.txt.gz"):
        try:
            chrom = int(row[1].replace("chr", ""))
        except ValueError:
            continue

        rsid = row[8]
        ref, alt = row[7].split("/")
        pos = row[2]
        forward = 1 if row[6] == "+" else 0
        cur.execute(query, (rsid, chrom, pos, forward, ref, alt))

def get_snp(cur, con, spec):
    """Get the RSID for a SNP specified as chrN:POS"""
    chr, pos = spec.replace("chr", "").split(":")
    try:
        chr = int(chr)
    except ValueError:
        return None

    cur.execute(("SELECT rsid FROM snp WHERE chrom = ?"
                 "AND position = ?"), chr, pos)
    return cur.fetchone()[0]

def import_genotype(cur, con):
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
                rsid, ref, alt = row[:3]
                if not rsid.startswith("rs"):
                    try:
                        rsid = get_snp(cur, con, rsid)
                    except ValueError:
                        continue

                for i, value in enumerate(row[3:]):
                    if header[i] is None: continue
                    cur.execute(query, (header[i], rsid, value))
            con.commit()
            return # DEBUG
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

    logging.info("Importing phenotypes")
    import_phenotype(cur, con)

    logging.info("Importing Ensembl genes")
    import_ensgene(cur, con)
   
    logging.info("Importing CpGs")
    import_cpgs(cur, con)

    logging.info("Importing SNPs")
    import_snp(cur, con)

    logging.info("Importing methylation")
    import_methylation(cur, con)

    logging.info("Importing expression")
    import_expression(cur, con)

    logging.info("Importing acetylation")
    import_acetylation(cur, con)

    logging.info("Importing genotype")
    import_genotype(cur, con)

    con.close()

if __name__ == "__main__":
    main()
