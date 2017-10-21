function jobs=getSPMFirstLevelBatch(settings,subject)
fid = fopen([settings.dataRoot settings.behDataFolder subject '\'...
    subject '_' settings.onsetsType '.txt'], 'rt');
T = textscan(fid, '%f %s %f %f', 'HeaderLines', 0, 'Delimiter',','); %Columns should be 1)Run, 2)Regressor Name, 3) Onset Time (in seconds, relative to start of each run), and 4)Duration, in seconds
fclose(fid);
    
disacqs=settings.disacqs;
dirInfo.rootDir=settings.dataRoot;
dirInfo.FirstLevelResults=settings.SPM.firstLevelAddress;
numScans=settings.numScans;
nameList=settings.conditionNames';
dirInfo.preprocessedDataDir=settings.fMRIPreprocessedData;
dirInfo.nameRegEx=settings.SPM.nameRegEx;
dirInfo.matPrefix=settings.SPM.matPrefix;
dirInfo.runName=settings.runNamePrefix;
TR=settings.TR;
outputDir = [dirInfo.rootDir dirInfo.FirstLevelResults subject '\'];

if ~exist(outputDir)
    mkdir(outputDir)
end

runs = unique(T{1});

%Begin creating jobs structure
jobs{1}.stats{1}.fmri_spec.dir = cellstr(outputDir);
jobs{1}.stats{1}.fmri_spec.timing.units = 'secs';
jobs{1}.stats{1}.fmri_spec.timing.RT = TR;
jobs{1}.stats{1}.fmri_spec.timing.fmri_t = 16;
jobs{1}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

%Create multiple conditions .mat file for each run
runIdxSpm=0;
conditionsMat=zeros(10,5);
for runIdx = 1:size(runs, 1)
%     nameList = unique(T{2});
    names = nameList';
    onsets = cell(1, size(nameList,1));
    durations = cell(1, size(nameList,1));
    sizeOnsets = size(T{3}, 1); 
    for nameIdx = 1:size(nameList,1)
        for idx = 1:sizeOnsets
            if isequal(lower(T{2}{idx}), lower(nameList{nameIdx})) && T{1}(idx) == runIdx
                onsets{nameIdx} = double([onsets{nameIdx} T{3}(idx)]);
                durations{nameIdx} = double([durations{nameIdx} T{4}(idx)]);
            end
        end 
        onsets{nameIdx} = (onsets{nameIdx} - (TR*disacqs)); %Adjust timing for discarded acquisitions
    end
    
    % Account for missed conditions
    onsetsRevised={}; 
    namesRevised={};
    durationsRevised={};
    
    k=1;
    for i=1:size(nameList,1)
        if(~isempty(onsets{i}))
            onsetsRevised{k}=onsets{i};
            namesRevised{k}=names{i};
            durationsRevised{k}=durations{i};
            k=k+1;
        end;
    end;

    if(length(names)~= length(namesRevised)) % Some conditions are missing for this subject
        continue;
    end;
    runIdxSpm=runIdxSpm+1;
%     onsets=onsetsRevised;
%     names=namesRevised;
%     durations=durationsRevised;

    save ([outputDir dirInfo.matPrefix '_' subject '_' num2str(runIdx)], 'names', 'onsets', 'durations')

    %Grab frames for each run using spm_select, and fill in session
    %information within jobs structure
%         files = spm_select(inf,'img$','Select img files to be converted');
    files = spm_select('ExtFPList', [dirInfo.rootDir dirInfo.preprocessedDataDir...
        subject dirInfo.runName num2str(runIdx)], dirInfo.nameRegEx, 1:numScans);

    if(isempty(files))
        disp('MRI preprocessed files to generate SPM is empty! Check the addresses.');
    end;
    
    jobs{1}.stats{1}.fmri_spec.sess(runIdxSpm).scans = cellstr(files);
    jobs{1}.stats{1}.fmri_spec.sess(runIdxSpm).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
    jobs{1}.stats{1}.fmri_spec.sess(runIdxSpm).multi = cellstr([outputDir dirInfo.matPrefix '_' num2str(subject) '_' num2str(runIdx) '.mat']);
    jobs{1}.stats{1}.fmri_spec.sess(runIdxSpm).regress = struct('name', {}, 'val', {});
    
    a=dir([dirInfo.rootDir dirInfo.preprocessedDataDir num2str(subject)...
        dirInfo.runName num2str(runIdx) '\*.txt']);
    multiRegFiles = [dirInfo.rootDir dirInfo.preprocessedDataDir ...
        num2str(subject) dirInfo.runName num2str(runIdx) '\' a.name];
    
    jobs{1}.stats{1}.fmri_spec.sess(runIdxSpm).multi_reg = {multiRegFiles};
    jobs{1}.stats{1}.fmri_spec.sess(runIdxSpm).hpf = 128;
end

%Fill in the rest of the jobs fields 
jobs{1}.stats{1}.fmri_spec.fact = struct('name', {}, 'levels', {});
jobs{1}.stats{1}.fmri_spec.bases.hrf = struct('derivs', [0 0]);
jobs{1}.stats{1}.fmri_spec.volt = 1;
jobs{1}.stats{1}.fmri_spec.global = 'None';
jobs{1}.stats{1}.fmri_spec.mask = {''};
if(settings.SPM.isFast);
    jobs{1}.stats{1}.fmri_spec.cvi = 'FAST';
else
    jobs{1}.stats{1}.fmri_spec.cvi = 'AR(1)';
end;

%Navigate to output directory, specify and estimate GLM
% cd(outputDir);
 

