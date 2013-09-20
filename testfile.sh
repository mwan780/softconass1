#!/bin/sh

program_name="`echo $0 | cut -f2 -d '/'`"
PID="`ps -ea | grep $0`"
tmp_file="$program_name$(date +%Y-%m-%d_%H:%M:%S)$PID.tmp"
python_file="`echo $1 | cut -f1 -d '.'`"

echo "Compiling file $1"
./perl2python.pl $1 > $tmp_file
echo "Source Code Comparison"
diff -y $tmp_file $python_file.py
result=$?
if [ $result -ne 0 ]; then
	echo "Source Code Comparison _________________________________________ Failed"
else 
	echo "Source Code Comparison _________________________________________ Passed"
fi 

echo "Compilation Test"
chmod +x $tmp_file
./$tmp_file
result=$?
if [ $result -ne 0 ]; then
	echo "Compilation Test _______________________________________________ Failed"
else 
	echo "Compilation Test _______________________________________________ Passed"
fi 


	echo "Output Comparison "
./$1 > expected$tmp_file
./$tmp_file > generated$tmp_file
diff -y generated$tmp_file expected$tmp_file
result=$?
if [ $result -ne 0 ]; then
	echo "Output Comparison _____________________________________________ Failed"
else 
	echo "Output Comparison _____________________________________________ Passed"
fi 


rm *.tmp