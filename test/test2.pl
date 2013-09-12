#!/usr/bin/perl -w
$i = 0;
for($i = 0; $i < 9; $i++) {
	print $i;
}
print "\n";
#@array = ();
foreach $i (1..9) {
	print $i;
	$array[$i] = $i + 10;
}
print "\n";
foreach $i (@ARGV) {
	print $array[$i];
}

print "\n";
