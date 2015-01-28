#!/usr/bin/env python3

import sys
import csv

def main():
    writer = csv.writer(sys.stdout, delimiter="\t")
    with open("allrevcoded.csv") as f:
        reader = csv.reader(f)
        for row in reader:
            writer.writerow(row)

if __name__ == "__main__":
    main()
