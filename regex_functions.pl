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
# #######  Requires   :- perl2python.pl, unit_tests.pl           ##############################
# #######  Description:- Contains Regex Functions associated with         #####################
# #######                perl2python translation. Functions are           #####################
# #######                grouped into five categories                     #####################
# #######                (has, is, strip, get & apply) of with different  #####################
# #######                purposes and return types for simplicity.        #####################
# #############################################################################################
# #############################################################################################
# #############################################################################################
# ############################       Function Prototypes      #################################
# #############################################################################################
# #############################################################################################
# #############################################################################################

sub has_opening_brace  ( $ );
sub has_strictly_closing_brace  ( $ );
sub has_strictly_opening_brace  ( $ );
sub has_both_braces  ( $ );
sub has_closing_then_opening_braces  ( $ );
sub has_pre_inc ( $ );
sub has_pre_dec ( $ );
sub has_post_inc ( $ );
sub has_post_dec ( $ );
sub has_prepost_incdec ( $ );
sub has_print_call ( $ );
sub has_regex  ( $ );
sub has_system_access  ( $ );
sub has_explicit_new_line  ( $ );
sub is_empty_line ( $ );
sub is_var_declaration_line ( $ );
sub is_closing_brace_line ( $ );
sub is_opening_brace_line ( $ );
sub is_comment_line ( $ );
sub is_else_line ( $ );
sub is_print_line ( $ );
sub is_standard_if ( $ );
sub is_reverse_order_if_line ( $ );
sub is_for_statement ( $ );
sub is_standard_for_statement_line ( $ );
sub is_foreach_statement_line ( $ );
sub is_for_var_in_set ( $ );
sub is_prepost_incdec_line ( $ );
sub is_while_statement_line ( $ );
sub is_single_word_line ( $ );
sub is_function_declaration ( $ );
sub is_function_arg_dec_line ( $ );
sub is_single_condition ( $ );
sub strip_outermost_parentheses ( $ );
sub strip_outermost_braces ( $ );
sub strip_dollar_signs ( $ );
sub strip_new_line ( $ );
sub strip_at_signs ( $ );
sub strip_logic_operators ( $ );
sub strip_input_methods ( $ );
sub strip_comparators ( $ );
sub strip_invalid_python ( $ );
sub strip_semi_colon ( $ );
sub strip_prepost_incdec ( $ );
sub strip_outer_spaces ( $ );
sub strip_condition_padding ( $ );
sub get_print ( $ );
sub get_for_statement_init ( $ );
sub get_for_statement_condition ( $ );
sub get_for_statement_postexec ( $ );
sub get_post_var( $ );
sub get_pre_var( $ );
sub get_incdec_op ( $ );
sub get_if_condition ( $ );
sub get_if_routine ( $ );
sub get_reverse_if_condition ( $ );
sub get_reverse_if_routine ( $ );
sub get_foreach_var ( $ );
sub get_foreach_set ( $ );
sub get_while_condition ( $ );
sub get_function_prototype_args ( $ );
sub get_function_defined_args ( $ );
sub get_function_name ( $ );

