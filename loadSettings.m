function settings=loadSettings()
%% General settings
settings.dataRoot='D:\Maryam\Exercise\'; % Root of the data that inludes fmri raw data and behavioral data

% settings.fMRIDataFolder='fMRIData\';
settings.fMRIRawData='fmriData\raw\rawData'; % raw fMRI
settings.fMRIPreprocessedData='fmriData\Preprocessed\'; % where to save preprocesses
settings.fMRIPreprocessedStructural='structure\'; % where to save structural
settings.fMRIRawStructural='MP2RAGE\'; % where are structural data 
settings.behDataFolder='behData\';  % where are behaviral data, with the reference to root
settings.behRawXls='TargetDistractor OnsetsEdited.xlsx'; % what is the name of the xls file of the behavioral data
settings.runNamePrefix='\RUN_'; % the prefix of run names in fMRI data
settings.spmFolder='D:\Maryam\spm12\spm12\'; % SPM 12 folder address
settings.plsFolder='R:\App\PLS\'; % PLS folder address
settings.connFolder='R:\App\conn 16b\conn\'; % Conn folder address
settings.numberOfRuns=4; % number of runs in your experiment

%% Save reports settings
t=datestr(datetime('now'),'dd-mm-yyyy-HH-MM-SS');
settings.reportFileName=['analysesReports\reports_' t '.txt'];

if(~exist('analysesReports'))
    mkdir('analysesReports');
end;

%% Analyses settings

%     '1202' Eror in coreg-Stroop
% 1191 error in reslice-gonogo
%1531 two GoNoGo runs

% settings.subjectsNames={'11' '12' '13' '14' '15' '16' '17' '18' '19' ...
%     '110' '111' '112' '113' '114' '115' '116' '117' '118' '119'...
%     '120' '121' '21' '22' '23' '24' '25' '26' '27' '28' '29' '210' '211' ...
%     '212' '213' '214' '215' '216' '217' '219' '220' '221' '222'};

settings.subjectsNames={'P01','P02' }; % Subject names
settings.TR= .625; % your TR
settings.numScans=[700]; % Number of scans
settings.disacqs=0; % 
settings.conditionNames={'DistMatch.Predictive' 'DistracMisMatch.Predictive' ...
    'DisMatch.Nonpredict' 'DisMisMatch.nonpredic' 'NoMemory'...
}; % the name for your conditions

settings.isBlock=0; % block or event analysis
settings.blockSize='0'; % the size of block

% settings.analysesName='conclusion_block';
settings.analysesName='DistractorMatch_event'; % A name to your analyses
% settings.analysesName='premise_event';

%% Dicom trans
settings.runDicamTransform=0; % generate dicom files
 
%% What to run
settings.generateOnsetTimes=0;  % generate onset files for analyses
settings.onsetsRangeData=2:6; % in the xls file, which columns are the conditions
settings.runNumberColumn=1; % where is the run number column in these columns
settings.conditionsDataLine=1; % is the first row the condition name
settings.onsetsType=settings.analysesName;

%% Preprocessing settings
settings.preprocess.run=1; % do you need to run preprocessing
settings.preprocess.runRealign=0; % do you need to run realignment
settings.preprocess.generateMovementFiles=0; % do you need to generate movement files
settings.preprocess.runCoreg=0; % do you need to run coregistration
settings.preprocess.runSegment=1; % do you segment
settings.preprocess.runNormalise=1; % do you normalise
settings.preprocess.runSmooth=1; % do you smooth

settings.preprocess.smoothingSize=[6 6 6]; % 
settings.preprocess.normaliseVoxSize=[2.0 2.0 2.0];

settings.preprocess.runRealignSerial = Inf; % number of processors for parallel processing accross subjects
settings.preprocess.runCoregSerial = Inf;
settings.preprocess.runSegmentSerial = Inf;
settings.preprocess.runNormaliseSerial = Inf;
settings.preprocess.runSmoothSerial = Inf;

%% First level SPM
settings.SPM.runSmpMat=0;%run spm first level
settings.SPM.isFast=0;
settings.SPM.runGlm=0;
settings.SPM.runFirstLevelContrasts=0;
settings.SPM.firstLevelAddress=['Results\SPM\' settings.analysesName '\firstLevel\'];
settings.SPM.nameRegEx=strcat('^', {'swr'});
settings.SPM.matPrefix='testMulti';
settings.SPM.contrastsNames={'U->B-','B->U-','U->N-','B->N-','-U>-B','-B>-U'};
settings.SPM.contrastsVectors=[
    1 1 -1 -1 0 0 0 0 0 0 0 0;
    -1 -1 1 1 0 0 0 0 0 0 0 0;
    1 1 0 0 -1 -1 0 0 0 0 0 0;
    0 0 1 1 -1 -1 0 0 0 0 0 0;
    1 -1 1 -1 0 0 0 0 0 0 0 0;
    -1 1 -1 1 0 0 0 0 0 0 0 0;
    ];

%% PLS settings
settings.pls.runFirstLevel=0;
settings.pls.firstLevelAddress=['fMRI\Results\Pls_6\' settings.analysesName '\firstLevel\'];
settings.pls.dataMatPrefix=settings.analysesName;
settings.pls.brainRegionThreshold=0.15;
settings.pls.scanPerHemodynamicPeriod=8;
settings.pls.mergeDataAccrossRuns=1;
settings.pls.singleSubject=0;
settings.pls.refScan=0;
settings.pls.numRefScan=1;
settings.pls.filesToFunctional='sw*.nii';
settings.pls.isOnsetTR=0;

%% Conn settings
settings.conn.run=0;
settings.conn.preprocess=0;
settings.conn.denoise=0;
settings.conn.atlasAddress=[settings.connFolder 'rois\atlas.nii'];
settings.conn.dmnAddress=[settings.connFolder 'rois\dmn.nii'];
% settings.conn.filesToProcess='^f.*\.nii';%'^sw.*\.nii';
settings.conn.analysesAddress=['Results\CONN\' settings.analysesName '\'];