INFILE=`awk '{print $1}' list.txt|sed -n "${SGE_TASK_ID}p"`


zcat $INFILE*.fastq.gz > $INFILE.fastq 

gzip $INFILE.fastq
