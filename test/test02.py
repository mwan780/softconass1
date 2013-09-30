#!/usr/bin/python2.7 -u
# Test For Statements
i = 0
array = []
for i in xrange(1, 10) :
    print i,
    array.append(i)
print
print "Array Default Print"
print array

i = 0
while (i < 9  and  i > -1) :
    print i,
    i += 1

print

print
print "Iterative Array Print"
for i in array :
    print i,

print
