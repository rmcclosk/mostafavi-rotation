#!/usr/bin/env python3

# we only import genotype values for positions within 100kb of a TSS

from tempfile import NamedTemporaryFile as tf
import subprocess
import sys
import csv
import psycopg2
import glob

# http://stackoverflow.com/questions/5679638/merging-a-list-of-time-range-tuples-that-have-overlapping-time-ranges
def merge(intervals):
    saved = list(intervals[0])
    for st, en in sorted([sorted(t) for t in intervals]):
        if st <= saved[1]:
            saved[1] = max(saved[1], en)
        else:
            yield tuple(saved)
            saved[0] = st
            saved[1] = en
    yield tuple(saved)

def liftover(chr, positions):
    """liftOver a set of positions"""
    with tf("w") as f, tf("w+") as g, tf("w+") as h:
        for pos in positions:
            f.write("chr{}\t{}\t{}\n".format(chr, pos, pos+1))
        f.flush()
        f.seek(0)
        subprocess.call(["liftOver", f.name, "hg19ToHg38.over.chain.gz", g.name, h.name],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        g.seek(0)
        return list(map(int, [line.split("\t")[1] for line in g]))

def resolve_loci(chr, loci, bounds, cur):
    """Get coordinates for each RSID or chromosome locus"""
    sorted_loci = sorted(loci)

    coords = list(map(int, [l.split(":")[1] for l in sorted_loci if not l.startswith("rs")]))
    positions = liftover(chr, coords)
    rsid_query = "SELECT position FROM snp WHERE rsid = %s"
    for l in [l for l in sorted_loci if l.startswith("rs")]:
        cur.execute(rsid_query, (l.replace("rs", ""),))
        try:
            positions.append(cur.fetchone()[0])
        except TypeError:
            positions.append(None)
    positions = zip(sorted_loci, positions)

    # filter out positions not near a TSS
    d = {}
    cur_interval = next(bounds)
    locus, p = next(positions)
    while True:
        if p is None or p <= cur_interval[1]: 
            d[locus] = None if p is None or p < cur_interval[0] else p
            try:
                locus, p = next(positions)
            except StopIteration:
                break
        else:
            try:
                cur_interval = next(bounds)
            except StopIteration:
                for locus, p in positions:
                    d[locus] = None
                break

    return [d[x] for x in loci]

def main():
    con = psycopg2.connect("dbname=cogdec user=rmcclosk")
    cur = con.cursor()
    writer = csv.writer(sys.stdout, delimiter="\t")
    thresh = 100000

    tss_query = ("SELECT DISTINCT tss FROM tss t "
                 "JOIN expression e ON e.gene_id = t.gene_id "
                 "JOIN gene g ON g.id = t.gene_id "
                 "WHERE g.chrom = %s")
    patient_query = "SELECT id FROM patient WHERE alt_id = %s"
    for chr in range(1, 23):
        # find all transcription start sites for genes in the expression assay
        cur.execute(tss_query, (chr,))
        tss = sorted([row[0] for row in cur.fetchall()])

        # pull RSIDs and old co-ordinates out of assay files
        for dosage_file in glob.glob("*/chr{}/*.trans.txt".format(chr)):
            bounds = merge([(t-thresh, t+thresh) for t in tss])
            with open(dosage_file) as f:
                reader = csv.reader(f, delimiter=" ")
                header = next(reader)
                header = resolve_loci(chr, header, bounds, cur)
                for row in reader:
                    cur.execute(patient_query, (row.pop(0),))
                    patient_id = cur.fetchone()[0]
                    for i, value in enumerate(row):
                        if header[i] is not None:
                            writer.writerow((patient_id, chr, header[i], value))
    con.close()

if __name__ == "__main__":
    main()
