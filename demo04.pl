#!/usr/bin/perl -w
# Pops first element if comma seperated then adds end 
# splits elements on -- rather than , 
while ($text = <>) {
	chomp $text;
	if($text =~ /,/) {
		@array = split(',', $text);
		foreach $element (reverse @array) {
			$element .= ' - ';
		}
		shift @array;
		push @array, 'end';
		$text = join ('-', @array);
	}
	print "$text\n";
}