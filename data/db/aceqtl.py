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
        peak_query = "SELECT DISTINCT peak_start, peak_end FROM acetylation_chr%s"
        cur.execute(peak_query, (chr,))
        peaks = cur.fetchall()
    
        query = ("SELECT (a.peak_start+a.peak_end)/2 peak_centre, g.position, a.value, g.value "
                 "FROM acetylation_chr%s a "
                 "JOIN genotype_chr%s g ON a.patient_id = g.patient_id "
                 "WHERE a.peak_start = %s "
                 "AND g.position between %s and %s "
                 "ORDER BY (a.peak_start+a.peak_end)/2, g.position ")
    
        writer = csv.writer(sys.stdout, delimiter="\t")
        for i, row in enumerate(peaks):
            peak_start, peak_end = row
            peak_mid = int((peak_end + peak_start)/2)
            sys.stderr.write("Chromosome {}, peak {}/{}\n".format(chr, i, len(peaks)))
            sys.stderr.flush()
            cur.execute(query, (chr, chr, peak_start, peak_mid-thresh, peak_mid+thresh))
            for k, g in itertools.groupby(cur, lambda x: x[:2]):
                peak_pos, snp_pos = k
                values = [x[2:] for x in g]
                acetylation = [x[0] for x in values]
                genotype = [x[1] for x in values]
                rho, p_value = scipy.stats.spearmanr(acetylation, genotype)
                writer.writerow((chr, peak_pos, snp_pos, rho, p_value))
    con.close()

if __name__ == "__main__":
    main()
