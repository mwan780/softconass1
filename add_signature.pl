#!/usr/bin/perl -w
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************
$unique = rand(10000000);
$tmp_file = "$0.$unique";
$tmp_file =~ s/[\.\/]//g;
$tmp_file .= ".tmp";

foreach $file (@ARGV) {
	open(IN, $file) or die "$0 : File could not be opened : $!\n";
    open(OUT, ">> $tmp_file");
    $first_line = <IN>;

    if ($first_line =~ /^\#\!/) {
    	
    	print OUT $first_line;
    	print $first_line;
    }
    $commentChar = "";
    if($file =~ /\.((sh)|(pl)|(py))$/) {
    	print "$1 uses # for comments\n";
   	    $commentChar = "#";
    } elsif ($file =~ /\.((c)|(java)|(h))$/i) {
    	print "$1 uses // for comments";
    	$commentChar = "//\n";
    } else { 
    	die "$0 : Comment Character not supported for file type\n"; 
    }

    print OUT "$commentChar *********************************\n";
    print OUT "$commentChar *********************************\n";
    print OUT "$commentChar Author:- Steven Falconieri    \n";
    print OUT "$commentChar *********************************\n";
    print OUT "$commentChar *********************************\n";

    while(<IN>) {
    	print OUT;
    }

    rename $tmp_file, $file;
    close(IN);
    close(OUT);

}

 




