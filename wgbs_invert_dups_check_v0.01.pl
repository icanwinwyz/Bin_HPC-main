#!/usr/bin/perl -w
##This script count the inverted dups by count the first N bases' match rate in two ends' sequences.

## take care, 1st end, T should be also considered as C, while in 2nd end, A should be also considered as G

## author: Yaping Liu  lyping1986@gmail.com 
## time: 2013-1-8

#Usage:  perl invert_dups_check.pl [option] output_log.txt sample.1st_end.fastq sample.2nd_end.fastq 


use strict;
use Getopt::Long;

my $mismatch=3;
my $first_N=40;
my $maxseqs=1E15;

sub usage {
	
    print "\nUsage:\n";
    print "perl invert_dups_check.pl [Options]  output_log.txt sample.1st_end.fastq sample.2nd_end.fastq\n\n";

    print " This script count the inverted dups by count the first N bases' match rate between two ends' sequences\n";
    print "It provides another way to count inverted dups other than count the same starting coordinate for mapped & proper paired reads, which could count inverted dups in all of the reads\n\n";
	print "[Options]:\n\n";
	
	print "  --mismatch INT : maximum mismathces allowed for account the inverted dups. (Default: 3)\n\n";
	print "  --first_N INT : First N bases to count for the matches. (Default: 40)\n\n";
	print "  --maxseqs INT : Only do the first n read pairs. (Default: Infinity)\n\n";
}

GetOptions(
	"mismatch=i" => \$mismatch,
	"first_N=i" => \$first_N,
	"maxseqs=i" => \$maxseqs,
);

my $output_log = $ARGV[0];
my $first_end = $ARGV[1];
my $second_end = $ARGV[2];



if ( scalar(@ARGV) < 3 )
{ 
    usage();
    print sprintf("args(%d) = %s\n",scalar(@ARGV),join(", ",@ARGV));
    die;
}


my $linecount_within = 1;
my $linecount_global = 1;
my $enough_long_pairs=0;
my $num_inv_dups = 0;
my $cur_name = 0;

#open(FH1,"<$first_end") or die "Can't read $first_end\n";
#open(FH2,"<$second_end") or die;
open(FH1,"gunzip -c $first_end |") or die;
open(FH2,"gunzip -c $second_end |") or die;

SEQ: while(my $seq1 = <FH1>, my $seq2 = <FH2>){

    last SEQ if ($linecount_global > ($maxseqs*4));
	chomp($seq1);
	chomp($seq2);
		if ($linecount_within == 1)
        {
            # Double check the format
            if($seq1 =~ /^\@/ and $seq2 =~ /^\@/){
		my $seq1orig = $seq1;
            	$seq1 =~ s/(\s)1(\S*)$/${1}2${2}/;
            	if($seq1 ne $seq2){
            		print STDERR "Incorrect FASTQ file \nLine ${linecount_global}: reads $seq1orig\t/\t$seq1\t/\t$seq2 are not paired and the same order in both of ends fastq files\n";
            	}
            	else{
		    $cur_name = $seq1;
            	}
            }
            else{
            	print STDERR "Incorrect FASTQ file \nLine ${linecount_global}: $seq1\nMod4 lines should start with \@\n";

            }
  
        }
        elsif ($linecount_within == 2)
        {
			if(length($seq1) >= $first_N and length($seq2) >= $first_N){
					if(my $matches_str = &match($seq1, $seq2)){
						$num_inv_dups++;

#
						print "$cur_name\n$matches_str\n";
					}
					$enough_long_pairs++;
			}

        }
        elsif ($linecount_within == 4)
        {
        	$linecount_within = 0;
		$cur_name = "";
        }
	$linecount_within++;
	$linecount_global++;
}
close(FH1);
close(FH2);


#my $percentage = sprintf("%.2f",100*$num_inv_dups/$enough_long_pairs);
#print "There are $enough_long_pairs enough long (>=$first_N) pair of reads in the fastq file\n";
#print "There are $num_inv_dups inverted dups reads (${percentage}%) in the fastq file\n";
#$enough_long_pairs *= 2;
## take care!! Here is not the real mapped reads!! Here is the reads that in the fastq file. This is just for USCEC pipeline convenient. 
$linecount_global--;
my $npairs = $linecount_global / 4;
my $nends = $npairs * 2;
my $percentage = sprintf("%.2f",100*$num_inv_dups/$npairs);
open(OUT,">$output_log") or die;
print OUT "nmismatch=$mismatch\n";
print OUT "matchlen=$first_N\n";
print OUT "mapped reads=$nends\n";
print OUT "mapped pairs=$npairs\n";
print OUT "Inverted Read Pairs=$num_inv_dups\n";
print OUT "inverted Pair Percentage=$percentage\n";
close(OUT);

sub match{
	my $seq= shift @_;
	my $query = shift @_;
	my @seqs=split "",$seq;
	my @queries = split "",$query;
	my $mismatch_count = 0;
	my $matches_str = "";

#	my $loopnum = $first_N;
	my $loopnum = scalar(@seqs);

	for(my $i=0;$i<$loopnum;$i++){

		if(&bisulfite_match($seqs[$i],$queries[$i])){
		    $matches_str .= "X";
			
		}
		else{
		    $mismatch_count++ if ($i < $first_N);
		    $matches_str .= "-";
		}

		if($mismatch_count > $mismatch){
		    # return 0;  # Do this to make it much faster
		}
	}

	my $out = 0;

	if ($mismatch_count <= $mismatch)
	{
	    $out = sprintf("%s\n%s\n%s\n","seq1  :$seq","seq2  :$query","match:$matches_str");
	}


	return $out;
	
}

sub bisulfite_match{
	my $first = shift @_;
	my $second = shift @_;

	if (!$first || !$second)
	{
	    return 1;
	}

	if($first eq $second){
		return 1;
	}
	else{
		if(($first eq 'T' and $second eq 'C') or ($first eq 'G' and $second eq 'A')){
			return 1;
		}
	}
	return 0;
}
