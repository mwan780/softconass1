#!/usr/bin/perl -w

$string = " hello split on spaces ";
@array = split(' ', $string);
print "@array \n";
$string = join(' ', @array);
print "$string \n";