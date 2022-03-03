
ARC_PATH=/common/genomics-core/apps/cellranger-arc-1.0.1/
REF_PATH=/common/genomics-core/reference/CellRanger_ARC_v1.0.1/refdata-cellranger-arc-mm10-2020-A/

$ARC_PATH/cellranger-arc count --id=BM-Ly6Chi-Mo \
                       --reference=$REF_PATH \
                       --libraries=./library.csv \
                       --nopreflight \
                       --jobmode=sge
                       
