#usage: bash ~/genomics-core/bin/FFPE_mRNA_results_generation.sh projectID

#config="/home/genomics/genomics/apps/multiqc/multiqc_config_example.yaml"




wd=$(pwd)

dir=$(ls -d */|sed 's/\///g'); 

for sample in $dir 
do 
  # preparation for multiqc generation
  cd $wd/$sample;  
  mv read_distribution.txt $sample\_R1.txt
  rename -v star $sample starLog.final.out
  tar -xvzf fastqc_files.tar.gz
  sed -i 's/UMI_//g' *_clean_fastqc.html
  unzip *.fastq_clean_fastqc.zip
  sed -i 's/UMI_//g' *.fastq_clean_fastqc/fastqc_report.html 
  sed -i 's/UMI_//g' *.fastq_clean_fastqc/fastqc_data.txt
  rm *clean_fastqc.zip
  mv *clean_fastqc $sample\_R1_trimmed.fastq_clean_fastqc
  zip_folder=$(ls|grep *clean_fastqc)
  zip -r $zip_folder\.zip $zip_folder

  # preparation for count matrix generation
  sample2=$(echo $sample | cut -d'_' -f 1)
  suffix6="_fastq_gz"
  sampleName2=${sample2%"$suffix6"}
  mv *counts.txt ${sampleName2}_counts.txt
  cd $wd
  { printf 'Gene\t'"${sampleName2}"'\n'; cat ${sample}/${sampleName2}_counts.txt; } > ${sampleName2}_counts.txt

done

cd $wd

paste *_counts.txt | awk 'NR==1{for(i=1;i<=NF;i++)b[$i]++&&a[i]}{for(i in a)$i="";gsub(" +"," ")}1' > counts.txt
mkdir sample_count_matrix
mv *_counts.txt* sample_count_matrix/ 

qsub -q all.q -N multiqc_generate -cwd /common/genomics-core/apps/mapping_qc_auto/multiqc.sh $1

