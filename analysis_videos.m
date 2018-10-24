%% analysis

filestring=input('Video name?');
%characteristics video
vidObj = VideoReader(filestring);
filename=vidObj.Name;
numFrames=vidObj.NumberOfFrames;

temps=vidObj.Duration; %en s
vidHeight=vidObj.Height;
vidWidth=vidObj.Width;
absnumFramespersecond=vidObj.FrameRate;%frame rate

multi=input('Single tracking (1) or Multitracking (2)?');
if multi==1
    manu=input('Manual detection when software fails? Yes (1) No (2)');
end
vide=input('30 s video of detected animals? Yes (1) No (2)?');
ana=input('Analysis? Yes (1) No (2)?');

numFramespersecondtoconsider=absnumFramespersecond;

[pathstr,namefich,ext] = fileparts(filename);
mkdir(namefich)

%% define TOI

cue=input('Define time window of interest: Visual (1), auditory (2), manual (3) or whole sequence (4)?');

if cue==1
    [data,nombrestimuli, befstim, afstim]=timepoints_visual(numFrames,vidObj,absnumFramespersecond,namefich);
elseif cue==2
    [data,nombrestimuli, befstim, afstim]=timepoints_audio(filestring,namefich);
elseif cue==3
    [data,nombrestimuli, befstim, afstim]=timepoints_manual(namefich);
else
    data=0;
    nombrestimuli=0;
    befstim=0;
    afstim=0;
end

%% load video (5 first minutes, 1 frame per 2 sec)
s_b=struct('cdata',zeros(vidHeight,vidWidth,3,'uint8')); %couleur matrice 3, image 8 bits
numFramespersecondtocons=0.5; % (1 frame toutes les 2 secondes);
saut_i=round(absnumFramespersecond/numFramespersecondtocons);

indtab=1;
k=absnumFramespersecond*300;
fram=1;
while indtab<=k
    s_b(fram).cdata=read(vidObj,indtab);
    indtab=indtab+saut_i;
    fram=fram+1;
    waitbar(indtab/k)
end

%% define ROI
numb_roi=input('How many fields of views?');
type_roi=input('Type of field of view? Rectangle 1, Ellipse 2');

scale=zeros(numb_roi,2);

for rroi=1:numb_roi
    x=round(length(s_b)/2);
    image(s_b(x).cdata)
    if type_roi==1
        rect=imrect;
        % wait for key pressed
        pause('on');
        pause;
        xy = rect.getPosition; %[xmin ymin width height].
        
        pos(:,:,rroi)=[xy(1), xy(2);xy(1)+xy(3),xy(2)+xy(4)]; %xext
        width(rroi)=xy(3);
        heigth(rroi)=xy(4);
        yext=[xy(2) xy(2)+xy(4)];
        y_extrem(:,rroi)=sort(yext);
        
        scale(rroi,1)=input('length roi in cm?');
        scale(rroi,2)=input('width roi in cm?');
        clear xy yext
    elseif type_roi==2
        circle=imellipse;
        pause('on');
        pause;
        xy(:,:,rroi)=circle.getVertices;
        pos(1,1,rroi)=min(xy,1);
        pos(2,1,rroi)=max(xy,1);
        y_extrem(1,rroi)=min(xy,2);
        y_extrem(2,rroi)=max(xy,2);
    end
    darbri(rroi)=input('Object darker (1) or brighter (2) than background?');
end

numb_roibeh=input('How many regions of interests?');
xy=[];
if numb_roibeh~=0
    
    for rroibeh=1:numb_roibeh
        type_roibeh=input('Type of ROI? Rectangle 1, Ellipse 2');
        image(s_b(x).cdata)
        
        if type_roibeh==1
            rect=imrect;
            % wait for key pressed
            pause('on');
            pause;
            xy(:,rroibeh) = rect.getPosition; %[xmin ymin width height].
            
        elseif type_roibeh==2
            circle=imellipse;
            pause('on');
            pause;
            xy(:,:,rroibeh)=circle.getVertices;
        end
        close all
    end
end
close all
%% define background
cinq=30;
answer='No';
while sum(ismember(answer,'No'))~=0 && cinq<300
    
    for he=1:vidHeight
        
        for we=1:vidWidth 
            
            for ind=1:cinq %number of frames
                concat(ind,:)=s_b(ind).cdata(he,we,:);
            end
            
            background(he,we,:)=median(concat,1);
            clear concat
        end
        waitbar(he/vidHeight)
        
    end
    
    %show background and ask user if OK
    imshow(background)
    answer = questdlg('Background OK?', 'background','Yes','No','Yes');
    
    close all
    cinq=cinq+30;
