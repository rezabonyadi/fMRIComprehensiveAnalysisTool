function runFirstLevelContrasts(settings)
for i = 1:length(settings.subjectsNames)
    subject=settings.subjectsNames{i};    
    disp(['Generating contrasts for subject: ' subject]);
%     spmSubject = [settings.dataRoot settings.SPM.firstLevelAddress subject '\'];
    [matlabbatch{i},numConditions]=getFirstLevelContrasts(settings,subject);
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch{i}); 
end