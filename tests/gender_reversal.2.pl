#!/usr/bin/perl -w
# written by andrewt@cse.unsw.edu.au as a COMP2041 example
# For each file given as argument replace occurrences of Hermione
# allowing for some misspellings with Harry and vice-versa.
# Relies on Zaphod not occurring in the text.
# Modified text is stored in an array then
# the file is over-written

foreach $filename (@ARGV) {
    open F, "<$filename" or die "$0: Can not open $filename: $!";
    @lines = <F>
    close F;
    
    # note loop variable $line is aliased to array elements
    # changes to it change the corresponding array element
    foreach $line (@lines) {
        $line =~ s/Herm[io]+ne/Zaphod/g;
        $line =~ s/Harry/Hermione/g;
        $line =~ s/Zaphod/Harry/g;
    }
    
    open G, ">$filename" or die "$0: Can not open $filename : $!";
    print G @lines;
    close G;
}
