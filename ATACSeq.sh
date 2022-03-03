export PATH=/stf/home/cluster/GenomicsCore/bin:$PATH
export PATH=/stf/home/cluster/GenomicsCore/apps/HOMER/bin:$PATH

export PYTHONPATH=/stf/home/cluster/GenomicsCore/lib/Python-2.7.3/bin/:$PYTHONPATH
export LD_LIBRARY_PATH=/stf/home/cluster/GenomicsCore/lib/Python-2.7.3/lib:$LD_LIBRARY_PATH



#/stf/home/cluster/GenomicsCore/bin/bowtie2  -p 12 -x /stf/home/cluster/GenomicsCore/NGS/refGenomes/Bowtie/mm10/mm10 --very-sensitive  -X 2000 --no-mixed --no-discordant -1 $1_R1_001.fastq.gz -2 $1_R2_001.fastq.gz  | /stf/home/cluster/GenomicsCore/bin/samtools view -b -S - | /stf/home/cluster/GenomicsCore/bin/samtools sort - $1


#/stf/home/cluster/GenomicsCore/bin/samtools index $1.bam
#/stf/home/cluster/GenomicsCore/bin/samtools view -b -q 10 $1.bam >$1.filter.bam
#/stf/home/cluster/GenomicsCore/bin/samtools flagstat $1.filter.bam
#/stf/home/cluster/GenomicsCore/bin/samtools rmdup $1.filter.bam  $1_dup_rem.bam
/stf/home/cluster/GenomicsCore/bin/samtools index $1.filter.bam
#/stf/home/cluster/GenomicsCore/bin/samtools flagstat $1_dup_rem.bam

#/stf/home/cluster/GenomicsCore/bin/macs2 callpeak   -t $1.filter.bam  --nomodel --tempdir ./ --format BAM  --gsize mm  --shift 100  --extsize 200 --name $1 -q 0.01 --broad
#/stf/home/cluster/GenomicsCore/bin/macs2 bdgdiff  --t1 cond1_treat_pileup.bdg --c1 cond1_control_lambda.bdg --t2 cond2_treat_pileup.bdg   --c2 cond2_control_lambda.bdg --d1 12914669 --d2 14444786 -g 60 -l 120 --o-prefix diff
#/stf/home/cluster/GenomicsCore/apps/R/3.2.2/bin/Rscript ./diffBind.R

#/stf/home/cluster/GenomicsCore/apps/HOMER/bin/annotatePeaks.pl $1_peaks.narrowPeak mm10  -annStats $1.annStat -genomeOntology > $1_peaks_mm10_Anno.xls 
#/stf/home/cluster/GenomicsCore/apps/HOMER/bin/findMotifsGenome.pl $1_peaks.narrowPeak mm10 ./ -p 8 #-preparse
#/stf/home/cluster/GenomicsCore/apps/HOMER/bin/findMotifsGenome.pl NarrowPeak_DiffBind.peaks.csv  mm10 NarrowPeakMotif/ -p 8
#/stf/home/cluster/GenomicsCore/apps/HOMER/bin/findMotifsGenome.pl BroadPeak_DiffBind.peaks.csv  mm10 BroadPeakMotif/ -p 8

#awk 'NF > 0 && FNR > 21 {counts[int($4/201)] = counts[int($4/201)] + 1;} END {for (peak in counts) print peak, counts[peak];}' $1_peaks.xls >$1.histogram
