import gzip
import codecs
import csv
import sqlite3
import logging
import logging.config

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

def db_connect():
    logging.info("Connecting to database")
    con = sqlite3.connect("db.sqlite")
    cur = con.cursor()
    cur.execute("PRAGMA foreign_keys = ON")
    con.commit()
    return (cur, con)
