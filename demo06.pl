#!/usr/bin/perl -w
sub factorial ( $ ) {
	my ($num) = @_;
	return $num * factorial($num - 1) if $num > 1;
	return $num;
}

$fac5 = factorial (5);
print "5! = $fac5";