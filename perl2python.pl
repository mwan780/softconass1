#!/usr/bin/perl -w 
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************

# ########################
# ###### Functions #######
# ########################

sub closing_bracket_line {
	my ($line) = @_;
	return $line =~ /^\s*\}\s*$/;
}

sub comment_line {
my ($line) = @_;
	return $line =~ /^\s*(\#.*)/;
}


# Returns last line read
sub convert_to_python {
	my (@input, $depth, $line_num) = @_;
	for($curr_line = $line_num; $curr_line < $#input; $curr_line++) {
		# Break up multiple lines of code into single lines
		$line = $input[$curr_line];
		@multiple_lines = split (/;\s*/, $line) if ($line =~ /.;\s*[ \#]+/);
		push @multiple_lines, $line if !(defined @multiple_lines);
		foreach $single_line (@multiple_lines) {
			chomp $single_line; 					# Is Force added to every line at the end
			print "Debug:- $single_line\n" if $debug;   		# Debugging
			if(closing_bracket_line($single_line)) {
				print "Debug:- Closing Bracket Detected\n" if $debug;
				return $curr_line;
			} elsif (comment_line($single_line)) {
				# Print Comments Directly Out and removing leading spaces
				$single_line =~ /(#.*)/;
				print "$1\n";
			} elsif ($single_line =~ /\s*if\s*\(?/) {
				# If Statements
				if ($single_line =~ /\{/) {
					# Multi Line If Statement
					$single_line =~ /^\s*if\s*(\([^\)]+\))/ or die "$0 : Unable to match multi line if condition";
					$condition = $1;
					print "if ($condition):\n";
					$curr_line = convert_to_python(@input, $depth+1, $curr_line+1);
				} else {
					# Single Line If
					# Reverse order declarion (command if condition)
					$single_line =~ /\s*([\w\s]+)if/ or die "$0 : Unable to match single line if command";
					$command_to_exec = $1;
					$single_line =~ /if\s*(.*);/ or die "$0 : Unable to match single line if condition";
					$condition = $1;
					$condition = tr/[\(\)]//;
					print "if ($condition): $command_to_exec\n";
				}
			} else {
				print "# $single_line\n";
			}
		}
	}
}







# ########################
# ######### Main #########
# ########################
# Debugging Flag
if($#ARGV > 0 && $ARGV[0] =~ /\-d/) {
	$debug = 1;
	shift @ARGV
}
# Process Files
foreach $file (@ARGV) {
	open(PERL, $file) or die "$0: Could not open file : $!\n";
	convert_to_python(<PERL>, 0, 0);
}
# Process STDIN
if ( !($#ARGV >= 0) ) {
	print "Reading from standard input\n" if $debug;
	convert_to_python(<STDIN>, 0, 0);
}
