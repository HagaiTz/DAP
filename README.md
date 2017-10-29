# DTI-Analysis-Pipeline
This is a pipeline for processing diffusion tensor images (DTI).
The pipeline was developed to analyze statistical properties of individual
subjects, as well as comparison between different groups.

This pipeline was developed in and for the Educational Neuro-Imaging Center.

## Getting Started
These instructions will walk you through on setting up the envinronemnt
and installing this pipeline on ypur local machine.

**This pipeline was developed for and tested on Ububtu based linux**
** - __linux Mint__ **

### Prerequisites
You will need to install the following softwares before using the pipeline:
-[MATLAB](https://www.mathworks.com/)
-[spm](http://www.fil.ion.ucl.ac.uk/spm/software/)
-[Vistasoft](https://github.com/vistalab/vistasoft)
-[AFQ](https://github.com/yeatmanlab/AFQ/wiki)

You will also need to add them to your MATLAB path, this can be done by
editting MATLAB startup file - `/PATH/TO/MATLAB/toolbox/local/`. The file
is called `startup.m`, and you should add path for the softwares mentioned above.
For each software add a line in `startup.m` file such as  
```
addpath(genpath(fullfile(PATH,TO,SOFTWARE)));
```
**example** - if `spm` folder is `/opt/spm` then add tje following line
```
addpath(genpath(fullfile('opt','AFQ')));
```

### Installing
After the environment is set you can install the pipeline simply by clonning.
First go to folder where the pipeline will be cloned to, 
then download the pipeline -
```
cd /PATH/TO/PIPELINE
git clone https://github.com/HagaiTz/DTI-Analysis-Pipeline.git
```
You should also add the pipline to MATLAB path.
Also, for convenience you can add an alias so that the pipeline can be run
with ease. This is done by going to your home folder and editting `.basrc`
environment file.
Open `.bashrc` with your favorite editor and add the following lines
 **at the bottom** -
```
alias runPipe='/PATH/TO/PIPELINE/DTI-Analysis-Pipeline/runPipe.sh'
alias tractAnalysis='/PATH/TO/PIPELINE/DTI-Analysis-Pipeline/tractAnalysis.sh'
```

## Quick Start
In order to run the pipeline use `runPipe [Input folder]` commad. 
If the environment was set-up as described above, the processin should start.
However, if you did not define `alias` then to run the pipeline you will need
to type the full path for the main script 
`/PATH/TO/PIPELINE/DTI-Analysis-Pipeline/runPipe.sh`.

For more details you can refer to [user manual](manual.pdf).

## Authors
- **Hagai Tzafrir** - HagayT@hotmail.com
- **Dr.Rola Farah** - rola.farah2@gmail.com
- **Dr.Tzipi Kraus-Horowitz** - tzipi.kraus@ed.technion.ac.il

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details http://www.gnu.org/licenses/