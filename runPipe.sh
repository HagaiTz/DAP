#!/bin/bash

function checkStructure {
	echo "================================================================="
	echo "Please make sure that the data is in the right structure."
	echo "There are two options for folder structure - Dicom & Nifti:"
	echo ""
	echo "Dicom - If the data is in dicom format the folder must contain
	another folder named 'dicom' (lower case). Following the dicom
	folder there must be another two folders - 1) 'DTI' (upper case)
	2) 'T1' (upper case). Each folder should contain the corresponding
	*.dcm files. (see example below)"
	echo ""
	echo "Nifti - If the data is already in format then the folder should
	contain the T1 weighted nifti file as 't1.nii.gz' and a folder called
	'raw' the 'raw folder in turn should contain the relevant dti file: 
	'dti.bvals','dti.bvecs' & 'dti.nii.gz'. (see example below)"
	echo ""
	echo "Example:"
	echo "--------"
	echo ""
	echo "     (path to subject)                  (path to subject)"
	echo "             |                             _____|_____"
	echo "             |                            |           |"
	echo "           dicom/           --OR--       raw/     t1.nii.gz"
	echo "         ____|____                        |"
	echo "        |         |                       |"
	echo "       DTI/      T1/                  dti.bvals"
	echo "        |         |                   dti.bvecs"
	echo "     (*.dcm)    (*.dcm)               dti.nii.gz"
	echo ""
	echo ""
	echo "If the data is already arranged in the format above press any
key to continue. Otherwise type 'no', arrange the data in the right 
format and run again."
	read -p "Do you wish to continue? " yn
	if [[ $yn == [Nn]* ]] ; then
		exit 1
	fi
} 

function mkFold {
	if [[ ! -e $1 ]]; then
	mkdir -p $1
fi
}


# Convert Dicom
function convertDTI {
	for file in `ls $1` ; do
		if [[ $file == *DTI* ]] ; then
			mkFold $2
			dcm2nii -o $2 -g y $1/$file/*.dcm
			mv $2/*.nii.gz $2/dti.nii.gz
			mv $2/*.bval $2/dti.bval
			mv $2/*.bvec $2/dti.bvec
			echo true
			return
		fi
	done
	echo --$1 >> $3/Missing_Data.txt
	echo false
}

function convertT1 {
	for file in `ls $1` ; do
		if [[ $file == *T1* ]] ; then
			dcm2nii -o $2 -g y -r y -x n $1/$file/*.dcm
			find $2 -type f ! -name o*.nii.gz -exec rm -f {} +
			mv $2/*.nii.gz $2/t1.nii.gz
			return
		fi
	done
}

# Copy Nifti form
function copyFold {
	if [[ ! -e $1/raw/dti.bvec* || \
		! -e $1/raw/dti.bval* || \
		! -e $1/raw/dti.nii.gz ]] ; then
		echo --$1 >> $3/Missing_Data.txt
	else
		mkFold $2
		cp -rf $1/* $2
	fi
}


function procFold {
	for file in `ls $1` ;do
		if [[ -f $1/$file ]] ; then 
			continue;
		elif [[  $file == dicom  ]]; then 
			if [[  `convertDTI $1/$file $2/raw $3 ` == true ]] ; then
				convertT1 $1/$file $2
			fi
			return;
		elif [[ $file == raw ]]; then
			copyFold $1 $2 $3
			return;
		elif [[ -d $1/$file ]] ; then
			procFold ${1}/${file} ${2}/${file} $3
			continue;
		fi
	done
}


####################################################################

# Input check
if (( $# != 1 )); then
	echo "Usage $0 [Input Folder]";
	exit 1;
fi

# Check Structure
checkStructure

# Setting directories
inFolder=$1
outFolder=`dirname ${inFolder}`/`basename ${inFolder}`_Processed
logFolder=`dirname ${inFolder}`/`basename ${inFolder}`_logs
mkFold ${outFolder}
mkFold ${logFolder}


# Setup Data
procFold ${inFolder} ${outFolder} ${logFolder} 2> ${logFolder}/tmp.txt
rm ${logFolder}/tmp.txt

