#!/usr/bin/env python3

import sys
import csv
import psycopg2
import scipy.stats
import itertools

def main():
    con = psycopg2.connect("dbname=cogdec user=rmcclosk")
    cur = con.cursor()
    thresh = 100000
    
    for chr in range(1, 23):
        if chr != 1: continue
        cpg_query = "SELECT DISTINCT position FROM methylation_chr%s"
        cur.execute(cpg_query, (chr,))
        cpgs = cur.fetchall()
    
        query = ("SELECT m.position, g.position, m.value, g.value "
                 "FROM methylation_chr%s m "
                 "JOIN genotype_chr%s g ON m.patient_id = g.patient_id "
                 "WHERE m.position = %s "
                 "AND g.position between %s and %s "
                 "ORDER BY m.position, g.position ")
    
        writer = csv.writer(sys.stdout, delimiter="\t")
        for i, row in enumerate(cpgs):
            cpg = row[0]
            sys.stderr.write("Chromosome {}, cpg {}/{}\n".format(chr, i, len(cpgs)))
            sys.stderr.flush()
            cur.execute(query, (chr, chr, cpg, cpg-thresh, cpg+thresh))
            for k, g in itertools.groupby(cur, lambda x: x[:2]):
                cpg_pos, snp_pos = k
                values = [x[2:] for x in g]
                methylation = [x[0] for x in values]
                genotype = [x[1] for x in values]
                rho, p_value = scipy.stats.spearmanr(methylation, genotype)
                writer.writerow((chr, cpg_pos, snp_pos, rho, p_value))
    con.close()

if __name__ == "__main__":
    main()
