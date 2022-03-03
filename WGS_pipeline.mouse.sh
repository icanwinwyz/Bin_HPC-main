#!/bin/bash


##This pipeline is specific for mouse variant calling. For human genome, please use the latest WGS analysis pipeline at /common/genomics-core/apps/WGS_GATK4_pipeline/

# $1 is the sample name prefix;$2 and $3 are FASTQ files Read1 and Read2

module load R
module load samtools

PICARD="/common/genomics-core/apps"
EMAIL=Alex.Rajewski@cshs.org ### this can be changed

REF="/common/genomics-core/reference/BWA/GRCm38_WGS/GCA_000001635.5_GRCm38.p3_no_alt_analysis_set.fna"
DIC="/common/genomics-core/reference/BWA/GRCm38_WGS/GCA_000001635.5_GRCm38.p3_no_alt_analysis_set.dict"

#if [ "$4" = "Human" ]; then
#	REF="/common/genomics-core/reference/BWA/hg38_WES/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
#	DIC="/common/genomics-core/reference/BWA/hg38_WES/GCA_000001405.15_GRCh38_no_alt_analysis_set.dict"
#elif [ "$4" = "Mouse" ]; then
#	REF="/common/genomics-core/reference/BWA/GRCm38_WGS/GCA_000001635.5_GRCm38.p3_no_alt_analysis_set.fna"
#	DIC="/common/genomics-core/reference/BWA/GRCm38_WGS/GCA_000001635.5_GRCm38.p3_no_alt_analysis_set.dict"
#fi

#if [ ! -e $REF.fai ]; then
#  echo "##############Faidx is started"
#  /common/genomics-core/anaconda2/bin/samtools faidx $REF
#  echo "Subject: Faidx is done for REF" | sendmail -v $EMAIL
#else
#  echo "Faidx already present."
#fi

#if [ ! -e $REF.dict ]; then
#  echo "##############Create SequenceDictionary is started"
#  /common/genomics-core/anaconda2/bin/java -jar $PICARD/picard.jar CreateSequenceDictionary R=$REF O=$REF/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.dict
#  echo "Subject: Create SequenceDictionary is done for REF" | sendmail -v $EMAIL
#else
#  echo "SequenceDictionary already present."
#fi

if [ ! -e $1_aligned_reads.sam ]; then
  echo "##############Mapping is started"
  /common/genomics-core/anaconda2/bin/bwa mem -M -t 10 -R '@RG\tID:$1\tLB:$1\tPL:ILLUMINA\tPM:HISEQ\tSM:$1' $REF $2 $3 > $1_aligned_reads.sam
  echo "Subject: Mapping is done for $1" | sendmail -v $EMAIL
else
  echo "Mapping already completed."
fi

if [ ! -e $1_sorted_reads.bam ]; then
  echo "##############Sorting BAM is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/picard.jar SortSam INPUT=$1_aligned_reads.sam OUTPUT=$1_sorted_reads.bam SORT_ORDER=coordinate TMP_DIR=`pwd`/tmp
  echo "Subject: Sorting is done for $1" | sendmail -v $EMAIL
else
  echo "Sorting already done."
fi

if [ ! -e $1_alignment_metrics.txt ]; then
  echo "##############Collect Alignment & Insert Size Metrics is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/picard.jar CollectAlignmentSummaryMetrics R=$REF I=$1_sorted_reads.bam O=$1_alignment_metrics.txt
  echo "Subject: Collect Alignment & Insert Size Metrics is done for $1" | sendmail -v $EMAIL
else
  echo "Alignment and Insert Size Metrics already collected."
fi

if [ ! -e $1_insert_size_histogram.pdf ]; then
  echo "##############Collect Alignment & Insert Size Metrics is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/picard.jar CollectInsertSizeMetrics INPUT=$1_sorted_reads.bam OUTPUT=$1_insert_metrics.txt HISTOGRAM_FILE=$1_insert_size_histogram.pdf
  echo "Subject: Collect Alignment & Insert Size Metrics is done for $1" | sendmail -v $EMAIL
else 
  echo "Alignment and Insert Size PDF already created."
fi

