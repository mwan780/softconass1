#!/bin/sh
# *********************************
# *********************************
# Author:- Steven Falconieri    
# *********************************
# *********************************

program_name="`echo $0 | cut -f2 -d '/'`"
PID="`ps -ea | grep $0`"
tmp_file="$program_name$(date +%Y-%m-%d_%H:%M:%S)$PID.tmp"
echo Running $program_name

die() {
	if [ $1 -ne 0 ]; then
		echo "$2" >&2
		exit 1
	fi
}

files="`ls $1/*.pl`"
echo "Testing .... $files"
for answer in $files
do 	
	curr_file_name="`echo $answer | cut -f1 -d '.'`"
	echo "######################################"
	echo "Converting perl-to-python for $answer"
	echo "######################################"
	./perl2python.pl $answer > $tmp_file
	result=$?
	if [ $result -ne 0 ]; then 
		echo result was $result
		echo "$0 : Error - perl2python output to temp file failed" >&2
		break;
	fi 
	diff -y $curr_file_name.py $tmp_file
	result=$?
	echo
	echo "Test:- $curr_file_name:-"
	if [ $result -ne 0 ]; then
		echo "Test:- Direct Comparison Source Code Check......................$result... Failed ............ $curr_file_name"
	else
		echo "Test:- Direct Comparison Source Code Check......................$result... Passed ............ $curr_file_name"
    fi
    chmod +x $tmp_file > /dev/null
    if [ $subset -eq 4 ]; then
    	echo -e "$1\n-1" | ./$tmp_file $curr_file_name...* > /dev/null
		result=$? 
	else 
    	./$tmp_file $curr_file_name...* > /dev/null
    	result=$?
    fi
    #echo "Test:- $curr_file_name:-"
	if [ $result -ne 0 ]; then
    	echo "Test:- Compilation Test.........................................$result... Failed ............ $curr_file_name"
    else
    	echo "Test:- Compilation Test.........................................$result... Passed ............ $curr_file_name"
	  	if [ $subset -eq 4 ]; then
	  		echo "Generated Output"

	  		echo -e "$1\n-1" | ./$tmp_file $curr_file_name...* > generatedoutput$tmp_file
    		die $? "Could not generate output to file"
    		echo "Expected Output"
			echo -e "$1\n-1" | ./$curr_file_name.py $curr_file_name...* > expectedoutput$tmp_file
			die $? "Could not generate expected ouptut"
		else 
    		./$tmp_file > generatedoutput$tmp_file
    		./$curr_file_name.py > expectedoutput$tmp_file
    		die $?
    	fi
    	diff -y generatedoutput$tmp_file expectedoutput$tmp_file
    	result=$?
		echo
		#echo "Test:- $curr_file_name:-"
		if [ $result -ne 0 ]; then
	     	echo "Test:- Program Output Comparison Check..........................$result... Failed ............ $curr_file_name"
	    else
    		echo "Test:- Program Output Comparison Check..........................$result... Passed ............ $curr_file_name"
    	fi
    fi
    echo
    echo "Press any key to Continue"
    cat | echo # Press any key to continue
done




# Temp File Cleanup
cd test
rm $tmp_file
rm expectedoutput$tmp_file
rm generatedoutput$tmp_file
rm -f ../*.tmp
rm -f *.tmp
