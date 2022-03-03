#!/bin/bash

# ****************************************************************************
#  bcl2fastq
#
#  Runs bcl2fastq illumina program.
#
# 
#  Created by#  Genomics Core
#
#  Last Modified by Ed K. 6/19/17
# 
#  Environment variables utilized by this script # 
#  
#     $1 , The first parameter from the command line
#     $2 , The second parameter from the command line
#     $3 , The third parameter from the command line
#     $4 , The fourth parameter from the command line
#
# 
#  Internal Variables used in this script# 
#
#     RUN="/stf/home/cluster/GenomicsCore/data/illuminaRun/NextSeq_RawData" , 
#     Temp="/stf/home/cluster/GenomicsCore/data/Temp" , 
#     Samplesheet="/stf/home/cluster/GenomicsCore/data/illuminaRun/NextSeq_RawData/Samplesheets" , 
# 
#  Temporary Files used by this script# 
#
#     None
#
#  Syntax:
#
#     bck2fastq 
#
# 
# *************************************************************************
# 
#                            Script Begins
# 
# *************************
#  Set Internal Variables *
# *************************
# 

##First part of the Sequencing data distribution Pipeline

export PATH=/stf/home/cluster/GenomicsCore/bin:$PATH
export PYTHONPATH=/stf/home/cluster/GenomicsCore/lib/Python-2.7.3/bin/:$PYTHONPATH

#Variables

RUN="/stf/home/cluster/GenomicsCore/data/illuminaRun/NextSeq_RawData"
Temp="/stf/home/cluster/GenomicsCore/data/Temp"
Samplesheet="/stf/home/cluster/GenomicsCore/data/illuminaRun/NextSeq_RawData/Samplesheets"

# Run folder
#cp $Samplesheet/$1*csv $RUN/$1
cd $RUN/$1
#mv $1.csv SampleSheet.csv
#create directories for all the projects in that run.

sed '1,/Sample_ID/d' SampleSheet.csv |  cut -d"," -f3|sort| uniq| while read V; do mkdir $Temp/"$V"; done

#run bcl2fastq to generate the fastq files

bcl2fastq --runfolder-dir ./ --output-dir ./Data/Intensities/BaseCalls/ --ignore-missing-bcl --ignore-missing-filter


#move the fastq files to respective directories in Temp folder

sed '1,/Sample_ID/d' SampleSheet.csv |   cut -d"," -f1,3|sed 's/,/"\t"/g'| sed 's/"//g'| while read v u ; do mv $RUN/$1/Data/Intensities/BaseCalls/"$v"*gz $Temp/$u; done


