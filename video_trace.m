function video_trace(centroids_whole,num_ani,fram,multi,numFramespersecondtoconsider,numb_roi,namefich,indtab,vidObj)

%% Prepare workspace
close all
% clear all
% clc

mov=QTWriter(strcat(namefich,'_output.mov'));

hf=figure('Color',[0 0 0]);
% set(hf, 'Position', [1 1 2500 1000])
% hold all
% if multi==2
%     for aiii=1:num_ani
%         c(aiii,:)=rand(1,3);
%     end
% end
for i_f=fram-round(30*numFramespersecondtoconsider):fram
% for i_f=1:fram  
    hold all
    
    s.cdata=read(vidObj,indtab(i_f));
    imshow(s.cdata)
    hold on
    for ro=1:numb_roi
        if multi==1
            
            plot(centroids_whole(i_f,1,1,ro), centroids_whole(i_f,2,1,ro), 'xb');
            
        elseif multi==2
            for ai=1:num_ani
                p=plot(centroids_whole(i_f,1,ai,ro), centroids_whole(i_f,2,ai,ro), 'xb');
%                 p.Color=c(ai,:);
                hold on
            end
        end
    end
    mov.FrameRate = numFramespersecondtoconsider;
    writeMovie(mov,getframe(hf));
    waitbar(i_f/(fram/4))
end
hold off
close(mov);