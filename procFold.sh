#!/bin/bash


function mkFold {
	if [[ ! -e $1 ]]; then
		mkdir -p $1
	fi
}

# Convert Dicom
function convertDicom {
	dti=(`ls $1/dicom | grep DTI`)
	if [[ $dti != "" ]]; then
		mkFold $2/raw
		dcm2niix -o $2/raw -g y $1/dicom/$dti/*.dcm
		mv $2/raw/*.nii.gz $2/raw/dti.nii.gz
		mv $2/raw/*.bval $2/raw/dti.bval
		mv $2/raw/*.bvec $2/raw/dti.bvec
		t1=(`ls $1/dicom | grep T1`)
		if [[ $t1 != "" ]]; then
			dcm2nii -o $2 -g y -r y -x n $1/dicom/$t1/*.dcm
			find $2 -maxdepth 1 -type f ! -name o*.nii.gz -exec rm -f {} +
			mv $2/*.nii.gz $2/t1.nii.gz
		fi
		return;
	fi
	echo --$1 >> $3/Missing_Data.txt
}

# Copy Nifti form
function copyFold {
	if [ ! -e $1/raw/dti.bvec* ] || \
		[ ! -e $1/raw/dti.bval* ] || \
		[ ! -e $1/raw/dti.nii.gz ] ; then
		echo --$1 >> $3/Missing_Data.txt
	else
		mkFold $2
		cp -rf $1/* $2
		mv $2/raw/dti.bvec* $2/raw/dti.bvec
		mv $2/raw/dti.bval* $2/raw/dti.bval
	fi
}

###########################################33

if [[ -e $1/dicom ]]; then
	convertDicom $1 $2 $3
	exit;
elif [[ -e $1/raw ]]; then
	copyFold $1 $2 $3
	exit;
fi

for name in $(ls $1); do
	if [ -d $1/$name ]; then
		bash $0 $1/$name $2/$name $3
	fi
done

