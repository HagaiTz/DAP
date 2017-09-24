#!/bin/bash

function beginMessege {
	echo ""
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
	'dti.bval','dti.bvec' & 'dti.nii.gz'. (see example below)"
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
	echo "       DTI/      T1/                   dti.bval"
	echo "        |         |                    dti.bvec"
	echo "     (*.dcm)    (*.dcm)                dti.nii.gz"
	echo ""
	echo ""
	echo "If the data is already arranged in the format above press any
key to continue. Otherwise type 'no', arrange the data in the right 
format and run again."
	echo ""
	read -p "Do you wish to continue? " yn
	if [[ $yn == [Nn]* ]] ; then
		exit 1
	fi
	echo ""
	echo "..."
} 

function setupMessege {
	echo " --->  Setting up data..."
	echo ""
}

function PreProcessMessege {
	echo " --->  Pre-processing data..."
	echo ""
}

function endMessege {
	echo ""
	echo ""
	echo "Finished processing, results are saved in:
\"$1\""
	echo ""
	echo "================================================================="
	echo ""
	exit 0
}

function mkFold {
	if [[ ! -e $1 ]]; then
		mkdir -p $1
	fi
}


####################################################################

# Input check
if (( $# != 1 )); then
	echo "Usage $0 [Input Folder]";
	exit 1;
fi

# Check Structure
beginMessege

# Setting directories
inFolder=$1
outFolder=`dirname ${inFolder}`/`basename ${inFolder}`_Processed
logFolder=`dirname ${inFolder}`/`basename ${inFolder}`_logs
mkFold ${outFolder}
mkFold ${logFolder}


# Setup Data
setupMessege

bash `dirname $0`/procFold.sh \
 ${inFolder} ${outFolder} ${logFolder} \
	> ${logFolder}/DataPreparation_Output.txt \
	2> ${logFolder}/DataPreparation_Error.txt

# dtiInit
PreProcessMessege
sh `dirname $0`/dtiInit.sh ${outFolder} ${logFolder}

# AFQ


endMessege ${outFolder}