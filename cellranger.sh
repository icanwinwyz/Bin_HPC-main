
export SGE_CLUSTER_NAME="csclprd1"
#/stf/home/cluster/GenomicsCore/apps/cellranger-1.3.0/cellranger mkfastq -R ./ --samplesheet=samplesheet.csv --jobmode=sge --mempercore=2



#~/genomics/apps/cellranger-2.0.1/cellranger count --nopreflight --id=$2_results --sample=$2 --fastqs=$1 --transcriptome=/home/wangyiz/genomics/reference/CellRanger/GRCh38 --jobmode=sge
#~/genomics/apps/cellranger-2.1.0/cellranger count --nopreflight --id=$2_results --sample=$2 --fastqs=$1 --transcriptome=/home/wangyiz/genomics/reference/CellRanger/GRCh38 --jobmode=sge
~/genomics/apps/cellranger-2.1.0/cellranger count --nopreflight --id=$2_results --sample=$2 --fastqs=$1 --transcriptome=/home/wangyiz/genomics/reference/CellRanger/GRCh38
#~/genomics/apps/cellranger-2.1.0/cellranger count --nopreflight --id=$2_results --sample=$2 --fastqs=$1 --transcriptome=/home/wangyiz/genomics/reference/CellRanger/mm10_WPRE/mm10_WPRE --jobmode=sge
#~/genomics/apps/cellranger-2.0.1/cellranger count --nopreflight --id=$2_results --sample=$2 --fastqs=$1 --transcriptome=/home/wangyiz/genomics/reference/CellRanger/mm10_WPRE/mm10_WPRE --jobmode=sge
#~/genomics/apps/cellranger-2.0.1/cellranger count --id=$2_results --sample=$2 --fastqs=$1 --transcriptome=/home/wangyiz/genomics/reference/CellRanger/mm10 --jobmode=sge
#~/genomics/apps/cellranger-1.3.1/cellranger count --id=$2_results --sample=$2 --fastqs=$1 --transcriptome=/home/wangyiz/genomics/reference/CellRanger/mm10 --jobmode=sge --maxjobs=32


echo "Subject: 10X data processing is done" | sendmail -v yizhou.wang@cshs.org

