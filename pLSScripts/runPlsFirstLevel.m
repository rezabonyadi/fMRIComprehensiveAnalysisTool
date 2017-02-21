function runPlsFirstLevel(settings)
if(~exist([settings.dataRoot settings.pls.firstLevelAddress]))
    mkdir([settings.dataRoot settings.pls.firstLevelAddress]);
end;
cd([settings.dataRoot settings.pls.firstLevelAddress]);
for i=1:length(settings.subjectsNames)
    subject=settings.subjectsNames{i};
    disp(['Starting subject: ' num2str(i) '/' ...
        num2str(length(settings.subjectsNames)) ': ' subject]);
    [~,settingFile]=generateSettingFile(settings,subject);
    batch_plsgui(settingFile);
end;

function [settingFile,settingFileAddress]=generateSettingFile(settings,subject)
settingFileAddress=[settings.dataRoot settings.pls.firstLevelAddress subject '_PLS_Setting.txt'];
fid=fopen(settingFileAddress,'wt');
fprintf(fid,'prefix %s\n',[settings.pls.dataMatPrefix '_' subject]);
fprintf(fid,'brain_region %s\n',num2str(settings.pls.brainRegionThreshold)); 

if(~settings.isBlock)
    fprintf(fid,'win_size %s\n',num2str(settings.pls.scanPerHemodynamicPeriod));
end;

fprintf(fid,'across_run %s\n',num2str(settings.pls.mergeDataAccrossRuns));
fprintf(fid,'single_subj %s\n',num2str(settings.pls.singleSubject));

%% Conditions names and settings
for i=1:length(settings.conditionNames)
    fprintf(fid,'cond_name %s\n',settings.conditionNames{i});
    fprintf(fid,'ref_scan_onset %s\n',num2str(settings.pls.refScan));
    fprintf(fid,'num_ref_scan %s\n',num2str(settings.pls.numRefScan)); 
end;

condsOnsets=cell(settings.numberOfRuns,length(settings.conditionNames));
condsLength=cell(settings.numberOfRuns,length(settings.conditionNames));
fid1=fopen([settings.dataRoot settings.behDataFolder subject '\'...
    subject '_' settings.onsetsType '.txt'],'rt');
if(settings.pls.isOnsetTR==1)
    tRFactor=1;
else
    tRFactor=settings.TR;
end;
    
s=fgetl(fid1);
while ~feof(fid1)
    data=strsplit(s,',');
    if(length(data)<4)
        s=fgetl(fid1);
        continue;
    end;
    condsOnsets{str2num(data{1}),strmatch(data{2},settings.conditionNames)}=...
    [condsOnsets{str2num(data{1}),strmatch(data{2},settings.conditionNames)},...
    (str2num(data{3})/tRFactor)];

    condsLength{str2num(data{1}),strmatch(data{2},settings.conditionNames)}=...
    [condsLength{str2num(data{1}),strmatch(data{2},settings.conditionNames)},...
    (str2num(data{4})/tRFactor)];

    s=fgetl(fid1);
end;

fclose(fid1);

%% runs files 
if(settings.isBlock)
    designType='block_onsets';
else
    designType='event_onsets';
end;

for i=1:settings.numberOfRuns
    fprintf(fid,'data_files %s\n',...
        [settings.dataRoot settings.fMRIPreprocessedData subject ...
        settings.runNamePrefix num2str(i) '\' settings.pls.filesToFunctional]);
    for j=1:length(settings.conditionNames)
        if(isempty(condsOnsets{i,j}))
            fprintf(fid,[designType ' %s\n'],num2str(-1));
        else
            fprintf(fid,[designType ' %s\n'],num2str(condsOnsets{i,j},'%1.3f '));
        end;
    end;    
    if(settings.isBlock)
        for j=1:length(settings.conditionNames)
            if(isempty(condsLength{i,j}))
                fprintf(fid,['block_length %s\n'],num2str(-1));
            else
                fprintf(fid,['block_length %s\n'],num2str(condsLength{i,j},'%1.3f '));
            end;
        end;    
    end;
end;

fclose(fid);

settingFile=[subject '_PLS_Setting.txt'];