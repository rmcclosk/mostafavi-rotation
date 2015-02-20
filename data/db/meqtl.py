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

    patient_query = "SELECT DISTINCT patient_id FROM methylation_chr22"
    cur.execute(patient_query)
    patients = set([x[0] for x in cur])
    
    for chr in range(1, 23):
        cpg_query = "SELECT DISTINCT position FROM methylation_chr%s"
        cur.execute(cpg_query, (chr,))
        cpgs = [x[0] for x in cur]

        methyl_query = "SELECT DISTINCT value, patient_id FROM methylation_chr%s WHERE position = %s ORDER BY patient_id"
    
        query = ("SELECT position, value, patient_id "
                 "FROM genotype_chr%s "
                 "WHERE position between %s and %s "
                 "ORDER BY position, patient_id ")
    
        writer = csv.writer(sys.stdout, delimiter="\t")
        for i, cpg_pos in enumerate(cpgs):
            cur.execute(methyl_query, (chr, cpg_pos))
            methylation = [x[0] for x in cur]

            sys.stderr.write("Chromosome {}, cpg {}/{}\n".format(chr, i, len(cpgs)))
            sys.stderr.flush()

            cur.execute(query, (chr, cpg_pos-thresh, cpg_pos+thresh))
            for snp_pos, g in itertools.groupby(cur, lambda x: x[0]):
                genotype = [x[1] for x in g if x[2] in patients]
                rho, p_value = scipy.stats.spearmanr(methylation, genotype)
                writer.writerow((chr, cpg_pos, snp_pos, rho, p_value))
    con.close()

if __name__ == "__main__":
    main()
