#!/usr/bin/perl -w
sub has_both_braces  ( $ )  {
	my ($line) = @_;
	return $line =~ /^[^\{]*\{[^\}]*\}[^\{\}]$/;	
}

sub has_closing_then_opening_braces  ( $ )  {
	my ($line) = @_;
	return $line =~ /^[^\}]*\}[^\{]*\{[^\{\}]$/;
}

sub has_pre_inc ( $ ) {
	my ($line) = @_;
	return $line =~ /\+\+\w/;
}

sub has_pre_dec ( $ ) {
	my ($line) = @_;
	return $line =~ /\-\-\w/;
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
	