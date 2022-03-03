#!/usr/bin/perl -w
use strict;

use JSON;
use Encode;
use Data::Dumper;

my $file = $ARGV[0];
my $fastq_path = $ARGV[1]; 
my $proj_ID = $ARGV[2];
my $seq_type= $ARGV[3];


open IN, $file or die $!;

my @data = <IN>;

my @number = `grep -A 100 \"Project name=\\\"all\\\"\" $file |grep \"<BarcodeCount>\"`;

my $add_total = 0;
my $add_unde = 0;

foreach my $line (@number){
	my @a = split(">",$line);
	my @b = split("</",$a[1]);
	$add_total = $add_total + $b[0];
} 

my @unde;

if ($seq_type eq "NextSeq"){

	@unde = `grep -A 18 \"<Sample name=\\\"Undetermined\\\">\" $file|grep \"<BarcodeCount>\"`;

}elsif($seq_type eq "NovaSeq"){

	@unde = `grep -A 10 \"<Sample name=\\\"Undetermined\\\">\" $file|grep \"<BarcodeCount>\"`;

}elsif($seq_type eq "MiSeq"){

	@unde = `grep -A 3 \"<Sample name=\\\"Undetermined\\\">\" $file|grep \"<BarcodeCount>\"`;

}

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
#print OUT "To: di.wu\@cshs.org\n";
print OUT "Subject: Fastq generation is done for $seq_type $proj_ID\n";
print OUT "From: titan_automation\n\n";
print OUT "Total number of reads yielded = $add_total;\n\n";
print OUT "Number of undetermined reads = $add_unde;\n\n";
print OUT "$perce of reads is undetermined;\n\n";
print OUT "The Fastq files are saved in \n";
print OUT "\n";
print OUT $fastq_path,"\n";
print OUT "\n";
print OUT "you can use this path to perform mapping and QC next.\n\n";


my $json_file = $ARGV[4];
my $context;
open TXT, $json_file or die "Can't open $json_file!\n";
while (<TXT>) {
      $context .= $_;
}
close TXT;
my $obj=decode_json($context);

#my $test = ${$obj}{"ConversionResults"}->[0]->{"DemuxResults"}->[0]->{"SampleName"};
my $test = ${$obj}{"ConversionResults"}->[0]->{"DemuxResults"};
my $test1 = ${$obj}{"ConversionResults"};

my %sample_count;

foreach my $line (@$test){
	$sample_count{$line->{"SampleName"}}=0;
}


foreach my $number (@$test1){
	my $test = $number->{"DemuxResults"};
	foreach my $line (@$test){
		$sample_count{$line->{"SampleName"}}=$sample_count{$line->{"SampleName"}}+$line->{"NumberReads"};
#		print $line->{"SampleName"},"\n";
#		print $line->{"NumberReads"},"\n";
	}
}

print OUT join("\t","Sample","Reads_yield"),"\n";

foreach my $key (keys %sample_count){
	print OUT join(" = ",$key,commify($sample_count{$key})),"\n";
}


#print Dumper \@test;

print OUT "\n\n";

my$unde=${$obj}{"UnknownBarcodes"};

print OUT "Index in Undetermined Reads (>1M):\n";
foreach my $line(@$unde){
        my $number=$line->{"Lane"};
        my $temp=$line->{"Barcodes"};
        print OUT join("","Lane",$number),"\n";
        foreach my $cal(keys %$temp){
                if($$temp{$cal} > 1000000){
                        print OUT join(" = ",$cal,commify($$temp{$cal})),"\n\n";
                }
        }
}



sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}


