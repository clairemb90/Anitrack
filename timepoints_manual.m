function [data,nombrestimuli, befstim, afstim]=timepoints_manual(namefich)

nombrestimuli=input('How many stimuli?');
durpe=input('Duration of the stimulus (in s)');
befstim=input('Duration before stimulus onset to be analyzed (in s) ' );
afstim=input('Duration after stimulus onset to be analyzed (in s) ' );

for tm=1:nombrestimuli
    data(tm)=input('type in seconds the beginning of the time-window of interest');
end

save(strcat(namefich,'_toi'),'durpe','nombrestimuli','befstim','afstim','data')
    
end
