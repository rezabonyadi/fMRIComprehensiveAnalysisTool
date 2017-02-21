function settings=handleMyErrors(toRemoveSubs,settings,analysis)
if(sum(toRemoveSubs)>0)
    fid=fopen(settings.reportFileName,'at');
    for i=1:length(toRemoveSubs)
        if(toRemoveSubs(i)>0)
            fprintf(fid,...
                'Subject %s was removed as there were some problems with generating its %s files \n',settings.subjectsNames{i},analysis);
        end;
    end;
    fclose(fid);
    settings.subjectsNames(toRemoveSubs==1)=[];
    settings.subjectsNames = ...
    settings.subjectsNames(~cellfun(@isempty, settings.subjectsNames));
end;
