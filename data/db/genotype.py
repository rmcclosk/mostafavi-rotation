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
        for i, pos in enumerate(positions):
            f.write("chr{}\t{}\t{}\t{}\n".format(chr, pos, pos+1, i))
        f.flush()
        f.seek(0)
        subprocess.call(["liftOver", f.name, "hg19ToHg38.over.chain.gz", g.name, h.name],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        g.seek(0)

        res = []
        i = 0
        for line in g:
            line = line.split("\t")
            while i < int(line[-1]):
                res.append(None)
                i += 1
            res.append(int(line[1]))
        return res

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
            d[locus] = None if (p is None or p < cur_interval[0]) else p
            try:
                locus, p = next(positions)
            except StopIteration:
                break
        else:
            try:
                cur_interval = next(bounds)
            except StopIteration:
                d[locus] = None
                for locus, p in positions:
                    d[locus] = None
                break

    return [d[x] for x in loci]

def main():
    chr = int(sys.argv[1])
    con = psycopg2.connect("dbname=cogdec user=rmcclosk")
    cur = con.cursor()
    thresh = 100000

    cur.execute("SELECT distinct p.alt_id, p.id FROM patient p;")
    patients = dict(cur.fetchall())

    # get the non-imputed SNPs
    with open("input/chr{}.snps".format(chr)) as f:
        snps = [row[1] for row in csv.reader(f, delimiter="\t")]
        snps = dict.fromkeys(snps)

    for snp in snps:
        rsid = snp.replace("rs", "")
        cur.execute("SELECT position FROM snp WHERE rsid = %s", (rsid,))
        try:
            snps[snp] = cur.fetchone()[0]
        except TypeError:
            continue

    # load data
    writer = csv.writer(sys.stdout, delimiter="\t")
    for dosage_file in glob.glob("transposed_1kG/chr{}/chr{}.*.trans.txt".format(chr, chr)):
        sys.stderr.write("Loading file {}\n".format(dosage_file))
        with open(dosage_file) as f:
            reader = csv.reader(f, delimiter=" ")
            header = next(reader)
            rsid = header[:]
            for i, h in enumerate(header):
                try:
                    header[i] = snps[h]
                except KeyError:
                    header[i] = None

            for row in reader:
                try:
                    patient_id = patients[row.pop(0)]
                except KeyError:
                    continue
                for i, value in enumerate(row):
                    if header[i] is not None:
                        writer.writerow((patient_id, chr, header[i], round(float(value))))
    con.close()

if __name__ == "__main__":
    main()