if [ ! -e $1_depth_out.txt ]; then
  echo "##############Depth calculation is started"
  /common/genomics-core/anaconda2/bin/samtools depth -a $1_sorted_reads.bam > $1_depth_out.txt
  echo "Subject: Depth calculation is done for $1" | sendmail -v $EMAIL
else
  echo "Depth calculation already completed."
fi

if [ ! -e $1_dedup_reads.bam ] || [ ! -e $1_metrics.txt ]; then
  echo "##############Sorting BAM is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/picard.jar MarkDuplicates INPUT=$1_sorted_reads.bam OUTPUT=$1_dedup_reads.bam METRICS_FILE=$1_metrics.txt
  echo "Subject: Mark Duplicates is done for $1" | sendmail -v $EMAIL
else
  echo "Mark Duplicates already completed."
fi

if [ ! -e $1_dedup_reads.bai ]; then
  echo "##############BuildBamINdex is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/picard.jar BuildBamIndex INPUT=$1_dedup_reads.bam
  echo "Subject: BuildBamIndex is done for $1" | sendmail -v $EMAIL
else
  echo "BuildBamIndex already completed."
fi

if [ ! -e $1_realignment_targets.list ]; then
  echo "##############RealignerTargetCreator is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $REF -I $1_dedup_reads.bam -o $1_realignment_targets.list
  echo "Subject: RealignerTargetCreator is done for $1" | sendmail -v $EMAIL
else 
  echo "RealignerTargetCreator already completed."
fi

if [ ! -e $1_realigned_reads.bam ] || [ ! -e $1_realigned_reads.bai ]; then
  echo "##############Realign Indels is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T IndelRealigner -R $REF -I $1_dedup_reads.bam -targetIntervals $1_realignment_targets.list -o $1_realigned_reads.bam
  echo "Subject: Realign Indels is done for $1" | sendmail -v $EMAIL
else 
  echo "Realign Indels already completed."
fi

if [ ! -e $1_raw_variants.vcf ] || [ ! -e $1_raw_variants.vcf.idx ]; then
  echo "##############Call Variants is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T HaplotypeCaller -R $REF -I $1_realigned_reads.bam -o $1_raw_variants.vcf
  echo "Subject: Call Variants is done for $1" | sendmail -v $EMAIL
else
  echo "Call Variants already completed."
fi

if [ ! -e $1_raw_snps.vcf ] || [ ! -e $1_raw_snps.vcf.idx ]; then
  echo "##############Extract SNPs is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $1_raw_variants.vcf -selectType SNP -o $1_raw_snps.vcf
  echo "Subject: Extract SNPs is done for $1" | sendmail -v $EMAIL
else
  echo "Extract SNPs already completed."
fi

if [ ! -e $1_raw_indels.vcf ] || [ ! -e $1_raw_indels.vcf.idx ]; then
  echo "##############Extract Indels is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $1_raw_variants.vcf -selectType INDEL -o $1_raw_indels.vcf
  echo "Subject: Extract Indels is done for $1" | sendmail -v $EMAIL
else
  echo "Extract Indels already completed."
fi

if [ ! -e $1_filtered_snps.vcf ] || [ ! -e $1_filtered_snps.vcf.idx ]; then
  echo "##############Filter SNP is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T VariantFiltration -R $REF -V $1_raw_snps.vcf --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0" --filterName "basic_snp_filter" -o $1_filtered_snps.vcf
  echo "Subject: Filter SNPs is done for $1" | sendmail -v $EMAIL
else
  echo "Filter SNPs already completed."
fi

if [ ! -e $1_filtered_indels.vcf ] || [ ! -e $1_filtered_indels.vcf.idx ]; then
  echo "##############Filter indel is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T VariantFiltration -R $REF -V $1_raw_indels.vcf --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0" --filterName "basic_indel_filter" -o $1_filtered_indels.vcf
  echo "Subject: Filter Indels is done for $1" | sendmail -v $EMAIL
else
  echo "Filter Indels already completed."
fi

if [ ! -e $1_recal_data.table ] || [ -s $1_recal_data.table ]; then
  echo "##############Base Quality Score Recalibration is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T BaseRecalibrator -R $REF -I $1_realigned_reads.bam -knownSites $1_filtered_snps.vcf -knownSites $1_filtered_indels.vcf -o $1_recal_data.table
  echo "Subject: 	Base Quality Score Recalibration (BQSR) is done for $1" | sendmail -v $EMAIL
