##### Merge sequences from all samples #####
 
#cat *_16S.fasta >16S.fna
#cat *_ITS1.fasta >ITS.fna




##### Now load qiime by running 'source activate qiime1' at genomics@csclprd1-s1v  #####

##### Standard Deliverable #####
##### Perform alignment #####

parallel_pick_otus_blast.py -i ITS.fna  -b /common/genomics-core/reference/Microbiome/THFv1.61.sort.fasta -O 120 -o otus_THFv1.61 

##### Generate OTU table #####
make_otu_table.py -i otus_THFv1.61/$1_otus.txt -o $1_table.biom -t /home/genomics/genomics/reference/Microbiome/$2.fasta.taxonomy

##### Convert into TXT format #####
biom convert -i $1_table.biom -o $1_table_$2.txt  --to-tsv --header-key="taxonomy"




##### Extra manipulations #####
##### Summarize profiles at all Taxonomy levels #####
summarize_taxa.py -i Sorted_otu_table_$1.biom   -o Taxa_summary

##### Filter OTU table by sample names #####
filter_samples_from_otu_table.py -i otu_table.biom -o filtered_otu_table.biom --sample_id_fp ids.txt

##### Filter OTU table by relative abundance #####
filter_otus_from_otu_table.py -i filtered_otu_table.biom -o Sorted_otu_table_$1.biom --min_count_fraction 0.00001

##### for more scripts, visit http://qiime.org/scripts/index.html #####
