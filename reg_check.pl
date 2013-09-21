#!/usr/bin/perl -w
sub get_for_statement_init ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /\s*for\s*\(\s*(.*?;).*?;.*?\)\s*\{?\s*$/;
	return "";
}

sub get_for_statement_condition ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /\s*for\s*\(\s*.*?;(.*?);.*?\)\s*\{?\s*$/;
	return "";
}

sub get_for_statement_postexec ( $ ) {
	my ($line) = @_;
	@exec_lines = split /,/, $1 if $line =~ /\s*for\s*\(\s*.*?;.*?;(.*?)\)\s*\{?\s*$/;
	return @exec_lines;
}

while(<>) {
	print "var = $1\n" if /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
	print "set = $2\n" if /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
	print "range($1, $2)" if /\s*\((.+)\s*\.\.\s*(.+)\)\s*/;
}
	