#!/usr/bin/perl -w
use strict;

my $file = $ARGV[0];
my $fastq_path = $ARGV[1]; 
my $seq_id = $ARGV[2];
my $project_id = $ARGV[3];
my $piname = $ARGV[4];
my $seq_type = $ARGV[5];
my $comments_file = $ARGV[6];
my $seq_num = $ARGV[7];
my $info = $ARGV[8];
my @projects;
my @pi;
my @seq_types;


open IN, $file or die $!;
open INN, $comments_file or die $!;



if ($seq_num eq "multiple"){
	open INNN, $info or die $!;
	my @temp = <INNN>;
	foreach my $line (@temp){
		chomp $line;
		my @a = split("_",$line);
		my $piname=$a[1]."_".$a[2];
		push(@projects,$a[0]);
		push(@pi,$piname);
		push(@seq_types,$a[3]);
	}
	$project_id = join(",",@projects);
	$piname = join(",",@pi);
	$seq_type = join(",",@seq_types);

	close INNN;
}


my $comments = <INN>;


my @data = <IN>;

my @number = `grep -A 100 \"Project name=\\\"all\\\"\" $file |grep \"<BarcodeCount>\"`;

my $add_total = 0;
my $add_unde = 0;

foreach my $line (@number){
	my @a = split(">",$line);
	my @b = split("</",$a[1]);
	$add_total = $add_total + $b[0];
} 



my @unde = `grep -A 3 \"<Sample name=\\\"Undetermined\\\">\" $file|grep \"<BarcodeCount>\"`;

foreach my $line (@unde){
	my @a = split(">",$line);
        my @b = split("</",$a[1]);
	$add_unde = $add_unde + $b[0];
}

my $perce = sprintf("%.2f",$add_unde*100/$add_total)."%";


$add_unde =~ s/(?<=\d)(?=(?:\d\d\d)+\b)/,/g;;
$add_total =~ s/(?<=\d)(?=(?:\d\d\d)+\b)/,/g;


open OUT, "> mail.txt" or die $!;


print OUT "To: genomics\@cshs.org\n";
#print OUT "To: yizhou.wang\@cshs.org\n";
print OUT "Subject: Fastq generation is done for $seq_id\n";
print OUT "From: titan_automation\n\n";
print OUT "Sequencing Run Summary: \n\n";
print OUT "###############################################\n\n";
print OUT "Sequencing ID: $seq_id\n\n";
print OUT "Project ID: $project_id\n\n";
print OUT "PI name: $piname\n\n";
print OUT "Sequencing type: $seq_type\n\n";
print OUT "Comments: $comments\n\n";
print OUT "Total number of reads yielded = $add_total;\n\n";
print OUT "Number of undetermined reads = $add_unde;\n\n";
print OUT "$perce of reads is undetermined;\n\n";
print OUT "###############################################\n\n";
print OUT "The Fastq files are saved in \n";
print OUT "\n";
print OUT $fastq_path,"\n";
print OUT "\n";
print OUT "you can use this path to perform mapping and QC next.\n";


#print $cmd,"\n";

#my @number = system($cmd);


#foreach my $line (@data){
	
