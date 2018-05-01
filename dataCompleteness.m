function dataCompleteness
% Computes the number of Bluetooth data points that were recorded for each 
% participant and compares it to the number of scheduled scans. Scanning 
% rate is plotted as percentage of scheduled scans.

DAY_ONE = datenum([2017,6,18,0,0,0]);
NUM_WEEKS = 11;

SCAN_RATES = [8,5,4,3]/(60*24);

%% Read data
Data = readtable('bluetooth.csv');
Participant = readtable('participant_info.csv');


%% Estimate scheduled scan times
scheduled_scans = [];
for w = 1:NUM_WEEKS
    week = rem(w-1,4)+1;
    start_week = (w-1)*7 + DAY_ONE;
    end_week = w*7 + DAY_ONE;
    
    scans = start_week:SCAN_RATES(week):end_week;
    scheduled_scans = [scheduled_scans,scans(1:end-1)];
end


%% Compute scanning rates
pid = unique([Data.pid]);
num_part = length(pid);
for p = 1:num_part
    scans = find([Data.pid] == pid(p));
    stat(p).scan_times = unique(datenum(Data.time(scans)));
    stat(p).num_scans = length(stat(p).scan_times);
    stat(p).iti = diff(stat(p).scan_times);
    stat(p).start = min(stat(p).scan_times);
    stat(p).end = max(stat(p).scan_times);
    stat(p).num_scheduled = sum(scheduled_scans>stat(p).start & scheduled_scans<stat(p).end);
    stat(p).data_rate = stat(p).num_scans/stat(p).num_scheduled;
    
    i = find(Participant.pid == pid(p));
    stat(p).model = Participant.model{i};
    stat(p).os = Participant.os{i};
end

mean_scan_rate = [stat.data_rate]*100;
model = {stat.model};
os = {stat.os};


%% Plot results
figure
set(gcf,'units','centimeters','position',[10 20 12 10])

% sort data
[mean_scan_rate,j] = sort(mean_scan_rate,'descend');
model = model(j);
os = os(j);

i = find(strcmp(model,''));
for x = 1:length(i)
    model{i(x)} = 'unknown';
end

i = find(strcmp(os,'Android'));
android = mean_scan_rate(i);
h(1) = bar(i,mean_scan_rate(i),'b','barwidth', 0.7);
hold on
i = find(strcmp(os,'iOS'));
iOS = mean_scan_rate(i);
h(2) = bar(i,mean_scan_rate(i),'r','barwidth', 0.7);
hold off
box off
ylabel('performed scans [%]','fontsize',9)
title('Completeness of data','fontsize',10)
lh = legend(h,{'Android','iOS'});
set(lh,'box','off','fontsize',9)

set(gca,'xlim',[0.2 num_part+0.8],'ylim',[0 100],'xtick',[1:num_part],'xticklabel',model,'xticklabelrotation',90)
set(gca,'position',[0.1 0.32 0.88 0.63],'fontsize',8)


%% Write summary statistics to screen
fprintf('Range: %2.1f - %2.1f\n',min(mean_scan_rate),max(mean_scan_rate))
fprintf('Android: %2.1f, SD %2.1f\n',mean(android),std(android))
fprintf('iOS: %2.1f, SD %2.1f\n\n',mean(iOS),std(iOS))


