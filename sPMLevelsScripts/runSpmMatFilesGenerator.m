function settings=runSpmMatFilesGenerator(settings)
subjectsIDs=settings.subjectsNames;
toRemoveSubs=zeros(1,length(settings.subjectsNames));
codeDir=cd;

parfor i = 1:length(subjectsIDs) 
    subject=subjectsIDs{i};
    disp(['Generating SPM.mat for subject ' subject]);
    batchs{i}=getSPMFirstLevelBatch(settings,subject);  

    try
        spm_jobman('run', batchs{i});
    catch mess
        toRemoveSubs(i)=1;
        disp(['Subject ' subject ' is removed: SPM Mat']);
    end;
end; 
cd(codeDir);
settings=handleMyErrors(toRemoveSubs,settings,'SPM Mat');


