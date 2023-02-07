p=/media/thong/Maico/cancer.WES

# copy data to project folder
id=$p/config/samples.tsv

### fastq
for sample in `awk 'NR>1 {print $2}' $id`; do
echo $sample
mkdir -p $p/raw/$sample
sleep 2
done

cd /media/thong/Maico/00.RawData
for sample in `awk 'NR>1 {print $2}' $id`; do
echo $sample
for lane in `awk -v sample=$sample '$2==sample {print $1}' $id | sort | uniq`; do
echo $lane
fq1=$(ls /media/thong/Maico/00.RawData | grep $lane | grep R1 )
fq2=$(ls /media/thong/Maico/00.RawData | grep $lane | grep R2 )
ls $fq1
ls $fq2
mkdir -p $p/raw/$sample/$lane
cp $fq1 $p/raw/$sample/$lane
cp $fq2 $p/raw/$sample/$lane
sleep 2
done
done

# bam 
for sample in `awk 'NR>1 {print $2}' $id`; do
echo $sample
mkdir -p $p/merged/$sample
sleep 2
done

cd /media/thong/Maico/bam
for sample in `awk 'NR>1 {print $2}' $id`; do
echo $sample
bam=/media/thong/Maico/bam/${sample}.mkdup.bam
ls $bam
ls ${bam}.bai
cp $bam $p/merged/$sample/
cp ${bam}.bai $p/merged/$sample/
sleep 2
done

# 1. fastqc
for sample in `awk 'NR>1 {print $2}' $id`; do
echo $sample
for lane in `awk -v sample=$sample '$2==sample {print $1}' $id | sort | uniq`; do
echo $lane
fq1=$p/raw/$sample/$lane/${lane}_R1_001.fastq.gz
fq2=$p/raw/$sample/$lane/${lane}_R2_001.fastq.gz
ls $fq1
ls $fq2

fastqc=/media/thong/Maico/cancer.WES/script/fastqc/fastqc.sh
input1="$fq1" input2="$fq2" output="$p/raw/$sample/$lane/" $fastqc
done
done

# alingment were done before in separated scripts

# 2. qualimap
qualimap=/media/thong/Maico/cancer.WES/script/qualimap/qualimap.sh
for sample in `awk 'NR>1 {print $2}' $id`; do
echo $sample
bam=$p/merged/$sample/$sample.mkdup.bam
ls $bam
output=$p/merged/$sample/QC
INPUT="$bam" OUTPUT="$output" $qualimap
sleep 10
done

# 3. qualimap dedup
qualimap_dedup=/media/thong/Maico/cancer.WES/script/qualimap/qualimap_dedup.sh
for sample in `awk 'NR>1 {print $2}' $id | head -1`; do
echo $sample
bam=$p/merged/$sample/$sample.mkdup.bam
ls $bam
output=$p/merged/$sample/QC_dedup
INPUT="$bam" OUTPUT="$output" $qualimap_dedup
sleep 10
done

### variant calling (MuTect2)
p=/media/thong/Maico/cancer.WES
export PATH=$PATH:/home/nhatthong/software/GATK3/3.8:/home/nhatthong/software/parallel/20210222/bin
GATK=$(which GenomeAnalysisTK.jar)
GENOME=$p/mouse_bundle/GRCm38.fa
dbSNP=$p/mouse_bundle/GRCm38.dbSNP.vcf.gz
output=$p/called

for sample in `awk 'NR>1{print $2}' $p/config/samples.tsv | grep -v 083N_S0_L001`; do
echo $sample
mkdir dir -p $output/$sample/
sleep 2
done

for sample in `awk 'NR>1{print $2}' $p/config/samples.tsv | grep -v 083N_S0_L001`; do
nbam=$p/merged/$sample/${sample}.mkdup.bam
ls $nbam
echo gatk Mutect2 -R $GENOME -I $nbam -O $output/$sample/$sample.vcf.gz --native-pair-hmm-threads 52
sleep 15
done

