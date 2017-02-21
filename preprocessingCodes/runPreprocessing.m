function settings=runPreprocessing(settings)

%% Realign
if(settings.preprocess.runRealign)
    toRemoveSubs=zeros(1,length(settings.subjectsNames));

    parfor (i=1:length(settings.subjectsNames), settings.preprocess.runRealignSerial)
        subjectRea=settings.subjectsNames{i};
        disp(['Running realignment for subject: ' subjectRea]);
        matlabbatch{i}=generateBatchRealign(settings, subjectRea);  
        spm('defaults', 'FMRI'); 
        try            
            spm_jobman('run', matlabbatch{i});
        catch mess
            toRemoveSubs(i)=1;
            disp(['Subject ' subjectRea ' is removed: realignment']);
        end;
    end;
    settings=handleMyErrors(toRemoveSubs,settings,'Realignment');

else
    disp('Realignment skipped');
end;

%% Other preprocessing steps 
%% Coreg
i=0;

if(settings.preprocess.runCoreg)
    % Ask for movement parameters alignment
    if(settings.preprocess.generateMovementFiles)
        for i=1:length(settings.subjectsNames)
            subject=settings.subjectsNames{i};
            selectedMeanFile{i}=getBestMovementMean(settings, subject);
        end;
    else        
        for i=1:length(settings.subjectsNames)
            subject=settings.subjectsNames{i};
            fid=fopen([settings.dataRoot settings.fMRIPreprocessedData ...
                subject '\movementsSelection.txt'],'rt');
            if(fid==-1) % Does not exist
                fclose(fid);
                selectedMeanFile{i}=getBestMovementMean(settings, subject);
            else
                selectedMeanFile{i}=fscanf(fid,'%s');
                fclose(fid);
            end;                
        end;
    end;
    toRemoveSubs=zeros(1,length(settings.subjectsNames));

    parfor (i=1:length(settings.subjectsNames), settings.preprocess.runCoregSerial)
%     for i=1:length(settings.subjectsNames)
        subjectCor=settings.subjectsNames{i};
        disp(['Running coreg for subject: ' subjectCor]);        
        
        matlabbatch{i}=generateBatchCoreg(settings, subjectCor, ...
            selectedMeanFile{i});
        spm('defaults', 'FMRI');
        try
            spm_jobman('run', matlabbatch{i});
        catch mess
            toRemoveSubs(i)=1;
        end;
    end;
    settings=handleMyErrors(toRemoveSubs,settings,'Coregistration');

else
    disp('Coregistration skipped');
end;
%% Segment

if(settings.preprocess.runSegment) 
    toRemoveSubs=zeros(1,length(settings.subjectsNames));

    parfor (i=1:length(settings.subjectsNames), settings.preprocess.runSegmentSerial)
%     for i=1:length(settings.subjectsNames)
        subjectSeg=settings.subjectsNames{i};
        disp(['Running segment for subject: ' subjectSeg]);
        matlabbatch{i}=generateBatchSegment(settings, subjectSeg);
        spm('defaults', 'FMRI'); 
        try
            spm_jobman('run', matlabbatch{i});
        catch mess
            toRemoveSubs(i)=1;
        end;
    end;
    settings=handleMyErrors(toRemoveSubs,settings,'Segmentation');

else
    disp('Segmentation skipped');
end;
%% Normalise

if(settings.preprocess.runNormalise)
    toRemoveSubs=zeros(1,length(settings.subjectsNames));

    parfor (i=1:length(settings.subjectsNames), settings.preprocess.runNormaliseSerial)
%     for i=1:length(settings.subjectsNames)
        subjectNorm=settings.subjectsNames{i};
        disp(['Running normalise for subject: ' subjectNorm]);
        matlabbatch{i}=generateBatchNormalise(settings, subjectNorm);
        spm('defaults', 'FMRI'); 
        try
            spm_jobman('run', matlabbatch{i});
        catch mess
            toRemoveSubs(i)=1;
        end;
    end;
    settings=handleMyErrors(toRemoveSubs,settings,'Normalisation');

else
    disp('Normalisation skipped');
end;
%% Smooth
toRemoveSubs=zeros(1,length(settings.subjectsNames));

