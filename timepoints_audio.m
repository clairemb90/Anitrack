function [data,nombrestimuli, befstim, afstim]=timepoints_audio(filestring,namefich)

    nombrestimuli=input('How many stimuli?');
    befstim=input('Duration before stimulus onset to be analyzed (in s) ' );
    afstim=input('Duration after stimulus onset to be analyzed (in s) ' );
    
    [d,sr] = audioread(filestring);
    
    num_stim=1;
    figure(1)
    specgram(d(:,1),1024,sr);
    
    while num_stim<nombrestimuli+1
        dcmObj=datacursormode
        pause
        data_cur{num_stim} = getCursorInfo(dcmObj);
        num_stim=num_stim+1;
    end
    close all
    cd(namefich);
    for extr=1:nombrestimuli
        data(extr)=data_cur{extr}.Position(1);
    end
    save(strcat(namefich,'_toi'),'data','nombrestimuli','befstim','afstim')
    cd ..
end
