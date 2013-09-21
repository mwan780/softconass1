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

sub is_comment_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*\#.*$/;
}

sub get_function_args ( $ ) {
	my ($line) = @_;
	return "" if !($line =~ /^\s*sub\s+(\w+)\s*(\(.*?\))\s*\{?\s*$/);
	my $args = $2;
	my $arguments = "(";
	while($args =~ /[\$\@\%]/g) {
		$arguments .= "arg".$num++;
	}
	$arguments .= ")";
	return $arguments;
}

while(<>) {

	print get_function_args($_);
}
	