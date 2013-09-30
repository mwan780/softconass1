#!/usr/bin/python2.7 -u
import fileinput
for _ in fileinput.input():
    _ = _.rstrip()
    print _