%keywords = (
	'last'  => 'break',
	'next'  => 'continue',
	'=~ s/' => 're.sub',
	'=~ /'  => 're.match',
	'sub'   => 'def',
);
# 0 = undefined
%lib_function_conversion_regex = (
	'print'   => 's/(\,\+\.\s*)?(\".*?)\\\n\s*(\")/$2$3/g',
	'split'   => 's/split\s*\(\s*\/?\s*([\'\"\/].*[\'\"\/])\/?,\s*([^\)]+)\)?/$2.split($1)/g',
	'join'    => 's/join\s*\(\s*\/?\s*(.+?)\/?,\s*([^\)]+)\)?/$1.join($2)/g',
	'chomp'   => 's/chomp\s*\(?\s*(\S+)\s*/$1 = $1.rstrip()/g',
	'//'      => 's/(\S+)\s*=~\s*\/(.*?)\/g?/re.search(r\'$2\', $1)/g',
	'///'     => 's/(\S+)\s*=~\s*s\/(.*?)\/(.*?)\/g?/$1 = re.sub(r\'$2\', \'$3\', $1)/g',
	'//i'     => 's/(\S+)\s*=~\s*\/(.*?)\/g?i/re.search(r\'(?i)$2\', $1)/g',
	'///i'    => 's/(\S+)\s*=~\s*s\/(.*?)\/(.*?)\/g?i/$1 = re.sub(r\'(?i)$2\', \'$3\', $1)/g',
	'push'    => 's/push\s*\(?\s*(\@\w+?)\s*,\s*([\$\"\']?\w+[\'\"]?)\s*\)?/$1.append($2)/g',
	'pop'     => 's/pop\s*\(?\s*(\@\w+)\s*\)?\s*/$1.pop()/g',
	'shift'   => 's/shift\s*\(?\s*(\@\w+)\s*\)?\s*/$1.pop(0)/g',
	'unshift' => 's/unshift\s*\(?\s*(\@\w+)\s*,python \s*(\@\w+)\s*\)?\s*/$1.extendleft($2)/g',
	'reverse' => 's/reverse\s*\(?(\@\w+)\s*\)?\s*/$1/g',
	'.='      => 's/\.\=/\+\=/g',
	'..'      => 's/\s*\((.+)\s*\.\.\s*(.+)\)\s*/ range($1, ($2+1))/',
	'return'  => 's/\s*return\s*(.+)/return $1/',
	'last'    => 's/last/break/g',
	'next'    => 's/next/continue/g',	
	'sub'     => 's/sub/def/g',
	'my'      => 's/my//g',
);

# #############################################################################################
# #############################################################################################
# #############################################################################################
# ##############################     Has  Regex Functions          ############################
# #############################################################################################
# #############################################################################################
# #############################################################################################
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Returns result of regex match on line parsed                   %
# Prototype:-   void match_description($line)                                  %
# Param string  $line      :- Content to compare to match on                   %
# Returns                  :- boolean                                          %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub has_opening_brace  ( $ )  {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\{/;
}

sub has_strictly_closing_brace  ( $ )  {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^[^\{]*\}/;
}
sub has_strictly_opening_brace  ( $ )  {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^[^\}\{]*\{[^\{\}]*$/;
}

sub has_both_braces  ( $ )  {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^[^\{\}]*[\{\}][^\}\{]*[\}\{][^\{\}]*$/;	
}

sub has_closing_then_opening_braces  ( $ )  {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^[^\}]*\}[^\{]*\{[^\{\}]*$/;
}

sub has_opening_then_closing_braces  ( $ )  {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^[^\{]*\{[^\}]*\}[^\{\}]*$/;
}

sub has_pre_inc ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\+\+\$?\w/;
}

sub has_pre_dec ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\-\-\$?\w/;
}

sub has_post_inc ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\w\+\+/;
}

sub has_post_dec ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
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
	$line = strip_quoted_expressions($line);
	return $line =~ /(\s|^)print\s*/;
}

sub has_regex  ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\=\~/;
}

sub has_system_access  ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /((open)|(close)|(STDIN)|(STDOUT)|(STDERR)|(\&1)|(\&2)|(ARGV))/;
}

sub has_explicit_new_line  ( $ ) {
	my ($line) = @_;
	return $line =~ /\".*?\\n\.*?"/;
}

sub has_lib_function_call ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	foreach my $word (split(/((\()|( ))/, $line)) {
		return 1 if defined $word && defined $lib_function_conversion_regex{$word};
	}
	return '';
}

sub has_unix_filter ( $ ) {
	my ($line) = @_;
	return $line =~ /\<\>/;
}

sub has_reverse_function_call ( $ ) {
	my ($line) = @_;
	return $line =~ /reverse\s*\@\w+/;
}

# #############################################################################################
# #############################################################################################
# #############################################################################################
# ##############################      Is  Regex Functions          ############################
# #############################################################################################
# #############################################################################################
# #############################################################################################
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Returns result of regex match on line parsed                   %
# Prototype:-   void match_description($line)                                  %
# Param string  $line      :- Content to compare to match on                   %
# Returns                  :- boolean                                          %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub is_empty_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*$/;
}

sub is_var_declaration_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*[\$\@\%]\w+.*?\s*\=\s*[\"\']?.*[\"\']?\s*$/;	
} 

sub is_closing_brace_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*\}\s*$/;
}

