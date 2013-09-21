#!/usr/bin/perl -w
while(@ARGV) {
	print "Testing $_\n";
	exec("./testfile.sh $_");
}