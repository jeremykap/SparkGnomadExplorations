""" Melt a VCF file into a tab delimited set of calls, one per line
VCF files have all the calls from different samples on one line.  This
script reads vcf on stdin and writes all calls to stdout in tab delimited
format with one call in one sample per line.  This makes it easy to find
a given sample's genotype with, say, grep.
"""

import sys
import csv
import vcf

out = csv.writer(sys.stdout, delimiter='\t')
if len(sys.argv) > 1:
    inp = open(sys.argv[1])
else:
    inp = sys.stdin
reader = vcf.VCFReader(inp)
infos = list(reader.infos.keys())
header = ["CHROM","POS","ID","REF","ALT","QUAL","FILTER"] + ["info_"+info for info in infos]

out.writerow(header)

def flatten(x):
    if type(x) == type([]):
        x = ','.join(map(str, x))
    return x

for record in reader:
    row = [record.CHROM,record.POS,record.ID,record.REF,flatten(record.ALT),record.QUAL,flatten(record.FILTER)] + [flatten(record.INFO.get(info,None)) for info in infos]
    out.writerow(row)
