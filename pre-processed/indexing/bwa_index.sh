#!/bin/bash -e

# load module
module load /home/913/lpl913/modules/bwa/0.7.13
module load java/jdk1.8.0_60
module load samtools/1.2
module load /home/913/lpl913/modules/picard-tools/2.3.0
picard=$(which picard.jar)

### 1. Generate the BWA index
ref="/g/data3/yo4/annotations/bwa/hg38/hg38.fa"
bwa index -a bwtsw "$ref"
# where -a bwtsw specifies that we want to use the indexing algorithm that is capable of handling the whole human genome.
# Expected Result: This creates a collection of files used by BWA to perform the alignment.

### 2. Generate the fasta file index
samtools faidx "$ref"
# Expected Result. This creates a file called reference.fa.fai, with one record per line for each of the contigs in the FASTA reference file. Each record is composed of the contig name, size, location, basesPerLine and bytesPerLine.

### 3. Generate the sequence dictionary
java -jar "$picard" CreateSequenceDictionary REFERENCE="$ref" OUTPUT="${ref/.fa/.dict}"
# Note that this is the new syntax for use with the latest version of Picard. Older versions used a slightly different syntax because all the tools were in separate jars, so you'd call e.g. java -jar CreateSequenceDictionary.jar directly.

