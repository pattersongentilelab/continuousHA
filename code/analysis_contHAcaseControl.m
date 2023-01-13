% Analyze continuous headache data

load([Pfizer_dataBasePath '/continuousHAcasecontrol_cleanICHD-3.mat'])
load([Pfizer_dataBasePath '/confirmedDX_contHAcaseControl.mat'])


% combine into a single table
migraine_case.type = cell(50,1);
migraine_case.type(migraine_case.record_id>0) = {'migraine'};
migraine_case.type = categorical(migraine_case.type);
ppth_case.type = cell(50,1);
ppth_case.type(ppth_case.record_id>0) = {'ppth'};
ppth_case.type = categorical(ppth_case.type);
ndph_case.type = cell(50,1);
ndph_case.type(ndph_case.record_id>0) = {'ndph'};
ndph_case.type = categorical(ndph_case.type);

casecontrol = [migraine_case; ppth_case; ndph_case];

casecontrol.good = ismember(casecontrol.record_id,[cm_good pth_good ndph_good]');

% casecontrol = casecontrol(casecontrol.good==1,:);

%% Headache quality

casecontrol.pulsate = sum(table2array(casecontrol(:,[123 124 133])),2);
casecontrol.pulsate(casecontrol.pulsate>1) = 1;
casecontrol.pressure = sum(table2array(casecontrol(:,[126:128 131])),2);
casecontrol.pressure(casecontrol.pressure>1) = 1;
casecontrol.neuralgia = sum(table2array(casecontrol(:,[125 129 130 132])),2);
casecontrol.neuralgia(casecontrol.neuralgia>1) = 1;


%% comparison of allodynia

casecontrol.allodynia = sum(table2array(casecontrol(:,191:194)),2);
casecontrol.allodynia(casecontrol.allodynia>0) = 1;

%% comparison of valsalva triggered headache
casecontrol.valsalva = sum(table2array(casecontrol(:,196:198)),2);
casecontrol.valsalva(casecontrol.valsalva>0) = 1;

casecontrol.worse_standing = casecontrol.p_valsalva_position___stand;
casecontrol.worse_lying = casecontrol.p_valsalva_position___lie;


%% Determine ICHD-3 diagnoses
[ICHD3] = ichd3_contDx(casecontrol);

%% Participant demographics
ageAll = boot95ciMedian(casecontrol.ageDays)./365.25;
ageMig = boot95ciMedian(casecontrol.ageDays(casecontrol.type=='migraine'))./365.25;
agePPTH = boot95ciMedian(casecontrol.ageDays(casecontrol.type=='ppth'))./365.25;
ageNDPH = boot95ciMedian(casecontrol.ageDays(casecontrol.type=='ndph'))./365.25;

%% Headache severity
figure(11)
subplot(1,2,1)
edges = 0.5:1:10.5;
center = edges(1:end-1) + diff(edges(1:2))./2;
center_fine = 1:0.1:10;
h = histogram(casecontrol.p_sev_usual,edges,'Normalization','probability','FaceColor',[0.5 0.5 0.5]);
hold on
interp = pchip(center,h.Values,center_fine);
plot(center_fine,interp,'-','Color',[0.5 0.5 0.5],'LineWidth',2)
HAsevAll = boot95ciMedian(casecontrol.p_sev_usual);
errorbar(HAsevAll(2),0.38,[],[],abs(diff(HAsevAll(1:2))),abs(diff(HAsevAll(2:3))),'v','MarkerFaceColor',[0.5 0.5 0.5])
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 11];ax.YLim=[0 0.5];


subplot(1,2,2)
hM = histogram(casecontrol.p_sev_usual(casecontrol.type=='migraine'),edges,'Normalization','probability','FaceColor','k');
hold on
interp = pchip(center,hM.Values,center_fine);
plot(center_fine,interp,'-k','LineWidth',2)

hP = histogram(casecontrol.p_sev_usual(casecontrol.type=='ppth'),edges,'Normalization','probability','FaceColor','b');
interp = pchip(center,hP.Values,center_fine);
plot(center_fine,interp,'-b','LineWidth',2)

hN = histogram(casecontrol.p_sev_usual(casecontrol.type=='ndph'),edges,'Normalization','probability','FaceColor','m');
interp = pchip(center,hN.Values,center_fine);
plot(center_fine,interp,'-m','LineWidth',2)

HAsevMig = boot95ciMedian(casecontrol.p_sev_usual(casecontrol.type=='migraine'));
HAsevPPTH = boot95ciMedian(casecontrol.p_sev_usual(casecontrol.type=='ppth'));
HAsevNDPH = boot95ciMedian(casecontrol.p_sev_usual(casecontrol.type=='ndph'));
errorbar(HAsevMig(2),0.39,[],[],abs(diff(HAsevMig(1:2))),abs(diff(HAsevMig(2:3))),'vk','MarkerFaceColor','k')
errorbar(HAsevPPTH(2),0.4,[],[],abs(diff(HAsevPPTH(1:2))),abs(diff(HAsevPPTH(2:3))),'vb','MarkerFaceColor','b')
errorbar(HAsevNDPH(2),0.41,[],[],abs(diff(HAsevNDPH(1:2))),abs(diff(HAsevNDPH(2:3))),'vm','MarkerFaceColor','m')
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 11];ax.YLim=[0 0.5];
[pHS,tblHS,statsHS] = kruskalwallis(casecontrol.p_sev_usual,casecontrol.type,'off');
title(sprintf('H = %2.2f, p = %1.2g',[tblHS{2,5} pHS]))

