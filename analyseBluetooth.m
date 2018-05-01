function analyseBluetooth
% Analyses the pattern of devices detected using Bluetooth following the
% procedure described in Do TMT, Gatica-Perez D. Human interaction discovery 
% in smartphone proximity networks. Pers Ubiquit Comput. 2013
% Mar;17(3):413-31. Plots the number of Bluetooth devices that were detected
% as function of participants (panel A) or time of day (panel B).

CUT_OFF = 1/24/60; % scans within 1 minute are considered simultaneous
THRESHOLD = 3; % devices detected on at least 3 seperate days are considered known devices


%% Read data
Data = readtable('bluetooth.csv');

pid = unique(Data.pid);
num_part = length(pid);


%% Compute patterns of detected devices
for p = 1:num_part
    i = find(Data.pid == pid(p));
    
    scan_times = datenum(Data.time(i));

    [devices, ia, ic]  = unique(Data.detected(i));
    devices = setdiff(devices,'None Detected');
    
    
    % Differiate between known and unknown devices
    known_devices = {};
    unknown_devices = {};
    for d = 1:length(devices)
        if length(unique(scan_times(ic==d)))>=THRESHOLD
            known_devices = [known_devices,devices{d}];
        else
            unknown_devices = [unknown_devices,devices{d}];
        end
    end
    
    known_detected = ismember(Data.detected(i),known_devices);
    unknown_detected = ismember(Data.detected(i),unknown_devices);
    seperate_scans = diff(scan_times) > CUT_OFF;
    
    participant(p).perc_known = sum(known_detected)/sum(seperate_scans);
    participant(p).perc_unknown = sum(unknown_detected)/sum(seperate_scans);
    participant(p).num_scans = sum(seperate_scans);
    
    
    % Determine pattern across the day
    bins = [0:24]; % bin across day time hours
    count_known = histcounts(rem(scan_times(known_detected),1)*24,bins);
    count_unknown = histcounts(rem(scan_times(unknown_detected),1)*24,bins);
    count_scans = histcounts(rem(scan_times(seperate_scans),1)*24,bins);
    
    participant(p).daily_known = count_known./count_scans; % normalize
    participant(p).daily_unknown = count_unknown./count_scans;
    participant(p).bins = bins;
end


%% Plot results
figure
set(gcf,'units','centimeters','position',[10 25,9,10])


% panel A
perc_known = [participant.perc_known];
perc_unknown = [participant.perc_unknown];

xlim = [0.2 num_part+0.8];
ylim = [0 1.5];
subplot('position',[0.13 0.59 0.83, 0.35])
bar(1:num_part,cat(1,perc_known,perc_unknown)','stacked')
set(gca,'box','off','fontsize',8,'xlim',xlim,'ylim',ylim)
xlabel('participants','fontsize',9)
ylabel('# of devices','fontsize',9)
title('average number of nearby smartphones','fontsize',10)

lh = legend({'known devices', 'unknown devices'});
set(lh,'box','off','fontsize',9,'position',[0.22 0.81,0.3,0.1])

text(xlim(1)-diff(xlim)*0.14, ylim(2)+diff(ylim)*0.12, 'A','fontsize',10','fontweight','bold')


% panel B
daily_known = cat(1,participant.daily_known);
daily_unknown = cat(1,participant.daily_unknown);

xlim = [0.2 24.8];
ylim = [0 0.27];
subplot('position',[0.13 0.095 0.83, 0.35])
size(cat(1,mean(daily_known,1),mean(daily_unknown,1))')
bar(bins(2:end),cat(1,mean(daily_known,1,'omitnan'),mean(daily_unknown,1,'omitnan'))','stacked')
set(gca,'box','off','fontsize',8,'xlim',xlim,'ylim',ylim,'xtick',[6,12,18,24])
xlabel('time of day','fontsize',9)
ylabel('# of devices','fontsize',9)

text(xlim(1)-diff(xlim)*0.14, ylim(2)+diff(ylim)*0.12, 'B','fontsize',10','fontweight','bold')