if(settings.preprocess.runSmooth)
    parfor (i=1:length(settings.subjectsNames), settings.preprocess.runSmoothSerial)
        subjectSmo=settings.subjectsNames{i};
        disp(['Running smooth for subject: ' subjectSmo]);
        matlabbatch{i}=generateBatchSmooth(settings, subjectSmo);
        spm('defaults', 'FMRI'); 
        try
            spm_jobman('run', matlabbatch{i});
        catch mess
            toRemoveSubs(i)=1;
        end;
    end;
    settings=handleMyErrors(toRemoveSubs,settings,'Smoothing');
else
    disp('Smoothing skipped');
end;

function matlabbatch=generateBatchRealign(settings, subject)
%% Realignment settings (for each run)
for i=1:settings.numberOfRuns

    matlabbatch{i}.spm.spatial.realign.estwrite.data=...
    {cellstr(spm_select('FPList', [settings.dataRoot settings.fMRIPreprocessedData ...
    subject settings.runNamePrefix num2str(i) '\'], '^f.*\.nii'))}';

    % 'R:\Projects\Maryam\Logical reasoning\fMRI\12_NW\R1\f12_NW-0003-00473-000473-01.nii,1'

    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{i}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
end;

function matlabbatch=generateBatchCoreg(settings, subject, meanFile)
%% Coregister settings
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {meanFile};
% {spm_select(1,'meanf.*\.nii','Select the file for coregistration estimate',...
%     {},[settings.dataRoot settings.fMRIDataFolder '\' subject])};
% ;    
%     {'R:\Projects\Maryam\Logical reasoning\fMRI\12_NW\R4\meanf12_NW-0014-00001-000001-01.nii,1'};

matlabbatch{1}.spm.spatial.coreg.estimate.source = ...
    cellstr(spm_select('FPList', [settings.dataRoot settings.fMRIPreprocessedData ...
    subject '\' settings.fMRIPreprocessedStructural], '^s.*\.nii'));
%     {[settings.dataRoot subject '\MP2RAGE\' s12_NW-0010-00001-000176-01.nii'};
matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];


function matlabbatch=generateBatchSegment(settings, subject)
%% Segment settings
matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(spm_select('FPList', ...
    [settings.dataRoot settings.fMRIPreprocessedData ...
    subject '\' settings.fMRIPreprocessedStructural], '^s.*\.nii'));
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1]; 
% 
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = cellstr([settings.spmFolder 'tpm\TPM.nii,1']);
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = cellstr([settings.spmFolder 'tpm\TPM.nii,2']);
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = cellstr([settings.spmFolder 'tpm\TPM.nii,3']);
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = cellstr([settings.spmFolder 'tpm\TPM.nii,4']);
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = cellstr([settings.spmFolder 'tpm\TPM.nii,5']);
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = cellstr([settings.spmFolder 'tpm\TPM.nii,6']);
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];

matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];

function matlabbatch=generateBatchNormalise(settings, subject)
%% Normalise
matlabbatch{1}.spm.spatial.normalise.write.subj.def = ...
    cellstr(spm_select('FPList', [settings.dataRoot settings.fMRIPreprocessedData ...
    subject '\' settings.fMRIPreprocessedStructural], '^y.*\.nii'));

files={};
for i=1:settings.numberOfRuns
    files=[files;cellstr(spm_select('FPList', [settings.dataRoot settings.fMRIPreprocessedData ...
    subject settings.runNamePrefix num2str(i) '\'], '^rf.*\.nii'))];
end;

matlabbatch{1}.spm.spatial.normalise.write.subj.resample =files;
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = settings.preprocess.normaliseVoxSize;
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

function matlabbatch=generateBatchSmooth(settings, subject)
% Smooth
files={};
for i=1:settings.numberOfRuns
    files=[files;cellstr(spm_select('FPList', [settings.dataRoot settings.fMRIPreprocessedData ...
    subject settings.runNamePrefix num2str(i) '\'], '^wrf.*\.nii'))];
end;
matlabbatch{1}.spm.spatial.smooth.data = files;

matlabbatch{1}.spm.spatial.smooth.fwhm = settings.preprocess.smoothingSize;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
