#/home/genomics/apps/cellranger-2.0.0/cellranger mkfastq -R /mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/ --csv=/mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/SampleSheet.csv  --id=cell_test
#/home/genomics/apps/cellranger-2.0.0/cellranger count --fastqs=/home/genomics/test/FT1/outs/fastq_path --sample=FT1 --id=FT1_results --transcriptome=/home/genomics/reference/CellRanger/GRCh38

###$1 is the sequencer name $2 is sequencing ID 

CELLRANGER="/home/genomics/genomics/apps/cellranger-arc-2.0.0/"

if [ "$1" = "NovaSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation"
	SEQ_PATH="/home/genomics/genomics-archive2/Genomics/NovaSeq_RawData"
	STR=$2
	OUTPUT_FOLDER=${STR:(-9):9}

elif [ "$1" = "NextSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation"
        SEQ_PATH="/home/genomics/genomics-archive2/Genomics/NextSeq500_RawData"

else
	
	echo "Please set the select the correct sequencer for data processing!"

fi

FN="$2_$(date|cut -b 12-19|sed 's/:/_/g')"


cd $FOLDER_PATH
#mkdir $2
mkdir $FN
chmod -R 775 $FN
cd $FN
mkdir Undetermined_Fastq
#$CELLRANGER/cellranger mkfastq --run $SEQ_PATH/$2 --samplesheet=$SEQ_PATH/$2/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

# --barcode-mismatches=0

cp $SEQ_PATH/$2/SampleSheet.csv $FOLDER_PATH/$FN

#$CELLRANGER/cellranger mkfastq --run $SEQ_PATH/$2 --ignore-dual-index --samplesheet=$SEQ_PATH/$2/SampleSheet.csv --barcode-mismatches=0 --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt
#$CELLRANGER/cellranger mkfastq --run $SEQ_PATH/$2 --samplesheet=$SEQ_PATH/$2/SampleSheet.csv --barcode-mismatches=0 --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt
$CELLRANGER/cellranger-arc mkfastq --run $SEQ_PATH/$2 --samplesheet=$SEQ_PATH/$2/SampleSheet.csv --output-dir=$FOLDER_PATH/$FN &> demultiplex_log.txt

mv Undetermined*.fastq.gz Undetermined_Fastq

sed '1,/Sample_ID/d' SampleSheet.csv > samplesheet_tmp.csv

#/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/ $2 $1 $FOLDER_PATH/$2/$OUTPUT_FOLDER/outs/qc_summary.json 

CHECK_FILE=$FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml

if [ -f $CHECK_FILE ]; then

	/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/ $2 $1 $FOLDER_PATH/$FN/Stats/Stats.json $FOLDER_PATH/$FN/SampleSheet.csv

	cd $FOLDER_PATH
	/home/genomics/bin/change_per.sh $FOLDER_PATH/$FN
#	chmod -R 775 $2
#	chown -R genomics $2

	sendmail -vt < $FOLDER_PATH/$FN/mail.txt

else
	/home/genomics/bin/change_per.sh $FOLDER_PATH/$FN
	echo "To: genomics@cshs.org" > mail_error.txt
        echo "Subject: demultiplexing error for $FN" >> mail_error.txt
        echo "From: titan_automation" >> mail_error.txt
        echo "" >> mail_error.txt
        echo "Error Message:" >> mail_error.txt
        echo "" >> mail_error.txt
      #  cp $FOLDER_PATH/$FN/demultiplex_log.txt /var/www/html/log/$FN.error.demultiplex_log.txt
#grep -A 10 -B 3 "ERROR" $FOLDER_PATH/$FN/log.txt >> mail_error.txt
	grep "error" demultiplex_log.txt >> mail_error.txt
	grep "stderr" demultiplex_log.txt >> mail_error.txt

#	cat $(grep 'error' demultiplex_log.txt) >> mail_error.txt
#	cat $(grep 'error' demultiplex_log.txt) > /var/www/html/log/$FN.error.demultiplex_log.txt
	#tail -n 20 $FOLDER_PATH/$FN/demultiplex_log.txt >> mail_error.txt
        sendmail -vt < mail_error.txt
       # rm -rf $FOLDER_PATH/$FN
fi
#rm mail.txt


