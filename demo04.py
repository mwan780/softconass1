#!/usr/bin/python2.7 -u
# Pops first element if comma seperated then adds end
# splits elements on -- rather than ,
import fileinput, re
for text in fileinput.input():
    text = text.rstrip()
    if re.match(r',', text) :
        array = text.split(',')
        for element in array.reverse(): 
            element += ' - '
        array.pop(0)
        array.append('end')
        text = '-'.join(array)
    print text
