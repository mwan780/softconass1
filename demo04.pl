#!/usr/bin/perl -w
# Pops first element if comma seperated then adds end 
# splits elements on -- rather than , 
while ($text = <>) {
	chomp $text;
	if($text =~ /,/) {
		$text .= ", end, the";
		@array = split(', ', $text);
		@array = reverse @array;
		foreach $element (@array) {
			print "$element\n";
		}
		shift @array;
		push @array, 'start';
		$text = join ('-', @array);
	}
	print "$text\n";
}