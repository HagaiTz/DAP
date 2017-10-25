#!/bin/bash

if (( $# == 2 )); then
	logDir=$2
else
	logDir=`basename $1 | sed -e s/"_Processed"//g`
	logDir=`dirname $1`/${logDir}_logs
fi

let depth=0

while [ true ]; do
	tmp=`find $1 -maxdepth $depth -type d -name raw`
	tmp=`echo $tmp | cut -d" " -f1`
	if [[ -e $tmp ]]; then
		break
	fi
	let depth++
done

if [ ! -e ${logDir} ]; then
	mkdir -p ${logDir}
fi

/opt/MATLAB/R2017a/bin/matlab -nodesktop -nodisplay -nosplash -r "analyzeGroups('$1',$depth)" \
	> ${logDir}/Analysis_output.txt \
	2> ${logDir}/Analysis_error.txt