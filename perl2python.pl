#!/usr/bin/perl -w 
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************

# ###############################
# ###### Output Functions #######
# ###############################

sub output_python ($$) {
	my ($tab_depth, $python) = @_;
	print "Output:- " if $debug;
	for($count = 0; $count < $tab_depth; $count++) {
		print "    ";
	}
	print "$python";
}

sub debug ($) {
	my ($message) = @_;
	print "Debug:- $message\n" if $debug;
}


# ###############################
# ###### Regex Functions ########
# ###############################
# Return:- Boolean 

sub has_opening_brace ($) {
	my ($line) = @_;
	return $line =~ /\{/;
}

sub has_strictly_closing_brace ($) {
	my ($line) = @_;
	return $line =~ /^[^\{]*\}/;
}
sub has_strictly_opening_brace ($) {
	my ($line) = @_;
	return $line =~ /^[^\{]*\{[^\{\}]*$/;
}

sub has_both_braces ($) {
	my ($line) = @_;
	return $line =~ /^[^\{]*\{[^\}]*\}[^\{\}]$/;	
}

sub has_closing_then_opening_braces ($) {
	my ($line) = @_;
	return $line =~ /^[^\}]*\}[^\{]*\{[^\{\}]$/;
}

sub is_closing_brace_line ($) {
	my ($line) = @_;
	return $line =~ /^\s*\}\s*$/;
}

sub is_opening_brace_line ($) {
	my ($line) = @_;
	return $line =~ /^\s*\{\s*$/;
}

sub is_comment_line ($) {
	my ($line) = @_;
	return $line =~ /^\s*(\#.*)/;
}

sub reverse_order_if ($) {
	my ($line) = @_;
	return $line =~ /^\s*\w+\s*if\s*\w+\s*$/;
}

sub print_line ($) {
	my ($line) = @_;
	return $line =~ /^\s*print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))[\.\,])*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\)?\s*$/;
}

sub get_print ($) {
	my ($line) = @_;
	return $1 if $line =~ /^\s*(print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))[\.\,])*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\)?)/;
	return "";
}

sub strip_outermost_parentheses ($) {
	my ($line) = @_;
	$no_parentheses_line = $line;
	$no_parentheses_line =~ s/^([^\(])\(/$1/;
	$no_parentheses_line =~ s/^(.*)\)([^\)]*$)/$1$2/;
	return $no_parentheses_line;
}

sub empty_line ($) {
	my ($line) = @_;
	return $line =~ /^$/;
}

# #######################################
# #### Recursive Conversion Function ####
# #######################################
# Return:- last line number read from
sub convert_to_python ($$@) {
	my ($tab_depth, $line_num, @input) = @_;
	debug("Tab Depth = $tab_depth and input line number = ".$line_num."/".($#input+1));
	$curr_line = $line_num;
	for($curr_line = $line_num; $curr_line <= $#input; $curr_line++) {
		# Break up multiple lines of code into single lines
		
		$line = "$input[$curr_line]";
		debug("Current line number = $curr_line");
		if(!empty_line($line)) {
			@multiple_lines = split (/;\s*/, $line);
			debug("Multiple ($#multiple_lines+1) Lines Detected at line $curr_line");
			foreach $single_line (@multiple_lines) {
				chomp $single_line; 					# Is Force added to every line at the end
				debug("Input:- $single_line;");
				if(is_closing_brace_line($single_line)) {
					debug("Closing Bracket Detected at line $curr_line");
					return ($curr_line);
				} elsif (is_opening_brace_line($single_line)) {
					# Do Nothing as it has been implemented in if statement
				} elsif (is_comment_line($single_line)) {
					# Print Comments Directly Out and removing leading spaces
					$single_line =~ /(#.*)/;
					output_python($tab_depth, "$1\n");
				} elsif ($single_line =~ /\s*if\s*\(?/) {
					# If Statements
					if (has_strictly_opening_brace($single_line)) {
						# Multi Line If Statement
						# if (condition) {
						# }
						$single_line =~ /^\s*if\s*(\([^\)]+\))/ or die "$0 : Unable to match multi line if condition";
						$condition = $1;
						$condition =~ tr/[\)\()]//;
						output_python($tab_depth, "if ($condition):\n");
						$curr_line = convert_to_python($tab_depth+1, $curr_line+1, @input);
					} elsif (has_both_braces($single_line)) {
						# Single Line If
						# if condition { };

					} elsif (reverse_order_if(single_line)) {
						# Reverse order declarion 
						# command if condition;
						$ifvars = split /\s*if\s*/, $single_line or die "$0 : Unable to match single line if command at line ".($curr_line+1);
						#$single_line =~ /\s*([\w\s]+)if/ 
						$command_to_exec = $ifvars[0];
						#$single_line =~ /^.*?if(.+);/ or die "$0 : Unable to match single line if condition at line ".($curr_line+1);
						$condition = $ifvars[1];
						$condition =~ tr/[\)\()]//;
						output_python($tab_depth, "if ($condition): $command_to_exec\n");
					} elsif (!has_opening_brace($single_line) && !reverse_order_if($single_line)) {
						# Not reverse order if statement and no opening bracket
						output_python($tab_depth, "$single_line:\n");
						$curr_line = convert_to_python($tab_depth+1, $curr_line+1, @input);
					}
				} elsif (print_line($single_line)) {
					$print_line = strip_outermost_parentheses(get_print($single_line));
					output_python($tab_depth, "$print_line,\n");
				} else {
					output_python($tab_depth, "# $single_line\n");
				}
			}
		} else {
			output_python($tab_depth, "\n");
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
	debug("Reading from File\n");
	convert_to_python(0, 0, <PERL>);
}
# Process STDIN
if ( !($#ARGV >= 0) ) {
	debug("Reading from standard input\n");
	convert_to_python(0, 0, <STDIN>);
}
