

files=`ls answer*.*`

for f in $files
do
   cp $f subset3_$f
done