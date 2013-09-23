#!/usr/bin/perl -w 
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************

# Style Notes:-
# If the first character of a variable is capitalised, this implies that the variable is a 
# reference to another variable does not contain any contents but a pointer to the actual data

#use constant NOT_CONVERTED => -1;
#use strict;

# #############################################################################################
# #############################################################################################
# #############################################################################################
# ############################       Function Prototypes      #################################
# #############################################################################################
# #############################################################################################
# #############################################################################################

sub convert_prepost_incdec ( $ );
sub convert_to_python ( $$$ );
sub debug  ( $ );
sub get_for_statement_condition ( $ );
sub get_for_statement_init ( $ );
sub get_for_statement_postexec ( $ );
sub get_incdec_op ( $ );
sub get_post_var( $ );
sub get_pre_var( $ );
sub get_print ( $ );
sub has_both_braces  ( $ );
sub has_closing_then_opening_braces  ( $ );
sub has_opening_brace  ( $ );
sub has_post_dec ( $ );
sub has_post_inc ( $ );
sub has_pre_dec ( $ );
sub has_pre_inc ( $ );
sub has_prepost_incdec ( $ );
sub has_strictly_closing_brace  ( $ );
sub has_strictly_opening_brace  ( $ );
sub is_closing_brace_line ( $ );
sub is_comment_line ( $ );
sub is_else_line ( $ );
sub is_empty_line ( $ );
sub is_foreach_statement_line ( $ );
sub is_for_statement ( $ );
sub is_opening_brace_line ( $ );
sub is_print_line ( $ );
sub is_reverse_order_if_line ( $ );
sub is_standard_for_statement_line ( $ );
sub is_var_declaration_line ( $ );
sub output_python ( $$ );
sub output_python_line ( $$$ );
sub strip_dollar_signs ( $ );
sub strip_invalid_python ( $ );
sub strip_new_line ( $ );
sub strip_outermost_braces ( $ );
sub strip_outermost_parentheses ( $ );




# #############################################################################################
# #############################################################################################
# #############################################################################################
# ##############################            MAIN           ####################################
# #############################################################################################
# #############################################################################################
# #############################################################################################


# Debugging Flag
# Must be first program argument
if($#ARGV > 0 && $ARGV[0] =~ /\-d/) {
	$debug = 1;
	shift @ARGV;
} 

%keywords = (
	'last' => 'break',
	'continue' => 'continue',
	'print' => 'print',
	'split' => '',
	'join' => '',
	'=~ s/' => 're.sub',
	'=~ /' => 're.match',
	'sub' => 'def',
);

# Process Files
# Check if any files have been parsed as arguments
# If so execute the conversion to each file individually
# If not continue to Standard Input processing below
foreach my $file (@ARGV) {
	open(PERL, $file) or die "$0: Could not open file : $!\n";
	debug("Reading from File");
	@perl_input = <PERL>;
	$Perl_ref = \@perl_input;
	convert_to_python(0, 0, $Perl_ref);
}
# Process Standard Input if no files were parsed
if ( !($#ARGV >= 0) ) {
	debug("Reading from standard input");
	@std_input = <STDIN>;
	$Stdin_ref = \@std_input;
	convert_to_python(0, 0, $Stdin_ref);
}


# #############################################################################################
# #############################################################################################
# #############################################################################################
# ################################       Output Functions        ##############################
# #############################################################################################
# #############################################################################################
# #############################################################################################

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-    Outputs to python code to standard output                       %
# Prototype:-  void output_python($tab_depth, $python)                         %
# Param int    $tab_depth :- Level of indentation to prepend to output         %
# Param string $python    :- Content to output                                 %
# Returns                 :- void                                              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub output_python ( $$ ) {
	my ($tab_depth, $python) = @_;
	my @valid_python = strip_invalid_python($python);
	foreach my $python_line (@valid_python) {
		#print "Output:- " if $debug;
		for(my $count = 0; $count < $tab_depth; $count++) {
			print "   ";
		}
		print "$python_line";
	}
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Outputs python code to standard output followed                %
#               by newline character                                           %
# Prototype:-   void output_python_line($tab_depth, $python, $last_line)       %
# Param int     $tab_depth :- Level of indentation to prepend to output        %
# Param string  $python    :- Content to output                                %
# Param boolean $last_line :- Determines if new line char should be appended   %
# Returns                  :- void                                             %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub output_python_line ( $$$ ) {
	my ($tab_depth, $python, $last_line) = @_;
	my @valid_python = strip_invalid_python($python);
	foreach my $python_line (@valid_python) {
		print "Output:- " if $debug;
		for(my $count = 0; $count < $tab_depth; $count++) {
			print "   ";
		}
		print "$python_line";
		print "\n" if !$last_line;
	}
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Outputs message with new line character to standard output if  %
#               debugging flag (-d) has been parsed as programs first argument %
# Prototype:-   void debug($message)                                           %
# Param string  $message   :- Content to output                                %
# Returns                  :- void                                             %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub debug  ( $ )  {
	my ($message) = @_;
	print "Debug:- $message\n" if $debug;
}