end

if sum(ismember(answer,'No'))~=0 && cinq>300
    error('animal not moving')
end

%% define threshold (gui) & number animals
if multi==2
    imshow(s_b(1).cdata)
    num_ani=input('how many animals?');
    close all
else
    num_ani=0;
end

for roui=1:numb_roi
    th_whol=5;  %(default)
    th_w_mat=[];
    answer1='No';
    th(1)=0;
    th(2)=0;
    at=3;
    
    while th(at-1)~=0 || th(at-2)~=1
        if darbri(roui)==1
            tsub=background-s_b(5).cdata>th_whol*ones(vidHeight,vidWidth,3); %sens soustraction important
            tsub1=background-s_b(cinq-5).cdata>th_whol*ones(vidHeight,vidWidth,3); %sens soustraction important
        elseif darbri(roui)==2
            tsub=s_b(5).cdata-background>th_whol*ones(vidHeight,vidWidth,3); %sens soustraction important
            tsub1=s_b(cinq-5).cdata-background>th_whol*ones(vidHeight,vidWidth,3); %sens soustraction important
        end
        
        
        tsub1(tsub1)=255;
        tsub(tsub)=255;
        trans=s_b(5).cdata;
        trans1=s_b(cinq-5).cdata;
        %pos(:,:,rroi)=[xy(1), xy(2)+xy(4)/2;xy(1)+xy(3),xy(2)+xy(4)/2]; %xext
        subplot(2,2,1)
        imshow(trans(round(y_extrem(1,roui)):round(y_extrem(2,roui)),round(pos(1,1,roui)):round(pos(2,1,roui)),:))
        subplot(2,2,2)
        image(tsub(round(y_extrem(1,roui)):round(y_extrem(2,roui)),round(pos(1,1,roui)):round(pos(2,1,roui)),:));
        subplot(2,2,3)
        imshow(trans1(round(y_extrem(1,roui)):round(y_extrem(2,roui)),round(pos(1,1,roui)):round(pos(2,1,roui)),:))
        subplot(2,2,4)
        image(tsub1(round(y_extrem(1,roui)):round(y_extrem(2,roui)),round(pos(1,1,roui)):round(pos(2,1,roui)),:));
        
        answer1 = questdlg('Threshold OK?', 'threshold','Yes','No','Yes');
        if sum(ismember(answer1,'No'))~=0
            th(at)=0;
        else
            th(at)=1;
            th_w_mat=[th_w_mat th_whol];
        end
        th_whol=th_whol+5;
        
        at=at+1;
    end
    clear tsub tsub1
    th_whole(roui)=max(th_w_mat);
    
    if darbri(roui)==1
        tsub=background-s_b(5).cdata>th_whole(roui)*ones(vidHeight,vidWidth,3); 
        tsub1=background-s_b(125).cdata>th_whole(roui)*ones(vidHeight,vidWidth,3); 
        tsub2=background-s_b(75).cdata>th_whole(roui)*ones(vidHeight,vidWidth,3); 
    elseif darbri(roui)==2
        tsub=s_b(5).cdata-background>th_whole(roui)*ones(vidHeight,vidWidth,3);
        tsub1=s_b(125).cdata-background>th_whole(roui)*ones(vidHeight,vidWidth,3);
        tsub2=s_b(75).cdata-background>th_whole(roui)*ones(vidHeight,vidWidth,3);
    end
    tsub(tsub)=255;
    v=regionprops(tsub(round(y_extrem(1,roui)):round(y_extrem(2,roui)),round(pos(1,1,roui)):round(pos(2,1,roui)),:), 'Area','BoundingBox');
    w=regionprops(tsub1(round(y_extrem(1,roui)):round(y_extrem(2,roui)),round(pos(1,1,roui)):round(pos(2,1,roui)),:), 'Area','BoundingBox');
    x=regionprops(tsub2(round(y_extrem(1,roui)):round(y_extrem(2,roui)),round(pos(1,1,roui)):round(pos(2,1,roui)),:), 'Area','BoundingBox');
    for ar=1:length(v)
        area(ar)=v(ar).Area;
        leng(ar)=max([v(ar).BoundingBox(length(v(ar).BoundingBox)/2+1),v(ar).BoundingBox(length(v(ar).BoundingBox)/2+2)]);
    end
    for ar=1:length(w)
        area1(ar)=w(ar).Area;
        leng1(ar)=max([w(ar).BoundingBox(length(w(ar).BoundingBox)/2+1),w(ar).BoundingBox(length(w(ar).BoundingBox)/2+2)]);
    end
    for ar=1:length(x)
        area2(ar)=x(ar).Area;
        leng2(ar)=max([x(ar).BoundingBox(length(x(ar).BoundingBox)/2+1),x(ar).BoundingBox(length(x(ar).BoundingBox)/2+2)]);
    end
    m_area_r(roui)=median([max(area),max(area1),max(area2)]);
    length_r(roui)=median([max(leng),max(leng1),max(leng2)]);
