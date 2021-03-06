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
# #######  Requires   :- perl2python.pl, regex_functions.pl      ##############################
# #######  Description:- Contains Unit Tests to ensure regex functions work correctly  ########
# #############################################################################################
# #############################################################################################
# #############################################################################################
use Test::More;


sub run_convert_tests {
	is(convert_set_to_python('(0..10)'), 'xrange(0, 11)',   'Set Conversion');
	is(convert_set_to_python('(0..1)'),  'xrange(0, 2)',    'Set Conversion');
	is(convert_set_to_python('(0..4)'),  'xrange(0, 5)',    'Set Conversion');
	is(convert_lib_functions('$line =~ s/hello/goodbye/i'), '$line = re.sub(r\'(?i)hello\', \'goodbye\', $line)', 'Function Conversion');

	return 1;
}

sub run_is_tests {
	is(is_closing_brace_line('}'),                                   1,          'Is Closing Brace Line');
	is(is_closing_brace_line('   }    '),                            1,          'Is Closing Brace Line');
	is(is_comment_line('# Comment'),                                 1,          'Is Comment Line');
	is(is_comment_line('      # Comment'),                           1,          'Is Comment Line');
	is(is_comment_line('#! /usr/bin/perl -w '),                      1,          'Is Comment Line');
	is(is_comment_line(' '),                                        '',          'Is Comment Line');
	is(is_comment_line(''),                                         '',          'Is Comment Line');
	is(is_standard_if('if (true) { '),                               1,          'Is Standard If');
	is(is_else_line('} else {'),                                     1,          'Is Else Line');
	is(is_else_line('else'),                                         1,          'Is Else Line');
	is(is_else_line(' else {'),                                      1,          'Is Else Line');
	is(is_else_line('} else '),                                      1,          'Is Else Line');
	is(is_elsif_line('} elsif (true) '),                             1,          'Is Else If Line');
	is(is_elsif_line('} elsif (true) {'),                            1,          'Is Else If Line');
	is(is_elsif_line('} elsif (true || false) { '),                  1,          'Is Else If Line');	
	is(is_empty_line(''),                                            1,          'Is Empty Line');
	is(is_empty_line('    '),                                        1,          'Is Empty Line');
	is(is_foreach_statement_line('foreach $i (@array) {'),           1,          'Is Foreach Statement Line');
	is(is_for_statement('for($i=0; $i < $x; $i++)'),                 1,          'Is For Statement');
	is(is_for_statement('foreach $i (@array) {)'),                   1,          'Is For Statement');
	is(is_for_statement('for $i in (0..10) {'),                      1,          'Is For Statement');
	is(is_for_var_in_set('for $i in (0..10) {'),                     1,          'Is For Var in Set');
	is(is_function_declaration('sub function_name ( $ ) { '),        1,          'Is Function Declaration');
	is(is_function_declaration('sub function_name ( $ );'),          1,          'Is Function Declaration');
	is(is_function_declaration('sub function_name ( $ )'),           1,          'Is Function Declaration');
	is(is_opening_brace_line('{'),                                   1,          'Is Opening Brace Line');
	is(is_opening_brace_line('   {'),                                1,          'Is Opening Brace Line');
	is(is_opening_brace_line('{    '),                               1,          'Is Opening Brace Line');
	is(is_prepost_incdec_line('$i--'),                               1,          'Is PrePost IncDec Line');
	is(is_prepost_incdec_line('$i++'),                               1,          'Is PrePost IncDec Line');
	is(is_prepost_incdec_line('--$i'),                               1,          'Is PrePost IncDec Line');
	is(is_prepost_incdec_line('++$i'),                               1,          'Is PrePost IncDec Line');
	is(is_print_line('print "value = " . $var . "\n"'),              1,          'Is Print Line');
	is(is_print_line('print "value = \n"'),                          1,          'Is Print Line');
	is(is_print_line('print $var."\n"'),                             1,          'Is Print Line');
	is(is_reverse_order_if_line('print "hello" if 1;'),              1,          'Is Reverse Order If Line');
	is(is_reverse_order_if_line('print "hello" if ($x > 2);'),       1,          'Is Reverse Order If Line');
	is(is_reverse_order_if_line('print "hello" if true && $var;'),   1,          'Is Reverse Order If Line');
	is(is_single_word_line('$i=0;'),                                 1,          'Is Single Word Line');
	is(is_standard_for_statement_line('for($i=0; $i < $x; $i++) {'), 1,          'Is Standard For Statement Line');
	is(is_var_declaration_line('$var = 2;'),                         1,          'Is Var Declaration Line');
	is(is_var_declaration_line('@var = ("hello", "goodbye");'),      1,          'Is Var Declaration Line');
	is(is_var_declaration_line('%var{$i} = 2;'),                     1,          'Is Var Declaration Line');
	is(is_while_statement_line('while ($i > $x) {'),                 1,          'Is While Statement Line');
	is(is_while_statement_line('while (true) {'),                    1,          'Is While Statement Line');
	is(is_while_statement_line('while (1) '),                        1,          'Is While Statement Line'); 
	is(is_function_arg_dec_line('my($line) = @_'),                   1,          'Is Function Argument Declaration Line'); 
	is(is_function_arg_dec_line('my($line, @rest) = @_'),            1,          'Is Function Argument Declaration Line'); 
	is(is_function_arg_dec_line('my($line, $var) = @_'),             1,          'Is Function Argument Declaration Line'); 
	is(is_if_line('if (true) { '),                                   1,          'Is If Line');
	is(is_if_line('} elsif (true) { '),                              1,          'Is If Line');
	is(is_if_line('print "hello" if (true);'),                       1,          'Is If Line');
	is(is_if_line('} else { '),                                      1,          'Is If Line');
	is(is_unix_filter_pattern_line('while ($line = <>) {'),          1,          'Is Unix Filter Pattern Line');
	is(is_unix_filter_pattern_line('while ($line = <STDIN>) {'),     1,          'Is Unix Filter Pattern Line');
	return 1;
}

