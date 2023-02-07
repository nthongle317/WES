#!/bin/bash -e

# load module 
export PATH=$PATH:/home/nhatthong/software/qualimap/310820/

ncores=48
mem="80G"
# $1=aligned/PrEC/PrEC.bam
sample=$(basename $INPUT| cut -d. -f1)
# $2=aligned/PrEC

LOGFILE="${OUTPUT}/${sample}.qualimap.log"

echo `date`" *** Qualimap BAM QC" > $LOGFILE
echo """ mkdir -p $OUTPUT """ >> $LOGFILE 
mkdir -p $OUTPUT 2>> $LOGFILE

echo """qualimap bamqc -bam $INPUT -gd mm10 -outdir $OUTPUT -nt $ncores -nr 800000 --java-mem-size=$mem""" >> $LOGFILE
qualimap bamqc -bam $INPUT -gd HUMAN -outdir $OUTPUT -nt $ncores -nr 800000 --java-mem-size=$mem 2>> $LOGFILE

echo `date`" - Finished Qualimap" >> $LOGFILE


