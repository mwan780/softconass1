#!/usr/bin/python2.7 -u
import re
line = "complex regex statement"
print "line = " + line
if re.search(r'complex', line) : print line + " = complex lower case"
if re.search(r'(?i)COMPLEX', line) : print line + " = complex ignore case"
line = re.sub(r'(?i)regex', 'reGX', line)
print line + " = regex substituted for regX"
line = re.sub(r'(?i)regx', 'reX', line)
print line + " = regX substituted for reX"
line = re.sub(r'(?i)e', '5', line)
print line + " = replace all e for 5"
print "line = " + line
