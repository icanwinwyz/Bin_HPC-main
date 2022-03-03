#!/bin/bash
##First part of the Sequencing data distribution Pipeline

export PATH=/stf/home/cluster/GenomicsCore/bin:$PATH
export PYTHONPATH=/stf/home/cluster/GenomicsCore/lib/Python-2.7.3/bin/:$PYTHONPATH

#Variables

RUN="/stf/home/cluster/GenomicsCore/data/illuminaRun/NextSeq_RawData"
Temp="/stf/home/cluster/GenomicsCore/data/Temp"
# Run folder

cd $RUN/$1

#create directories for all the projects in that run.

sed '1,/Sample_ID/d' SampleSheet.csv |  cut -d"," -f3| uniq| while read V; do mkdir ~genomics/data/Temp/"$V"; done

#run bcl2fastq to generate the fastq files

bcl2fastq --runfolder-dir ./ --output-dir ./Data/Intensities/BaseCalls/ --ignore-missing-bcl --ignore-missing-filter


#move the fastq files to respective directories in Temp folder

sed '1,/Sample_ID/d' SampleSheet.csv |   cut -d"," -f1,3|sed 's/,/"\t"/g'| sed 's/"//g'| while read v u ; do mv $RUN/$1/Data/Intensities/BaseCalls/"$v"*gz $Temp/$u; done


#unzip the fastq.gz files

sed '1,/Sample_ID/d' SampleSheet.csv |   cut -d"," -f1,3|sed 's/,/"\t"/g'| sed 's/"//g'| while read v u ; do zcat $Temp/"$u"/"$v"*R1_001.fastq.gz > $Temp/"$u"/"$v".R1.fastq ; done

##unzip fastq.gz files for Paired end data

sed '1,/Sample_ID/d' SampleSheet.csv |  cut -d"," -f3| uniq > uniq.txt

awk  '/Sample_ID/,0' SampleSheet.csv| sed 's/,/"\t"/g'|sed 's/"//g'| awk -v col1=Sample_Name -v col2=SampleProject -v col3=ORGANISM -v col4=TYPE 'NR==1{for(i=1;i<=NF;i++){if($i==col1)c1=i; if ($i==col2)c2=i; if ($i==col3)c3=i;if ($i==col4)c4=i}} NR>1{print $c1 "     " $c2"  "$c3"   "$c4}' > input.txt

grep PE input.txt | while read v u w ; do zcat $Temp/"$u"/"$v"*R2_001.fastq.gz > ~genomics/data/Temp/"$u"/"$v".R2.fastq ; done


# Creating the samplesheet for Joe's pipeline

while IFS= read -r line; do grep "$line" input.txt > ~genomics/data/Temp/"$line"/inputfile.txt ; done < uniq.txt


#for d in $Temp/* ; do (cd "$d" && ~genomics/bin/Mapping_auto.pl -e vineela.gangalapudi@cshs.org); done

###~genomics/bin/Mapping_auto.pl -e vineela.gangalapudi@cshs.org -t SE -o Human -p PJA-1962--07--13--2016
