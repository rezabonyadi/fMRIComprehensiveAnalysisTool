function settings=dicomToNii(settings)

rootDir=settings.dataRoot;
subjects=settings.subjectsNames;
rawDataDir=settings.fMRIRawData;
resultsDir=settings.fMRIPreprocessedData;
structOut=settings.fMRIPreprocessedStructural;
% rootDir = 'E:\Data\Decoding\Maryam\Face study\fmriData\';
% subjects = [112,113,114,116];
% rawDataDir='rawData\';
% resultsDir='PreprocessedSubjects\'; % where to save the results
runName=settings.runNamePrefix; % prefix for the folders that contain runs
structreInput=settings.fMRIRawStructural;
% structOut='\structural';

numberOfRuns=settings.numberOfRuns;
toRemoveSubs=zeros(1,length(subjects));
% for subjectIndx = 1:length(subjects)
parfor subjectIndx = 1:length(subjects)
    subject=subjects{subjectIndx};
    try
        for runIdx=1:numberOfRuns
            files = spm_select('FPList', [rootDir rawDataDir subject runName...
                num2str(runIdx)], '^*.\.IMA');
            outputDir = [rootDir resultsDir subject runName ...
                num2str(runIdx)];

            if ~exist(outputDir,'dir')
                mkdir(outputDir)
            end

            hdr = spm_dicom_headers(files);
            spm_dicom_convert(hdr,'all','flat','nii',outputDir);
            disp(['nii generated for subject: ' subject ', Run: ' num2str(runIdx)]); 
        end;    
        % Structures
        outputDir = [rootDir resultsDir subject '\' structOut];

        if ~exist(outputDir,'dir')
            mkdir(outputDir)
        end

        files = spm_select('FPList', [rootDir rawDataDir subject...
            '\' structreInput],'^*.\.IMA');
        hdr = spm_dicom_headers(files);
        spm_dicom_convert(hdr,'all','flat','nii',outputDir);

        disp(['Structure generated for subject: ' subject]);

    catch mess
        toRemoveSubs(subjectIndx)=1;
        disp(['Subject ' subject ' is removed: DICOM']);
    end;  
end;

settings=handleMyErrors(toRemoveSubs,settings,'DICOM');
