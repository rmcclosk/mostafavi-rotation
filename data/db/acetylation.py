#!/usr/bin/env python3

import psycopg2
import sys
import csv
from _shared import iter_gzip

def main():
    con = psycopg2.connect("dbname=cogdec user=rmcclosk")
    cur = con.cursor()

    peaks = {}
    r = iter_gzip("peakInfo.csv.gz", skip=1)
    for row in r:
        try:
            peaks[row[0]] = (int(row[3]), row[1], row[2])
        except ValueError:
            continue
    
    r = iter_gzip("chipSeqResiduals.csv.gz")
    header = next(r)
    patient_query = "SELECT * FROM patient WHERE id = %s"
    for i, id in enumerate(header):
        cur.execute(patient_query, (id,))
        if cur.fetchone() is None:
            header[i] = None

    writer = csv.writer(sys.stdout, delimiter="\t")
    for i, row in enumerate(r, start=1):
        if i % 100 == 0:
            sys.stderr.write("Done {} peaks\n".format(i))
            sys.stderr.flush()
        try:
            chr, start, end = peaks[row.pop(0)]
        except KeyError:
            continue
        row = list(row)
        if "NA" in row: 
            continue
        for j, value in enumerate(row):
            if header[j] is not None:
                writer.writerow((header[j], chr, start, end, value))

    con.close()

if __name__ == "__main__":
    main()
