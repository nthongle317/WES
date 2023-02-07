#!/bin/bash -e

# load module
module load java/jdk1.8.0_60
module load /home/913/lpl913/modules/GenomeAnalysisTK/3.7
GenomeAnalysisTK=$(which GenomeAnalysisTK.jar)

BAM=$1
GENOME=$2
KNOWN1=$3
KNOWN2=$4
KNOWN3=$5
OUTPUT=$6
mem='120G'
ncores='16'
sample=$(basename $BAM| cut -d. -f1)

LOGFILE="${OUTPUT}/${sample}.BaseRecalibrator.log"
echo `date`" *** BaseRecalibrator" > $LOGFILE
# java -Xmx62g -jar GenomeAnalysisTK.jar -nct 4 -T BaseRecalibrator -R Homo_sapiens_assembly38_chromosome.fasta \
# -I Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort_dedup.realigned.bam \
# -o recal_1_150913_FR07887779_hg38.grp \
# -knownSites Homo_sapiens_assembly38.dbsnp138.vcf 
# -knownSites Mills_and_1000G_gold_standard.indels.hg38.vcf \
# -knownSites Homo_sapiens_assembly38.known_indels.vcf \
# --bqsrBAQGapOpenPenalty 30
cmd="""
java -Xmx$mem -jar $GenomeAnalysisTK -nct $ncores -T BaseRecalibrator 
-R $GENOME 
-I $BAM 
-o $OUTPUT/${sample}.grp 
-knownSites $KNOWN1 
-knownSites $KNOWN2 
-knownSites $KNOWN3 
--bqsrBAQGapOpenPenalty 30
"""
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished BaseRecalibrator" >> $LOGFILE

# maxvmem=61.876G for 7 threads on 1 CPU and 64G of mem
