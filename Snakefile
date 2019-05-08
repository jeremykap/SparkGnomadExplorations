
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
from pathlib import Path
import os
configfile: "chrom_list.yaml"
GENOMES_TO_DOWNLOAD = config["GENOMES_TO_DOWNLOAD"]
EXOMES_TO_DOWNLOAD = config["EXOMES_TO_DOWNLOAD"]

EXOME_DOWNLOAD = "https://storage.googleapis.com/gnomad-public/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.{chrom}.vcf.bgz"
GENOME_DOWNLOAD = "https://storage.googleapis.com/gnomad-public/release/2.1.1/vcf/genomes/gnomad.genomes.r2.1.1.sites.{chrom}.vcf.bgz"

chroms = {}
for chrom in config["GENOMES_TO_DOWNLOAD"]:
    chroms["genome_"+chrom] = GENOME_DOWNLOAD.format(chrom=chrom)

for chrom in config["EXOMES_TO_DOWNLOAD"]:
    chroms["exome_"+chrom] = GENOME_DOWNLOAD.format(chrom=chrom)

def link_chroms_to_link(wildcards):
    return chroms[wildcards.chrom_id]


INPUT_DATA = Path("data/input/")
VARIANTS_DATA = Path("data/variants/")
# First rule will drive the rest of the workflow
rule all:
    input:
        # expand generates the list of the final files we want
        expand(str(VARIANTS_DATA / "{chrom_id}.tsv")    , chrom_id=chroms.keys())

rule download:
    output:
        str(INPUT_DATA / "{chrom_id}.vcf.bgz")
    params:
        # using a function of wildcards in params
        link = link_chroms_to_link,
    shell:
        """
        wget {params.link} -O {output}
        """

rule melt_vcf:
    input: rules.download.output
    output: str(VARIANTS_DATA / "{chrom_id}.tsv.gz")
    shell:
        """
        gunzip -c {input} | python scripts/melt_vcf.py  | gzip -c >  {output}
        """
