function batch=generateBatch(batchInfo)

rootDir = batchInfo.dataRoot;
subjects = batchInfo.subjectsNames;
% effectsOld = batchInfo.effectsOld;
% effectsYoung = batchInfo.effectsYoung;
runName=batchInfo.runNamePrefix; % prefix for the folders that contain runs
numberOfRuns=batchInfo.numberOfRuns;
structalProcessedData=batchInfo.fMRIPreprocessedStructural; 
niiFilesDir=batchInfo.fMRIPreprocessedData;
timingSuffix = batchInfo.onsetsType; % the suffix of the onset timing data 
behRoot=batchInfo.behDataFolder;
connFileName=batchInfo.analysesName;
preprocess=batchInfo.conn.preprocess;
denoise=batchInfo.conn.denoise;

% if(preprocess==0)
%    batchInfo.generateNii=0; 
% end;
% 
% if(batchInfo.generateNii)
%     tic;
%     dicomToNii([rootDir fmriData],subjects,'rawData\AllData\',...
%         niiFilesDir,structalProcessedData);
%     dicomTime=toc; 
% end;

TR=batchInfo.TR;  
i=1;

%% Prepare structural and functional files

if(preprocess==1)
    filtFunctional='^f.*\.nii';
    filtStruc='^s';
else
    filtFunctional='^swau';
    filtStruc='^wc0';
end;

for i = 1:length(subjects)
    subject=subjects{i};
    
    for runIdx=1:numberOfRuns
        files = (spm_select('FPList', ...
            [rootDir, niiFilesDir, subject, '\', ...
            runName, num2str(runIdx), '\'],filtFunctional));
        
        functionals{i}{runIdx}=files;
    end;
    filesStructural = spm_select('FPList', ... 
        [rootDir,niiFilesDir,subject,'\',structalProcessedData],filtStruc);
    filesStructurals{i}=filesStructural; 
%     i=i+1;
end;

%% Prepare conditions

conditions.names=batchInfo.conditionNames;
subjectIndx=1;
for j = 1:length(subjects)
    subject=subjects{j};
    behavioralDataAddress=[rootDir behRoot];
    
    fid = fopen([behavioralDataAddress subject '\' ... 
        subject '_' timingSuffix '.txt'], 'rt');
    T = textscan(fid, '%f %s %f %f', 'HeaderLines', 0, 'Delimiter',','); 
    %Columns should be 1)Run, 2)Regressor Name, 3) Onset Time (in seconds, relative to start of each run), and 4)Duration, in seconds
    fclose(fid);
    
    if(isempty(conditions.names))
        conditions.names=unique(T{2});
    end;
    
    runs = unique(T{1});
    for runIdx = 1:size(runs, 1)
        for i=1:length(conditions.names)
            conditions.onsets{i}{subjectIndx}{runIdx}=T{3}(T{1}==runIdx & strcmp(T{2},conditions.names{i})==1);
            conditions.durations{i}{subjectIndx}{runIdx}=T{4}(T{1}==runIdx & strcmp(T{2},conditions.names{i})==1);
        end;
    end
    subjectIndx=subjectIndx+1; 
end;

%% Create ROIs/Covariates first level

if(preprocess==0)% ROIs are determined automatically if preprocess is done.
    % list ROIs
    rois.names={'Grey Matter','White Matter','CSF','atlas','dmn'};
    filters={'^c1','^c2','^c3','',''};
    rois.dimensions={1,16,16,1,1};
     
    for i=1:length(rois.names)
        for subject = 1:length(subjects)
            if(strcmp(rois.names{i},'atlas')==1)
                rois.files{i}{subject}=batchInfo.conn.atlasAddress;
            else
                if(strcmp(rois.names{i},'dmn')==1)
                    rois.files{i}{subject}=batchInfo.conn.dmnAddress;
                else 
                    rois.files{i}{subject}=spm_select('FPList', [rootDir niiFilesDir subjects{subject} '\' structalProcessedData],filters{i});
                end;
            end;
        end;
    end;
    batch.Setup.rois=rois;
    % list Covariates
%     covariates.names={'realignment','scrubbing'};
%     filters={'^rp','^art_regression_outliers_wauf'};
    covariates.names={'realignment'};
    filters={'^rp'};

    for i=1:length(covariates.names)
        for subject = 1:length(subjects)
            for runIdx=1:numberOfRuns
                covariates.files{i}{subject}{runIdx}=...
                    spm_select('FPList', [rootDir niiFilesDir subjects{subject} ...
                     runName num2str(runIdx)],filters{i});
            end;
        end;
    end;
    batch.Setup.covariates=covariates;
end;

%% Create the mat file Setups basics

batch.filename=['conn_' connFileName];
batch.Setup.RT=TR*ones(1,length(subjects));
batch.Setup.nsubjects=length(subjects);
batch.Setup.functionals=functionals;
batch.Setup.structurals=filesStructurals;
batch.Setup.roifunctional.roiextract=2; % Default: same as functional files
batch.Setup.conditions=conditions;
batch.Setup.outputfiles=zeros(1,6);% Default
batch.Setup.analysisunits=1;
batch.Setup.unwarp_functional={};% Default
batch.Setup.cwthreshold=[0.5,1];% Default
% batch.Setup.subjects.effect_names={'All','Old','Young'}; % Define second level groups
% batch.Setup.subjects.effects{1}=ones(1,length(subjects));
% batch.Setup.subjects.effects{2}=effectsOld;
% batch.Setup.subjects.effects{3}=effectsYoung;

% if(preprocess==1)
%     batch.Setup.isnew=1;
%     batch.Setup.overwrite='Yes';
%     batch.Setup.done=1;
% else
%     batch.Setup.isnew=1;
%     batch.Setup.overwrite='No';
%     batch.Setup.done=0;
% end;

%% Create the mat file Setups preprocesses
if(preprocess==1)
%     batch.Setup.preprocessing.steps='default_mni';
%     batch.Setup.preprocessing.sliceorder='interleaved (Siemens)';
end;

%% Denoise
% if(denoise==1)
%     batch.Setup.add=1;
%     batch.Denoising.overwrite='Yes';
%     batch.Denoising.done=0;
% end;

%% First level analysis: ROI-to-ROI and Seed-to-Voxel analyses

% if(batchInfo.isParallel==0) % It is not possible to run second level in parallel
%     batch.Analysis.done=1;
%     batch.Analysis.overwrite='Yes';
% end;
% 
% %% Dynamic FC analysis
% % if(batchInfo.isParallel==0)
% %     batch.dynAnalyses.done=1;
% %     batch.dynAnalyses.overwrite='Yes';
% % end;
% %% Second level analysis
% if(batchInfo.isParallel==0) % It is not possible to run second level in parallel
%     batch.Results.done=1;
%     batch.Results.overwrite='Yes';
% end;