else
  echo " BQSR already completed."
fi

if [ ! -e $1_post_recal_data.table ] || [ -s $1_post_recal_data.table ]; then
  echo "##############Post Base Quality Score Recalibration is started"
  /common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T BaseRecalibrator -R $REF -I $1_realigned_reads.bam -knownSites $1_filtered_snps.vcf -knownSites $1_filtered_indels.vcf -BQSR $1_recal_data.table -o $1_post_recal_data.table
  echo "Subject: Post Base Quality Score Recalibration is done for $1" | sendmail -v $EMAIL
else
  echo "Post BQSR already completed."
fi

# I dont know how the outputs of these files looks yet, so I can't make error handling statments just yet.

echo "##############Analyze Covariates is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T AnalyzeCovariates -R $REF -before $1_recal_data.table -after $1_post_recal_data.table -plots $1_recalibration_plots.pdf
echo "Subject: Analyze Covariates is done for $1" | sendmail -v $EMAIL

echo "##############Apply BQSR is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T PrintReads -R $REF -I $1_realigned_reads.bam -BQSR $1_recal_data.table -o $1_recal_reads.bam
echo "Subject: Apply BQSR is done for $1" | sendmail -v $EMAIL

echo "##############Call Variants is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T HaplotypeCaller -R $REF -I $1_recal_reads.bam -o $1_raw_variants_recal.vcf
echo "Subject: Call Variants is done for $1" | sendmail -v $EMAIL

echo "##############Extract SNPs & Indels is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $1_raw_variants_recal.vcf -selectType SNP -o $1_raw_snps_recal.vcf
echo "Subject: Extract SNPs & Indels is done for $1" | sendmail -v $EMAIL

echo "##############Extract SNPs & Indels is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $1_raw_variants_recal.vcf -selectType INDEL -o $1_raw_indels_recal.vcf
echo "Subject: Extract SNPs & Indels is done for $1" | sendmail -v $EMAIL

echo "##############Filter SNP is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T VariantFiltration -R $REF -V $1_raw_snps_recal.vcf --filterExpression 'QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0' --filterName "basic_snp_filter" -o $1_filtered_snps_final.vcf
echo "Subject: 	Filter SNP is done for $1" | sendmail -v $EMAIL

echo "##############Filter Indels is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T VariantFiltration -R $REF -V $1_raw_indels_recal.vcf --filterExpression 'QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0' --filterName "basic_indel_filter" -o $1_filtered_indels_final.vcf
echo "Subject: 	Filter Indels is done for $1" | sendmail -v $EMAIL


echo "##############SNP anno is started"
/common/genomics-core/anaconda2/bin/java -jar /common/genomics-core/apps/snpEff_latest_core/snpEff/snpEff.jar -csvStats $1_snps.snpEff.summary.csv -v -s $1_snps.snpEff.summary.html GRCm38.86 $1_filtered_snps_final.vcf > $1_filtered_snps_final.ann.vcf
echo "Subject: 	SNP anno is done for $1" | sendmail -v $EMAIL


echo "##############indel anno is started"
/common/genomics-core/anaconda2/bin/java -jar /common/genomics-core/apps/snpEff_latest_core/snpEff/snpEff.jar -csvStats $1_indels.snpEff.summary.csv -v -s $1_indels.snpEff.summary.html GRCm38.86 $1_filtered_indels_final.vcf > $1_filtered_indels_final.ann.vcf
echo "Subject: 	Indel anno is done for $1" | sendmail -v $EMAIL

echo "##############GATK eval for SNP is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T VariantEval --eval $1_filtered_snps_final.vcf -R $REF -o $1.snps.eval
echo "Subject: GATK eval is done for $1" | sendmail -v $EMAIL


echo "##############GATK eval for Indels  is started"
/common/genomics-core/anaconda2/bin/java -jar $PICARD/GenomeAnalysisTK.jar -T VariantEval --eval $1_filtered_indels_final.vcf -R $REF -o $1.indels.eval
echo "Subject: GATK eval is done for $1" | sendmail -v $EMAIL

#after all samples processed, run multiqc to generate the QC report

#bedtools genomecov -bga -ibam recal_reads.bam > genomecov.bedgraph