sub run_has_tests {
	is(has_both_braces('} else { '),                                 1,          'Has Both Braces');
	is(has_both_braces('for (1) { $i++ }; '),                        1,          'Has Both Braces');
	is(has_both_braces('} elsif ($i == 1) { '),                      1,          'Has Both Braces');
	is(has_closing_then_opening_braces('} else {'),                  1,          'Has Closing then Opening Brace');
	is(has_closing_then_opening_braces('} elsif ($1) {'),            1,          'Has Closing then Opening Brace');
	is(has_opening_then_closing_braces('if(true){print}'),           1,          'Has Opening then Closing Brace');
	is(has_explicit_new_line('"$var here \n"'),                      1,          'Has Explicit New Line');
	is(has_explicit_new_line('print "$var here \n"'),                1,          'Has Explicit New Line');
	is(has_opening_brace('foreach $i (@array) { '),                  1,          'Has Opening Brace');
	is(has_opening_brace('for $i (1..10) { '),                       1,          'Has Opening Brace');
	is(has_post_dec('$i--'),                                         1,          'Has Post Dec');
	is(has_post_dec('@array[$i--]'),                                 1,          'Has Post Dec');
	is(has_post_inc('$i++'),                                         1,          'Has Post Inc');
	is(has_post_inc('@array[$i++]'),                                 1,          'Has Post Inc');
	is(has_pre_dec('--$i'),                                          1,          'Has Pre Dec');
	is(has_pre_dec('@array[--$i]'),                                  1,          'Has Pre Dec');
	is(has_pre_inc('++$i'),                                          1,          'Has Pre Inc');
	is(has_pre_inc('@array[++$i]'),                                  1,          'Has Pre Inc');
	is(has_prepost_incdec('$array[$i++] = 1;'),                      1,          'Has PrePost IndDec');
	is(has_prepost_incdec('$array[$i--] = 1;'),                      1,          'Has PrePost IndDec');
	is(has_prepost_incdec('$array[--$i] = 1;'),                      1,          'Has PrePost IndDec');
	is(has_prepost_incdec('$array[++$i] = 1;'),                      1,          'Has PrePost IndDec');
	is(has_print_call('print "me".$var."\n" if 1;'),                 1,          'Has Print Call');
	is(has_regex('$line =~ s/h/g/gi'),                               1,          'Has Regex');
	is(has_strictly_closing_brace('}'),                              1,          'Has Strictly Closing Brace');
	is(has_strictly_opening_brace('{'),                              1,          'Has Strictly Opening Brace');
	is(has_system_access('<STDIN>'),                                 1,          'Has System Access');
	is(has_lib_function_call('print "hello\n"'),                     1,          'Has Lib Function Call');
	is(has_lib_function_call('split "hello\n"'),                     1,          'Has Lib Function Call');
	is(has_lib_function_call('chomp "hello\n"'),                     1,          'Has Lib Function Call');
	is(has_lib_function_call('chomp "hello\n" if true;'),            1,          'Has Lib Function Call');
	is(has_lib_function_call('"hello\n" if true;'),                  '',         'Has Lib Function Call');
	is(has_no_args('chomp'),                                         1,          'Has No Args');
	is(has_no_args('chomp $var'),                                    '',         'Has No Args');
	return 1;
}

