#!/usr/bin/perl -w

while("1") {
	last;
}

while (2 > $i) {
	print "$i\n";
	$i++;
	next if $i == 1;
}

while (++$k)
{
	print "$i"."\n";
	last if($k > 5);
	$k++;
}

while (1) {
	
	last;
}