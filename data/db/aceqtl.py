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

    patient_query = "SELECT DISTINCT patient_id FROM acetylation_chr22"
    cur.execute(patient_query)
    patients = set([x[0] for x in cur])
    
    for chr in range(1, 23):
        peak_query = "SELECT DISTINCT peak_start, peak_end FROM acetylation_chr%s"
        cur.execute(peak_query, (chr,))
        peaks = cur.fetchall()

        acetyl_query = "SELECT DISTINCT value, patient_id FROM acetylation_chr%s WHERE peak_start = %s ORDER BY patient_id"
    
        query = ("SELECT position, value, patient_id "
                 "FROM genotype_chr%s "
                 "WHERE position between %s and %s "
                 "ORDER BY position, patient_id ")
    
        writer = csv.writer(sys.stdout, delimiter="\t")
        for i, row in enumerate(peaks):
            peak_start, peak_end = row
            cur.execute(acetyl_query, (chr, peak_start))
            acetylation = [x[0] for x in cur]

            peak_mid = int((peak_end + peak_start)/2)
            sys.stderr.write("Chromosome {}, peak {}/{}\n".format(chr, i, len(peaks)))
            sys.stderr.flush()

            cur.execute(query, (chr, peak_mid-thresh, peak_mid+thresh))
            for snp_pos, g in itertools.groupby(cur, lambda x: x[0]):

                genotype = [x[1] for x in g if x[2] in patients]
                rho, p_value = scipy.stats.spearmanr(acetylation, genotype)
                writer.writerow((chr, peak_mid, snp_pos, rho, p_value))
    con.close()

if __name__ == "__main__":
    main()
