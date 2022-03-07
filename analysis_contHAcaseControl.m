% Analyze continuous headache data

load continuousHAcasecontrol_clean

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

%% Participant demographics
ageAll = boot95ciMedian(casecontrol.ageDays)./360;

figure(10)
subplot(1,2,1)
histogram(casecontrol.ageDays./360,'Normalization','probability')
subplot(1,2,2)
histogram(casecontrol.gender,'Normalization','probability')
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

[pPM,tblPM,statsPM] = kruskalwallis(casecontrol.p_pedmidas_score,casecontrol.type,'off');
title(sprintf('H = %2.2f, p = %1.2g',[tblPM{2,5} pPM]))

casecontrol.pedmidas_grade = cell(150,1);
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score<=10) = {'none'};
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score>10 & casecontrol.p_pedmidas_score<=30) = {'mild'};
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score>30 & casecontrol.p_pedmidas_score<=50) = {'moderate'};
casecontrol.pedmidas_grade(casecontrol.p_pedmidas_score>50) = {'severe'};
casecontrol.pedmidas_grade(cellfun(@isempty,casecontrol.pedmidas_grade)) = {'NaN'};
casecontrol.pedmidas_grade = categorical(casecontrol.pedmidas_grade);

[tbl_pmg,chi2_pmg,p_pmg] = crosstab(removecats(casecontrol.pedmidas_grade(casecontrol.pedmidas_grade~='NaN')),casecontrol.type(casecontrol.pedmidas_grade~='NaN'));
fprintf('pedmidas grade: chi2 = %2.2f, p = %1.2g',[chi2_pmg p_pmg])

%% Headache quality

migrainous = sum(table2array(casecontrol(:,[123 124 133])),2);
migrainous(migrainous>1) = 1;
tension = sum(table2array(casecontrol(:,[126:128 131])),2);
tension(tension>1) = 1;
neuralgia = sum(table2array(casecontrol(:,[125 129 130 132])),2);
neuralgia(neuralgia>1) = 1;

%% Headache location

casecontrol.unilateral_sideLocked = zeros(150,1);
casecontrol.unilateral_sideLocked(casecontrol.p_location_side___both == 0 & sum(table2array(casecontrol(:,[136 137])),2)==1) = 1;

%% comparison of allodynia

casecontrol.allodynia = sum(table2array(casecontrol(:,191:194)),2);
casecontrol.allodynia(casecontrol.allodynia>0) = 1;

%% comparison of valsalva triggered headache
valsalva = sum(table2array(casecontrol(:,196:198)),2);
valsalva(valsalva>0) = 1;

worse_standing = casecontrol.p_valsalva_position___stand;
worse_lying = casecontrol.p_valsalva_position___lie;

%% MCA for associated symptoms

% Extract headache location metrics

haASx=table2array(casecontrol(:,[245 247 250:257 259:261 1133]));
var_HAaSx=char('nausea','vomiting','light sensitivity','smell sensitivity','sound sensitivity','light headed',...
    'room spinning','balance problems','difficulty hearing','ear ringing','neck pain','difficulty thinking','difficulty talking','allodynia');


% reconfigure data so they can be used in the MCA function, mcorran2. All variables need to be converted to binary

binary_hx=cell(size(haASx));
binary_struct=NaN*ones(size(haASx,2),1);
for x=1:size(haASx,2)
    temp=haASx(:,x);
    outcome=unique(temp);
        for y=1:size(haASx,1)
            binary_struct(x,:)=2;
                switch temp(y)
                    case outcome(1)
                        binary_hx{y,x}=[1 0];
                    case outcome(2)
                        binary_hx{y,x}=[0 1];
                end
        end
end

% concatonate each subjects binary outcomes
binary_Hx=NaN*ones(size(binary_hx,1),size(var_HAaSx,1)*2);
temp=[];
for x=1:size(binary_hx,1)
    for y=1:size(binary_hx,2)
        temp=cat(2,temp,cell2mat(binary_hx(x,y)));
    end
    binary_Hx(x,:)=temp;
    temp=[];
