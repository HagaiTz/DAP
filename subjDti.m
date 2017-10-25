%%%%%%%
function subjDti(subjDir)

    % Get home directory:
    var = getenv('HOME');

    % Add modules to MATLAB. Do not change the order of these programs:
    fsldir=getenv('FSLDIR');
    setenv('FSLOUTPUTTYPE','NIFTI_GZ');
    fsllibdir=sprintf('%s/%s', fsldir, 'bin');
    ldlibpath=getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH',fsllibdir);

    addpath(genpath(subjDir));
    
    % Set file names
    dtiFile = fullfile(subjDir,'raw','dti.nii.gz');
    t1File = fullfile(subjDir,'t1.nii.gz');

    cd (subjDir);

    % Ac-Pc Alignment
    if (exist(t1File))
        t1AcpcFile = fullfile(subjDir,'t1_acpc.nii.gz');
        mrAnatAutoAlignAcpcNifti(t1File,t1AcpcFile);
        mrAnatAutoAlignAcpcNifti(t1AcpcFile,t1AcpcFile);
        ni = readFileNifti(t1AcpcFile);
        ni = niftiSetQto(ni, ni.sto_xyz);
        writeFileNifti(ni, t1AcpcFile);
    else
        t1AcpcFile = 'MNI';
    end

    % Set Qto, may not be necessery
    ni = readFileNifti(dtiFile);
    ni = niftiSetQto(ni, ni.sto_xyz);
    writeFileNifti(ni, dtiFile);
   
    bvals = dlmread(fullfile(subjDir,'raw','dti.bval'));
    bvals(bvals < 1e-3) = 0;
    dlmwrite(fullfile(subjDir,'raw','dti.bval'),bvals,' ');

    % Determine phase encode dir:
    % > info=dicominfo([var,'/compute/images/EDSD/FRE_AD001/DICOM/diff/MR.22533.01274.dcm']);
    % To get the manufacturer information:
    % > info.(dicomlookup('0008','0070'))
    % To get the axis of phase encoding with respect to the image:
    % > info.(dicomlookup('0018','1312'))
    % If phase encode dir is 'COL', then set 'phaseEncodeDir' to '2'
    % If phase encode dir is 'ROW', then set 'phaseEncodeDir' to '1'
    % For Siemens / Philips specific code we need to add 'rotateBvecsWithCanXform',
    % AND ALWAYS DOUBLE CHECK phaseEncodeDir:
    % > dwParams = dtiInitParams('rotateBvecsWithCanXform',1,'phaseEncodeDir',2,'clobber',1);
    % For GE specific code,
    % AND ALWAYS DOUBLE CHECK phaseEncodeDir:
    % > dwParams = dtiInitParams('phaseEncodeDir',2,'clobber',1);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   if the results are not feasible:
    %   uncomment the following lines and set 'rotateBvecsWithCanXform' to 0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   bvecs = dlmread(fullfile(subjDir,'raw','dti.bvec'));
    %   if (size(bvecs,2)==3), bvecs = [ bvecs(:,1) -bvecs(:,2) bvecs(:,3)];
    %   else, bvecs = [ bvecs(1,:); -bvecs(2,:); bvecs(3,:)]; end
    %   dlmwrite(fullfile(subjDir,'raw','dti.bvec'),bvecs,' ');
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%%%%%%%%%%%    Change parameters here!!  %%%%%%%%%%%%%%

    dwParams = dtiInitParams('phaseEncodeDir', 2, 'clobber', 1,'dt6BaseName',...
        'dti','eddyCorrect',1,'rotateBvecsWithCanXform',1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    % dtiInit pipeline
    dtiInit(dtiFile, t1AcpcFile, dwParams);

    exit;
