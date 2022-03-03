##### ITS Primers Trimming #####
/common/genomics-core/anaconda2/bin/cutadapt -a CTTGGTCATTTAGAGGAAGTAA...GCATCGATGAAGAACGCAGC  -A GCTGCGTTCTTCATCGATGC...TTACTTCCTCTAAATGACCAAG  --discard-untrimmed -o $1_R1_ITS1.fastq.gz -p $1_R2_ITS1.fastq.gz  $1_R1_001.fastq.gz $1_R2_001.fastq.gz >$1_ITS1.log

##### Paired-end Reads Merging #####
/common/genomics-core/anaconda2/bin/SeqPrep -f $1_R1_ITS1.fastq.gz  -r $1_R2_ITS1.fastq.gz  -1 $1.ITS1_unassembled_R1.fastq.gz -2 $1.ITS1_unassembled_R2.fastq.gz -s $1.ITS1_joined.fastq.gz

##### Formatting for QIIME #####
zcat $1.ITS1_joined.fastq.gz $1.ITS1_unassembled_R1.fastq.gz |cut -f1,5- -d':'|sed s/@M03606:/\>$1_/|awk '{y= i++ % 4 ; L[y]=$0; if(y==1 && length(L[1])>100) {printf("%s\n%s\n",L[0],L[1]);}}' >$1_ITS1.fasta

