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

# Perform temp file cleanup
echo "******************************"
echo "******************************"
echo "*** Performing Temp Cleanup***"
echo "******************************"
echo "******************************"
cd ./test
for i in 1 2
do 
	old_temps="`ls -1 | egrep -i '$program_name.*\.tmp'`"
	for temp in $old_temps
	do
		echo "Trying to delete $temp"
		rm -f $temp
		result=$?
		if [ $result -eq 0 ]; then
			echo "Old Temp File $temp was deleted" 
		fi
	done
done

echo 
echo 
echo


die() {
	if [ $1 -ne 0 ]; then
		echo "$2" >&2
		exit 1
	fi
}


for subset in 1 2 3 4 5 6 7 8 9 10
do 
	echo "******************************"
	echo "******************************"
	echo "*Running Subset $subset Tests*"
	echo "******************************"
	echo "******************************"

	files="`ls subset"$subset"*.pl test$subset.pl`"
	echo "Testing .... $files"
	for answer in $files
	do 	
		curr_file_name="`echo $answer | cut -f1 -d '.'`"
		echo "Converting perl-to-python for $answer"
		../perl2python.pl $answer > $tmp_file
		result=$?
		if [ $result -ne 0 ]; then 
			echo result was $result
			echo "$0 : Error - perl2python output to temp file failed" >&2
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
	    if [ $subset -eq 4 ]; then
	    	echo -e "$1\n-1" | ./$tmp_file > /dev/null
			result=$? 
		else 
	    	./$tmp_file > /dev/null
	    	result=$?
	    fi
	       
		if [ $result -ne 0 ]; then
	    	echo "Compilation Test..........................................$result... Failed"
	    else
	    	echo "Compilation Test..........................................$result... Passed"
		  	if [ $subset -eq 4 ]; then
		  		echo "Generated Output"

		  		echo -e "$1\n-1" | ./$tmp_file > generatedoutput$tmp_file
	    		die $? "Could not generate output to file"
	    		echo "Expected Output"
				echo -e "$1\n-1" | ./$curr_file_name.py > expectedoutput$tmp_file
				die $? "Could not generate expected ouptut"
			else 
	    		./$tmp_file > generatedoutput$tmp_file
	    		./$curr_file_name.py > expectedoutput$tmp_file
	    		die $?
	    	fi
	    	diff -q generatedoutput$tmp_file expectedoutput$tmp_file
	    	result=$?
			if [ $result -ne 0 ]; then
		     	echo "Program Output Comparison Check...........................$result... Failed"
		    else
	    		echo "Program Output Comparison Check...........................$result... Passed"
	    	fi
	    fi
	    echo
	    echo
	done
	echo 
	echo 
	echo
	echo
done





# Temp File Cleanup
cd test
rm $tmp_file
rm expectedoutput$tmp_file
rm generatedoutput$tmp_file
rm -f ../*.tmp
rm -f *.tmp
