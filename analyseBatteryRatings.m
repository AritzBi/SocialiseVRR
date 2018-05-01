function analyseBatteryRatings
% Plots the responses of participants indicating how much they thought the
% app impacted the battery life of their smartphone.

DAY_ONE = datenum([2017,6,18,0,0,0]);
SCANNING_RATE = [8,5,4,3];

labels = {'not much','2','3','4','5','6','very much'};
legends = {'8 min','5 min','4 min','3 min'};

% Read data
survey = readtable('app_survey.csv');

% Determine scanning rate
days = ceil(datenum(survey.time-1)-DAY_ONE);
weeks = ceil(days/7);

size(SCANNING_RATE(rem(weeks-1,4)+1))
size(survey)
survey.scanning_rate = SCANNING_RATE(rem(weeks-1,4)+1)';


%% Count answers
counts = zeros(7,4);

for answers = 1:7
    i1 = survey.battery == answers;
    
    for rates = 1:4
        i2 = survey.scanning_rate == SCANNING_RATE(rates);
        
        counts(answers,rates) = sum(i1 & i2)/sum(i2)*100;
    end
end

%% Plot results
set(gcf,'units','centimeters','position',[10 20 9 7])

subplot('position',[0.11 0.1 0.86, 0.82])
colors = cbrewer('seq','Reds',5);
h = bar([1:7],counts);
for x = 1:4
    set(h(x),'facecolor',colors(x+1,:))
end
set(gca,'fontsize',8, 'box','off','xtick',[1:7],'xticklabel',labels,'xlim',[0.5 7.5],'ylim',[0 52])
ylabel('percentage of respondents','fontsize',9)
title('Perceived impact on battery life','fontsize',10)
lh = legend(h,legends);
set(lh,'box','off','fontsize',9,'position',[0.13 0.68 0.25 0.2])