sub run_get_tests {                         
	is(get_foreach_set('foreach $i (@array) {'),                                        '(@array)',        'Get Foreach Set');
	is(get_foreach_set('foreach $i (0..4) {'),                                          '(0..4)',          'Get Foreach Set');
	is(get_foreach_var('foreach $i (@array) {'),                                        '$i',              'Get Foreach Var'); 
	is(get_for_statement_condition('for($i=0; $i < $x; $i++)'),                         '$i < $x',         'Get For Statement Condition');
	is(get_for_statement_init('for($i=0; $i < $x; $i++)'),                              '$i=0',            'Get For Statement Initialisation');            
	is(join("",get_for_statement_postexec('for($i=0; $i < $x; $i++) {')),               '$i++',            'Get For Statement Post Execution');
	is(get_function_prototype_args('sub function_name ( $$ ) { '),                      '(arg0, arg1)',    'Get Function Arguments');
	is(get_function_name('sub function_name ( $$ ) { '),                                'function_name',   'Get Function Name');
	is(get_if_condition('if (true) {'),                                                 '(true)',          'Get If Condition');
	is(get_if_routine('if (true) { routine };'),                                        'routine',         'Get If Routine');
	is(get_incdec_op('--$i'),                                                           '-',               'Get IncDec Operator');
	is(get_post_var('$i++'),                                                            '$i',              'Get Post Var');
	is(get_pre_var('++$i'),                                                             '$i',              'Get Pre Var');
	is(get_print('print $i."\n"'),                                                      'print $i."\n"',   'Get Print Args');
	is(get_while_condition('while (true) {'),                                           'true',            'Get While Condition');
	is(get_unix_filter_input_variable('while ($line = <>) {'),                          '$line',           'Get Unix Filter Pattern Input Variable');
	is(get_unix_filter_input_variable('while ($line = <STDIN>) {'),                     '$line',           'Get Unix Filter Pattern Input Variable');
	is(get_unix_filter_input_source('while ($line = <>) {'),                            '<>',              'Get Unix Filter Pattern Input Source');
	is(get_unix_filter_input_source('while ($line = <STDIN>) {'),                       '<STDIN>',         'Get Unix Filter Pattern Input Source');
	return 1;
}

