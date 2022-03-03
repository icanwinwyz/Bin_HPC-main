#~/genomics/apps/cellranger-atac-1.0.1/cellranger-atac mkfastq --id=$1 --run=~/genomics-archive/NextSeq500_RawData/190207_NS500624_0274_AHHHW3AFXY/ --samplesheet=~/genomics-archive/NextSeq500_RawData/190207_NS500624_0274_AHHHW3AFXY/SampleSheet.csv --output-dir=

~/genomics/apps/cellranger-atac-1.0.1/cellranger-atac count --id=K27M-ATAC-121418_results_2 --fastqs=/home/wangyiz/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation/181219_NS500624_0266_AHF5YGAFXY/fastq --sample=K27M-ATAC-121418 --reference=/home/wangyiz/genomics/reference/CellRanger_ATAC/mm10_Breunig_transgene --jobmode=sge --nopreflight --disable-ui
echo "Subject: 10X data processing is done for atacseq" | sendmail -v yizhou.wang@cshs.org
