#!/usr/bin/python2.7 -u
def factorial(num):
    if num > 1 : return num * factorial(num - 1)
    return num

fac5 = factorial (5)
print "5 not  = " + fac5
