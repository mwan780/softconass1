#!/usr/bin/perl -w 
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************

# ###############################
# ###### Output Functions #######
# ###############################

sub output_python ( $$ ) {
	my ($tab_depth, $python) = @_;
	$python = strip_dollar_signs($python);
	print "Output:- " if $debug;
	for($count = 0; $count < $tab_depth; $count++) {
		print "    ";
	}
	print "$python";
}

sub output_python_line ( $$$ ) {
	my ($tab_depth, $python, $last_line) = @_;
	$python = strip_dollar_signs($python);
	print "Output:- " if $debug;
	for($count = 0; $count < $tab_depth; $count++) {
		print "    ";
	}
	print "$python";
	print "\n" if !$last_line;
}

sub debug  ( $ )  {
	my ($message) = @_;
	print "Debug:- $message\n" if $debug;
}


# ###############################
# ###### Regex Functions ########
# ###############################
# Return:- Boolean 

sub has_opening_brace  ( $ )  {
	my ($line) = @_;
	return $line =~ /\{/;
}

sub has_strictly_closing_brace  ( $ )  {
	my ($line) = @_;
	return $line =~ /^[^\{]*\}/;
}
sub has_strictly_opening_brace  ( $ )  {
	my ($line) = @_;
	return $line =~ /^[^\}\{]*\{[^\{\}]*$/;
}

sub has_both_braces  ( $ )  {
	my ($line) = @_;
	return $line =~ /^[^\{]*\{[^\}]*\}[^\{\}]$/;	
}

sub has_closing_then_opening_braces  ( $ )  {
	my ($line) = @_;
	return $line =~ /^[^\}]*\}[^\{]*\{[^\{\}]$/;
}

sub is_closing_brace_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*\}\s*$/;
}

sub is_opening_brace_line ( $ )  {
	my ($line) = @_;
	return $line =~ /^\s*\{\s*$/;
}

sub is_comment_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*(\#.*)/;
}

sub reverse_order_if ( $ ) {
	my ($line) = @_;
	return $line =~ /\s*?.+?\sif\s*\(?.*\)?\s*$/;
}

sub else_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*\}\s*els[ie]f?\s*\{\s*$/;
}

sub print_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\s*[\.\,\+\*\-\/]\s*)*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\)?\s*$/;
}

sub get_print ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /^\s*(print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))[\.\,\+\-\/\*])*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\)?)/;
	return "";
}

sub strip_outermost_parentheses ( $ )  {
	my ($line) = @_;
	my $no_parentheses_line = $line;
	$no_parentheses_line =~ s/^([^\(]*)\(/$1/;
	$no_parentheses_line =~ s/^(.*)\)([^\)]*$)/$1$2/;
	return $no_parentheses_line;
}

sub strip_outermost_braces ( $ ) {
	my ($line) = @_;
	my $no_braces_line = $line;
	# Also replaces first occuring brace with a :
	$no_braces_line =~ s/^([^\{]*)\{/$1:/;
	$no_braces_line =~ s/^(.*)\}([^\}]*$)/$1$2/;
	return $no_braces_line;
}

sub strip_dollar_signs ( $ ) {
	my ($line) = @_;
	my $var_line = $line;
	$var_line =~ s/\$(\w+)/$1/g;
	return $var_line;
}

sub empty_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^$/;
}

