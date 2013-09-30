#!/usr/bin/perl -w
@array = ();
foreach $i (0..10) {
	$array[$i]++;
}
print "@array\n";
for($i = 10; $i >= 0; $i--) {
	$array[$i] = $i;
}
print "@array\n";