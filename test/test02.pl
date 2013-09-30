#!/usr/bin/perl -w
# Test For Statements
$i = 0;
@array = ();
foreach $i (1..9) {
	print $i;
	push @array, $i
}
print "\n";
print "Array Default Print\n";
print @array;

for($i = 0; $i < 9 && $i > -1; $i++) {
	print $i;
}
print "\n";

print "\n";
print "Iterative Array Print\n";
foreach $i (@array) 
{
	print $i;
}

print "\n";