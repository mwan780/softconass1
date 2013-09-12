#!/bin/sh
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************
PID="`ps -ea | grep $0`"
tmp_file="$0$(date +%Y-%m-%d_%H:%M:%S)$PID.tmp"
tmp_file="`echo $tmp_file | cut -f2 -d '/'`"
for subset in 1 2 3 4 5 
do 
	echo "******************************"
	echo "******************************"
	echo "*Running Subset $subset Tests*"
	echo "******************************"
	echo "******************************"
	cd test
	files="`ls subset"$subset"*.pl`"
	echo $files
	for answer in $files
	do 	
		curr_file_name="`echo $answer | cut -f1 -d '.'`"
		echo "Converting perl-to-python for $answer"
		cd ..
		./perl2python.pl test/$answer > $tmp_file
		cd test
		if [ $? ]; then 
			echo "_______________________$0 : Error - perl2python output to temp file failed" >&2
			break;
		fi 

		diff -q $curr_file_name.py ../$tmp_file
		if [ $? ]; then 
			echo "Direct Comparison Source Code Check........................ Failed"
		else
			echo "Direct Comparison Source Code Check........................ Passed"
	    fi
	    echo "Compilation Test"
	    cd ..
	    chmod +x /$tmp_file
	    ./$tmp_file
	    cd test
	    if [ $? ]; then
	    	echo "Compilation Test........................................... Failed"
	    else
	    	echo "Compilation Test........................................... Passed"
		    ../$tmp_file > generatedoutput$tmp_file
	    	./$curr_file_name.py > expectedoutput$tmp_file
	    	diff -q generatedoutput$tmp_file expectedoutput$tmp_file
	    	if [ $? ]; then
		     	echo "Program Output Comparison Check............................ Failed"
		    else
	    		echo "Program Output Comparison Check............................ Passed"
	    	fi
	    fi
	done
done

rm -f ../*$tmp_file
rm -f *$tmp_file

