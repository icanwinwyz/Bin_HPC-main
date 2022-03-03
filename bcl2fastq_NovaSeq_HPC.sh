module load bcl2fastq/2.19.1.403

CELLRANGER="/common/genomics-core/apps/cellranger-5.0.0"
FOLDER_PATH_NOVASEQ="/common/genomics-core/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation"
FOLDER_PATH_NEXTSEQ="/common/genomics-core/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation"
FOLDER_PATH_MISEQ="/common/genomics-core/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation"
SEQ_PATH_NOVASEQ="/common/genomics-core/smb/raw/Genomics/NovaSeq_RawData"
SEQ_PATH_NEXTSEQ="/common/genomics-core/smb/raw/Genomics/NextSeq500_RawData"
SEQ_PATH_MISEQ="/common/genomics-core/smb/raw/Genomics/MiSeq_RawData"
USE_BASE_MASK=$3

if [ "$1" = "NovaSeq" ]; then

	FOLDER_PATH=$FOLDER_PATH_NOVASEQ
	SEQ_PATH=$SEQ_PATH_NOVASEQ
	STR=$2
	OUTPUT_FOLDER=${STR:(-9):9}

elif [ "$1" = "NextSeq" ]; then

	FOLDER_PATH=$FOLDER_PATH_NEXTSEQ
        SEQ_PATH=$SEQ_PATH_NEXTSEQ

elif [ "$1" = "MiSeq" ]; then
	
	FOLDER_PATH=$FOLDER_PATH_MISEQ
        SEQ_PATH=$SEQ_PATH_MISEQ

else

	echo "Please set the select the correct sequencer for data processing!"

fi

FN="$2_$(date|cut -b 12-19|sed 's/:/_/g')"

cd $FOLDER_PATH
mkdir $FN
chmod 775 $FN
cd $FN
mkdir Undetermined_Fastq

cp $SEQ_PATH/$2/SampleSheet.csv $FOLDER_PATH/$FN

if [ -z "$USE_BASE_MASK" ]; then

	if [ "$1" = "NextSeq" ]; then
		
		cp -r $SEQ_PATH/$2 $FOLDER_PATH/$FN

		bcl2fastq -R $FOLDER_PATH/$FN/$2 -o $FOLDER_PATH/$FN --sample-sheet=$FOLDER_PATH/$FN/SampleSheet.csv -r 10 -p 10 -w 10 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"
	#####   bcl2fastq -R $FOLDER_PATH/$FN/$2 -o $FOLDER_PATH/$FN -r 25 -p 25 -w 25 --barcode-mismatches 0 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"

	else

		bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$FN --sample-sheet=$FOLDER_PATH/$FN/SampleSheet.csv -r 10 -p 10 -w 10 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"

	fi	
else
	if [ "$1" = "NextSeq" ]; then
		
		cp -r $SEQ_PATH/$2 $FOLDER_PATH/$FN

		bcl2fastq -R $FOLDER_PATH/$FN/$2 --use-bases-mask $USE_BASE_MASK -o $FOLDER_PATH/$FN --sample-sheet=$FOLDER_PATH/$FN/SampleSheet.csv -r 10 -p 10 -w 10 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"
	#####   bcl2fastq -R $FOLDER_PATH/$FN/$2 -o $FOLDER_PATH/$FN -r 25 -p 25 -w 25 --barcode-mismatches 0 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"

	else

		###bcl2fastq -R $SEQ_PATH/$2 --use-bases-mask $USE_BASE_MASK -o $FOLDER_PATH/$FN --sample-sheet=$FOLDER_PATH/$FN/SampleSheet.csv -r 10 -p 10 -w 10 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"
		bcl2fastq -R $SEQ_PATH/$2 --use-bases-mask $USE_BASE_MASK --barcode-mismatches 0 -o $FOLDER_PATH/$FN --sample-sheet=$FOLDER_PATH/$FN/SampleSheet.csv -r 10 -p 10 -w 10 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"
	fi	
fi


mv Undetermined*.fastq.gz Undetermined_Fastq

sed '1,/Sample_ID/d' SampleSheet.csv > samplesheet_tmp.csv

bash /common/genomics-core/apps/adapter_trim/integrate_HPC.sh $FOLDER_PATH/$FN

CHECK_FILE=$FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml

if [ -f $CHECK_FILE ]; then

        if [ "$1" = "NovaSeq" ]; then

		/common/genomics-core/anaconda3/bin/perl /common/genomics-core/bin/bcl_summary_mail_test.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/ $2 NovaSeq $FOLDER_PATH/$FN/Stats/Stats.json $FOLDER_PATH/$FN/SampleSheet.csv

	elif [ "$1" = "NextSeq" ]; then

                mkdir "Data_processing"

                mv *.gz Data_processing

                mv ./Data_processing/Undetermined* ./
	
		/common/genomics-core/anaconda3/bin/perl /common/genomics-core/bin/bcl_summary_mail_test.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/Data_processing $2 NextSeq $FOLDER_PATH/$FN/Stats/Stats.json $FOLDER_PATH/$FN/SampleSheet.csv

		elif [ "$1" = "MiSeq" ]; then

                /common/genomics-core/anaconda3/bin/perl /common/genomics-core/bin/bcl_summary_mail_test.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/ $2 MiSeq $FOLDER_PATH/$FN/Stats/Stats.json $FOLDER_PATH/$FN/SampleSheet.csv

        fi

	sendmail -vt < ./mail.txt

else
        echo "To: genomics@cshs.org" > mail_error.txt
        echo "Subject: demultiplexing error for $FN" >> mail_error.txt
        echo "From: titan_automation" >> mail_error.txt
        echo "" >> mail_error.txt
        echo "Error Message:" >> mail_error.txt
        echo "" >> mail_error.txt
##        cp $FOLDER_PATH/$FN/demultiplex_log.txt /var/www/html/log/$FN_error.demultiplex_log.txt
##grep -A 10 -B 3 "ERROR" $FOLDER_PATH/$FN/log.txt >> mail_error.txt
	tail -n 20 $FOLDER_PATH/$FN/demultiplex_log.txt >> mail_error.txt
	sendmail -vt < mail_error.txt
fi

