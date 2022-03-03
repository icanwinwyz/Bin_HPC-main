#!/usr/bin/perl -w
use strict;

my $file =shift;

open IN, $file or die "$!";

my @data=<IN>;

foreach my $line(@data){
	chomp $line;
	if($line=~/^chr\d+/){
		my@a=split("\t",$line);
		my@b=split("/",$a[$#a]);
		$a[$#a]=$b[$#b];
		print join("\t",@a),"\n";
	}
}
