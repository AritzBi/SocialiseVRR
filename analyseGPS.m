function analyseGPS
% Estimate clusters and circadian movement from GPS data following the
% procedures described in Saeb S, Zhang M, Karr CJ, Schueller SM, Corden ME, 
% Kording KP, et al. Mobile phone sensor correlates of depressive symptom severity 
% in daily-life behavior: An exploratory study. Journal of medical Internet 
% research. 2015 Jul 15;17(7):e175. Plots the GPS location of all participants 
% on the map, the extracted clusters for a representative participant and 
% the circadian movement for all participants during each of the four weeks 
% of the study.

THRESHOLD_SPEED = 1; % speed below 1km/h is considered stationary
MIN_DATA = 100; % Minimum number of data points per participants

DAY_ONE = datenum([2017,6,18,0,0,0]);


%% Load data
gps = readtable('gps.csv');

% Remove empty scans
i = gps.latitude==0;
j = gps.longitude==0;
i = ~(i&j);
gps = gps(i,:);

pid = unique(gps.pid);
num_part = length(pid)


%% Analyse data
num_weeks = ceil(days(ceil(max(gps.time)-min(gps.time)))/7)

warning off
for p = 1:num_part
    
    % get data from participant
    i = find(gps.pid == pid(p));
    longitude = gps.longitude(i);
    latitude = gps.latitude(i);
    time = datenum(gps.time(i));
    
    % analyse CM if sufficient data
    if length(i)>MIN_DATA
        
        % compute clusters
        
        % compute speed
        [d1km d2km]=lldistkm2(latitude,longitude);
        dkm = (d1km+d2km)/2;
        dhour = diff(time)*24;
        speed = dkm./dhour;        
        
        % select samples at which participant is stationairy
        speed = conv(speed,ones(3,1)/3,'same'); % smooth data
        i = find(speed<THRESHOLD_SPEED);     
        
        clusters(p) = computeClusters(latitude(i),longitude(i));        
        
        
        % compute circadian rhythm using least-squares spectral analysis
        
        % get data points for each scanning frequency
        for w = 1:4
            week(w).i = [];
        end
        for w = 1:num_weeks
            i = find(time > (w-1)*7+DAY_ONE & time < w*7+DAY_ONE);
            w2 = rem(w-1,4)+1;
            week(w2).i = [week(w2).i;i];
        end
        
        % perform least-squares spectral analysis
        freq_vec = 0.2:0.2:24*6; % frequency vector 
        for w = 1:4
            if length(week(w).i)>25
                i = week(w).i;
                [P_lon,f_lon] = plomb(longitude(i),time(i),freq_vec);
                [P_lat,f_lat] = plomb(latitude(i),time(i),freq_vec);
                
                P(:,w) = log((P_lon + P_lat)); % total power
                j = find(freq_vec == 1); % freq of 1 corresponds to 24-h or circadian rhythmw
                CM(p,w) = P(j,w); % circadian movement
            end
        end
    end
    
end


%% Plot resutls

% Panel A
colours = cbrewer('qual','Set1',num_part);

figure
set(gcf,'units','centimeters','position',[5 20 7 5.775])

warning off
hold on
for p = 1:num_part
    i = find(gps.pid == pid(p));
    [m j] = sort(gps.time(i),'ascend');
    plot(gps.longitude(i),gps.latitude(i),'.','MarkerSize',10,'color',colours(p,:))
    plot(gps.longitude(i(j)),gps.latitude(i(j)),'color',colours(p,:),'linewidth',1)
end
plot_google_map('scale',2)
hold off
set(gcf,'renderer','zbuffer')
set(gca,'position',[0.11 0.12 0.84 0.8],'fontsize',8,'ytick',[-40:10:20],'ylim',[-45 -10],'xlim',[110 157])

% Panel B
part = 8;
num_clust = clusters(part).num_clust;
colours = cbrewer('qual','Dark2',min([12,num_clust]));

figure
set(gcf,'units','centimeters','position',[12 20 7 5.775])

for n = 1:num_clust
    markersize = sqrt(sum(clusters(part).i==n));
    plot(clusters(part).centroid(n,2),clusters(part).centroid(n,1),'.','MarkerSize',markersize,'color',colours(rem(n-1,12)+1,:))
    hold on
end
plot_google_map('scale',2);
set(gca,'position',[0.11 0.12 0.84 0.8],'fontsize',8)
hold off

% Panel C
CM(CM==0) = NaN;

figure
colours = cbrewer('seq','Reds',5);

set(gcf,'units', 'centimeters','position',[5 12 14 6])
h = plot(CM);

for x = 1:4
    set(h(x),'color',colours(x+1,:),'linewidth', 1.5)
end
set(gca,'xlim',[0 28], 'ylim',[-17,2],'position', [0.1 0.18,0.87,0.75],'box','off')

xlabel('participants','fontsize',9)
ylabel('circadian movement','fontsize',9)

lh = legend({'8 min','5 min','4 min','3 min'});
set(lh,'position',[0.8 0.7,0.2 0.3],'box','off')


%% Report descriptive statistics
num_clusters = [clusters.num_clust];
fprintf(['Median number of clusters: ' num2str(median(num_clusters),'%2.1f'),'\n']) 
fprintf(['Range: ' num2str(min(num_clusters),'%2.1f'),' - ',num2str(max(num_clusters),'%2.1f'),'\n']) 

end


function cluster = computeClusters(lat,lon)
% Function to compute the number of clusters of GPS by increasing the
% number of clusters until the maximum distance to centroid falls below a
% threshold

THRESHOLD_DISTANCE = 2;
coord = [lat(:),lon(:)];

cont = 1;
num_clust = 2;
while(cont)
    [idx, centroid] = kmeans(coord,num_clust);
    
    distances = zeros(length(idx),num_clust);
    for n = 1:num_clust
        [d1km,d2km]=lldistkm3(lat,lon,centroid(n,1),centroid(n,2));
        distances(:,n) = (d1km+d2km)/2;
    end
    distances = min(distances,[],2);
        
    if max(distances) < THRESHOLD_DISTANCE
        cont = 0;        
    else
        num_clust = num_clust+1;
    end
end
cluster.centroid = centroid;
cluster.i = idx;
cluster.num_clust = num_clust;
end