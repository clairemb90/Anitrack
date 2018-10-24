function analysisofdata(background,absnumFramespersecond,centroids_whole,numb_roi,numb_roibeh,namefich,fram,xy,pos,y_extrem,num_ani)

%overview
image(background)
hold on
for rr=1:numb_roi
    for aa=1:num_ani
        plot(centroids_whole(:,1,aa,rr),centroids_whole(:,2,aa,rr))
        hold on
    end
end
saveas(gcf,strcat('track',namefich),'png')

close all

%time in region of interest
rc=[];
if num_ani==1
    for rrb=1:numb_roibeh
        for rrc=1:numb_roi
            if xy(1,rrb)>pos(1,1,rrc) && xy(2,rrb)>y_extrem(1,rrc) && xy(3,rrb)<pos(2,1,rrc) && xy(4,rrb)<y_extrem(2,rrc)
                rc=rrc;
            end
        end
        if isempty(rc)==1
            error('region of interest not included in field of view')
        end
        inzone=zeros(1,numb_roibeh);
        outzone=zeros(1,numb_roibeh);
        timenan=zeros(1,numb_roibeh);
        for ff=1:fram
            if sum(isnan(centroids_whole(ff,:,1,rc)))==0
                if centroids_whole(ff,1,1,rc)>xy(1,rrb) && centroids_whole(ff,2,1,rc)>xy(2,rrb) && centroids_whole(ff,1,1,rc)<xy(3,rrb) && centroids_whole(ff,1,1,rc)<xy(4,rrb)
                    inzone(rrb)=inzone(rrb)+1;
                else
                    outzone(rrb)=outzone(rrb)+1;
                end
            else
                timenan(rrb)=timenan(rrb)+1;
            end
        end
        bar([inzone(rrb)/absnumFramespersecond outzone(rrb)/absnumFramespersecond timenan(rrb)/absnumFramespersecond ]);
        saveas(gcf,strcat(num2str(rrb),'time_in_sec',namefich),'png')
        close all
    end 
end

cd(namefich)
save(strcat(namefich,'_analysis'),'inzone','outzone','timenan') ;

%further analysis can be added below

end