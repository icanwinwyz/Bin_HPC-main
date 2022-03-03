inputfastq=$1
inputfastq2=$2
#inputfastq3=$3
echo $inputfastq
echo $inputfastq2
cat="cat"
to=">"
folder="/common/genomics-core/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation/200928_NB501439_0047_AHH3V5AFX2_09_57_38/TRRM-10554--09--09--2020_Marban_Eduardo_Total_RNA_Mouse/Trimmed/"
folder2="/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation/200922_A00319_0211_AHTTGTDRXX_10_38_02/TRRM-10554--09--09--2020_Marban_Eduardo_Total_RNA_Mouse/Trimmed/"
suffix="_R1_trimmed.fastq.gz"
suffix2="_R1.trimmed.merged.fastq.gz"
suffix3=".sh"
echo $cat $folder$inputfastq$suffix $folder2$inputfastq2$suffix $to $folder$inputfastq$suffix2 >> $inputfastq$suffix3
qsub -q all.q $inputfastq$suffix3