sub is_opening_brace_line ( $ )  {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*\{\s*$/;
}

sub is_comment_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*\#.*$/;
}

sub is_else_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*\}?\s*else\s*\{?\s*$/;
}

sub is_elsif_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*\}?\s*elsif\s*\(.+\)\s*\{?\s*$/;
}

sub is_print_line ( $ ) {
	my ($line) = @_;
	#$line = strip_quoted_expressions($line);
	return $line =~ /^\s*print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\s*[\.\,\+\*\-\/]\s*)*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\)?\s*$/;
}

sub is_if_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return (is_standard_if($line) || is_reverse_order_if_line($line) || is_else_line($line) || is_elsif_line($line));
}

sub is_standard_if ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*if\s*\(?.*\)?\s*$/;
}

sub is_reverse_order_if_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\s*?.+?\sif\s*\(?.*\)?\s*$/;
}

sub is_for_statement ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*for(each)?.*\s*$/;
}

sub is_standard_for_statement_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\s*for\s*\(\s*.*?;.*?;.*?\)\s*\{?\s*$/;
}

sub is_foreach_statement_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
}

sub is_for_var_in_set ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /\s*for\s*(.*?)\s*in\s*(\(?.*?\)?)\s*\{?\s*$/;
}

sub is_prepost_incdec_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*((((\-\-)|(\+\+))\$\w+)|(\$\w+((\-\-)|(\+\+))))\s*$/;
}

sub is_while_statement_line ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*while\(?.*?\)\s*\{?\s*$/;
}

sub is_single_word_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\S+$/;
}

sub is_function_declaration ( $ ) {
	my ($line) = @_;
	$line = strip_quoted_expressions($line);
	return $line =~ /^\s*sub\s+(\w+)\s*(\(?.*?\)?)?\s*[\;\{]?\s*$/;
}

sub is_function_arg_dec_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*my.*?\(.*\$.+?\)+\s*=.*?\@_.*\s*$/;	
}

sub is_single_condition ( $ ) {
	my ($line) = @_;
	return $line !~ /((\&\&)|(\|\|))/;		
}

sub is_unix_filter_pattern_line ( $ ) {
	my ($line) = @_;
	return $line =~ /^\s*while\s*\(?\s*(.+)?\s*\=?\s*\<(.*)?\>\s*\)?\s*\{?\s*$/;		
}

# #############################################################################################
# #############################################################################################
# #############################################################################################
# ##############################    Strip  Regex Functions          ###########################
# #############################################################################################
# #############################################################################################
# #############################################################################################
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Performs substitution regex on line parsed to remove specific  %
#               characters/sequences                                           %
# Prototype:-   string strip_content_to_remove($line)                          %
# Param string  $line      :- Content to strip chars/sequences from            %
# Returns                  :- string Result of regex substitution              %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub strip_outermost_parentheses ( $ )  {
	my ($line) = @_;
	my $no_parentheses_line = $line;
	$no_parentheses_line =~ s/\(//;
	$no_parentheses_line =~ s/\)(.*)$/$1/;
	return strip_outer_spaces($no_parentheses_line);
}

sub strip_outermost_braces ( $ ) {
	my ($line) = @_;
	my $no_braces_line = $line;
	# Also replaces first occuring brace with a :
	$no_braces_line =~ s/^([^\{]*)\{/$1:/;
	$no_braces_line =~ s/^(.*)\}([^\}]*$)/$1$2/;
	return strip_outer_spaces($no_braces_line);
}

sub strip_dollar_signs ( $ ) {
	my ($line) = @_;
	my $var_line = $line;
	$var_line =~ s/\$(\w+)/$1/g;
	return strip_outer_spaces($var_line);	
}

