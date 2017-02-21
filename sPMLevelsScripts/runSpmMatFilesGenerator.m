function settings=runSpmMatFilesGenerator(settings)
subjectsIDs=settings.subjectsNames;
toRemoveSubs=zeros(1,length(settings.subjectsNames));

parfor i = 1:length(subjectsIDs) 
    subject=subjectsIDs{i};
    disp(['Generating SPM.mat for subject ' subject]);
    try
        batchs{i}=getSPMFirstLevelBatch(settings,subject);  
        spm_jobman('run', batchs{i});
    catch mess
        toRemoveSubs(i)=1;
        disp(['Subject ' subjectRea ' is removed: SPM Mat']);
    end;
end; 

settings=handleMyErrors(toRemoveSubs,settings,'SPM Mat');


