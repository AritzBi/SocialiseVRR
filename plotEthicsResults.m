function plotEthicsResults
% Plots the responses of participants to questions on their views about the 
% acceptability of passive data collection for mental health research.

ANSWERS = {'very comfortable','comfortable','neither comfortable nor uncomfortable','uncomfortable','very uncomfortable'};
LEGEND = {'very comfortable','comfortable','neither','unconfortable','very unconfortable'};

%% Load data

questionnaire = readtable('ethics_multiple_choice.csv');

%% Count responses

NQ = size(questionnaire,2)-1;
NA = length(ANSWERS);
questions = questionnaire.Properties.VariableNames(2:end);
counts = zeros(NA,NQ);

for q = 1:NQ
    for a = 1:NA
        counts(a,q) = sum(strcmp(questionnaire{:,q+1},ANSWERS{a}));
    end
    counts(:,q) = counts(:,q)/sum(counts(:,q))*100;
end


%% Plot responses

colours = cbrewer('div','RdYlGn',5);

set(gcf,'units','centimeters','position',[10 20 12 12])
subplot('position', [0.18 0.595 0.78 0.36])
h = barh(counts(:,1:4)','stacked');
for x = 1:length(h)
    set(h(x),'facecolor',colours(6-x,:))
end
set(gca,'fontsize',9,'xlim',[0 100],'ylim',[0.5 4.5],'box', 'off','ydir','reverse','yticklabel',questions(1:4))
title('Type of data that is collected','fontsize',10)
text(-20,0.25,'A','fontsize',10,'fontweight','bold')

subplot('position', [0.18 0.14 0.78 0.36])
h = barh(counts(:,5:8)','stacked');
for x = 1:length(h)
    set(h(x),'facecolor',colours(6-x,:))
end
set(gca,'fontsize',9,'xlim',[0 100],'ylim',[0.5 4.5],'box', 'off','ydir','reverse','yticklabel',questions(5:8))
title('Context in which data is collected','fontsize',10)
xlabel('percentage of respondents','fontsize',9)
text(-20,0.25,'B','fontsize',10,'fontweight','bold')

legendflex(h, LEGEND, 'ref', gcf,'anchor', {'s','s'},'buffer',[0 3],'nrow',1,'fontsize',8,'box','off','xscale',0.3);
% set(lh,'fontsize',8,'box','off','position',[0.05 0.02, 0.8 0.02])

    
