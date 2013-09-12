#!/bin/sh
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************

cd /home/steven/Documents/softconass1
git pull
git add .
git commit -m "Updating Git - $1"
git push