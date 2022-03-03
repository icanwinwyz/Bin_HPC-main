/common/genomics-core/apps/cellranger-4.0.0/cellranger aggr --id=Noraml_Dia_all --csv=aggr.csv --nopreflight --jobmode=sge

#/common/genomics-core/apps/cellranger-3.1.0//cellranger reanalyze --id=aggr_N19-55_DM19-56_filtered --matrix=aggr_N19-55_DM19-56/outs/filtered_feature_bc_matrix.h5 --barcodes=two_samples_barcodes_QC.csv --nopreflight --jobmode=sge

echo "Aggr for all samples is done !" | sendmail di.wu@cshs.org
