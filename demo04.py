#!/usr/bin/python2.7 -u
# Pops first element if comma seperated then adds end
# splits elements on -- rather than ,
import fileinput, re
for text in fileinput.input():
    text = text.rstrip()
    if re.search(r',', text) :
        text += ", end, the"
        array = text.split(', ')
        array.reverse()
        array = array
        for element in array :
            print element
        array.pop(0)
        array.append('start')
        text = '-'.join(array)
    print text