# #############################################################################################
# #############################################################################################
# #############################################################################################
# #######################        Recursive Conversion Functions          #######################
# #############################################################################################
# #############################################################################################
# #############################################################################################
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-       Recursively converts perl code to python by evaulating a line%
#                 at a time and various syntax cases.                          %
# Prototype:-     int  debug($tab_depth, $line_num, $Input)                    %
# Param int       $tab_depth :- Indentation level to prepend to python output  %
# Param int       $line_num  :- Current line number of input array             %
# Param array ref $Input     :- Reference to array of input lines              %
# Returns                    :- int Number of last line converted              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Return:- last line number read from
sub convert_to_python ( $$$ ) {
	my ($tab_depth, $line_num, $Input) = @_;
	debug("Tab Depth = $tab_depth and input line number = ".$line_num."/".($#{$Input}+1));
	die "Line Number $line_num not in file\n" if ($line_num < 0 || $line_num > $#{$Input});
	my $curr_line = $line_num;
	for($curr_line = $line_num; $curr_line <= $#{$Input}; $curr_line++) {
		# Break up multiple lines of code into single lines
		my $last_line = ($curr_line == $#{$Input});
		my $line = "${$Input}[$curr_line]";
		debug("Current line number = $curr_line");
		chomp $line;
		if(!is_empty_line($line)) {
			debug("Ignore ; since for statement line") if is_standard_for_statement_line($line);
			my @multiple_lines = split (/;\s*/, $line) if !is_standard_for_statement_line($line);
			push @multiple_lines, $line if is_standard_for_statement_line($line);
			debug("Multiple ($#multiple_lines+1) Lines Detected at line $curr_line") if @multiple_lines > 1;
			foreach my $single_line (@multiple_lines) {
				chomp $single_line; 					# Is Force added to every line at the end
				# Striping on output instead --- should be able to delete this. $single_line = strip_dollar_signs($single_line);
				$single_line = strip_outer_spaces($single_line);
				debug("Input:- $single_line");
				if(is_closing_brace_line($single_line)) {
					# #######################################
					# ###### Sole Closing Brace #############
					# #######################################
					debug("Line Type:- Closing Brace ");
					debug("Returning after line $curr_line and depth $tab_depth");
					return ($curr_line);
				} elsif (is_opening_brace_line($single_line)) {
					# #######################################
					# ###### Sole Opening Brace #############
					# #######################################
					# Do Nothing as it has been implemented in if statement below
					debug("Line Type:- Opening Brace ");
				} elsif (is_comment_line($single_line)) {
					# #######################################
					# ############## Comments ###############
					# #######################################
					# Print Comments Directly Out and removing leading spaces
					debug("Line Type:- Comments ");
					$single_line =~ /(#.*)/;
					$single_line = $1;
					my $first_line = ($curr_line == 0);
					# Convert Shabang 
					$single_line =~ s/perl \-w/python2.7 \-u/;
					# Print all consecutive comment lines
					output_python_line($tab_depth, $single_line, $last_line);
					while(is_comment_line(${$Input}[$curr_line+1])) {
						# Note ++ increments the current line counter for accurate return val
						debug("Current line number = ".(1+$curr_line));
						$single_line = ${$Input}[++$curr_line];
						chomp $single_line;
						output_python_line($tab_depth, $single_line, $last_line);
					}
					import_libraries($Input) if $first_line;
				} elsif (is_var_declaration_line($single_line)) { 
					# #######################################
					# #######  Variable Declaration  #########
					# #######################################
					debug("Line Type:- Variable Declaration ");
					output_python_line($tab_depth, "$single_line", $last_line);
					while($single_line =~ /[\$\@\%](\w+)/g) {
						#$vars{$line}{$1} = 1;	# This may be useful later otherwise delete it
					}
				} elsif (is_function_declaration($single_line)) { 
					# #######################################
					# #######  Function Declaration  ########
					# #######################################
					output_python($tab_depth, "$keywords{'sub'} ");
					output_python(0, get_function_name($single_line));
					output_python(0, get_function_args($single_line)); 
					output_python(0, ":\n"); 
					$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
				} elsif (is_prepost_incdec_line($single_line)) {
					# #######################################
					# #######  Pre/Post Inc/Dec Line  #######
					# #######################################
					output_python_line($tab_depth, "$single_line", $last_line);
				} elsif ($single_line =~ /\s*if\s*\(?/) {
					# #######################################
					# ########### If Statements #############
					# #######################################
					debug("Line Type:- If");
					$curr_line = convert_if_statement_to_python($tab_depth, $curr_line, $Input);
				} elsif (is_else_line($single_line)) {
					# #######################################
					# ######### Else Statements #############
					# #######################################
					debug("Line Type:- Else ");
					debug("Line Type:- Else Type :- Else ");
					# Print to tab depth minus one and continue traversal
					output_python_line(($tab_depth-1), "else:", $last_line);
				} elsif(is_for_statement($single_line)) {
					# #######################################
					# ########## For Statements #############
					# #######################################
					debug("Line Type:- For ");
					$curr_line = convert_for_statement_to_python($tab_depth, $curr_line, $Input);
				} elsif (is_while_statement_line($single_line)) {
					# #######################################
					# ###########  While Loops  #############
					# #######################################
					debug("Line Type:- While ");
					my $condition = get_while_condition($single_line);
					$condition = strip_condition_padding($condition);
					output_python_line($tab_depth, "while ($condition):", $last_line);
					$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
				} elsif (is_print_line($single_line)) {
					# #######################################
					# ###############  Prints  ##############
					# #######################################
					debug("Line Type:- Print ");
					my $print_line = strip_outermost_parentheses(get_print($single_line));
					$print_line = strip_new_line($print_line) if has_explicit_new_line($print_line);
					$print_line =~ s/[\"\']\s*\$(\w+)\s*[\"\']/$1 /g;
					$print_line .= "," if !has_explicit_new_line($single_line);					
					output_python_line($tab_depth, "$print_line", $last_line);

				} elsif (is_single_word_line(strip_outer_spaces($single_line))) {
					# #######################################
					# #####  Keyword or Function Call  ######
					# #######################################
					$single_line = strip_outer_spaces($single_line);
					if(defined $keywords{$single_line}) {
					 	debug("Line Type:- Keyword ");
						output_python_line($tab_depth, "$keywords{$single_line}", $last_line);
					} else {
						# #######################################
						# ########### Undertermined #############
						# #######################################
						debug("Line Type:- Undertermined ");
						output_python_line($tab_depth, "# $single_line", $last_line);
					}

				} elsif (has_print_call($single_line)) {
					debug("Line Type:- Print Maybe");
					output_python_line($tab_depth, "$single_line", $last_line);
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
			debug("Line Type:- Empty ");
			output_python_line($tab_depth, "", $last_line);
		}
	}
	return $curr_line if $curr_line >= $line_num;
	die "Main: Current Line out of bounds";
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-       Recursively converts perl if statement code to python by     %
#                 evaulating a line at a time and various syntax cases.        %                    %
# Prototype:-     int  debug($tab_depth, $line_num, $Input)                    %
# Param int       $tab_depth :- Indentation level to prepend to python output  %
# Param int       $line_num  :- Current line number of input array             %
# Param array ref $Input     :- Reference to array of input lines              %
# Returns                    :- int Number of last line converted              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub convert_if_statement_to_python ( $$$ ) {
	my ($tab_depth, $line_num, $Input) = @_;
	my $curr_line = $line_num;
	my $last_line = ($curr_line == $#{$Input});
	my $single_line = ${$Input}[$curr_line];
	die "Line Number $line_num not in file\n" if ($line_num < 0 || $line_num > $#{$Input});
	chomp $single_line;
	if (has_strictly_opening_brace($single_line)) {
		# **************************************
		# ******* Multi Line If Statement ******
		# if (condition) {
		# }
		# **************************************
		debug("Line Type:- If Type:- Multi Line");
		my $condition = get_if_condition($single_line);
		$condition = strip_condition_padding($condition);
		output_python_line($tab_depth, "if ($condition):", $last_line);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
	} elsif (has_both_braces($single_line)) {
		# **************************************
		# ************ Single Line If **********
		# if condition { };
		# **************************************
		debug("Line Type:- If Type:- Single Line with braces");
		my $routine = get_if_routine($single_line);
		my $condition = get_if_condition($single_line);
		$condition = strip_condition_padding($condition);
		output_python_line($tab_depth, "if $condition: $routine", $last_line);		
	} elsif (is_reverse_order_if_line($single_line)) {
		# **************************************
		# **** Reverse Order If Declarion ******
		# command if condition;
		# **************************************
		debug("Line Type:- If Type:- Reverse Order");
		$single_line =~ /^(.*)if(.*)\;?$/ or die "$0 : Unable to match single line if command at line ".($curr_line+1);
		push (my @command_to_exec, $1);
		my $condition = $2;
		$condition = strip_condition_padding($condition);
		output_python($tab_depth, "if ($condition): ");
		my $Command_ref = \@command_to_exec;
		convert_to_python(0, 0, $Command_ref);
		# Add extra line for formatting purposes since last line of 
		# array when converted will not have a new line trailing it.
		output_python_line($tab_depth, "\n", $last_line); 
	} elsif (!has_opening_brace($single_line) && !is_reverse_order_if_line($single_line)) {
		# **************************************
		# *** Not reverse order if statement ***
		# *** no opening bracket             ***
		# *** Opening Brace on next line     ***
		# **************************************
		debug("Line Type:- If Type:- Brace on Next line");
		$single_line = strip_outer_spaces($single_line);
		output_python_line($tab_depth, "$single_line:", $last_line);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
	} elsif ($single_line =~ /elsif\s*(\(?.*)\{\s*$/) {
		# #######################################
		# ######### ElsIf Statements ############
		# #######################################
		my $condition = $1;
		debug("Line Type:- Else If ");
		$condition = strip_condition_padding($condition);
		# Print to tab depth minus one and continue traversal
		output_python_line(($tab_depth-1), "elif ($condition):", $last_line);
	} else {
		# **************************************
		# ******  Undertimed If Statement ******
		# **************************************
		debug("Line Type:- If Type:- Undertermined !");
		output_python_line($tab_depth, "# $single_line", $last_line);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
	}
	return $curr_line if $curr_line >= $line_num;
	die "If: Current Line out of bounds";
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-       Recursively converts perl for statement code to python by    %
#                 evaulating a line at a time and various syntax cases.        %                    %
# Prototype:-     int  debug($tab_depth, $line_num, $Input)                    %
# Param int       $tab_depth :- Indentation level to prepend to python output  %
# Param int       $line_num  :- Current line number of input array             %
# Param array ref $Input     :- Reference to array of input lines              %
# Returns                    :- int Number of last line converted              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub convert_for_statement_to_python ( $$$ ) {
	my ($tab_depth, $line_num, $Input) = @_;
	my $curr_line = $line_num;
	my $last_line = ($curr_line == $#{$Input});
	my $single_line = ${$Input}[$curr_line];
	die "Line Number $line_num not in file\n" if ($line_num < 0 || $line_num > $#{$Input});
	if(is_standard_for_statement_line($single_line)) {
		# **************************************
		# ******  Standard For Statement *******
		# for(initialisation; condition; postexecution)
		# **************************************
		# Since python does not support this standard 
		# for statement syntax, conversion to the 
		# equivalent while statement has been implemented
		# due to its better accuracy in translating the 
		# purpose of this code in more cases than using 
		# pythons "for i in set" syntax.
		debug("Line Type:- For Type :- Standard ");
		#$single_line = strip_outermost_braces($single_line);
		my $initialisation = get_for_statement_init($single_line); 
		my $condition = get_for_statement_condition($single_line);
		$condition = strip_condition_padding($condition);
		output_python_line($tab_depth, "$initialisation", $last_line);
		output_python_line($tab_depth, "while ($condition):", $last_line);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
		# Call convert_to_python on 
		my @postexecution = get_for_statement_postexec($single_line);
		my $Post_exec_ref = \@postexecution;
		convert_to_python($tab_depth+1, 0, $Post_exec_ref);
		# Add extra line for formatting purposes since last line of 
		# array when converted will not have a new line trailing it.
		output_python_line($tab_depth, "\n", $last_line); 
	} elsif (is_foreach_statement_line($single_line)) {
		# **************************************
		# ***  Standard Foreach Statement ******
		# **************************************						
		debug("Line Type:- For Type :- Foreach ");
		my $variable = get_foreach_var($single_line);
		my $set = get_foreach_set($single_line);
		debug("Var = $variable");
		debug("Set = $set");
		output_python($tab_depth, "for $variable in ");
		convert_set_to_python($set);
		output_python($tab_depth, ":\n");
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
	} elsif (is_for_var_in_set($single_line)) {
		$single_line = strip_outermost_braces($single_line);
		output_python_line($tab_depth, "$single_line:", $last_line);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input);
	} else {
		# **************************************
		# ******  Undertimed For Statement *****
		# **************************************
		debug("Line Type:- For Type :- Undertimed ");
	
		output_python_line($tab_depth, "# $single_line", $last_line);
	}
	return $curr_line if $curr_line >= $line_num;
	die "For: Current Line out of bounds";
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Converts single pre/post increment/decrement statements in     %
#               argument string to array of python equivalent lines of code to %
#               achieve similar program outcome                                %
# Prototype:-   array convert_prepost_incdec($line)                            %
# Param string  $line      :- Content to convert to python equivalent          %
# Returns                  :- array                                            %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub convert_prepost_incdec ( $ ) {
	my ($line) = @_;
	my @valid_python = ();
	my $op = get_incdec_op($line);
	if(has_post_dec($line) || has_post_inc($line)) {
		debug("Post Increment or Decrement Detected on:- $line");
		my $var = get_post_var($line);
		$line = strip_prepost_incdec($line);
		push @valid_python, $line if !is_single_word_line($line);
		push @valid_python, "$var $op= 1";
	} elsif (has_pre_dec($line) || has_pre_inc($line)) {
		debug("Pre Increment or Decrement Detected on:- $line");
		my $var = get_pre_var($line);
		$line = strip_prepost_incdec($line);
		push @valid_python, "$var $op= 1";
		push @valid_python, $line if !is_single_word_line($line);
	} else {
		push @valid_python, $line;
	}
	return @valid_python;
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Prints perl set expression such as range to python equivalent  %
# Prototype:-   void  convert_set_to_python($line)                             %
# Param string  $line      :- Set representation in perl                       %
# Returns                  :- void                                             %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub convert_set_to_python ( $ ) {
	my ($line) = @_;
	if($line =~ /\s*\((.+)\s*\.\.\s*([\$\@\%]\#?.+)\)\s*/) {
		# (1..(@array)|($#array))
		output_python(0, "range($1, $2)");
	} elsif ($line =~ /\s*\((.+)\s*\.\.\s*(.+)\)\s*/) {
		# (1..x+1)
		output_python(0, "range($1, ".($2+1).")");
	} elsif ($line =~ /^\s*\(\s*(@\w+)\s*\)\s*$/) {
		# (@array)
		output_python(0, "$1");
	}
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Checks entire file for reference of library objects such as re %
# Prototype:-   void convert_prepost_incdec($line)                             %
# Param array ref $Input     :- Reference to array of input lines              %
# Returns                    :- array                                            %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub import_libraries ( $ ) {
	my ($Input) = @_;
	my $file = join("", @{$Input});
	debug("Checking if Libraries need to be imported");
	push @libraries, "sys" if has_system_access($file);
	push @libraries, "re" if has_regex($file);
	foreach my $lib (@libraries) {
		output_python_line(0, "import $lib", 0);
	}
}


# #############################################################################################
# #############################################################################################
# #############################################################################################
# ##############################         Regex Functions          #############################
# #############################################################################################
# #############################################################################################
# #############################################################################################
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Returns result of regex match on line parsed                   %
# Prototype:-   void match_description($line)                                  %
# Param string  $line      :- Content to compare to match on                   %
# Returns                  :- boolean                                          %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# ##########################################
# ########## Has Regex Functions ###########
# ##########################################

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

sub has_pre_inc ( $ ) {
	my ($line) = @_;
	return $line =~ /\+\+\w/;
}

sub has_pre_dec ( $ ) {
	my ($line) = @_;
	return $line =~ /\-\-\w/;
}

sub has_post_inc ( $ ) {
	my ($line) = @_;
	return $line =~ /\w\+\+/;
}

sub has_post_dec ( $ ) {
	my ($line) = @_;
	return $line =~ /\w\-\-/;
}

sub has_prepost_incdec ( $ ) {
	my ($line) = @_;
	# post dec or post inc
	# .-- || .++ 
	# pre dec or pre inc
	# --. || ++.
	return (has_pre_inc($line) || has_pre_dec($line) || has_post_inc($line) || has_post_dec($line));
}

sub has_print_call ( $ ) {
	my ($line) = @_;
	return $line =~ /(\s|^)print\s*/;
}

sub has_regex  ( $ ) {
	my ($line) = @_;
	return $line =~ /\=\~/;
}

sub has_system_access  ( $ ) {
	my ($line) = @_;
	return $line =~ /((open)|(close)|(\<\>)|(STDIN)|(STDOUT)|(STDERR)|(\&1)|(\&2)|(ARGV))/;
}

sub has_explicit_new_line  ( $ ) {
	my ($line) = @_;
	return $line =~ /\".*?\\n\.*?"/;
}

# ##########################################
# ########## Is Regex Functions ############
# ##########################################

sub is_empty_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^$/;
}

sub is_var_declaration_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*[\$\@\%]\w+\s*\=\s*[\"\']?.*[\"\']?\s*$/;	
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
	return $line =~ /^\s*\#.*$/;
}

sub is_else_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*\}\s*els[ie]f?\s*\{\s*$/;
}

sub is_print_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\s*[\.\,\+\*\-\/]\s*)*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\)?\s*$/;
}

sub is_reverse_order_if_line ( $ ) {
	my ($line) = @_;
	return $line =~ /\s*?.+?\sif\s*\(?.*\)?\s*$/;
}

sub is_for_statement ( $ ) {
	my ($line) = @_;
	return $line =~ /\s*for(each)?.*\s*$/;
}

sub is_standard_for_statement_line ( $ ) {
	my ($line) = @_;
	return $line =~ /\s*for\s*\(\s*.*?;.*?;.*?\)\s*\{?\s*$/;
}

sub is_foreach_statement_line ( $ ) {
	my ($line) = @_;
	return $line =~ /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
}

sub is_for_var_in_set ( $ ) {
	my ($line) = @_;
	return $line =~ /\s*for\s*(.*?)\s*in\s*(\(?.*?\)?)\s*\{?\s*$/;
}

sub is_prepost_incdec_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*((((\-\-)|(\+\+))\$\w+)|(\$\w+((\-\-)|(\+\+))))\s*$/;
}

sub is_while_statement_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*while\(?.*?\)\s*\{?\s*$/;
}

sub is_single_word_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\S+$/;
}

sub is_function_declaration ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*sub\s+(\w+)\s*(\(.*?\))\s*\{?\s*$/;
}

# ##########################################
# ######## Strip Regex Functions ###########
# ##########################################
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

sub strip_new_line ( $ ) {
	my ($line) = @_;
	$line =~ s/(".*)\\n(.*\".*)$/$1$2/;
	return $line;
}

sub strip_at_signs ( $ ) {
	my ($line) = @_;
	$line =~ s/\@//g;
	return $line;
}

sub strip_logic_operators ( $ ) {
	my ($line) = @_;
	$line =~ s/\&\&/ and /g;
	$line =~ s/\|\|/ or /g;
	$line =~ s/\!/ not /g if $line !~ /\#\!/;
	return $line;
}

sub strip_input_methods ( $ ) {
	my ($line) = @_;
	$line =~ s/\<STDIN\>/sys.stdin.readline()/g;
	$line =~ s/\<STDOUT\>/sys.stdout.write()/g;
	$line =~ s/\<STDERR\>/sys.stderr.write()/g;
	$line =~ s/\&1/sys.stdout.write()/g;
	$line =~ s/\$\#ARGV/len(sys.argv)/g;
	$line =~ s/\&2/sys.stderr.write()/g;
	$line =~ s/len\(\@ARGV\)/len(sys.argv)/g;
	$line =~ s/\$ARGV\[(.*)\]/sys.argv[$1+1]/g;
	$line =~ s/\@ARGV/sys.argv[1:]/g;
	$line =~ s/ARGV/sys.argv/g;
	return $line;
}

sub strip_comparators ( $ ) {
	my ($line) = @_;
	$line =~ s/\seq\s/ == /g;
	return $line;
}

sub strip_invalid_python ( $ ) {
	my ($line) = @_;
	debug("Given Output:- $line");
	$line = strip_semi_colon($line);
	$line = strip_logic_operators($line);
	$line = strip_comparators($line);
	$line = strip_input_methods($line);
	$line = strip_dollar_signs($line);
	$line = strip_at_signs($line);
	#print "should be no dol signs here :- $line\n";

	my @valid_python = convert_prepost_incdec($line);
	debug("Produced Output:- @valid_python");
	return @valid_python;
}

sub strip_semi_colon ( $ ) {
	my ($line) = @_;
	$line =~ s/\;//g;
	return $line;	
}

sub strip_prepost_incdec ( $ ) {
	my ($line) = @_;
	$line =~ s/((\-\-)|(\+\+))//g;
	return $line;	
}

sub strip_outer_spaces ( $ ) {
	my ($line) = @_;
	$line =~ s/^\s*//;
	$line =~ s/\s*$//;
	return $line;	
}

sub strip_condition_padding ( $ ) {
	my ($line) = @_;
	$line = strip_semi_colon($line);
	$line = strip_outer_spaces($line);
	$line = strip_outermost_braces($line);
	$line = strip_outermost_parentheses($line);
	$line = strip_outer_spaces($line);
	return $line;
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Returns capture part of regex match on line parsed             %
# Prototype:-   void match_description($line)                                  %
# Param string  $line      :- Content to compare to match on                   %
# Returns                  :- string                                           %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# ##########################################
# ########## Get Regex Functions ###########
# ##########################################
sub get_print ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /^\s*(print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))[\.\,\+\-\/\*])*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\)?)/;
	return "";
}

sub get_for_statement_init ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /\s*for\s*\(\s*(.*?);.*?;.*?\)\s*\{?\s*$/;
	return "";
}

sub get_for_statement_condition ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /\s*for\s*\(\s*.*?;(.*?);.*?\)\s*\{?\s*$/;
	return "";
}

sub get_for_statement_postexec ( $ ) {
	my ($line) = @_;
	my @exec_lines = split /,/, $1 if $line =~ /\s*for\s*\(\s*.*?;.*?;(.*?)\)\s*\{?\s*$/;
	return @exec_lines;
}



sub get_post_var( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /([A-Za-z_]+)((\-\-)|(\+\+))/;
	return "";
}

sub get_pre_var( $ ) {
	my ($line) = @_;
	return $4 if $line =~ /((\-\-)|(\+\+))([A-Za-z_]+)/;
	return "";
}

sub get_incdec_op ( $ ) {
	my ($line) = @_;
	return "+" if (has_post_inc($line) || has_pre_inc($line));
	return "-" if (has_post_dec($line) || has_pre_dec($line));
}

sub get_if_condition ( $ ) {
	my ($line) = @_;
	return $1 if $line =~/^\s*if\s*(\([^\)]+\))/;
	return "";
}

sub get_if_routine ( $ ) {
	my ($line) = @_;
	return $2 if $line =~/^\s*if\s*(\([^\)]+\))\s*\{(.*)\}/;
	return "";
}

sub get_foreach_var ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
	return "";
}

sub get_foreach_set ( $ ) {
	my ($line) = @_;
	return $2 if $line =~ /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
	return "";
}

sub get_while_condition ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /^\s*while\(?(.*?)\)\s*\{?\s*$/;
	return "";
}

sub get_function_args ( $ ) {
	my ($line) = @_;
	return "" if !($line =~ /^\s*sub\s+(\w+)\s*(\(.*?\))\s*\{?\s*$/);
	my $args = $2;
	my $arguments = "(";
	my $arg_num = 0;
	while($args =~ /[\$\@\%]/g) {
		$arguments .= "arg".$arg_num++;
	}
	$arguments .= ")";
	return $arguments;
}

sub get_function_name ( $ ) {
	my ($line) = @_;
	return $1 if $line =~ /^\s*sub\s+(\w+)\s*(\(.*?\))\s*\{?\s*$/;
	return "";
}









