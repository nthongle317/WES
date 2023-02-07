#!/bin/bash -e

# load module
module load java/jdk1.8.0_60
module load /home/913/lpl913/modules/GenomeAnalysisTK/3.7
GenomeAnalysisTK=$(which GenomeAnalysisTK.jar)

BAM=$1
GRP=$2
GENOME=$3
OUTPUT=$4
mem='120G'
ncores='16'
sample=$(basename $BAM| cut -d. -f1)

LOGFILE="${OUTPUT}/${sample}.PrintReads.log"
echo `date`" *** PrintReads" > $LOGFILE
# java -Xmx62g -jar GenomeAnalysisTK.jar -nct 4 -T PrintReads -R Homo_sapiens_assembly38_chromosome.fasta \
# -I Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort_dedup.realigned.bam \
# -BQSR recal_1_150913_FR07887779_hg38.grp 
# -o Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort_dedup.realigned.recalibrated.bam
cmd="""
java -Xmx$mem -jar $GenomeAnalysisTK -nct $ncores -T PrintReads -R $GENOME -I $BAM -BQSR $GRP -o $OUTPUT/${sample}.recalibrated.bam
"""
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished PrintReads" >> $LOGFILE

# maxvmem=61.876G for 7 threads on 1 CPU and 64G of mem
