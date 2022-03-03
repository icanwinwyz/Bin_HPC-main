###$1 is the sequencer name $2 is sequencing ID
if [ "$1" = "NovaSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation"
	SEQ_PATH="/home/genomics/genomics-archive2/Genomics/NovaSeq_RawData"
	STR=$2
	OUTPUT_FOLDER=${STR:(-9):9}

elif [ "$1" = "NextSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation"
        SEQ_PATH="/home/genomics/genomics-archive2/Genomics/NextSeq500_RawData"

elif [ "$1" = "MiSeq" ]; then
	
	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation"
        SEQ_PATH="/home/genomics/genomics-archive2/Genomics/MiSeq_RawData"

else

	echo "Please set the select the correct sequencer for data processing!"

fi

FN="$2_$(date|cut -b 12-19|sed 's/:/_/g')"

cd $FOLDER_PATH
#mkdir $2
mkdir $FN
chmod 775 $FN
cd $FN


#bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$2 -p 30 --barcode-mismatches 0 --ignore-missing-bcl --no-lane-splitting --ignore-missing-filter
#bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$FN -p 30 --ignore-missing-bcls --no-lane-splitting --ignore-missing-filter &> "$FOLDER_PATH/$FN/demultiplex_log.txt"
#bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$FN -p 20 --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"
#bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$FN -p 20 --barcode-mismatches 0 --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"

bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$FN -r 5 -p 5 -w 5 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"

#--mask-short-adapter-reads 0
#--minimum-trimmed-read-length 0
#bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$FN -r 5 -p 5 -w 5 --ignore-missing-controls --ignore-missing-bcls --ignore-missing-positions --ignore-missing-filter --no-lane-splitting --minimum-trimmed-read-length 0  &> "$FOLDER_PATH/$FN/demultiplex_log.txt"

#bcl2fastq --use-bases-mask=Y26,I8,Y98 \
#  --create-fastq-for-index-reads \
#  --minimum-trimmed-read-length=8 \
#  --mask-short-adapter-reads=8 \
#  --ignore-missing-positions \
#  --ignore-missing-controls \
#  --ignore-missing-filter \
#  --ignore-missing-bcls \
#  -r 6 -w 6 \
#  -R ${FLOWCELL_DIR} \
#  --output-dir=${OUTPUT_DIR} \
#  --interop-dir=${INTEROP_DIR} \
#  --sample-sheet=${SAMPLE_SHEET_PATH}



CHECK_FILE=$FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml

if [ -f $CHECK_FILE ]; then

        if [ "$1" = "NovaSeq" ]; then

		/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/ $2 NovaSeq $FOLDER_PATH/$FN/Stats/Stats.json

	elif [ "$1" = "NextSeq" ]; then

                mkdir "Data_processing"

                mv *.gz Data_processing

                mv ./Data_processing/Undetermined* ./
	
		/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/Data_processing $2 NextSeq $FOLDER_PATH/$FN/Stats/Stats.json

		elif [ "$1" = "MiSeq" ]; then

                /usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$FN/Stats/DemultiplexingStats.xml $FOLDER_PATH/$FN/ $2 MiSeq $FOLDER_PATH/$FN/Stats/Stats.json

        fi

	sendmail -vt < ./mail.txt

        /home/genomics/bin/change_per.sh $FOLDER_PATH/$FN

else
        echo "To: genomics@cshs.org" > mail_error.txt
        echo "Subject: demultiplexing error for $FN" >> mail_error.txt
        echo "From: titan_automation" >> mail_error.txt
        echo "" >> mail_error.txt
        echo "Error Message:" >> mail_error.txt
        echo "" >> mail_error.txt
        cp $FOLDER_PATH/$FN/demultiplex_log.txt /var/www/html/log/$FN_error.demultiplex_log.txt
#grep -A 10 -B 3 "ERROR" $FOLDER_PATH/$FN/log.txt >> mail_error.txt
	tail -n 20 $FOLDER_PATH/$FN/demultiplex_log.txt >> mail_error.txt
	sendmail -vt < mail_error.txt
       # rm -rf $FOLDER_PATH/$FN
fi

#if [ "$1" = "NovaSeq" ]; then

#	/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/ $2 NovaSeq $FOLDER_PATH/$2/Stats/Stats.json

#	sendmail -vt < ./mail.txt
	
#	chmod -R 775 $FOLDER_PATH/$2
	
#	chown genomics -R $FOLDER_PATH/$2
#	/home/genomics/bin/change_per.sh $FOLDER_PATH/$2

#	rm mail.txt

#elif [ "$1" = "NextSeq" ]; then

#	mkdir "Data_processing"

#	mv *.gz Data_processing

#	mv ./Data_processing/Undetermined* ./

#	chmod -R 775 $FOLDER_PATH/$2

#	chown genomics -R $FOLDER_PATH/$2	

#	/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/Data_processing $2 NextSeq $FOLDER_PATH/$2/Stats/Stats.json
#echo "Subject: the fastq generation for $1 is done!" | sendmail -v yizhou.wang@cshs.org
#	sendmail -vt < ./mail.txt

#	/home/genomics/bin/change_per.sh $FOLDER_PATH/$2

#	rm mail.txt

#elif [ "$1" = "MiSeq" ]; then

#	/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/ $2 MiSeq $FOLDER_PATH/$2/Stats/Stats.json

#        sendmail -vt < ./mail.txt

#	/home/genomics/bin/change_per.sh $FOLDER_PATH/$2

#	chmod -R 775 $FOLDER_PATH/$2

#	chown genomics -R $FOLDER_PATH/$2

#        rm mail.txt

#fi
