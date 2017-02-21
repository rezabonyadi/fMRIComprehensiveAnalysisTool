clear all;
close all;
% 
% %% get settings
settings=loadSettings();
% function runFmriAnalyses(settings)
%% load required toolboxes

addpath('preprocessingCodes\');
addpath('pLSScripts\');
addpath('sPMLevelsScripts\');
addpath('connScripts\');
if(strcmp(settings.connFolder,'')==0)
    addpath(genpath(settings.connFolder));
end;
if(strcmp(settings.plsFolder,'')==0)
    addpath(genpath(settings.plsFolder));
end;
if(strcmp(settings.spmFolder,'')==0)
    addpath(genpath(settings.spmFolder)); 
end; 


%% generating onset times
if(settings.generateOnsetTimes)
    disp('Generating onset times running'); 
    generateOnsets(settings);
else 
    disp('Generating onset times skipped');
end;

%% Dicom to nii
if(settings.runDicamTransform)
    disp('Dicom transform running');
    settings=dicomToNii(settings);  
else
    disp('Dicom transform skipped');
end;

%% Run preprocessing
if(settings.preprocess.run)
    disp('Preprocess running');
    settings=runPreprocessing(settings); 
else
    disp('Preprocess skipped'); 
end;

%% Run SPM
if(settings.SPM.runSmpMat)
    disp('Generate spm.mat running');
    settings=runSpmMatFilesGenerator(settings);
else
    disp('Generate spm.mat skipped');
end;

if(settings.SPM.runGlm)
    disp('GLM running');
    settings=runGlm(settings);
else
    disp('GLM skipped');
end;

if(settings.SPM.runFirstLevelContrasts)
    disp('First level contrast running');
    runFirstLevelContrasts(settings);
else
    disp('First level contrast skipped');
end;

%% run PLS
if(settings.pls.runFirstLevel)
    disp('PLS first level running'); 
    runPlsFirstLevel(settings);  
else
    disp('PLS first level skipped');
end;

%% run Conn 
if(settings.conn.run)
    disp('Conn running'); 
    runConn(settings); 
else
    disp('Conn skipped');
end;