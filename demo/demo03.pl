#!/usr/bin/perl -w
$text = "print";
$test = 'test';
$true = 0;
print "This is a $text " . $test . " hello\n" if (++$true && 1);
