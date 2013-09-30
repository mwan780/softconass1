#!/usr/bin/perl -w 
# #############################################################################################
# #############################################################################################
# ###############################                          ####################################
# ###############################     Perl To Python       ####################################
# ###############################                          ####################################
# #############################################################################################
# #############################################################################################
# #######  Lecturer   :- Andrew Taylor                           ##############################
# #######  Course     :- COMP2041 Software Construction          ##############################
# #######  Author     :- Steven Falconieri                       ##############################
# #######  Znumber    :- z3419220                                ##############################
# #######  Created    :- September 2013                          ##############################
# #######  Assignment :- Perl2Python                             ##############################
# #######  Language   :- Perl                                    ##############################
# #######  Requires   :- regex_functions.pl, unit_tests.pl       ##############################
# #######  Description:- Recursively converts Perl code to best Python equivalent.  ###########
# #######  Program Structure:-                                                      ###########
# #######    Main:->                                                                ###########
# #######      |convert_to_python:->                                                ###########
# #######      |        |convert_to_python                                          ###########
# #######      |        |import_libraries                                           ###########
# #######      |        |convert_to_system_out                                      ###########
# #######      |        |output_python_line:->                                      ###########
# #######      |        |        |strip_invalid_python:->                           ###########
# #######      |        |        |        |strip_semi_colon                         ###########
# #######      |        |        |        |strip_logic_operators                    ###########
# #######      |        |        |        |strip_comparators                        ###########
# #######      |        |        |        |strip_input_methods                      ###########
# #######      |        |        |        |convert_lib_functions                    ###########
# #######      |        |        |        |strip_dollar_signs                       ###########
# #######      |        |        |        |strip_at_signs                           ###########
# #######      |        |        |        |convert_prepost_incdec                   ###########
# #######      |        |convert_if_statement_to_python:->                          ###########
# #######      |        |        |convert_to_python                                 ###########
# #######      |        |        |output_python_line                                ###########
# #######      |        |convert_for_statement_to_python:->                         ###########
# #######      |        |        |convert_to_python                                 ###########
# #######      |        |        |output_python_line                                ###########
# #######      |        |        |convert_set_to_pyton                              ###########
# #######                                                                           ###########
# #############################################################################################
# #############################################################################################




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

sub output_python ( $$$ );
sub output_python_line ( $$$ );
sub debug  ( $ );
sub format_output ( @ );
sub array_compare ( $$$ );
sub python_file ( $ );
sub convert_to_python ( $$$$ );
sub convert_if_statement_to_python ( $$$$ );
sub convert_for_statement_to_python ( $$$$ );
sub convert_prepost_incdec ( $ );
sub convert_set_to_python ( $ );
sub import_libraries ( $ );
sub store_variables ( $ );




# #############################################################################################
# #############################################################################################
# #############################################################################################
# ##############################            MAIN           ####################################
# #############################################################################################
# #############################################################################################
# #############################################################################################

require 'regex_functions.pl' or die "Could not import Regex Functions\n";

# Debugging Flag -d
# Must be first program argument
if($#ARGV > 0 && $ARGV[0] =~ /\-d/) {
	$debug = 1;
	shift @ARGV;
	# Call and Run All Unit Tests
	require 'unit_tests.pl';
} 