### failed samples (re-run)
for sample in `awk 'NR>1{print $2}' $p/config/samples.tsv | grep "128T\|157N\|168T"`; do
nbam=$p/merged/$sample/${sample}.mkdup.bam
ls $nbam
echo gatk Mutect2 -R $GENOME -I $nbam -O $output/$sample/$sample.vcf.gz --native-pair-hmm-threads 24
gatk Mutect2 -R $GENOME -I $nbam -O $output/$sample/$sample.vcf.gz --native-pair-hmm-threads 24 &>> $output/$sample/${sample}_mutect2.log

sleep 15
done

### FilterMutectCalls 
for sample in `awk 'NR>1{print $2}' $p/config/samples.tsv`; do
vcf=$p/called/$sample/$sample.vcf.gz
ls $vcf
gatk FilterMutectCalls --java-options "-Xmx20g" -V $vcf -O ${vcf/.vcf.gz/.filter.vcf.gz} -R $GENOME
sleep 2
done

for sample in `awk 'NR>1{print $2}' $p/config/samples.tsv | grep -v "083N"`; do
vcf=$p/called/$sample/$sample.vcf.gz
ls $vcf
gatk FilterMutectCalls --java-options "-Xmx20g" -V $vcf -O ${vcf/.vcf.gz/.filter.vcf.gz} -R $GENOME
sleep 2
done

### Fiter DP
for sample in `awk 'NR>1{print $2}' $p/config/samples.tsv`; do
vcf=$p/called/$sample/$sample.filter.vcf.gz
ls $vcf
bcftools view --threads 16 -i 'MIN(FMT/DP)>20 && FILTER=="PASS"' $vcf -o ${vcf/.filter.vcf.gz/.Mutect2_DP20_filtered.vcf}
sleep 2
done

### snpEff annotation
export PATH=$PATH:/home/nhatthong/software/snpEff/5.0e
snpEff=$(which snpEff.jar)

sample="083N_S0_L001"
vcf=$p/called/$sample/$sample.Mutect2_DP20_filtered.vcf
ls $vcf
java -Xmx8g -jar $snpEff -v -stats $p/snpEff_annotation/$sample/$sample.annotation.html mm10  $vcf > $p/snpEff_annotation/$sample/$sample.annotation.vcf

for sample in `awk 'NR>1{print $2}' $p/config/samples.tsv`; do
echo $sample
mkdir -p $p/snpEff_annotation/$sample
vcf=$p/called/$sample/$sample.Mutect2_DP20_filtered.vcf
ls $vcf
java -Xmx8g -jar $snpEff -v -stats $p/snpEff_annotation/$sample/$sample.annotation.html mm10  $vcf > $p/snpEff_annotation/$sample/$sample.annotation.vcf
sleep 2
done

### Variant calling (Germline mutation)
p=/media/thong/Maico/cancer.WES
export PATH=$PATH:/home/nhatthong/software/GATK3/3.7
GENOME=$p/mouse_bundle/GRCm38.fa
dbSNP=$p/mouse_bundle/GRCm38.dbSNP.vcf.gz
GATK=$(which GenomeAnalysisTK.jar)
mem=25G
ncores=16

for sample in 083N_S0_L001 083T_S0_L001 128N_S0_L001 128T_S0_L001; do
bam=$p/merged/$sample/${sample}.mkdup.bam
java -Xmx$mem -jar $GATK -T HaplotypeCaller -R $GENOME -I $bam -o $p/called/$sample/${sample}.raw.g.vcf.gz -nct $ncores --dbsnp $dbSNP -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 -pairHMM VECTOR_LOGLESS_CACHING &>> $p/called/$sample/${sample}.HC.log
sleep 2
done

for sample in 128T_S0_L001; do
bam=$p/merged/$sample/${sample}.mkdup.bam
java -Xmx$mem -jar $GATK -T HaplotypeCaller -R $GENOME -I $bam -o $p/called/$sample/${sample}.raw.g.vcf.gz -nct $ncores --dbsnp $dbSNP -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 -pairHMM VECTOR_LOGLESS_CACHING &>> $p/called/$sample/${sample}.HC.log
sleep 2
done

