function generateOnsets(settings)
% sheets=[10,11,12,13,14];
% address='R:\projects\Logical reasoning\fmri Experiments\behData\';
sheets=settings.subjectsNames;
address=[settings.dataRoot settings.behDataFolder settings.behRawXls];

% range=34:39; % premise
range=settings.onsetsRangeData;%22:27; % conclusion
runNumberIndx=settings.runNumberColumn;
conditionsDataLine=settings.conditionsDataLine; 

resultsDir=[settings.dataRoot settings.behDataFolder];
mkdir(resultsDir);
for i=1:length(sheets) 
    subject=sheets{i};
    disp(['Generating onsets for ' (subject)]);
    [~,~,data]=xlsread(address,(subject),'','basic'); 
    data=data(conditionsDataLine:end,[runNumberIndx range]);
    res={};
    conditions=data(1,2:end);
    k=1;
    for j=2:size(data,1)
        runNum=data{j,1}; 
        for l=1:length(conditions)
            if(isnumeric(data{j,1+l}))
                res{k,1}=num2str(runNum);
                res{k,2}=conditions{l};
                res{k,3}=num2str(data{j,1+l});
                res{k,4}=settings.blockSize;
                k=k+1;
            end;
        end;        
    end;
    mkdir([resultsDir '\' (subject)]);
    fid=fopen([resultsDir '\' (subject) '\' (subject) '_' settings.onsetsType '.txt'],'wt');
    for l=1:length(res)
        fprintf(fid,'%s,%s,%s,%s\n',res{l,1},res{l,2},res{l,3},res{l,4});
    end;
    fclose all;
end;