function settings=runGlm(settings)
codeDir=cd;
toRemoveSubs=zeros(1,length(settings.subjectsNames));

for i = 1:length(settings.subjectsNames)
    subject=settings.subjectsNames{i};
    disp(['Running GLM for subject ' subject]);
    outputDir = [settings.dataRoot settings.SPM.firstLevelAddress subject '\'];
    cd(outputDir);% Stupid spm_spm uses based on the current directory, hence it is not paralellizable!
    try
        load('SPM.mat');
        spm_spm(SPM);
    catch mess
        toRemoveSubs(i)=1;
        disp(['Subject ' subject ' is removed: GLM']);
    end;
end;
cd(codeDir);
settings=handleMyErrors(toRemoveSubs,settings,'GLM');