sub strip_new_line ( $ ) {
	my ($line) = @_;
	$line =~ s/(\".*)\\n(\s*\")\s*$/$1$2/;
	return strip_outer_spaces($line);	
}

sub strip_at_signs ( $ ) {
	my ($line) = @_;
	$line =~ s/\@//g;
	return strip_outer_spaces($line);	
}

sub strip_logic_operators ( $ ) {
	my ($line) = @_;
	$line =~ s/\&\&/ and /g;
	$line =~ s/\|\|/ or /g;
	$line =~ s/\!/ not /g if $line !~ /\#\!/;
	return strip_outer_spaces($line);	
}

sub strip_input_methods ( $ ) {
	my ($line) = @_;
	$line =~ s/\<\>/fileinput.input()/g;
	$line =~ s/\<STDIN\>/sys.stdin.readline()/g;
	$line =~ s/\<STDOUT\>/sys.stdout.write()/g;
	$line =~ s/\<STDERR\>/sys.stderr.write()/g;
	$line =~ s/\&1/sys.stdout.write()/g;
	$line =~ s/\$\#ARGV/len(sys.argv) - 1/g;
	$line =~ s/\&2/sys.stderr.write()/g;
	$line =~ s/len\(\@ARGV\)/len(sys.argv)/g;
	$line =~ s/\$ARGV\[(.*)\]/sys.argv[$1+1]/g;
	$line =~ s/\@ARGV/sys.argv[1:]/g;
	$line =~ s/ARGV/sys.argv/g;
	return strip_outer_spaces($line);	
}

sub strip_comparators ( $ ) {
	my ($line) = @_;
	$line =~ s/\seq\s/ == /g;
	$line =~ s/\sne\s/ != /g;
	return strip_outer_spaces($line);	
}

sub strip_invalid_python ( $ ) {
	my ($line) = @_;
	#debug("Given Output:- $line");
	$line = strip_semi_colon($line);
	$line = strip_logic_operators($line);
	$line = strip_comparators($line);
	$line = strip_input_methods($line);
	$line = convert_lib_functions($line);
	$line = strip_dollar_signs($line);
	$line = strip_at_signs($line);
	#print "should be no dol signs here :- $line\n";
	my @valid_python = convert_prepost_incdec($line);

	#debug("Produced Output:- @valid_python");
	return @valid_python;
}

sub strip_semi_colon ( $ ) {
	my ($line) = @_;
	$line =~ s/\;//g;
	return strip_outer_spaces($line);	
}

sub strip_prepost_incdec ( $ ) {
	my ($line) = @_;
	$line =~ s/((\-\-)|(\+\+))//g;
	return strip_outer_spaces($line);	
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
	$line = "(".$line.")" if !is_single_condition($line);
	return $line;
}

sub strip_regex_expressions ( $ ) {
	my ($line) = @_;
	$line =~ s/([^\/]*)s\/[^\/]*\/[^\/]*\/g?(.*)$/$1\/\/\/$2/g;
	while($line =~ /^((.*?\/.*?\/.*?)*[^\/]*)m?\/[^\/]+\/(.*)$/) {
		$line =~ s/^((.*?\/.*?\/.*?)*[^\/]*)m?\/[^\/]+\/g?(.*)$/$1\/\/$3/g;
	}
	return $line;
}

sub strip_quoted_expressions ( $ ) {
	my ($line) = @_;
	$line = strip_regex_expressions($line);
	while($line =~ /^((.*?\".*?\".*?)*[^\"]*)\"[^\"]+\"(.*)$/) {
		$line =~ s/^((.*?\".*?\".*?)*[^\"]*)\"[^\"]+\"(.*)$/$1\"\"$3/g;
	}
	return $line;
}

sub strip_quoted_variables ( $ ) {
	my ($line) = @_;
	debug("Print :- stripping $line quotes");
	$line =~ s/[\"\']\s*(\$\w+(\[.+\])?)\s*[\"\']/$1 /g;
	debug("Print :- stripping $line quotes");
	$line =~ s/(\"[^\.\+\,\"\$]*)\$(\w+)([^\.\+\,\"\$]*)/$1\" + $2 + \"$3/g;
	$line =~ s/\./\+/g;
	$line =~ s/[\"\']\s*[^\.\+]?\s*(\$\w+?)\s*[^\.\+]?\s*[\"\']/$1 /g;
	$line =~ s/\"\"\s*\+\s*//g;
	$line =~ s/\"\"\s*//g;
	$line =~ s/\s*\+\s*$//g;

	debug("Print Output :- stripped $line quotes");
	return strip_outer_spaces($line);
}

# #############################################################################################
# #############################################################################################
# #############################################################################################
# ##############################     Get  Regex Functions          ############################
# #############################################################################################
# #############################################################################################
# #############################################################################################
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Returns capture part of regex match on line parsed             %
# Prototype:-   void match_description($line)                                  %
# Param string  $line      :- Content to compare to match on                   %
# Returns                  :- string                                           %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub get_print ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /^\s*(print\s*\(?\s*(((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\s*[\.\,\+\-\/\*]\s*)*((\"[^\"]+\"\s*)|(\s*\$\w+\s*))\s*\)?)/;
	return "";
}

sub get_for_statement_init ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /\s*for\s*\(\s*(.*?);.*?;.*?\)\s*\{?\s*$/;
	return "";
}

sub get_for_statement_condition ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /\s*for\s*\(\s*.*?;(.*?);.*?\)\s*\{?\s*$/;
	return "";
}

sub get_for_statement_postexec ( $ ) {
	my ($line) = @_;
	my @exec_lines = split /,/, $1 if $line =~ /\s*for\s*\(\s*.*?;.*?;\s*(.*?)\)\s*\{?\s*$/;
	return @exec_lines;
}

sub get_post_var( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /(\$?[A-Za-z_]+)((\-\-)|(\+\+))/;
	return "";
}

sub get_pre_var( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($4) if $line =~ /((\-\-)|(\+\+))(\$?[A-Za-z_]+)/;
	return "";
}

sub get_incdec_op ( $ ) {
	my ($line) = @_;
	return "+" if (has_post_inc($line) || has_pre_inc($line));
	return "-" if (has_post_dec($line) || has_pre_dec($line));
}

sub get_if_condition ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /^\s*if\s*(\(.*\))/;
	return "";
}

sub get_if_routine ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($2) if $line =~ /^\s*if\s*(\(.*?\))\s*\{(.*)\}/;
	return "";
}

sub get_reverse_if_condition ( $ ) {
	my ($line) = @_;
	return strip_condition_padding($2) if $line =~ /\s*(.+)\s+if\s*(\(?.+\)?)\s*\;?\s*$/;
	return "";
}

sub get_reverse_if_routine ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /\s*(.+)\s+if\s*(\(?.+\)?)\s*\;?\s*$/;
	return "";
}

sub get_foreach_var ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
	return "";
}

sub get_foreach_set ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($2) if $line =~ /\s*foreach\s*(.*?)\s*(\(.*?\))\s*\{?\s*$/;
	return "";
}

sub get_while_condition ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /^\s*while\s*\(?(.*?)\)\s*\{?\s*$/;
	return "";
}

sub get_function_prototype_args ( $ ) {
	my ($line) = @_;
	return "" if !($line =~ /^\s*sub\s+(\w+)\s*(\(.*?\))\s*\{?\s*$/);
	my $args = $2;
	my @arguments = ();
	my $arg_num = 0;
	while($args =~ /[\$\@\%]/g) {
		push (@arguments, "arg".$arg_num++);
	}
	return strip_outer_spaces("(".join(', ', @arguments).")");
}

sub get_function_defined_args ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /^\s*my.*?(\(.*\$.+?\))+\s*=.*?\@_.*\s*$/;
	return "";
}

sub get_function_name ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /^\s*sub\s+(\w+)\s*(\(?.*?\)?)\s*\{?\s*$/;
	return "";
}

sub get_unix_filter_input_variable ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($1) if $line =~ /^\s*while\s*\(?\s*(.+?)\s*\=?\s*(\<.*?\>)\s*\)?\s*\{?\s*$/;
	return "";
}

sub get_unix_filter_input_source ( $ ) {
	my ($line) = @_;
	return strip_outer_spaces($2) if $line =~ /^\s*while\s*\(?\s*(.+?)\s*\=?\s*(\<.*?\>)\s*\)?\s*\{?\s*$/;
	return "";
}

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Purpose:-     Applies regex statement to string and returns the result       %
# Prototype:-   string apply_regex($regex, $line)                              %
# Param string  $regex     :- Regex statement to apply                         %
# Param string  $string    :- Content to apply regex to                        %
# Returns                  :- string                                           %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub apply_regex ( $$ ) {
	my ($regex, $string) = @_;
	#debug("string is $string");
	#debug("regex  is $regex");
	debug("eval $string =~ $regex");
	eval "\$string =~ $regex";
	#debug("eval result = $?");
	#debug("$string");
	return $string;
}


1;