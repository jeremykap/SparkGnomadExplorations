
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
from pathlib import Path
import os
configfile: "chrom_list.yaml"
chroms_to_download = ["genome_exome","exome_all"]
chroms = {key:value for key,value in config["chroms"].items() if key in chroms_to_download }

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
    output: str(VARIANTS_DATA / "{chrom_id}.tsv")
    shell:
        """
        gunzip -c {input} | python scripts/melt_vcf.py  > {output}
        """
