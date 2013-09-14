#!/bin/sh
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************

cd /home/steven/Documents/softconass1
cd test 
rm -fv *.tmp
cd ..
git pull
git add .
git commit -m "Updating Git - $1"
git push