end

clear th th_w_mat th_whol tsub tsub1 tsub2 trans trans1 s_b v w x area area1 area2 leng leng1 leng2
close all

%m_area=;

%% tracking

saut=round(absnumFramespersecond/numFramespersecondtoconsider);
tbetwframes=saut/absnumFramespersecond;

fram=1;
fram_s(1)=1;
fram_toi=[];
if cue==4
    indtab(fram)=1;
    while indtab(fram)<=numFrames     
        fram=fram+1;
        indtab(fram)=indtab(fram-1)+saut;
    end
else
    for extr=1:nombrestimuli
        timepoint(extr)=round(data(extr)*numFrames/temps)+1;
        
        it1=befstim*absnumFramespersecond;
        it2=afstim*absnumFramespersecond;
        indtab(fram)=timepoint(extr)-it1;
        
        while indtab(fram)<=timepoint(extr)+it2
            fram=fram+1;
            indtab(fram)=indtab(fram-1)+saut;
            if indtab(fram)-saut<=timepoint(extr) && indtab(fram)+saut>=timepoint(extr)
                fram_toi=[fram_toi fram];
            end
        end
        fram_s(extr+1)=fram;
    end
    fram_s=fram_s(1:nombrestimuli);
end

fram=fram-1;

centroids_whole=NaN(fram,2,num_ani,numb_roi);

