#!/usr/bin/perl -w
$var = "hello\n";
chomp $var;
@array = split ('l', $var);
print "@array\n";
$line = join ('-', @array);
print "$line\n";
$line =~ s/l/s/gi;
print "$line\n";
$line =~ /l/i;
print "$line\n";
$line =~ /p/;
print "$line\n";