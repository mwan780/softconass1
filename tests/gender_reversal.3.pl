#!/usr/bin/perl -w
# written by andrewt@cse.unsw.edu.au as a COMP2041 example
# For each file given as argument replace occurrences of Hermione
# allowing for some misspellings with Harry and vice-versa.
# Relies on Zaphod not occurring in the text.
# text is read into a string, the string is changed,
# then the file is over-written

# See http://www.perlmonks.org/?node_id=1952
# for aletrantive way to read a file into a string

foreach $filename (@ARGV) {
    open F, "<$filename" or die "$0: Can not open $filename: $!";
    while ($line = <F>) {
        $novel .= $line;
    }
    close F;
    
    $novel =~ s/Herm[io]+ne/Zaphod/g;
    $novel =~ s/Harry/Hermione/g;
    $novel =~ s/Zaphod/Harry/g;
    
    open G, ">$filename" or die "$0: Can not open $filename : $!";
    print G $novel;
    close G;
}
