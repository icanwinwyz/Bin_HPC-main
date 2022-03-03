export PATH=/stf/home/cluster/GenomicsCore/bin:$PATH
export PYTHONPATH=/stf/home/cluster/GenomicsCore/lib/Python-2.7.3/bin/:$PYTHONPATH


###example##
###~/genomics/apps/cellranger-dna-1.0.0/cellranger-dna cnv --id=scCNV_Training_Knott_all_nodes --fastqs=/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation/190123_A00319_0031_BHJ5FTDMXX_scCNV/fastq/scCNV_Gather_training --reference=/common/genomics-core/reference/Cellranger_DNA/GRCm38 --sample=scCNV_Training_Knott --nopreflight --jobmode=sge

~/genomics/apps/cellranger-dna-1.0.0/cellranger-dna cnv --id=$1 --fastqs=$2 --reference=$3 --sample=$4 --nopreflight --jobmode=sge