for sample in 135N_S0_L001 135T_S0_L001 147N_S0_L001 147T_S0_L001; do
bam=$p/merged/$sample/${sample}.mkdup.bam
ls $bam 
java -Xmx$mem -jar $GATK -T HaplotypeCaller -R $GENOME -I $bam -o $p/called/$sample/${sample}.raw.g.vcf.gz -nct $ncores --dbsnp $dbSNP -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 -pairHMM VECTOR_LOGLESS_CACHING &>> $p/called/$sample/${sample}.HC.log
sleep 2
done

for sample in 157N_S0_L001 157T_S0_L001 168N_S0_L001 168T_S0_L001; do
bam=$p/merged/$sample/${sample}.mkdup.bam
ls $bam
java -Xmx$mem -jar $GATK -T HaplotypeCaller -R $GENOME -I $bam -o $p/called/$sample/${sample}.raw.g.vcf.gz -nct $ncores --dbsnp $dbSNP -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 -pairHMM VECTOR_LOGLESS_CACHING &>> $p/called/$sample/${sample}.HC.log
sleep 2
done

### combine variant
# WT group
export PATH=$PATH:/home/nhatthong/software/GATK3/3.8/
GATK=$(which GenomeAnalysisTK.jar)

for sample in `ls | grep "083\|135\|147"`; do
vcf=$sample/${sample}.vcf.gz
echo -e "-V $p/called/$vcf"
done
# normal
java -jar $GATK -T CombineVariants -nt 3 \
-R $GENOME \
-V /media/thong/Maico/cancer.WES/called/083N_S0_L001/083N_S0_L001.vcf.gz \
-V /media/thong/Maico/cancer.WES/called/135N_S0_L001/135N_S0_L001.vcf.gz \
-V /media/thong/Maico/cancer.WES/called/147N_S0_L001/147N_S0_L001.vcf.gz \
-o $p/bigTable/Combined/WT_Normal.vcf.gz
# tumor
java -jar $GATK -T CombineVariants -nt 3 \
-R $GENOME \
-V /media/thong/Maico/cancer.WES/called/083T_S0_L001/083T_S0_L001.vcf.gz \
-V /media/thong/Maico/cancer.WES/called/135T_S0_L001/135T_S0_L001.vcf.gz \
-V /media/thong/Maico/cancer.WES/called/147T_S0_L001/147T_S0_L001.vcf.gz \
-o $p/bigTable/Combined/WT_Tumor.vcf.gz

### ANNOVAR
path=/media/thong/Maico/cancer.WES/ANNOVAR
# convert vcf to avinput
vcf2avinput=/home/nhatthong/software/ANNOVAR/2019Oct24/convert2annovar.pl
for sample in `ls $p/called | grep "083\|135\|147"`; do
vcf=$p/called/$sample/${sample}.vcf.gz
ls $vcf
mkdir -p $path/$sample
perl $vcf2avinput -format vcf4 <(zcat $vcf) > $path/$sample/$sample.avinput
done

# gene-based annotation
annotate_variation=/home/thong/Documents/Tools/ANNOVAR/annovar/annotate_variation.pl
retrieve_seq=/home/thong/Documents/Tools/ANNOVAR/annovar/retrieve_seq_from_fasta.pl
mm10db=~/Documents/Tools/ANNOVAR/annovar/mm10db

perl $annotate_variation -downdb -buildver mm10 gene $mm10db
perl $annotate_variation --buildver mm10 --downdb seq $mm10db/mm10_seq
perl $retrieve_seq $mm10db/mm10_refGene.txt -seqdir $mm10db/mm10_seq -format refGene -outfile $mm10db/mm10_refGeneMrna.fa

annotate_variation=/home/nhatthong/software/ANNOVAR/2019Oct24/annotate_variation.pl
mm10db=/home/nhatthong/software/ANNOVAR/2019Oct24/mm10db

for sample in `ls $path`; do
echo $sample
echo "perl $annotate_variation -out $path/$sample/$sample -build mm10 $path/$sample/$sample.avinput $mm10db" > $path/$sample/command.line.sh
perl $annotate_variation -out $path/$sample/$sample -build mm10 $path/$sample/$sample.avinput $mm10db
done