%% Bad headache frequency
figure(12)
hold on
histogram(casecontrol.p_fre_bad(casecontrol.type=='migraine'),'Normalization','probability')
histogram(casecontrol.p_fre_bad(casecontrol.type=='ppth'),'Normalization','probability')
histogram(casecontrol.p_fre_bad(casecontrol.type=='ndph'),'Normalization','probability')
[~,chi2,p] = crosstab(removecats(casecontrol.p_fre_bad),casecontrol.type);
title(sprintf('chi2 = %2.2f, p = %1.2g',[chi2 p]))
ax=gca;ax.Box='off';ax.TickDir='out';

%% Duration of bad headaches
figure(14)
hold on
histogram(casecontrol.p_sev_dur(casecontrol.type=='migraine'),'Normalization','probability') 
histogram(casecontrol.p_sev_dur(casecontrol.type=='ppth'),'Normalization','probability')
histogram(casecontrol.p_sev_dur(casecontrol.type=='ndph'),'Normalization','probability')
[~,chi2,p] = crosstab(removecats(casecontrol.p_sev_dur),casecontrol.type);
title(sprintf('chi2 = %2.2f, p = %1.2g',[chi2 p]))
ax=gca;ax.Box='off';ax.TickDir='out';

%% Rate of rise of bad headaches
figure(15)
hold on
histogram(casecontrol.p_sev_rate_rise(casecontrol.type=='migraine'),'Normalization','probability')
histogram(casecontrol.p_sev_rate_rise(casecontrol.type=='ppth'),'Normalization','probability')
histogram(casecontrol.p_sev_rate_rise(casecontrol.type=='ndph'),'Normalization','probability')
[~,chi2,p] = crosstab(removecats(casecontrol.p_sev_rate_rise),casecontrol.type);
title(sprintf('chi2 = %2.2f, p = %1.2g',[chi2 p]))
ax=gca;ax.Box='off';ax.TickDir='out';

%% Headache-related disability (pedmidas)

figure(13)
subplot(1,2,1)
edges = 0:20:460;
center = edges(1:end-1) + diff(edges(1:2))./2;
center_fine = 1:1:450;
h = histogram(casecontrol.p_pedmidas_score,edges,'Normalization','probability','FaceColor',[0.5 0.5 0.5]);
hold on
interp = pchip(center,h.Values,center_fine);
HApedmidAll = boot95ciMedian(casecontrol.p_pedmidas_score);
errorbar(HApedmidAll(2),0.4,[],[],abs(diff(HApedmidAll(1:2))),abs(diff(HApedmidAll(2:3))),'o','MarkerFaceColor',[0.5 0.5 0.5])
plot(center_fine,interp,'-k','LineWidth',2)
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 460];ax.YLim=[0 0.5];

subplot(1,2,2)
hM = histogram(casecontrol.p_pedmidas_score(casecontrol.type=='migraine'),edges,'Normalization','probability','FaceColor','k');
hold on
interp = pchip(center,hM.Values,center_fine);
plot(center_fine,interp,'-k','LineWidth',2)

hP = histogram(casecontrol.p_pedmidas_score(casecontrol.type=='ppth'),edges,'Normalization','probability','FaceColor','b');
interp = pchip(center,hP.Values,center_fine);
plot(center_fine,interp,'-b','LineWidth',2)

hN = histogram(casecontrol.p_pedmidas_score(casecontrol.type=='ndph'),edges,'Normalization','probability','FaceColor','m');
interp = pchip(center,hN.Values,center_fine);
plot(center_fine,interp,'-m','LineWidth',2)

HApedmidMig = boot95ciMedian(migraine_case.p_pedmidas_score);
HApedmidPPTH = boot95ciMedian(ppth_case.p_pedmidas_score);
HApedmidNDPH = boot95ciMedian(ndph_case.p_pedmidas_score);
errorbar(HApedmidMig(2),0.38,[],[],abs(diff(HApedmidMig(1:2))),abs(diff(HApedmidMig(2:3))),'vk','MarkerFaceColor','k')
errorbar(HApedmidPPTH(2),0.4,[],[],abs(diff(HApedmidPPTH(1:2))),abs(diff(HApedmidPPTH(2:3))),'vb','MarkerFaceColor','b')
errorbar(HApedmidNDPH(2),0.42,[],[],abs(diff(HApedmidNDPH(1:2))),abs(diff(HApedmidNDPH(2:3))),'vm','MarkerFaceColor','m')
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 460];ax.YLim=[0 0.5];

[pPM,tblPM,~] = kruskalwallis(casecontrol.p_pedmidas_score,casecontrol.type,'off');
title(sprintf('H = %2.2f, p = %1.2g',[tblPM{2,5} pPM]))


