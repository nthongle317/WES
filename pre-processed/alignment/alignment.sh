#!/bin/bash -e

# load module
module load /home/913/lpl913/modules/bwa/0.7.13
module load /home/913/lpl913/modules/samblaster/v.0.1.22
module load java/jdk1.8.0_60
module load samtools/1.2
module load /home/913/lpl913/modules/picard-tools/2.3.0
picard=$(which picard.jar)

# $1=raw/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R1.fastq.gz
# $2=raw/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/TKCC20140123_LNCaP_P73_Test_trimmed_R2.fastq.gz
# $3="/share/ClusterShare/biodata/contrib/phuluu/WGS/hg38/Homo_sapiens_assembly38_chromosome.fasta"
# $4=28
# $5="aligned/LNCaP/TKCC20140123_LNCaP_P73_Test_trimmed/"
input1=$1
input2=$2
GENOME=$3
ncores=$4
output=$5
mem='200G'
ID=$(basename ${input1/_R1.fastq.gz/})
PL='ILLUMINA'
PU='None'
LB='1'
SM=$(echo $input1| cut -d/ -f2)
# @RG\tID:Clean3_1_150913_FR07887779_fix_kmer_q15_TrimN_N0_L70\tPL:ILLUMINA\tPU:None\tLB:1\tSM:5287-1079625-B\tCN:hcpcg
RG="@RG\tID:$ID\tPL:$PL\tPU:None\tLB:$LB\tSM:$SM\tCN:epiClark"
LOGFILE="$output/${ID}.alignment.log"
### alignment 
# bwa mem -t 4 Homo_sapiens_assembly38_chromosome.fasta /project/RDS-SMS-PCaGenomes-RW/weejar/Clean3_1_150913_FR07887779_R1_fix_kmer_q15_TrimN_N0_L70.fastq.gz \
# /project/RDS-SMS-PCaGenomes-RW/weejar/Clean3_1_150913_FR07887779_R2_fix_kmer_q15_TrimN_N0_L70.fastq.gz -M \
# -R '@RG\tID:Clean3_1_150913_FR07887779_fix_kmer_q15_TrimN_N0_L70\tPL:ILLUMINA\tPU:None\tLB:1\tSM:5287-1079625-B\tCN:hcpcg' | ./samblaster -M --addMateTags | ./samtools view -h -S -b - \
# > Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70.bam
echo `date`" - Alignment" > $LOGFILE
cmd="bwa mem -t $ncores $GENOME $input1 $input2 -M -R '$RG'| samblaster -M --addMateTags| samtools view -h -S -b - > $output/${ID}.align.bam"
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished Alignment" >> $LOGFILE
echo ' ' >> $LOGFILE
### sort
# java -Xmx55g -jar picard.jar SortSam INPUT=Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70.bam \
# OUTPUT=Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort.bam SORT_ORDER=coordinate
echo `date`" - Sort BAM" >> $LOGFILE
cmd="java -Xmx${mem} -jar $picard SortSam I=$output/${ID}.align.bam O=$output/${ID}.sorted.bam SO=coordinate CREATE_INDEX=TRUE TMP_DIR=$output"
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished Sort" >> $LOGFILE
echo ' ' >> $LOGFILE
### MarkDup
# java -Xmx55g -jar picard.jar MarkDuplicates INPUT=Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort.bam \
# OUTPUT=Clean3_1_150913_FR07887779_hg38_fix_kmer_q15_TrimN_N0_L70_sort_dedup.bam METRICS_FILE=metrics_1_150913_FR07887779_hg38.txt
echo `date`" - Mark Duplicates BAM" >> $LOGFILE
cmd="java -Xmx${mem} -jar $picard MarkDuplicates I=$output/${ID}.sorted.bam O=$output/${ID}.bam M=$output/${ID}.metrics REMOVE_DUPLICATES=FALSE AS=TRUE CREATE_INDEX=TRUE TMP_DIR=$output"
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished Mark Duplicates" >> $LOGFILE
echo ' ' >> $LOGFILE
echo " - Clean up" >> $LOGFILE
cmd="rm $output/${ID}.align.bam $output/${ID}.sorted.bam $output/${ID}.sorted.bai"
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished Clean up" >> $LOGFILE