end

% Calculate MCA
[~,~,~,~,~,MCA_corrHAaSx,sx_scores] = mcorran3(binary_Hx,binary_struct','var_names',var_HAaSx);

% Calculate MCA scores
MCA_no=3;
MCA_score_HAaSx=NaN*ones(size(binary_Hx,1),MCA_no);
for x=1:size(binary_Hx,1)
    for y=1:MCA_no
        temp1=binary_Hx(x,:);
        temp2=MCA_corrHAaSx(:,y);
        r=temp1*temp2;
        MCA_score_HAaSx(x,y)=r;
    end
end

casecontrol.MCA1_HAaSx = MCA_score_HAaSx(:,1);
casecontrol.MCA2_HAaSx = MCA_score_HAaSx(:,2);
casecontrol.MCA3_HAaSx = MCA_score_HAaSx(:,3);

mig1 = boot95ciMean(casecontrol.MCA1_HAaSx(casecontrol.type=='migraine'));
mig2 = boot95ciMean(casecontrol.MCA2_HAaSx(casecontrol.type=='migraine'));
ppth1 = boot95ciMean(casecontrol.MCA1_HAaSx(casecontrol.type=='ppth'));
ppth2 = boot95ciMean(casecontrol.MCA2_HAaSx(casecontrol.type=='ppth'));
ndph1 = boot95ciMean(casecontrol.MCA1_HAaSx(casecontrol.type=='ndph'));
ndph2 = boot95ciMean(casecontrol.MCA2_HAaSx(casecontrol.type=='ndph'));

figure
hold on
plot([0 0],[-5 5],'--','Color',[0.5 0.5 0.5])
plot([-10 10],[0 0],'--','Color',[0.5 0.5 0.5])
plot(casecontrol.MCA1_HAaSx(casecontrol.type=='migraine'),casecontrol.MCA2_HAaSx(casecontrol.type=='migraine'),'.k','MarkerSize',10)
plot(casecontrol.MCA1_HAaSx(casecontrol.type=='ppth'),casecontrol.MCA2_HAaSx(casecontrol.type=='ppth'),'.b','MarkerSize',10)
plot(casecontrol.MCA1_HAaSx(casecontrol.type=='ndph'),casecontrol.MCA2_HAaSx(casecontrol.type=='ndph'),'.m','MarkerSize',10)
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[-6 9];ax.YLim=[-3 4];

errorbar(mig1(2),mig2(2),abs(diff(mig2(1:2))),abs(diff(mig2(2:3))),abs(diff(mig1(1:2))),abs(diff(mig1(2:3))),'ok','MarkerFaceColor','k')
errorbar(ppth1(2),ppth2(2),abs(diff(ppth2(1:2))),abs(diff(ppth2(2:3))),abs(diff(ppth1(1:2))),abs(diff(ppth1(2:3))),'ob','MarkerFaceColor','b')
errorbar(ndph1(2),ndph2(2),abs(diff(ndph2(1:2))),abs(diff(ndph2(2:3))),abs(diff(ndph1(1:2))),abs(diff(ndph1(2:3))),'om','MarkerFaceColor','m')


%% 3D plot of the first 3 MCA dimensions
fig308 = figure(308);
fig308.Renderer='Painters';
X = casecontrol.MCA1_HAaSx;
Y = casecontrol.MCA2_HAaSx;
Z = casecontrol.MCA3_HAaSx;

scatter3(X,Y,Z,'ok','MarkerFaceColor',[0.9 0.9 0.9]);
hold on
xlabel('MCA 1')
ylabel('MCA 2')
zlabel('MCA 3')

% Find the 3D vector
simLS = [-6 8];
xyz = nan(2);
uvw = nan(2);
for ii = 1:2
    switch ii
        case 1
            temp=polyfit(X,Y,1);
        case 2
            temp=polyfit(X,Z,1);
    end
    xyz(ii) = polyval(temp,simLS(1));
    uvw(ii) = polyval(temp,simLS(2))-polyval(temp,simLS(1));
end

% Draw an arrow for this vector
plot3(simLS,[xyz(1) uvw(1)],[xyz(2) uvw(2)],'-k','LineWidth',1);


%% Compare continuous sample across different metrics

% pedmidas vs. usual headache severity
figure
subplot(2,3,1)
hold on
plot(casecontrol.p_sev_usual,casecontrol.p_pedmidas_score,'.','Color',[0.5 0.5 0.5],'MarkerSize',8)
lsline
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 11];ax.YLim=[0 450];axis('square');
[r,p] = corrcoef(casecontrol.p_sev_usual(~isnan(casecontrol.p_pedmidas_score)),casecontrol.p_pedmidas_score(~isnan(casecontrol.p_pedmidas_score)));
title(sprintf('headache severity v. pedmidas, R = %1.2f, p = %1.2g',[r(1,2) p(1,2)]))

