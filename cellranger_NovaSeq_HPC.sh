export PATH=$PATH:/common/genomics-core/anaconda3/bin/

FOLDER_PATH_NOVASEQ="/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation"
FOLDER_PATH_NEXTSEQ="/common/genomics-core/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation"
SEQ_PATH_NOVASEQ="/common/genomics-core/smb/raw/Genomics/NovaSeq_RawData"
SEQ_PATH_NEXTSEQ="/common/genomics-core/smb/raw/Genomics/NextSeq500_RawData"
SEQ_TYPE=$3
USE_BASE_MASK=$4

if [ "$1" = "NovaSeq" ]; then

	FOLDER_PATH=$FOLDER_PATH_NOVASEQ
	SEQ_PATH=$SEQ_PATH_NOVASEQ
	STR=$2
	OUTPUT_FOLDER=${STR:(-9):9}

elif [ "$1" = "NextSeq" ]; then

	FOLDER_PATH=$FOLDER_PATH_NEXTSEQ
        SEQ_PATH=$SEQ_PATH_NEXTSEQ

else
	
	echo "Please set the select the correct sequencer for data processing!"

fi

FN="$2_$(date|cut -b 12-19|sed 's/:/_/g')"


cd $FOLDER_PATH
mkdir $FN
chmod -R 775 $FN
cd $FN
mkdir Undetermined_Fastq


cp $SEQ_PATH/$2/SampleSheet.csv $FOLDER_PATH/$FN

if [ -z "$USE_BASE_MASK" ]; then

	if [ "$SEQ_TYPE" = "scRNA_10X" ] || [ "$SEQ_TYPE" = "VDJ_10X" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-6.0.0"
	$CELLRANGER/cellranger mkfastq --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --barcode-mismatches=0 --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "scATAC_10X" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-atac-1.2.0/"
	$CELLRANGER/cellranger-atac mkfastq --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "Multiome" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-arc-1.0.1/"
	$CELLRANGER/cellranger-arc mkfastq --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "scCNV_10X" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-dna-1.1.0/"
	$CELLRANGER/cellranger-dna mkfastq --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "Visium" ]; then

	CELLRANGER="/common/genomics-core/apps/spaceranger-1.1.0/"
	$CELLRANGER/spaceranger mkfastq --run=$SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	fi
else
	if [ "$SEQ_TYPE" = "scRNA_10X" ] || [ "$SEQ_TYPE" = "VDJ_10X" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-6.0.0"
	$CELLRANGER/cellranger mkfastq --use-bases-mask=$USE_BASE_MASK --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --barcode-mismatches=0 --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "scATAC_10X" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-atac-1.2.0/"
	$CELLRANGER/cellranger-atac mkfastq --use-bases-mask=$USE_BASE_MASK --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "Multiome" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-arc-2.0.0/"
	$CELLRANGER/cellranger-arc mkfastq --use-bases-mask=$USE_BASE_MASK --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "scCNV_10X" ]; then

	CELLRANGER="/common/genomics-core/apps/cellranger-dna-1.1.0/"
	$CELLRANGER/cellranger-dna mkfastq --use-bases-mask=$USE_BASE_MASK --run $SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	elif [ "$SEQ_TYPE" = "Visium" ]; then

	CELLRANGER="/common/genomics-core/apps/spaceranger-1.1.0/"
	$CELLRANGER/spaceranger mkfastq --use-bases-mask=$USE_BASE_MASK --run=$SEQ_PATH/$2 -r 10 -p 10 -w 10 --samplesheet=$FOLDER_PATH/$FN/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

	fi
fi

mv Undetermined*.fastq.gz Undetermined_Fastq

sed '1,/Sample_ID/d' SampleSheet.csv > samplesheet_tmp.csv


CHECK_FILE=$FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml

if [ -f $CHECK_FILE ]; then

	/common/genomics-core/anaconda3/bin/perl /common/genomics-core/bin/bcl_summary_mail_test.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/ $2 $1 $FOLDER_PATH/$FN/Stats/Stats.json $FOLDER_PATH/$FN/SampleSheet.csv

	cd $FOLDER_PATH

	sendmail -vt < $FOLDER_PATH/$FN/mail.txt

else
#	echo "To: yizhou.wang@cshs.org" > mail_error.txt
	echo "To: genomics@cshs.org" > mail_error.txt
        echo "Subject: demultiplexing error for $FN" >> mail_error.txt
        echo "From: titan_automation" >> mail_error.txt
        echo "" >> mail_error.txt
        echo "Error Message:" >> mail_error.txt
        echo "" >> mail_error.txt
	grep "error" demultiplex_log.txt >> mail_error.txt
	grep "stderr" demultiplex_log.txt >> mail_error.txt
        sendmail -vt < mail_error.txt
fi


