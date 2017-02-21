function [matlabbatch,numContrasts]=getFirstLevelContrasts(settings, subject)
spmAddressSubject=[settings.dataRoot settings.SPM.firstLevelAddress subject '\SPM.mat'];
%%Define conditions
contrastsNames=settings.SPM.contrastsNames;
contrastsVectors=settings.SPM.contrastsVectors;

%% Fill the batch
matlabbatch{1}.spm.stats.con.spmmat = {spmAddressSubject};
for i=1:length(contrastsNames)
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.name=contrastsNames{i};
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.weights=contrastsVectors(i,:);
    matlabbatch{1}.spm.stats.con.consess{i}.tcon.sessrep = 'replsc';
end;

matlabbatch{1}.spm.stats.con.delete = 0;
numContrasts=length(contrastsNames);