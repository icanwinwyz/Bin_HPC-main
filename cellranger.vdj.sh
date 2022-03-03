CELLRANGER_PATH=/home/wangyiz/genomics/apps/cellranger-4.0.0/
REF_PATH=/home/wangyiz/genomics/reference/CellRanger_VDJ/refdata-cellranger-vdj-GRCh38-alts-ensembl-4.0.0/

$CELLRANGER_PATH/cellranger vdj --id=Patient-B-Cell_results \
                 --reference=$REF_PATH \
                 --fastqs=/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation/201009_A00319_0218_AHVL32DMXX_23_52_09/CJ-10718--09--26--2020_Jefferies_Caroline_VDJ_10X_Human/fastq \
                 --sample=Patient-B-Cell \
                 --jobmode=sge \

echo "Subject: 10X VDJ processing is done" | sendmail -v yizhou.wang@cshs.org


$CELLRANGER_PATH/cellranger vdj --id=Control-B-Cell_results \
                 --reference=$REF_PATH \
                 --fastqs=/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation/201009_A00319_0218_AHVL32DMXX_23_52_09/CJ-10718--09--26--2020_Jefferies_Caroline_VDJ_10X_Human/fastq \
                 --sample=Control-B-Cell \
                 --jobmode=sge \

echo "Subject: 10X VDJ processing is done" | sendmail -v yizhou.wang@cshs.org