unsure=zeros(numb_roi,1);
m_area=zeros(fram,numb_roi);
for ind=1:fram
    
    s=struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'));
    s.cdata=read(vidObj,indtab(ind));
    t=struct('subtrac',zeros(vidHeight,vidWidth,3,'uint8'));
    
    for roui=1:numb_roi
        if darbri(roui)==1
            t.subtrac=background-s.cdata>th_whole(roui)*ones(vidHeight,vidWidth,3);
        elseif darbri(roui)==2
            t.subtrac=s.cdata-background>th_whole(roui)*ones(vidHeight,vidWidth,3);
        end
        t.subtrac(t.subtrac==1)=255;
        
        v=regionprops(t.subtrac,'Centroid','Area','BoundingBox','Orientation');
        animal=0;
        nombsup=1;
        for cherch=1:length(v)
            dimens=length(v(cherch).BoundingBox);
            if v(cherch).Area>m_area_r(roui)/10 && v(cherch).Area<m_area_r(roui)*5 && v(cherch).Centroid(2)>y_extrem(1,roui) && v(cherch).Centroid(2)<y_extrem(2,roui) && v(cherch).Centroid(1)>pos(1,1,roui) && v(cherch).Centroid(1)<pos(2,1,roui)
                animal(nombsup)=cherch;
                nombsup=nombsup+1;
            end
        end
        if multi==1
            if (isempty(animal) || nombsup~=2) && manu==1
                image(s(ind).cdata)
                dcmObj=datacursormode
                % set(dcmObj,'DisplayStyle','datatip','SnapToDataVertex','on','Enable','on')
                pause
                prov = getCursorInfo(dcmObj);
                clf
                centroids_whole(ind,1,1,roui) = prov.Position(1);
                centroids_whole(ind,2,1,roui) = prov.Position(2);
                m_area(ind,roui)=m_area_r(roui);
            elseif (isempty(animal) || nombsup~=2) && manu==2
                if nombsup>2 && ind>1 && sum(isnan(centroids_whole(ind-1,:,1,roui)))==0
                    for ns=1:nombsup-1
                        dist(ns)=sqrt((centroids_whole(ind-1,1,1,roui)-v(animal(ns)).Centroid(1)).^2+(centroids_whole(ind-1,2,1,roui)-v(animal(ns)).Centroid(2)).^2);
                        are(ns)=abs(m_area(ind-1,roui)-v(animal(ns)).Area);
                    end
                    min_wt=dist<length_r(roui)+are<m_area_r(roui)/5;
                    min_w=find(min_wt==2);
                    if length(min_w)==1
                        unsure(roui)=unsure(roui)+1;
                        centroids_whole(ind,:,1,roui) = cat(1, v(animal(min_w)).Centroid(1:2));
                        m_area(ind,roui)=v(animal(min_w)).Area;
                    elseif isempty(length(min_w))==1
                        for ns=1:nombsup-1
                            dist_p(ns)=sqrt((centroids_whole(ind-3,1,1,roui)-v(animal(ns)).Centroid(1)).^2+(centroids_whole(ind-3,2,1,roui)-v(animal(ns)).Centroid(2)).^2);
                            are_p(ns)=abs(m_area(ind-3,roui)-v(animal(ns)).Area);
                        end
                        min_wt_p=dist<length_r(roui)*2+are<m_area_r(roui)/5;
                        min_w_p=find(min_wt_p==2);
                        if length(min_w_p)==1
                            unsure(roui)=unsure(roui)+1;
                            centroids_whole(ind,:,1,roui) = cat(1, v(animal(min_w_p)).Centroid(1:2));
                            m_area(ind,roui)=v(animal(min_w_p)).Area;
                        end
                        clear min_w_p dist_p are_p
                    end
                    clear min_w dist are
                end
            elseif nombsup==2
                centroids_whole(ind,:,1,roui) = cat(1, v(animal(nombsup-1)).Centroid(1:2));
                m_area(ind,roui)=v(animal(nombsup-1)).Area;
                
                
            end
        elseif multi==2 && ~isempty(animal)
            
            if nombsup-1>num_ani
                x_na=[];
                y_na=[];
                ar_na=[];
                for nana=1:length(animal)
                    x_na=[x_na;cat(1, v(animal(nana)).Centroid(1))];
                    y_na=[y_na;cat(1, v(animal(nana)).Centroid(2))];
                    ar_na=[ar_na;cat(1, v(animal(nana)).Area)];
                end
                
                dist=sqrt((centroids_whole(ind-1,1,1,roui)-x_na).^2+(centroids_whole(ind-1,2,1,roui)-y_na).^2);
                are=abs(m_area(ind-1,roui)-ar_na);
                
                min_wt=dist<length_r(roui)+are<m_area_r(roui)/5;
                min_w=find(min_wt==2);
                
                if length(min_w)<num_ani
                    fant=find(~ismember([1:1:num_ani],min_w));
                    min_w=[min_w fant(1:num_ani-length(min_w))];
                elseif length(min_w)>num_ani
                    min_w=min_w(1:num_ani);
                end
                for pop=1:length(min_w)
                    unsure(roui)=unsure(roui)+1;
                    centroids_whole(ind,:,pop,roui) = cat(1, v(animal(min_w(pop))).Centroid(1:2));
                    m_area(ind,roui)=v(animal(min_w)).Area;
                end
            else
                if nombsup-1<num_ani
                    fornum=nombsup-1;
                else
                    fornum=num_ani;
                end
                for pop=1:fornum
                    centroids_whole(ind,:,pop,roui) = cat(1, v(animal(pop)).Centroid(1:2));
                    
                end
            end
            
        end
        
    end
    clear v animal prov s t
    waitbar(ind/fram)
end
    
%% save important variables in mat file

cd(namefich)
save(strcat(namefich,'_background'),'background','th_whole','m_area_r','length_r','-v7.3') ;
save(strcat(namefich,'_roi'),'scale','pos','y_extrem','numb_roi','numb_roibeh','xy','-v7.3');
save(strcat(namefich,'_output'),'centroids_whole','tbetwframes','-v7.3') ;
if cue~=4
    save(strcat(namefich,'_sections'),'fram_s','fram_toi','-v7.3') ;
end
%xlswrite
%% simple analysis
if ana==1
    analysisofdata
end
cd ..
%% create video?
if vide==1
    video_trace(centroids_whole,num_ani,fram,multi,numFramespersecondtoconsider,numb_roi,namefich,indtab,vidObj)
end
% clear all
% close all