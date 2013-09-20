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
	$initialisation = get_for_statement_init($_); 
	$condition = get_for_statement_condition($_);
	@postexecution = get_for_statement_postexec($_);
	print "init = $initialisation\n";
	print "cond = $condition\n";
	print "exec = @postexecution\n";
	#print if /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
}