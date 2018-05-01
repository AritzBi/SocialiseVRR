function analyseBattery
% Uses robust linear regression to estimate the average change in battery
% life across scanning rates. Scanning rates were varied across different
% weeks. For each scanning rate, select data points were phone was
% discharging and the actual inter-scan interval was close to the intended
% scanning rate. Plots the battery consumption for the four different scanning 
% rates (every 3, 4, 5 or 8 minutes) for individual participants and the 
% estimated regression line across participants.

BINS = [7,9; 4,6; 3,5; 2,4]/60; % only use data points with prescribed ITIs 
MIN_SCAN = 100; % only include participants with sufficient data

STATUS = {'Battery is in use (discharging).','Disconnected - Battery Discharging'};

DAY_ONE = datenum([2017,6,18,0,0,0]);


%% Load data
battery = readtable('battery.csv');

pid = unique(battery.pid);
num_part = length(pid)

% only time points when phone was discharging
i = ismember(battery.status,STATUS);
battery = battery(i,:);

% convert time to Matlab time
battery.time = datenum(battery.time);

%% Analyse data
num_weeks = ceil((max(battery.time)-min(battery.time))/7);

for p = 1:num_part
    i_p = find(battery.pid == pid(p));
    
    for w = 1:num_weeks        
        i_w = find(battery.time > (w-1)*7+DAY_ONE & battery.time < w*7+DAY_ONE);
        i = intersect(i_p,i_w);
        
        if w<5
            data(p,w).num_scans = 0;
            data(p,w).iti = [];
            data(p,w).usage = [];
            data(p,w).times = [];
        end
        
        if ~isempty(i)
            iti = diff(battery.time(i))*24; %inter-scan interval in hours
            usage = diff(battery.level(i));
                      
            w2 = rem(w-1,4)+1;
            
            % find data points with prescribed ITIs
            j = find(iti>BINS(w2,1) & iti<BINS(w2,2));
            
            data(p,w2).num_scans = data(p,w2).num_scans+length(j);
            data(p,w2).iti = [data(p,w2).iti;iti(j)];
            data(p,w2).usage = [data(p,w2).usage;usage(j)];
            data(p,w2).times = [data(p,w2).times;battery.time(i(j))];
            
            num_scans(p,w2) = data(p,w2).num_scans;
            mean_iti(p,w2) = mean(data(p,w2).iti);
            consumption_per_hour(p,w2) = mean(data(p,w2).usage)./mean(data(p,w2).iti); % average battery consumption per hour
        end
    end
end

% only use data from subjects with sufficient data
min_scans = min(num_scans');
i = find(min_scans>MIN_SCAN);
num_part = length(i)

mean_iti = mean_iti(i,:)';
rates = 1./mean_iti;
consumption_per_hour = -consumption_per_hour(i,:)';

% use robust linear regression to estimate change in battery consumption
% with scann rate
brob = robustfit(rates(:),consumption_per_hour(:));


%% Plot resutls
figure
set(gcf,'units','centimeters', 'position', [30 30 8 6]);

% plot individual data
plot(mean_iti*60,100./consumption_per_hour,'color',[0.7 0.7 0.7])

% plot regression line
rate = [0:0.1:60];
i = find(rate>=7.5 & rate<=20);
hours_till_empty = 100./(brob(1)+brob(2)*rate);
hold on
plot(60./rate(i),hours_till_empty(i),'b', 'linewidth',1.5)
hold off

set(gca,'xlim',[2.5 8.5],'ylim',[0 32], 'fontsize', 8);
box off
xlabel('inter-scan interval (minutes)','fontsize', 9)
ylabel('hours until empty','fontsize', 9)
title('battery consumption', 'fontsize',10)


%% Descriptive statistics
i1 = find(rate == 0);
i2 = find(rate == 12);
fprintf(['Time till empty at 0 scans per hours: ' num2str(hours_till_empty(i1),'%2.1f'),' hours\n']) 
fprintf(['Time till empty at 12 scans per hours: ' num2str(hours_till_empty(i2),'%2.1f'),' hours\n\n']) 
