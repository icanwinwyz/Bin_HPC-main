#~/genomics/apps/cellranger-dna-1.0.0/cellranger-dna mkfastq --samplesheet=~/genomics-archive/NovaSeq_RawData/190123_A00319_0031_BHJ5FTDMXX/SampleSheet_scCNV.csv --run=~/genomics-archive/NovaSeq_RawData/190123_A00319_0031_BHJ5FTDMXX/ --output-dir=./fastq

#~/genomics/apps/cellranger-dna-1.0.0/cellranger-dna cnv --id=scCNV_Training_Knott_max_open --fastqs=/home/wangyiz/genomics/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation/190123_A00319_0031_BHJ5FTDMXX_scCNV/fastq/scCNV_Gather_training --reference=/home/wangyiz/genomics/reference/Cellranger_DNA/GRCm38 --sample=scCNV_Training_Knott --nopreflight --jobmode=local

/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation/190123_A00319_0031_BHJ5FTDMXX_scCNV/cellranger-dna-1.0.0/cellranger-dna cnv --id=scCNV_Training_Knott_all_nodes_final --fastqs=/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation/190123_A00319_0031_BHJ5FTDMXX_scCNV/fastq/scCNV_Gather_training --reference=/common/genomics-core/reference/Cellranger_DNA/GRCm38 --sample=scCNV_Training_Knott --jobmode=sge

echo "Subject: scCNV is done" | sendmail -v yizhou.wang@cshs.org

