#!/usr/bin/perl -w
@array = (0..10);
$i = 0;
$array[$i++] = 0;
$i--;
print "$array[++$i]\n";