INFILE=`awk '{print $1}' $1|sed -n "${SGE_TASK_ID}p"`

#gzip -c $INFILE > $INFILE.gz
gzip -t -v $INFILE.gz
