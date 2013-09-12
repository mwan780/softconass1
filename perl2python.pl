#!/usr/bin/perl -w 
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************


sub convert_to_python {
	my (@input) = @_;
	foreach $line (@input) {
		print $line;
	}
}

foreach $file (@ARGV) {
	open(PERL, $file) or die "$0: Could not open file : $!\n";
	convert_to_python(<PERL>);
}

if ( !($#ARGV >= 0) ) {
	print "Reading from standard input\n";
	convert_to_python(<STDIN>);
}
