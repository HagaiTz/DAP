#!/bin/bash


if [ -e $1/raw ]; then
	if [ ! -e $2 ]; then
		mkdir -p $2
	fi

	/opt/MATLAB/R2017a/bin/matlab -nodesktop -nodisplay -nojvm -nosplash -r "subjDti('$1')" \
	> $2/dtiInit_output.txt \
	2> $2/dtiInit_error.txt

	exit;
fi

for file in $(ls $1); do
	if [ -d $1/$file ]; then
		bash $0 $1/$file $2/$file
	fi
done