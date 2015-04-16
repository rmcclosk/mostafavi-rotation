#!/usr/bin/env python3

import sys

try:
    g1, g2 = sys.argv[1:]
except IndexError:
    sys.exit("Usage: ./compare_graphs.py [graph1] [graph2]")

print("digraph g {")
edges = [set([]), set([])]
for i, g in enumerate([g1, g2]):
    with open (g) as f:
        for line in f:
            if "->" in line:
                line = line.replace(";", "").split()
                edges[i].add((line[0], line[2]))

for source, target in edges[0] & edges[1]:
    print('\t{} -> {} [color="black"]'.format(source, target))
for source, target in edges[0] - edges[1]:
    print('\t{} -> {} [color="red"]'.format(source, target))
for source, target in edges[1] - edges[0]:
    print('\t{} -> {} [color="blue"]'.format(source, target))
    
print("}")
