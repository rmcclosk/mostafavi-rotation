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
        gene_query = "SELECT DISTINCT gene_id, position FROM expression_chr%s"
        cur.execute(gene_query, (chr,))
        genes = cur.fetchall()
    
        query = ("SELECT e.gene_id, g.position, e.value, g.value "
                 "FROM expression_chr%s e "
                 "JOIN genotype_chr%s g ON e.patient_id = g.patient_id "
                 "WHERE e.position = %s "
                 "AND g.position between %s and %s "
                 "ORDER BY e.gene_id, g.position ")
    
        writer = csv.writer(sys.stdout, delimiter="\t")
        for i, row in enumerate(genes):
            gene, tss = row
            sys.stderr.write("Chromosome {}, gene {}/{}\n".format(chr, i, len(genes)))
            cur.execute(query, (chr, chr, tss, tss-thresh, tss+thresh))
            for k, g in itertools.groupby(cur, lambda x: x[:2]):
                gene_id, position = k
                values = [x[2:] for x in g]
                expression = [x[0] for x in values]
                genotype = [x[1] for x in values]
                rho, p_value = scipy.stats.spearmanr(expression, genotype)
                writer.writerow((chr, gene_id, position, rho, p_value))
    con.close()

if __name__ == "__main__":
    main()