# Process Files
# Check if any files have been parsed as arguments
# If so execute the conversion to each file individually
# If not continue to Standard Input processing below
foreach my $file (@ARGV) {
	open(PERL, $file) or die "$0: Could not open '$file' : $!\n";
	debug("Reading from File");
	# Place File Contents into Array
	@perl_input = <PERL>;
	# Get Reference to Input Contents
	$Perl_ref = \@perl_input;
	%program_variables = store_variables($Perl_ref);


	# Create Empty Array for Output Contents
	@python_output = ();
	# Get Reference to Output Contents
	$Python_ref = \@python_output;
	# Convert Perl Input to Python Output
	# Places python into output array referenced
	convert_to_python(0, 0, $Perl_ref, $Python_ref);
	# Formats Array into individual lines	
	@python_output = format_output(@python_output);
	
	# Print each line of the Output array
	for $i (0..$#python_output) {
		print "$python_output[$i]\n";
	}
	if ($debug) {
		# Open file with expected Python result
		@expected = <EXP> if open(EXP, python_file($file));
		$Expected_ref = \@expected;
		# Compare Perl input, Python Output and Expected Output for Debugging
		array_compare($Perl_ref, $Python_ref, $Expected_ref);
	}
}
# Process Standard Input if no files were parsed
if ( !($#ARGV >= 0) ) {
	debug("Reading from standard input");
	# Place Input Contents into Array
	@std_input = <STDIN>;
	# Get Reference to Input Contents
	$Stdin_ref = \@std_input;
	# Create Empty Array for Output Contents
	@python_output = ();
	# Get Reference to Output Contents
	$Python_ref = \@python_output;
	# Convert Perl Input to Python Output
	# Places python into output array referenced
	convert_to_python(0, 0, $Stdin_ref, $Python_ref);
	# Formats Array into individual lines	
	@python_output = format_output(@python_output);
	# Print each line of the Output array
	for $i (0..$#python_output) {
		print "$python_output[$i]\n";
	}
	array_compare($Perl_ref, $Python_ref, "");
}


sub store_variables ( $ ) {
	my ($Input) = @_;
	my $input_string = join ('', @{$Input});
	$input_string = strip_quoted_expressions($input_string);
	my %code_variables = ();
	my @scalars_found = $input_string =~ /(\$\w+[^\[\{])\W/g;
	foreach my $scalar (@scalars_found) {
		if(!exists $code_variables{'scalars'}{$scalar}) {
			debug("$scalar");
			$code_variables{'scalars'}{$scalar} = 0;
		}
	}
	my @arrays_found = $input_string =~ /(\@\w+\W/g;
	foreach my $array (@arrays_found) {
		if(!exists $code_variables{'arrays'}{$array}) {
			debug("$array");
			$code_variables{'arrays'}{$array} = 0;
		}
	}
	my @hashes_found = $input_string =~ /(\%\w+\W/g;
	foreach my $hash (@hashes_found) {
		if(!exists $code_variables{'hashes'}{$hash}) {
			debug("$hash");
			$code_variables{'hashes'}{$hash} = 0;
		}
	}
	return %code_variables;
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
# Param array ref $Output  :- Reference to array for output lines              %
# Returns                 :- void                                              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub output_python ( $$$ ) {
	my ($tab_depth, $python, $Output) = @_;
	my @valid_python = strip_invalid_python($python);
	$python =~ /(\s+)$/;
	my $trailing_space = $1;
	my $indentation = "";
	for my $count (0..$tab_depth-1) {
			$indentation .= "    ";
	}
	my $counter;
	foreach my $python_line (@valid_python) {
		# $output[last element]
		$counter++;
		$python_line .= $trailing_space if defined $trailing_space;
		push @{$Output}, "$indentation$python_line";
		push @{$Output}, "\n" if @valid_python > 1 && $counter < @valid_python;
	}
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Outputs python code to standard output followed                %
#               by newline character                                           %
# Prototype:-   void output_python_line($tab_depth, $python, $Ouput)           %
# Param int     $tab_depth :- Level of indentation to prepend to output        %
# Param string  $python    :- Content to output                                %
# Param array ref $Output  :- Reference to array for output lines              %
# Returns                  :- void                                             %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub output_python_line ( $$$ ) {
	my ($tab_depth, $python, $Output) = @_;
	my @valid_python = strip_invalid_python($python);
	my $indentation = "";
	for my $count (0..$tab_depth-1) {
		$indentation .= "    ";
	}
	foreach my $python_line (@valid_python) {
		print "Output:- $python_line" if $debug;
		push @{$Output}, "$indentation$python_line\n";
	}
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Outputs comment line to standard output followed               %
#               by newline character                                           %
# Prototype:-   void output_comment_line($tab_depth, $python, $Output)         %
# Param int     $tab_depth :- Level of indentation to prepend to output        %
# Param string  $python    :- Content to output                                %
# Param array ref $Output  :- Reference to array for output lines              %
# Returns                  :- void                                             %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub output_comment_line ( $$$ ) {
	my ($tab_depth, $comment, $Output) = @_;
	my $indentation = "";
	for my $count (0..$tab_depth-1) {
		$indentation .= "    ";
	}
	push @{$Output}, "$indentation$comment\n";
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

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Formats Array by placing individual lines into seperate array  %
#               elements. Joins array into single string and then splits on    %
#               new lines. Trailing newlines will also be removed.             %
# Prototype:-   array format_output(@array)                                    %
# Param array   @input     :- Content to format into output                    %
# Returns                  :- array                                            %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub format_output ( @ ) {
	my (@input) = @_;
	my $string = join('', @input);
	#$string =~ s/\n/\n\^/g;
	#$string =~ s/\s{4}/\t/g;
	# Replace consecutive spaces with single one
	#$string =~ s/\s+/ /g;
	@input = split('\n', $string);
	return @input;
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Prints Input, Output and Expected Output arrays as parallel    %
#               columns for debugging comparison.                              %
# Prototype:-   void array_compare($Input, $Output, $Expected)                 %
# Param array ref $Input   :- Reference to array for input    lines            %
# Param array ref $Output  :- Reference to array for output   lines            %
# Param array ref $Expected:- Reference to array for expected lines            %
# Returns                  :- void                                             %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub array_compare ( $$$ ) {
	my ($Input, $Output, $Expected) = @_;
	print "\n\n############## Input ############################################# Output #################################################### Expected ############################\n\n" if $debug;
	for my $i (0..$#{$Output}) {
		my $input = ${$Input}[$i];
		my $output = ${$Output}[$i];
		my $expected = ${$Expected}[$i];
		chomp($input);
		chomp($output);
		chomp($expected);
		printf "%-60s %-60s %-60s\n", $input, $output, $expected if $debug;
	}
	print "############## Input ############################################# Output #################################################### Expected ############################\n" if $debug;
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Returns name of associated python file version of a perl file. %
# Prototype:-   string python_file($file)                                      %
# Param string  $file      :- Perl Filename to identify python version         %
# Returns                  :- string                                           %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub python_file ( $ ) {
	my ($file) = @_;
	$file =~ s/l$/y/;
	return $file;
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
# Prototype:-     int convert_to_python($tab_depth, $line_num, $Input, $Output)%
# Param int       $tab_depth :- Indentation level to prepend to python output  %
# Param int       $line_num  :- Current line number of input array             %
# Param array ref $Input     :- Reference to array of input lines              %
# Param array ref $Output    :- Reference to array for output lines            %
# Returns                    :- int Number of last line converted              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Return:- last line number read from
sub convert_to_python ( $$$$ ) {
	my ($tab_depth, $line_num, $Input, $Output) = @_;
	debug("Tab Depth = $tab_depth and input line number = ".$line_num."/".($#{$Input}+1));
	die "Line Number $line_num not in file\n" if ($line_num < 0 || $line_num > $#{$Input});
	my $curr_line = $line_num;
	my $system_lib = has_system_access(join('', @{$Input}));
	for($curr_line = $line_num; $curr_line <= $#{$Input}; $curr_line++) {
		# Break up multiple lines of code into single lines
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
				if(has_reverse_function_call($single_line)) {
					$single_line =~ s/reverse\s*\@(\w+)/$1/;
					my $array = $1;
					output_python_line($tab_depth, "$array.reverse()", $Output);
				}

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
					$single_line =~ s/perl\s*\-w/python2.7 \-u/ if $first_line;
					# Print all consecutive comment lines
					
					output_comment_line($tab_depth, $single_line, $Output);
					while(is_comment_line(${$Input}[$curr_line+1])) {
						# Note ++ increments the current line counter for accurate return val
						debug("Current line number = ".(1+$curr_line));
						$single_line = strip_outer_spaces(${$Input}[++$curr_line]);
						chomp $single_line;
						output_comment_line($tab_depth, $single_line, $Output);
					}
					if ($first_line) {
						my @libraries = import_libraries($Input);
						output_python($tab_depth, "import ", $Output) if @libraries > 0;
						output_python_line($tab_depth, join(', ', @libraries), $Output) if @libraries > 0;
					}
				} elsif (is_var_declaration_line($single_line)) { 
					# #######################################
					# #######  Variable Declaration  #########
					# #######################################
					debug("Line Type:- Variable Declaration ");
					output_python_line($tab_depth, "$single_line", $Output);
					while($single_line =~ /[\$\@\%](\w+)/g) {
						#$vars{$line}{$1} = 1;	# This may be useful later otherwise delete it
					}
				} elsif (is_function_declaration($single_line)) { 
					# #######################################
					# #######  Function Declaration  ########
					# #######################################
					my $next_line = ${$Input}[$curr_line + 1];
					chomp $next_line;
					if(is_function_arg_dec_line($next_line) || is_opening_brace_line($next_line) || has_opening_brace($single_line)) {
						output_python($tab_depth, "$keywords{'sub'} ", $Output);
						output_python(0, get_function_name($single_line), $Output);
						if (is_function_arg_dec_line($next_line)) {
							# If Function Argument Declaration then 
							# Declare functions accordingly.
							$curr_line++;
							output_python(0, get_function_defined_args(${$Input}[$curr_line]), $Output);
						} else {
							# Declare Function Arguments as best as possible
							output_python(0, get_function_prototype_args($single_line), $Output); 	
						}
						output_python_line(0, ":\n", $Output); 
						$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
					}
				} elsif (is_prepost_incdec_line($single_line)) {
					# #######################################
					# #######  Pre/Post Inc/Dec Line  #######
					# #######################################
					output_python_line($tab_depth, "$single_line", $Output);
				} elsif (is_if_line($single_line)) {
					# #######################################
					# ########### If Statements #############
					# #######################################
					debug("Line Type:- If");
					$curr_line = convert_if_statement_to_python($tab_depth, $curr_line, $Input, $Output);
				} elsif(is_for_statement($single_line)) {
					# #######################################
					# ########## For Statements #############
					# #######################################
					debug("Line Type:- For ");
					$curr_line = convert_for_statement_to_python($tab_depth, $curr_line, $Input, $Output);
				} elsif (is_while_statement_line($single_line)) {
					# #######################################
					# ###########  While Loops  #############
					# #######################################
					debug("Line Type:- While ");
					if(is_unix_filter_pattern_line($single_line)) {
						my $input_var = get_unix_filter_input_variable($single_line);
						my $input_source = get_unix_filter_input_source($single_line);
						output_python_line($tab_depth, "for $input_var in $input_source:", $Output);
					} else {
						my $condition = get_while_condition($single_line);
						$condition = strip_condition_padding($condition);
						output_python_line($tab_depth, "while $condition:", $Output);
					}
					$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
				} elsif (is_print_line($single_line)) {
					# #######################################
					# ###############  Prints  ##############
					# #######################################
					debug("Line Type:- Print ");
					my $print_line = strip_outermost_parentheses(get_print($single_line));
					
					$print_line = strip_new_line($print_line) if has_explicit_new_line($print_line);
					
					$print_line = strip_quoted_variables($print_line);
					$print_line = convert_to_system_out($print_line) if !has_explicit_new_line($single_line) && $system_lib;					
					output_python_line($tab_depth, "$print_line", $Output);

				} elsif (is_single_word_line(strip_outer_spaces($single_line))) {
					# #######################################
					# #####  Keyword or Function Call  ######
					# #######################################
					$single_line = strip_outer_spaces($single_line);
					if(defined $keywords{$single_line}) {
					 	debug("Line Type:- Keyword ");
						output_python_line($tab_depth, "$keywords{$single_line}", $Output);
					} elsif (has_lib_function_call($single_line)) {
						# #######################################
						# ###### Assumed Lib Function Call ######
						# #######################################
						debug("Line Type:- Lib Function ");
						output_python_line($tab_depth, "$single_line", $Output);
					} else {
						# #######################################
						# ########### Undertermined #############
						# #######################################
						debug("Line Type:- Undertermined ");
						output_python_line($tab_depth, "# $single_line", $Output);
					}
				} elsif (has_print_call($single_line)) {
					debug("Line Type:- Print Maybe");
					output_python_line($tab_depth, "$single_line", $Output);
				} elsif (has_lib_function_call($single_line)) {
					# #######################################
					# ###### Assumed Lib Function Call ######
					# #######################################
					debug("Line Type:- Lib Function ");
					output_python_line($tab_depth, "$single_line", $Output);
				} else {
					# #######################################
					# ########### Undertermined #############
					# #######################################
					debug("Line Type:- Undertermined ");
					output_python_line($tab_depth, "# $single_line", $Output);
					$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output) if has_strictly_opening_brace($single_line);
				}
				debug("");
				debug("");
			}
		} else {
			debug("Line Type:- Empty ");
			output_python_line($tab_depth, "\n", $Output);
		}
	}
	return $curr_line if $curr_line >= $line_num;
	die "Main: Current Line out of bounds";
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-       Recursively converts perl if statement code to python by     %
#                 evaulating a line at a time and various syntax cases.        % 
# Prototype:-                                                                  %                   %
#   int convert_if_statement_to_python($tab_depth, $line_num, $Input, $Output) %
# Param int       $tab_depth :- Indentation level to prepend to python output  %
# Param int       $line_num  :- Current line number of input array             %
# Param array ref $Input     :- Reference to array of input lines              %
# Param array ref $Output    :- Reference to array for output lines            %
# Returns                    :- int Number of last line converted              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub convert_if_statement_to_python ( $$$$ ) {
	my ($tab_depth, $line_num, $Input, $Output) = @_;
	my $curr_line = $line_num;
	my $single_line = ${$Input}[$curr_line];
	die "Line Number $line_num not in file\n" if ($line_num < 0 || $line_num > $#{$Input});
	chomp $single_line;
	if (has_strictly_opening_brace($single_line) && is_standard_if($single_line)) {
		# **************************************
		# ******* Multi Line If Statement ******
		# if (condition) {
		# }
		# **************************************
		debug("Line Type:- If Type:- Multi Line");
		my $condition = get_if_condition($single_line);
		$condition = strip_condition_padding($condition);
		
		output_python_line($tab_depth, "if $condition :", $Output);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
	} elsif (has_opening_then_closing_braces($single_line)) {
		# **************************************
		# ************ Single Line If **********
		# if condition { };
		# **************************************
		debug("Line Type:- If Type:- Single Line with braces");
		my $routine = get_if_routine($single_line);
		my $condition = get_if_condition($single_line);
		$condition = strip_condition_padding($condition);
		output_python_line($tab_depth, "if $condition : $routine", $Output);		
	} elsif (is_reverse_order_if_line($single_line)) {
		# **************************************
		# **** Reverse Order If Declarion ******
		# command if condition;
		# **************************************
		debug("Line Type:- If Type:- Reverse Order");
		push (my @command_to_exec, get_reverse_if_routine($single_line));
		my $condition = get_reverse_if_condition($single_line);
		output_python($tab_depth, "if $condition : ", $Output);
		my $Command_ref = \@command_to_exec;
		convert_to_python(0, 0, $Command_ref, $Output);
		# Add extra line for formatting purposes since last line of 
		# array when converted will not have a new line trailing it.
		#output_python_line($tab_depth, "", $Output); 
	} elsif (!has_opening_brace($single_line) && !is_reverse_order_if_line($single_line)) {
		# **************************************
		# *** Not reverse order if statement ***
		# *** no opening bracket             ***
		# *** Opening Brace on next line     ***
		# **************************************
		debug("Line Type:- If Type:- Brace on Next line");
		$single_line = strip_outer_spaces($single_line);
		output_python_line($tab_depth, "$single_line :", $Output);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
	} elsif ($single_line =~ /elsif\s*(\(?.*)\{\s*$/) {
		# #######################################
		# ######### ElsIf Statements ############
		# #######################################
		my $condition = $1;
		debug("Line Type:- Else If ");
		$condition = strip_condition_padding($condition);
		# Print to tab depth minus one and continue traversal
		output_python_line(($tab_depth-1), "elif $condition :", $Output);
	} elsif (is_else_line($single_line)) {
		# #######################################
		# ######### Else Statements #############
		# #######################################
		debug("Line Type:- Else ");
		debug("Line Type:- Else Type :- Else ");
		# Print to tab depth minus one and continue traversal
		output_python_line(($tab_depth-1), "else:", $Output);
	} else {
		# **************************************
		# ******  Undertimed If Statement ******
		# **************************************
		debug("Line Type:- If Type:- Undertermined !");
		output_python_line($tab_depth, "# $single_line", $Output);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
	}
	return $curr_line if $curr_line >= $line_num;
	die "If: Current Line out of bounds";
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-       Recursively converts perl for statement code to python by    %
#                 evaulating a line at a time and various syntax cases.        % 
# Prototype:-                                                                  %
#   int convert_for_statement_to_python($tab_depth, $line_num, $Input, $Output)%
# Param int       $tab_depth :- Indentation level to prepend to python output  %
# Param int       $line_num  :- Current line number of input array             %
# Param array ref $Input     :- Reference to array of input lines              %
# Param array ref $Output    :- Reference to array for output lines            %
# Returns                    :- int Number of last line converted              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub convert_for_statement_to_python ( $$$$ ) {
	my ($tab_depth, $line_num, $Input, $Output) = @_;
	my $curr_line = $line_num;
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
		output_python_line($tab_depth, "$initialisation", $Output);
		output_python_line($tab_depth, "while $condition :", $Output);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
		# Call convert_to_python on 
		my @postexecution = get_for_statement_postexec($single_line);
		my $Post_exec_ref = \@postexecution;
		convert_to_python($tab_depth+1, 0, $Post_exec_ref, $Output);
		# Add extra line for formatting purposes since last line of 
		# array when converted will not have a new line trailing it.
		output_python_line($tab_depth, "\n", $Output); 
	} elsif (is_foreach_statement_line($single_line)) {
		# **************************************
		# ***  Standard Foreach Statement ******
		# **************************************						
		debug("Line Type:- For Type :- Foreach ");
		my $variable = get_foreach_var($single_line);
		my $set = get_foreach_set($single_line);
		debug("Var = $variable");
		debug("Set = $set");
		output_python($tab_depth, "for $variable in ", $Output);
		output_python(0, convert_set_to_python($set)." :", $Output);
		output_python_line(0, "\n", $Output);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
	} elsif (is_for_var_in_set($single_line)) {
		$single_line = strip_outermost_braces($single_line);
		output_python_line($tab_depth, "$single_line :", $Output);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
	} else {
		# **************************************
		# ******  Undertimed For Statement *****
		# **************************************
		debug("Line Type:- For Type :- Undertimed ");
		output_python_line($tab_depth, "# $single_line", $Output);
		$curr_line = convert_to_python($tab_depth+1, $curr_line+1, $Input, $Output);
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
		if (!is_single_word_line($line)) {
			push @valid_python, "$var $op= 1";
			push @valid_python, strip_outer_spaces($line);
		} else {
			push @valid_python, "$var $op= 1";
		}
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
	my $result = "";
	if($line =~ /\s*\(0\s*\.\.\s*([\$\@\%]\#?.+)\)\s*/) {
		# (1..(@array)|($#array))
		$result = "xrange($1)";
	} elsif($line =~ /\s*\((.+)\s*\.\.\s*([\$\@\%]\#?.+)\)\s*/) {
				# (1..(@array)|($#array))
		$result = "xrange($1, $2)";
	} elsif ($line =~ /\s*\((.+)\s*\.\.\s*(.+)\)\s*/) {
		# (1..x+1)
		$result = "xrange($1, ".($2+1).")";
	} elsif ($line =~ /^\s*\(\s*(@\w+)\s*\)\s*$/) {
		# (@array)
		$result = "$1";
	} else {
		$result = strip_condition_padding($line);
	}
	# Remove xrange if assigning values to an array
	$line =~ s/(=\s*)x(range)/$1$2/;
	return $result;
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Checks if any word in string is a library function and converts%
#               the function to a python equivalent if it is.                  %
# Prototype:-   void  convert_set_to_python($line)                             %
# Param string  $line      :- Set representation in perl                       %
# Returns                  :- void                                             %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub convert_lib_functions ( $ ) {
	my ($line) = @_;
	# Reverse traversal of words so that subfunctions (E.g. join in print statement)
	# Can be evaluated correctly.
	foreach my $word (reverse (split(/((\(\d+)|( )|(\d+\))|(\()|(\)))+/, strip_regex_expressions($line)))) {
		
		if(defined $word && defined $lib_function_conversion_regex{$word}) {
			# Word is a Library Function
			 debug("\n-$word-\n");
			 debug("\n-$lib_function_conversion_regex{$word}-\n");
			$line = apply_regex($lib_function_conversion_regex{$word}, $line);
		}
		$program_variables{'scalars'}{$word}++ if defined $program_variables{'scalars'}{$word};
		$program_variables{'arrays'}{$word}++ if defined $program_variables{'arrays'}{$word};
		$program_variables{'hashes'}{$word}++ if defined $program_variables{'hashes'}{$word};
	}
	return $line;
}

sub convert_to_system_out ( $ ) {
	my ($line) = @_;
	$line =~ s/print\s*\(?(.+)\)?\,?/sys.stdout.write($1)/i;
	return $line;
}



# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Checks entire file for reference of library objects such as re %
# Prototype:-   void import_libraries($line)                                   %
# Param array ref $Input     :- Reference to array of input lines              %
# Returns                    :- array                                          %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub import_libraries ( $ ) {
	my ($Input) = @_;
	my $file = join("", @{$Input});
	debug("Checking if Libraries need to be imported");
	push @libraries, "fileinput" if has_unix_filter($file);
	push @libraries, "sys" if has_system_access($file);
	push @libraries, "re" if has_regex($file);
	return @libraries;
}


