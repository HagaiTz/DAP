%%%%%%%
function subjAfq(subjDir)

    % Get home directory:
    var = getenv('HOME');

    % Add modules to MATLAB. Do not change the order of these programs:
    fsldir=getenv('FSLDIR');
    setenv('FSLOUTPUTTYPE','NIFTI_GZ');
    fsllibdir=sprintf('%s/%s', fsldir, 'bin');
    ldlibpath=getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH',fsllibdir);

    % Folders
    addpath(genpath(subjDir));
    subjDir = fullfile(subjDir,'dti');

    % AFQ pipeline
    afq = AFQ_Create('sub_dirs', subjDir,'sub_group',0,'showfigs', false);
    afq = AFQ_run(subjDir,0,afq);
    afq = AFQ_SegmentCallosum(afq, 0);

    save(fullfile(subjDir,'AFQ.mat'),'afq');
    
    exit;    

end
