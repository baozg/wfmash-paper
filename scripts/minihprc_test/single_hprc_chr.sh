#!/bin/bash

FASTA=$1
PREFIX=$2
PATH_WFMASH=$3
OUTPUT_DIR=$4
PATH_EASY_REGIONS=$5
PATH_HARD_REGIONS=$6
PATH_FASTA_PAF_TO_VCF=$7
DIR_TRUTH_VCF=$8
PATH_VCF_PREPROCESS_SH=$9
PATH_VCF_EVALUATION_SH=${10}

cd /scratch
bash ${PATH_FASTA_PAF_TO_VCF} $FASTA 100k 300k 98 14 grch38 '#' ${PATH_WFMASH} ${PREFIX};

FASTA_PREFIX=$(basename $FASTA .fa.gz)
VCF=$PREFIX.$FASTA_PREFIX.s100k.l300k.p98.n14.k16.paf.k0.B10M.gfa.vcf.gz

for SAMPLE in HG00438 HG00621 HG00673 HG00733 HG00735 HG00741; do
  TRUTH_VCF=${DIR_TRUTH_VCF}/$SAMPLE.GRCh38_no_alt.deepvariant.vcf.gz

  bash ${PATH_VCF_EVALUATION_SH} $SAMPLE $TRUTH_VCF $VCF ${PATH_EASY_REGIONS} ${PATH_HARD_REGIONS} ${OUTPUT_DIR}/$SAMPLE ${PATH_VCF_PREPROCESS_SH}
done

mv ${PREFIX} ${OUTPUT_DIR}