sub run_strip_tests {
	is(strip_at_signs('@array'),                                                        'array',                                              'Strip Condition Padding');
	is(strip_comparators(''),                                                           '',                                                   'Strip Comparators');
	is(strip_condition_padding('($var > x)'),                                           '$var > x',                                           'Strip Condition Padding');
	is(strip_dollar_signs('$var - $var2 = $var3'),                                      'var - var2 = var3',                                  'Strip Dollar Signs');
	is(strip_input_methods('<STDIN>'),                                                  'sys.stdin.readline()',                               'Strip Input Methods');
	is(join ("", strip_invalid_python('@ARGV')),                                        'sys.argv[1:]',                                       'Strip Invalid Python');
	is(strip_logic_operators('$i&&$j'),                                                 '$i and $j',                                          'Strip Logic Operators');
	is(strip_new_line('print "$var\n"'),                                                'print "$var"',                                       'Strip New Line');
	is(strip_outermost_braces('} elsif {'),                                             'elsif :',                                            'Strip Outer Braces');
	is(strip_outermost_parentheses(' ( condition ) '),                                  'condition',                                          'Strip Outer Parentheses');
	is(strip_outer_spaces('   $var = 10;    '),                                         '$var = 10;',                                         'Strip Outer Spaces');
	is(strip_semi_colon('$i++;'),                                                       '$i++',                                               'Strip Semi Colon');
	is(strip_regex_expressions('$line =~ /^val/'),                                      '$line =~ //',                                        'Strip Regex Expressions');
	is(strip_regex_expressions('$line =~ /;val/; /match/'),                             '$line =~ //; //',                                    'Strip Regex Expressions');
	is(strip_regex_expressions('s/find/replace/g'),                                     '///',                                                'Strip Regex Expressions');
	is(strip_quoted_expressions('$line =~ /^val/'),                                     '$line =~ //',                                        'Strip Quoted Expressions');
	is(strip_quoted_expressions('$line =~ /;val/; /match/'),                            '$line =~ //; //',                                    'Strip Quoted Expressions');
	is(strip_quoted_expressions('s/find/replace/g'),                                    '///',                                                'Strip Quoted Expressions');
	is(strip_quoted_expressions('"hello"'),                                             '""',                                                 'Strip Quoted Expressions');
	is(strip_quoted_expressions('"hello" /regex/'),                                     '"" //',                                              'Strip Quoted Expressions');
	is(strip_quoted_variables('"this is a $test hello"'),                               '"this is a " + test + " hello"',                     'Strip Quoted Variables');
	is(strip_quoted_variables('"$test"'),                                               '$test',                                              'Strip Quoted Variables');
	is(apply_regex('s/l/o/g', 'hello'),                                                 'heooo',                                              'Apply Regex');
	is(apply_regex('s/split\s*\(\s*\/?\s*(.+)\/?,\s*([^\)]+)\)?/$2.split($1)/g',        'split ("hello", string)'),  'string.split("hello")', 'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'split'}, 'split ("hello", string)'), 'string.split("hello")',                              'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'join'}, 'join (" ", $string)'),      '" ".join($string)',                                  'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'chomp'}, 'chomp $variable'),         '$variable = $variable.rstrip()',                     'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'//'}, '$line =~ /hello/'),           're.search(r\'hello\', $line)',                       'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'///'}, '$line =~ s/hello/goodbye/'), '$line = re.sub(r\'hello\', \'goodbye\', $line)',     'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'//i'}, '$line =~ /hello/i'),         're.search(r\'(?i)hello\', $line)',                   'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'///i'}, '$line =~ s/hello/goodbye/i'),'$line = re.sub(r\'(?i)hello\', \'goodbye\', $line)','Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'push'}, 'push (@array, $string)'),    '@array.append($string)',                            'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'push'}, 'push @array, $string'),      '@array.append($string)',                            'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'pop'}, '$line = pop @array'),         '$line = @array.pop()',                              'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'pop'}, '$line = pop (@array)'),       '$line = @array.pop()',                              'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'reverse'}, 'reverse @array'),         '@array',                                            'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'.='}, '$line .= "text"'),             '$line += "text"',                                   'Apply Regex');
	is(apply_regex($lib_function_conversion_regex{'shift'}, 'shift @array'),             '@array.pop(0)',                                     'Apply Regex');

	return 1;
}



run_convert_tests() or die "Failed Conversion Tests";
run_is_tests()      or die "Failed Is Tests";
run_has_tests()     or die "Failed Has Tests";
run_get_tests()     or die "Failed Get Tests"; 
run_strip_tests()   or die "Failed Strip Tests";
done_testing();
1;