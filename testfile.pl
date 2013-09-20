#!/usr/bin/perl -w
$ran = rand(100000000);
$temp= "$0$ran.tmp";

while($file = shift @ARGV) {
	print "Testing $file\n";
	exec("./perl2python.pl $file > $temp") or die "Cannot output file\n";
	print "Ouptut Generated\n";
	$python_file = $file;
	$python_file =~ s/.$//;
	$python_file .= "y";
	print "Python file is $python_file\n";
	print "Compare source code __________________________________________";
	if(exec("diff -y $temp $python_file")) {
		print " Passed\n";
	} else {
		print " Failed\n";
	}
	print "Compilation Test _____________________________________________";
	if(exec("./$temp > generated$temp")) {
		print " Passed\n";
	} else {
		print " Failed\n";
	}
	exec("./$python_file > expected$temp") or die "Cannot generated expected output\n";
	print "Compare program output________________________________________";
	if(exec("diff -y generated$temp expected$temp")) {
		print " Passed\n";
	} else {
		print " Failed\n";
	}
}

exec("rm *.tmp");