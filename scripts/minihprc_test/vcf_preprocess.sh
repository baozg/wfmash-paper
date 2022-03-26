#!/bin/bash

# From https://github.com/wwliao/pangenome-utils/blob/main/preprocess_vcf.sh
# Usage: preprocess_vcf.sh <VCF file> <sample name> <max variant size>

VCF=$1
FNAME=$(basename $VCF)
PREFIX=$(dirname $VCF)/"${FNAME%.vcf.gz}"
SAMPLE=$2
CHROMS="chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY"
MAXSIZE=$3
REF="/lizardfs/erikg/HPRC/year1v2genbank/evaluation/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
MEM="10G"

bcftools=/gnu/store/4gjki13dw2cr6chc3ac3jwhkqj0q9vwz-bcftools-1.14/bin/bcftools
$bcftools view -a -s ${SAMPLE} -Ou ${VCF} \
    | $bcftools norm -f ${REF} -c s -m - -Ou \
    | $bcftools view -e 'GT="ref" | GT~"\."' -f 'PASS,.' -Ou \
    | $bcftools sort -m ${MEM} -T bcftools-sort.XXXXXX -Ou \
    | $bcftools norm -d exact -Oz -o ${PREFIX}.norm.vcf.gz \
    && $bcftools index -t ${PREFIX}.norm.vcf.gz \
    && $bcftools view -e "STRLEN(REF)>${MAXSIZE} | STRLEN(ALT)>${MAXSIZE}" \
                 -r ${CHROMS} -Oz -o ${PREFIX}.max${MAXSIZE}.chr1-22.vcf.gz \
                 ${PREFIX}.norm.vcf.gz \
    && $bcftools index -t ${PREFIX}.max${MAXSIZE}.chr1-22.vcf.gz \
    && rm ${PREFIX}.norm.vcf.gz*
