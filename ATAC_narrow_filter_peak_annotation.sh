###$1 is the peak file name withouth "narrowPeak" and $2 is the species(hg38 or mm10) and $3 is the sample name

#PATH=/home/genomics/genomics/bin/
#PATH=/common/genomics-core/bin/

module load R

FILENAME="track type=narrowPeak name\"$3\""


perl -e '{while(<>){@a=split("\t",$_);print join("\t",$a[3],$a[0],$a[1],$a[2],"+",@a[4..$#a]);}}' $1.narrowPeak > $1.narrowPeak.format.txt

~/genomics/apps/HOMER/bin/annotatePeaks.pl $1.narrowPeak.format.txt $2 > $1.narrowPeak.anno.temp.txt
#/common/genomics-core/apps/HOMER/bin/annotatePeaks.pl $1.narrowPeak.format.txt $2 > $1.narrowPeak.anno.temp.txt


perl -e '{while(<>){@a=split("\t",$_);if($a[0]=~/PeakID/){$a[0]=~s/PeakID.*/PeakID/;print join("\t",@a[0..3],@a[5..$#a]);}else{print join("\t",@a[0..3],@a[5..$#a]);}}}' $1.narrowPeak.anno.temp.txt > $1.narrowPeak.anno.txt

#Rscript $PATH/ATAC_narrowpeak_merge.sh $1.narrowPeak.anno.txt $1.narrowPeak
#Rscript /common/genomics-core/bin/ATAC_narrowpeak_merge.sh $1.narrowPeak.anno.txt $1.narrowPeak
#Rscript home/genomics/genomics/bin/ATAC_narrowpeak_merge.R $1.narrowPeak.anno.txt $1.narrowPeak
#Rscript /common/genomics-core/bin/ATAC_narrowpeak_merge.R $1.narrowPeak.anno.txt $1.narrowPeak
Rscript /common/genomics-core/bin/ATAC_narrowpeak_merge.R $1.narrowPeak.anno.txt $1.narrowPeak


sed '1itrack type=narrowPeak name"$3"' $1.narrowPeak > $1.USCS_GB.narrowPeak

echo "$FILENAME"

sed "1i$FILENAME" $1.narrowPeak > $1.USCS_GB.narrowPeak

rm $1.narrowPeak.anno.temp.txt

rm $1.narrowPeak.format.txt

#rm $1.narrowPeak.anno.txt
