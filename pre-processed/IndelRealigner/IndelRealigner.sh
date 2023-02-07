#!/bin/bash -e

# load module
module load java/jdk1.8.0_60
module load /home/913/lpl913/modules/GenomeAnalysisTK/3.7
GenomeAnalysisTK=$(which GenomeAnalysisTK.jar)

BAM=$1
INTERVALS=$2
GENOME=$3
KNOWN1=$4
KNOWN2=$5
OUTPUT=$6
mem='120G'
ncores='16'
sample=$(basename $BAM| cut -d. -f1)

LOGFILE="${OUTPUT}/${sample}.IndelRealigner.log"
echo `date`" *** IndelRealigner" > $LOGFILE
# java -Xmx62g -jar GenomeAnalysisTK.jar -T IndelRealigner -R Homo_sapiens_assembly38_chromosome.fasta -I Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort_dedup.bam \
# -targetIntervals realign_1_150913_FR07887779_hg38.intervals -o Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort_dedup.realigned.bam --filter_bases_not_stored \
# -known Homo_sapiens_assembly38.known_indels.vcf -known Mills_and_1000G_gold_standard.indels.hg38.vcf
cmd="""
java -Xmx$mem -jar $GenomeAnalysisTK -T IndelRealigner -R $GENOME -I $BAM -targetIntervals $INTERVALS -o $OUTPUT/${sample}.realigned.bam --filter_bases_not_stored -known $KNOWN1 -known $KNOWN2
"""
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished IndelRealigner" >> $LOGFILE

# maxvmem=61.876G for 7 threads on 1 CPU and 64G of mem
