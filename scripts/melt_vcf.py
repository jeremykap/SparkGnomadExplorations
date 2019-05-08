"""
Melt a VCF file - adapted from pyvcf
"""

import sys
import csv
from pysam import VariantFile


out = csv.writer(sys.stdout, delimiter='\t')
if len(sys.argv) > 1:
    inp = open(sys.argv[1])
else:
    inp = sys.stdin
input_vcf = VariantFile(inp)
infos = list(input_vcf.header.info.keys())
header = ["CHROM","POS","ID","REF","ALT","QUAL","FILTER"] + [info for info in infos]

out.writerow(header)

def flatten(x):
    if type(x) == type([]) or type(x) == type(()):
        x = ','.join(map(str, x))
    return x

for record in input_vcf:
    row = [record.chrom,record.pos,record.id,record.ref,flatten(record.alts),record.qual,flatten(record.filter.keys())] + [flatten(record.info.get(info,None)) for info in infos]
    out.writerow(row)
