#!/usr/bin/perl -w
$line = "complex regex statement";
print "line = $line\n";
print "$line = complex lower case\n" if $line =~ /complex/;
print "$line = complex ignore case\n" if $line =~ /COMPLEX/i;
$line =~ s/regex/reGX/i;
print "$line = regex substituted for regX\n";
$line =~ s/regx/reX/i;
print "$line = regX substituted for reX\n";
$line =~ s/e/5/gi;
print "$line = replace all e for 5\n";
print "line = $line\n";