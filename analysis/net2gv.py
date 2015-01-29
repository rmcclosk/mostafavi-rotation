#!/usr/bin/env python3

import sys
import re

print("digraph g {")
for line in sys.stdin:
    if "continuous node" in line or "discrete node" in line:
        print("\t{};".format(line.split()[2]))
    elif "potential" in line:
        line = re.sub("\W", " ", line).split()
        target = line[1]
        for source in line[2:]:
            if source == ")": break
            print("\t{} -> {};".format(source, target))
print("}")
