function [data,nombrestimuli, befstim, afstim]=timepoints_visual(numFrames,vidObj,absnumFramespersecond,namefich)

nombrestimuli=input('How many stimuli?');
durpe=input('Duration of the stimulus (in s)');
befstim=input('Duration before stimulus onset to be analyzed (in s) ' );
afstim=input('Duration after stimulus onset to be analyzed (in s) ' );

image(read(vidObj,5))
rect=imrect;
% wait for key pressed
pause('on');
pause;
limit=rect.getPosition; %[xmin ymin width height].

numFrpersec=1/(durpe/2);
saut=round(absnumFramespersecond/numFrpersec);
k=numFrames;
fram=1;
indtab=1;
while indtab<=k
    s_vis=read(vidObj,indtab);
    indtab=indtab+saut;
    mvis(:,:,:,fram)=s_vis(round(limit(2)):round(limit(2)+limit(4)),round(limit(1)):round(limit(1)+limit(3)),:);    
    mvis_sum(fram)=sum(sum(sum(s_vis(round(limit(2)):round(limit(2)+limit(4)),round(limit(1)):round(limit(1)+limit(3)),:))));
    fram=fram+1;
    waitbar(indtab/k)
    clear s_vis
end

[peo,timep]=findpeaks(mvis_sum./max(mvis_sum),'MinPeakHeight',0.9);
timeconv=round(timep/numFrpersec);

if length(timep)<nombrestimuli
    disp('some stimuli were undetected')
elseif length(timep)>nombrestimuli
    disp('too many stimuli were detected')
end
 
numFrpersec1=round(absnumFramespersecond);

for nbt=1:length(timep)
    
    for indtab1=timeconv(nbt)*numFrpersec1-durpe*numFrpersec1/2:timeconv(nbt)*numFrpersec1
        s_vis=read(vidObj,indtab1);
        mvis_d(fram)=sum(sum(sum(s_vis(round(limit(2)):round(limit(2)+limit(4)),round(limit(1)):round(limit(1)+limit(3)),:))));
        fram=fram+1;
        
        clear s_vis
    end
    data(nbt)=((timeconv(nbt)-durpe/2)*numFrpersec1+min(find(mvis_d==max(mvis_d))))/numFrpersec1; 
    
end
    
    save(strcat(namefich,'_toi'),'durpe','nombrestimuli','befstim','afstim','data')
    
end
