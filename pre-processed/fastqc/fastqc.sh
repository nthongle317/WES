#!/bin/bash -e

# $1=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R1.fastq.gz
# $2=raw/LNCaP/TKCC20140123_LNCaP_P73_Test/TKCC20140123_LNCaP_P73_Test_R2.fastq.gz
# $3="/share/ClusterShare/biodata/contrib/phuluu/fastqc/Fastqc_contaminants.list.txt"
# $4="/share/ClusterShare/biodata/contrib/phuluu/fastqc/Fastqc_adapter_list.txt"
# $5=raw_trimmed/LNCaP/TKCC20140123_LNCaP_P73_Test/
LOGFILE="$output/fastqc.log"
con=/home/nhatthong/software/fastqc/0.11.9/Configuration/contaminant_list.txt
adapter=/home/nhatthong/software/fastqc/0.11.9/Configuration/adapter_list.txt
echo `date`" - QC FASTQ" > $LOGFILE
cmd="fastqc -t 20 -o $output --contaminants $con -a $adapter $input1 $input2 "
echo $cmd >> $LOGFILE; eval $cmd >> $LOGFILE 2>&1
echo `date`"- Finished QC FASTQ" >> $LOGFILE