% MCA1 vs. usual headache severity
subplot(2,3,2)
hold on
plot(casecontrol.p_sev_usual,casecontrol.MCA1_HAaSx,'.','Color',[0.5 0.5 0.5],'MarkerSize',8)
lsline
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 11];ax.YLim=[-6 8];axis('square');
[r,p] = corrcoef(casecontrol.p_sev_usual,casecontrol.MCA1_HAaSx);
title(sprintf('headache severity v. MCA1, R = %1.2f, p = %1.2g',[r(1,2) p(1,2)]))

% MCA2 vs. usual headache severity
subplot(2,3,3)
hold on
plot(casecontrol.p_sev_usual,casecontrol.MCA2_HAaSx,'.','Color',[0.5 0.5 0.5],'MarkerSize',8)
lsline
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[0 11];ax.YLim=[-3 4];axis('square');
[r,p] = corrcoef(casecontrol.p_sev_usual,casecontrol.MCA2_HAaSx);
title(sprintf('headache severity v. MCA2, R = %1.2f, p = %1.2g',[r(1,2) p(1,2)]))


% pedmidas vs. MCA1
subplot(2,3,4)
hold on
plot(casecontrol.MCA1_HAaSx,casecontrol.p_pedmidas_score,'.','Color',[0.5 0.5 0.5],'MarkerSize',8)
lsline
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[-6 8];ax.YLim=[0 450];axis('square');
[r,p] = corrcoef(casecontrol.MCA1_HAaSx(~isnan(casecontrol.p_pedmidas_score)),casecontrol.p_pedmidas_score(~isnan(casecontrol.p_pedmidas_score)));
title(sprintf('MCA1 v. pedmidas, R = %1.2f, p = %1.2g',[r(1,2) p(1,2)]))

% pedmidas vs. MCA2
subplot(2,3,5)
hold on
plot(casecontrol.MCA2_HAaSx,casecontrol.p_pedmidas_score,'.','Color',[0.5 0.5 0.5],'MarkerSize',8)
lsline
ax=gca;ax.Box='off';ax.TickDir='out';ax.XLim=[-3 4];ax.YLim=[0 450];axis('square');
[r,p] = corrcoef(casecontrol.MCA2_HAaSx(~isnan(casecontrol.p_pedmidas_score)),casecontrol.p_pedmidas_score(~isnan(casecontrol.p_pedmidas_score)));
title(sprintf('MCA2 v. pedmidas, R = %1.2f, p = %1.2g',[r(1,2) p(1,2)]))

%% Local functions

function [boot95] = boot95ciMean(Y)

         bootstat = bootstrp(1000,@nanmean,Y);
         bootstat = sort(bootstat);
         boot95 = bootstat([25 500 975]);
end

function [boot95] = boot95ciMedian(Y)

         bootstat = bootstrp(1000,@nanmedian,Y);
         bootstat = sort(bootstat);
         boot95 = bootstat([25 500 975]);
end