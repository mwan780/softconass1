#!/usr/bin/python2.7 -u
import re
var = "hello\n"
var = var.rstrip()
array = var.split('l')
print array
line = '-'.join(array)
print line
line = re.sub(r'(?i)l', 's', line)
print line
re.search(r'(?i)l', line)
print line
re.search(r'p', line)
print line
