function selectedMeanFile=getBestMovementMean(settings, subject)
f=figure;
set(f, 'Name', ['Subject: ' subject]);
subplotStruct=[2 ceil(settings.numberOfRuns/2)];
for i=1:settings.numberOfRuns
    file{i}=spm_select('FPList', [settings.dataRoot settings.fMRIPreprocessedData ...
    subject settings.runNamePrefix num2str(i) '\'], '^rp.*\.txt');
    fid=fopen(file{i},'rt'); 
    data=fscanf(fid,'%f '); 
    fclose(fid);
    reshapedData=reshape(data,6,length(data)/6);
    subplot(subplotStruct(1),subplotStruct(2),i);
    plot(reshapedData(1:3,:)');
    ylim([-1.5 1.5]);
    grid on;
    title(['Run ' num2str(i)]);    
end;

% drawnow;
% set(get(handle(gcf),'JavaFrame'),'Maximized',1);

saveas(f,[settings.dataRoot settings.fMRIPreprocessedData ...
        subject '\movementsFile.png']);
for i=1:settings.numberOfRuns
    uicontrol('Style', 'pushbutton', 'String', ['Run ' num2str(i)],'Position', ...
        [10 20+30*(i-1) 50 20],'Callback', ['set(gcbf, ''Name'', ''' num2str(i) ''')']);
end;
plt=get(0,'Screensize');
plt(4)=plt(4)-150;
plt(2)=plt(2)+50;
set(f, 'Position', plt); % Maximize figure.
drawnow;

waitfor(f, 'Name');
selectedMeanFile=spm_select('FPList', [settings.dataRoot settings.fMRIPreprocessedData ...
        subject settings.runNamePrefix num2str(str2double(f.Name)) '\'], 'meanf.*\.nii');

fid=fopen([settings.dataRoot settings.fMRIPreprocessedData ...
    subject '\movementsSelection.txt'],'wt');
fprintf(fid,'%s',selectedMeanFile);
fclose(fid);    
close all;
