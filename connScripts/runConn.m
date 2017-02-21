function runConn(settings)

batch=generateBatch(settings);

% numGroups=12;
% if(batchInfo.isParallel==0)
%     numGroups=1;
% end;
% modul=mod(length(subjects), numGroups);
% groupsSize=round((length(subjects))/(numGroups));
% j=1;
% for i=1:numGroups-1
%     subjectsGroups{j,1}=subjects((i-1)*groupsSize+1:(i)*groupsSize);
%     effectsOldGroups{j,1}=effectsOld((i-1)*groupsSize+1:(i)*groupsSize);
%     effectsYoungGroups{j,1}=effectsYoung((i-1)*groupsSize+1:(i)*groupsSize);
%     j=j+1;
% end; 
% subjectsGroups{j,1}=subjects((j-1)*groupsSize+1:end);
% effectsOldGroups{j,1}=effectsOld((j-1)*groupsSize+1:end);
% effectsYoungGroups{j,1}=effectsYoung((j-1)*groupsSize+1:end);
% 
% batchInfo.preprocess=0;
% batchInfo.denoise=1;
% 
% batch=cell(1,length(subjectsGroups));
% for i=1:length(subjectsGroups)
%     batchInfo.subjects=subjectsGroups{i};
%     batchInfo.effectsOld=effectsOldGroups{i};
%     batchInfo.effectsYoung=effectsYoungGroups{i};
% %     batchInfo.connFileName=[batchInfo.connFileName '_SubjGroup_' num2str(i)];
%     batch{i}=generateBatch(batchInfo);
% end;

%% Output directory prepration
 
outputDirConn = [settings.dataRoot settings.conn.analysesAddress];
if ~exist(outputDirConn,'dir')
    mkdir(outputDirConn)
end
cd(outputDirConn);

%% Run batches in parallel/sequence
% for i=1:length(batch)
conn_batch(batch); 
% end;
