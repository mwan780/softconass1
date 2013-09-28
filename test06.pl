#!/usr/bin/perl -w
$var = "hello\n";
chomp $var;
@array = split ('l', $var);
$var = join ('-', @array);
$line =~ s/l/s/gi;
$line =~ /l/i;
$line =~ /p/;
