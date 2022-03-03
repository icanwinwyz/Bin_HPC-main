###$1 is the sample ID; $2 is slide series；$3 is area $4 is sample name in FASTQ files $5 is the FASTQ file path $6 is path to image file

##EXAMPLE
REF_PATH=/common/genomics-core/reference/SpaceRanger/
SPACERANGER=/common/genomics-core/apps/spaceranger-1.2.1
FASTQ_PATH=$5

##refdata-gex-GRCh38-2020-A  refdata-gex-mm10-2020-A

###~/genomics/apps/spaceranger-1.1.0/spaceranger count --id=JAS-A1_Visium_results --transcriptome=$REF_PATH/GRCh38-3.0.0 --fastqs=/common/genomics-core/data/Services/Aldinger_Kimberly/KS-9728--06--05--2020/FASTQ --slide=V10F06-075 --area=A1 --sample=JAS-A1 --image=./JAS_A1.tif  --jobmode=sge

$SPACERANGER/spaceranger count --id=$1_results --transcriptome=$REF_PATH/refdata-gex-GRCh38-2020-A --fastqs=$FASTQ_PATH --slide=$2 --area=$3 --sample=$4 --image=$6  --jobmode=sge


