#!/usr/bin/env python3

# Make a dot graph from an SQLite schema.

import sys
import re

create_ptn = re.compile("create\s+table\s+(?P<name>\S+)\s+[(]", flags=re.I)
field_ptn = re.compile("\s*(?P<field>\S+)\s+(real|text|int|blob)", flags=re.I)
fk_ptn = re.compile("references\s+(?P<table>\S+)[(](?P<field>\S+)[)]",
                    flags=re.I)
end_ptn = re.compile("[)];")

print("digraph db {")
print('\tgraph [rankdir="LR"];')
print("\tsplines=true;")
print("\toverlap=portho;")
print("\tmodel=subset;")
edges = []
for line in sys.stdin:
    match = create_ptn.search(line)
    if match:
        table = match.group("name")
        fields = []
        continue

    match = field_ptn.search(line)
    if match:
        field = match.group("field")
        fields.append(field)
        match = fk_ptn.search(line)
        if match:
            edges.append((table, field, match.group("table"),
                          match.group("field")))
        continue

    if end_ptn.search(line):
        label = ['<<TABLE BORDER="1" CELLBORDER="1" CELLSPACING="0">']
        label.append('<TR><TD BGCOLOR="lightsteelblue" PORT="table"><B>{}</B></TD></TR>'.format(table))
        for f in fields:
            label.append('<TR><TD PORT="{}">{}</TD></TR>'.format(f, f))
        label.append('</TABLE>>')
        label = "".join(label)
        print('\t"{}" [label={}, shape="none"];'.format(table, label))

for e in edges:
    print('\t"{}":{} -> "{}":{};'.format(*e))

print("}")