figure(23)
hold on
HApedmidMig = boot95ciMedian(migraine_case.p_pedmidas_score);
HApedmidPPTH = boot95ciMedian(ppth_case.p_pedmidas_score);
HApedmidNDPH = boot95ciMedian(ndph_case.p_pedmidas_score);
errorbar(1,HApedmidMig(2),abs(diff(HApedmidMig(1:2))),abs(diff(HApedmidMig(2:3))),'ok','MarkerFaceColor','k')
errorbar(2,HApedmidPPTH(2),abs(diff(HApedmidPPTH(1:2))),abs(diff(HApedmidPPTH(2:3))),'ob','MarkerFaceColor','b')
errorbar(3,HApedmidNDPH(2),abs(diff(HApedmidNDPH(1:2))),abs(diff(HApedmidNDPH(2:3))),'om','MarkerFaceColor','m')
ax=gca;ax.Box='off';ax.TickDir='out';ax.YLim=[0 150];ax.XLim=[0 4];

[pPM,tblPM,~] = kruskalwallis(casecontrol.p_pedmidas_score,casecontrol.type,'off');
title(sprintf('H = %2.2f, p = %1.2g',[tblPM{2,5} pPM]))


casecontrol.pedmidas_grade = cell(height(casecontrol),1);
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score<=10) = {'none'};
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score>10 & casecontrol.p_pedmidas_score<=30) = {'mild'};
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score>30 & casecontrol.p_pedmidas_score<=50) = {'moderate'};
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score>50) = {'severe'};
casecontrol.pedmidas_grade(cellfun(@isempty,casecontrol.pedmidas_grade)) = {'NaN'};
casecontrol.pedmidas_grade = categorical(casecontrol.pedmidas_grade);

[tbl_pmg,chi2_pmg,p_pmg] = crosstab(removecats(casecontrol.pedmidas_grade(casecontrol.pedmidas_grade~='NaN')),casecontrol.type(casecontrol.pedmidas_grade~='NaN'));

figure
bar(1:4,tbl_pmg([3 1 2 4],:)')
xticklabels({'none','mild','moderate','severe'})
set(gca,'Box','off')
set(gca,'TickDir','out')
title(sprintf('pedmidas grade: chi2 = %2.2f, p = %1.2g',[chi2_pmg p_pmg]))


save contHA_analysisICHD casecontrol ICHD3


%% headache severity of NDPH high vs. low usual headache severity
ndph_case.sev_level = zeros(height(ndph_case),1);
ndph_case.sev_level(ndph_case.p_sev_usual>=6) = 2;
ndph_case.sev_level(ndph_case.p_sev_usual<=5) = 1;


% headache frequency
subplot(1,2,1)
hold on
histogram(ndph_case.p_fre_bad(ndph_case.sev_level==1),'Normalization','probability','FaceColor','r');
histogram(ndph_case.p_fre_bad(ndph_case.sev_level==2),'Normalization','probability','FaceColor','c');
[~,chi2,p] = crosstab(removecats(ndph_case.p_fre_bad),ndph_case.sev_level);
title(sprintf('chi2 = %2.2f, p = %1.2g',[chi2 p]))
ax=gca;ax.Box='off';ax.TickDir='out';

% headache disability
subplot(1,2,2)
hd_hi = histogram(ndph_case.p_pedmidas_score(ndph_case.sev_level==2),edges,'Normalization','probability','FaceColor','r');
hold on
interp = pchip(center,hd_hi.Values,center_fine);
plot(center_fine,interp,'-r','LineWidth',2)

hd_lo = histogram(ndph_case.p_pedmidas_score(ndph_case.sev_level==1),edges,'Normalization','probability','FaceColor','c');
interp = pchip(center,hd_lo.Values,center_fine);
plot(center_fine,interp,'-c','LineWidth',2)

HApedmidNDPH_hi = boot95ciMedian(ndph_case.p_pedmidas_score(ndph_case.sev_level==2));
HApedmidNDPH_lo = boot95ciMedian(ndph_case.p_pedmidas_score(ndph_case.sev_level==1));
errorbar(HApedmidNDPH_hi(2),0.38,[],[],abs(diff(HApedmidNDPH_hi(1:2))),abs(diff(HApedmidNDPH_hi(2:3))),'vr','MarkerFaceColor','r')
errorbar(HApedmidNDPH_lo(2),0.4,[],[],abs(diff(HApedmidNDPH_lo(1:2))),abs(diff(HApedmidNDPH_lo(2:3))),'vc','MarkerFaceColor','c')
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 460];ax.YLim=[0 0.5];

[pnPM,tblnPM,statsnPM] = kruskalwallis(ndph_case.p_pedmidas_score,ndph_case.sev_level,'off');
title(sprintf('H = %2.2f, p = %1.2g',[tblnPM{2,5} pnPM]))

%% Local functions


function [boot95] = boot95ciMedian(Y)

         bootstat = bootstrp(1000,@nanmedian,Y);
         bootstat = sort(bootstat);
         boot95 = bootstat([25 500 975]);
end