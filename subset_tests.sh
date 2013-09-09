#!/bin/sh
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************
program_name="`echo $0 | cut -f2 -d '/'`"
PID="`ps -ea | grep $0`"
tmp_file="$program_name$(date +%Y-%m-%d_%H:%M:%S)$PID.tmp"

# Perform temp file cleanup
	echo "******************************"
	echo "******************************"
	echo "*** Performing Temp Cleanup***"
	echo "******************************"
	echo "******************************"
cd test
for i in 1 2
do 
	old_temps="`ls -1 | egrep -i '$program_name.*\.tmp'`"
	for temp in $old_temps
	do
		rm $temp
		result=$?
		if [ $result -eq 0 ]; then
			echo "Old Temp File $temp was deleted"
		fi
	done
	cd ..
done
cd test



for subset in 1 2 3 4 5 
do 
	echo "******************************"
	echo "******************************"
	echo "*Running Subset $subset Tests*"
	echo "******************************"
	echo "******************************"
	files="`ls subset"$subset"*.pl`"
	echo $files
	for answer in $files
	do 	
		curr_file_name="`echo $answer | cut -f1 -d '.'`"
		echo "Converting perl-to-python for $answer"
		../perl2python.pl $answer > $tmp_file
		result=$?
		if [ $result -ne 0 ]; then 
			echo result was $result
			echo "_______________________$0 : Error - perl2python output to temp file failed" >&2
			break;
		fi 
		diff -q $curr_file_name.py $tmp_file
		result=$?
		if [ $result -ne 0 ]; then
			echo "Direct Comparison Source Code Check.......................$result... Failed"
		else
			echo "Direct Comparison Source Code Check.......................$result... Passed"
	    fi
	    chmod +x $tmp_file > /dev/null
	    ./$tmp_file > /dev/null
	    result=$?
		if [ $result -ne 0 ]; then
	    	echo "Compilation Test..........................................$result... Failed"
	    else
	    	echo "Compilation Test..........................................$result... Passed"
		    ./$tmp_file > generatedoutput$tmp_file
	    	./$curr_file_name.py > expectedoutput$tmp_file
	    	diff -q generatedoutput$tmp_file expectedoutput$tmp_file
	    	result=$?
			if [ $result -ne 0 ]; then
		     	echo "Program Output Comparison Check...........................$result... Failed"
		    else
	    		echo "Program Output Comparison Check...........................$result... Passed"
	    	fi
	    fi
	done
done

rm -f "../*$tmp_file"
rm -f "*$tmp_file"