sub var_declaration ( $ ) {
	my ($line) = @_;
	return $line =~ /\$\w+\s*\=\s*[\"\']?.*[\"\']?\s*$/;	
} 

sub strip_new_line ( $ ) {
	my ($line) = @_;
	$line =~ s/(".*)\\n(.*\".*)$/$1$2/;
	return $line;
}

# #######################################
# #### Recursive Conversion Function ####
# #######################################
# Return:- last line number read from
sub convert_to_python ( $$@ );
sub convert_to_python ( $$@ ) {
	my ($tab_depth, $line_num, @input) = @_;
	debug("Tab Depth = $tab_depth and input line number = ".$line_num."/".($#input+1));
	$curr_line = $line_num;
	for($curr_line = $line_num; $curr_line <= $#input; $curr_line++) {
		# Break up multiple lines of code into single lines
		$last_line = ($curr_line == $#input);
		$line = "$input[$curr_line]";
		debug("Current line number = $curr_line");
		if(!empty_line($line)) {
			@multiple_lines = split (/;\s*/, $line);
			debug("Multiple ($#multiple_lines+1) Lines Detected at line $curr_line") if @multiple_lines > 1;
			foreach $single_line (@multiple_lines) {
				chomp $single_line; 					# Is Force added to every line at the end
				# Striping on output instead --- should be able to delete this. $single_line = strip_dollar_signs($single_line);
				debug("Input:- $single_line");
				if(is_closing_brace_line($single_line)) {
					# #######################################
					# ###### Sole Closing Brace #############
					# #######################################
					debug("Line Type:- Closing Brace ");
					return ($curr_line);
				} elsif (is_opening_brace_line($single_line)) {
					# #######################################
					# ###### Sole Opening Brace #############
					# #######################################
					# Do Nothing as it has been implemented in if statement
					debug("Line Type:- Opening Brace ");
				} elsif (is_comment_line($single_line)) {
					# #######################################
					# ############## Comments ###############
					# #######################################
					# Print Comments Directly Out and removing leading spaces
					debug("Line Type:- Comments ");
					$single_line =~ /(#.*)/;
					$single_line = $1;
					if($curr_line == 0) {
						$single_line =~ s/perl -w/python2.7 \-u/;
					}
					output_python_line($tab_depth, "$single_line", $last_line);
				} elsif (var_declaration($single_line)) { 
					# #######################################
					# #######  Variabe Declaration  #########
					# #######################################
					debug("Line Type:- Variable Declaration ");
					output_python_line($tab_depth, "$single_line", $last_line);
					while($single_line =~ /\$(\w+)/g) {
						#$vars{$line}{$1} = 1;	# This may be useful later otherwise delete it
					}
				} elsif ($single_line =~ /\s*if\s*\(?/) {
					# #######################################
					# ########### If Statements #############
					# #######################################
					debug("Line Type:- If");
					if (has_strictly_opening_brace($single_line)) {
						# ############ Multi Line If Statement
						# ############ if (condition) {
						# ############ }
						debug("Line Type:- If Type:- Multi Line");
						$single_line =~ /^\s*if\s*(\([^\)]+\))/ or die "$0 : Unable to match multi line if condition";
						$condition = $1;
						$condition =~ tr/[\)\()]//;
						output_python_line($tab_depth, "if ($condition):", $last_line);
						$curr_line = convert_to_python($tab_depth+1, $curr_line+1, @input);
					} elsif (has_both_braces($single_line)) {
						# ############ Single Line If
						# ############ if condition { };
						debug("Line Type:- If Type:- Single Line with braces");
						$if_statement = strip_outermost_braces($single_line);
						output_python_line($tab_depth, "$if_statement", $last_line);		
					} elsif (reverse_order_if($single_line)) {
						# ############ Reverse order declarion 
						# ############ command if condition;
						debug("Line Type:- If Type:- Reverse Order");
						$single_line =~ /^(.*)if(.*)/ or die "$0 : Unable to match single line if command at line ".($curr_line+1);
						#$single_line =~ /\s*([\w\s]+)if/ 
						$command_to_exec = $1;

						#$single_line =~ /^.*?if(.+);/ or die "$0 : Unable to match single line if condition at line ".($curr_line+1);
						$condition = $2;
						$condition =~ tr/[\)\(]//;
						output_python_line($tab_depth, "if ($condition): $command_to_exec", $last_line);
					} elsif (!has_opening_brace($single_line) && !reverse_order_if($single_line)) {
						# ############ Not reverse order if statement and no opening bracket
						# ############ Assumed Opening Brace on next line
						debug("Line Type:- If Type:- Brace on Next line");
						output_python_line($tab_depth, "$single_line:", $last_line);
						$curr_line = convert_to_python($tab_depth+1, $curr_line+1, @input);
					} elsif ($single_line =~ /elsif\s*(\(?.*)\s*$/) {
						# #######################################
						# ######### ElsIf Statements ############
						# #######################################
						$condition = $1;
						debug("Line Type:- Else If ");
						$condition = strip_outermost_braces($condition);
						output_python_line(($tab_depth-1), "elif $condition", $last_line);
					} else {
						debug("Line Type:- If Type:- Undertermined !");
						output_python_line($tab_depth, "# $single_line", $last_line);
					}
				} elsif (else_line($single_line)) {
					# #######################################
					# ######### Else Statements #############
					# #######################################
					debug("Line Type:- Else ");
					debug("Line Type:- Else Type :- Else ");
					output_python_line(($tab_depth-1), "else:", $last_line);
				} elsif (print_line($single_line)) {
					# #######################################
					# ###############  Prints  ##############
					# #######################################
					debug("Line Type:- Print ");
					$print_line = strip_outermost_parentheses(get_print($single_line));
					$print_line = strip_new_line($print_line);
					$print_line =~ s/[\"\']\s*\$(\w+)\s*[\"\']/$1 /g;

					output_python_line($tab_depth, "$print_line", $last_line);					
				} else {
					# #######################################
					# ########### Undertermined #############
					# #######################################
					debug("Line Type:- Undertermined ");
					output_python_line($tab_depth, "# $single_line", $last_line);
				}
				debug("");
				debug("");
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
