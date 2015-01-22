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
        label = ["<table> {}".format(table)]
        for i, f in enumerate(fields, start=1):
            label.append("<{}> {}".format(f, f))
        label = " | ".join(label)
        print('\t"{}" [label="{}", shape="record"];'.format(table, label))

for e in edges:
    print('\t"{}":{} -> "{}":{};'.format(*e))

print("}")
