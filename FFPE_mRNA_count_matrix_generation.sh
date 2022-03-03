cd results
for dir2 in */
do
dir2="$dir2"
echo $dir2
sample2=$(echo $dir2 | cut -d'_' -f 1)
suffix6="_fastq_gz"
sampleName2=${sample2%"$suffix6"}
cd $dir2
mv *counts.txt ${sampleName2}_counts.txt
cd ..
{ printf 'Gene\t'"${sampleName2}"'\n'; cat ${dir2}/${sampleName2}_counts.txt; } > ${sampleName2}_counts.txt
done
paste *_counts.txt | awk 'NR==1{for(i=1;i<=NF;i++)b[$i]++&&a[i]}{for(i in a)$i="";gsub(" +"," ")}1' > counts.txt
