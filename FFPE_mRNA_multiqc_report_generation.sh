#cd $1
#project=$2
#config="/home/genomics/genomics/apps/multiqc/multiqc_config_example.yaml"

#copy the FFPE_mRNA_results_generation file to the corresponding project folder and create a folder called results
#before running this file, please run this file before running the count matrix generation bash file

wd=$(pwd)

dir=$(ls -d */|sed 's/\///g'); 

for sample in $dir 
do 
  cd $wd/$sample;  
  mv read_distribution.txt $sample\_R1.txt
  echo $(pwd)

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
done

cd $wd
qsub -q all.q -N multiqc_generate -cwd /common/genomics-core/apps/mapping_qc_auto/multiqc.sh $1


