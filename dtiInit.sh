#!/bin/bash




if [ -e $1/raw ]; then
	if [ ! -e $2 ]; then
		echo mkdir -p $2
	fi

	/opt/MATLAB/R2017a/bin/matlab -nodisplay -nojvm -nosplash -r "subjDti('$1')" \
	> $2/Init_output.txt \
	2> $2/Init_error.txt

    return;
fi

for file in $(ls $1); do
	if [ -d $1/$file ]; then
		bash $0 $1/$file $2/$file
	fi
done