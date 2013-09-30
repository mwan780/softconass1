#!/usr/bin/perl -w

$string = " hello split on spaces ";
@array = split(' ', $string);
print @array;