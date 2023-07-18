% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath 'PfizerHAdataJun23.mat'])


data.p_con_pattern_duration = categorical(data.p_con_pattern_duration);
data.p_con_pattern_duration = reordercats(data.p_con_pattern_duration,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});
data.p_con_start_epi_time = categorical(data.p_con_start_epi_time);
data.p_con_start_epi_time = reordercats(data.p_con_start_epi_time,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});

data.con_epi_time_cat = NaN*ones(height(data),1);
data.con_epi_time_cat(data.p_pattern_to_con=='none'|data.p_pattern_to_con=='rare') = 2;
data.con_epi_time_cat(data.p_con_start_epi_time == '2wks' | data.p_con_start_epi_time=='2to4wk' | data.p_con_start_epi_time=='4to8wk' | data.p_con_start_epi_time=='8to12wk') = 1;
data.con_epi_time_cat(data.p_con_start_epi_time == '3to6mo' | data.p_con_start_epi_time=='6to12mo' | data.p_con_start_epi_time=='1to2y' | ...
    data.p_con_start_epi_time=='2to3y' | data.p_con_start_epi_time=='3yrs') = 0;


ICHD3 = ichd3_Dx(data);
ICHD3.dx = reordercats(ICHD3.dx,{'migraine','prob_migraine','chronic_migraine','tth','chronic_tth','tac','other_primary','new_onset','ndph','pth','undefined'});
ICHD3.dx = mergecats(ICHD3.dx,{'migraine','prob_migraine','chronic_migraine'});
ICHD3.dx = mergecats(ICHD3.dx,{'tth','chronic_tth'});
data.ichd3 = ICHD3.dx;
data.pulsate = ICHD3.pulsate;
data.pressure = ICHD3.pressure;
data.neuralgia = ICHD3.neuralgia;
data.ICHD_data = sum(table2array(ICHD3(:,2:40)),2);

%% Apply inclusion criteria
% Find participants, 6 to 17 years old with continuous headache, without
% PTH or NDPH

data_recent = data(data.visit_dt>datetime(2022,11,01),:);

data_start = data_recent(data_recent.p_current_ha_pattern == 'cons_flare' | data_recent.p_current_ha_pattern == 'cons_same' | data_recent.p_current_ha_pattern == 'episodic',:);

Age_req = data_start(data_start.age>=6 & data_start.age<18,:);

% Convert age to years
Age_req.ageY = floor(Age_req.age);

% Reorder race categories to make white (largest group) the reference group
Age_req.race = reordercats(Age_req.race,{'white','black','asian','am_indian','pacific_island','no_answer','unk'});

% Reorder ethnicity categories to make non-hispanic (largest group) the
% reference group
Age_req.ethnicity = reordercats(Age_req.ethnicity,{'no_hisp','hisp','no_answer','unk'});


% Identify those with continuous headache
Cont_req = Age_req((Age_req.p_current_ha_pattern == 'cons_flare' | Age_req.p_current_ha_pattern == 'cons_same'),:);
exclude_cont =  Age_req(Age_req.p_current_ha_pattern=='episodic',:);

Evo_req = Cont_req(~isnan(Cont_req.con_epi_time_cat),:);
missdata_evo = Cont_req(isnan(Cont_req.con_epi_time_cat),:);

HA = Evo_req;

HA3mo = HA(HA.p_con_pattern_duration=='1to2y'|HA.p_con_pattern_duration=='2to3y'|...
    HA.p_con_pattern_duration=='3to6mo'|HA.p_con_pattern_duration=='3yrs'|...
    HA.p_con_pattern_duration=='6to12mo',:);

[HA_severity] = prctile(HA.p_sev_usual,[25 50 75]);
[pedmidas] = prctile(HA.p_pedmidas_score,[25 50 75]);





%% evolution of headache to continuous

figure
histogram(HA.p_con_start_epi_time,'Normalization','probability')
set(gca,'TickDir','out'); set(gca,'Box','off');
title('Duration of evolution from episodic to constant headache')

figure
subplot(2,2,1)
histogram(HA.p_con_pattern_duration,'Normalization','probability')
set(gca,'TickDir','out'); set(gca,'Box','off');
title('Duration of constant headache')

subplot(2,2,2)
histogram(HA.p_current_ha_pattern,'Normalization','probability')
set(gca,'TickDir','out'); set(gca,'Box','off');

subplot(2,2,3)
histogram(HA.p_fre_bad,'Normalization','probability')
set(gca,'TickDir','out'); set(gca,'Box','off');

subplot(2,2,3)
histogram(HA.age,'Normalization','probability')
set(gca,'TickDir','out'); set(gca,'Box','off');

%% Triggers
noTrig = HA.p_con_prec___none;
concTrig = HA.p_con_prec___conc;
othinjTrig = HA.p_con_prec___oth_inj;
GIsxTrig = HA.p_con_prec___sxg;
infectTrig = HA.p_con_prec___infect;
othIllTrig = HA.p_con_prec___oth_ill;
mensTrig = HA.p_con_prec___mens;
stressTrig = HA.p_con_prec___stress;
othTrig = HA.p_con_prec___oth;

%% Differences in transition to continuous by age and sex assigned at birth

HA.race = removecats(HA.race);
HA.ethnicity = removecats(HA.ethnicity);
HA.ichd3 = removecats(HA.ichd3);
mdl = fitglm(HA,'con_epi_time_cat ~ ageY + gender + race + ethnicity + p_pedmidas_score + p_sev_usual + ichd3');



%% compare no, rapid, and gradual evolution of headache to continuous

[pAge,tblAge,statsAge] = kruskalwallis(HA.age,HA.con_epi_time_cat);
[tblSex,ChiSex,pSex] = crosstab(HA.gender,HA.con_epi_time_cat);
[pSev,tblSev,statsSev] = kruskalwallis(HA.p_sev_usual,HA.con_epi_time_cat);
[pDis,tblDis,statsDis] = kruskalwallis(HA.p_pedmidas_score,HA.con_epi_time_cat);
[tblICHD,~,~] = crosstab(HA.ichd3,HA.con_epi_time_cat);
[tblDur,ChiDur,pDur] = crosstab(HA.p_con_pattern_duration,HA.con_epi_time_cat);
[tblPat,ChiPat,pPat] = crosstab(removecats(HA.p_current_ha_pattern),HA.con_epi_time_cat);
[tblEvo,~,~] = crosstab(HA.p_con_start_epi_time,HA.con_epi_time_cat);

[tblnTrig,ChinTrig,pnTrig] = crosstab(noTrig,HA.con_epi_time_cat);
[tblcTrig,ChicTrig,pcTrig] = crosstab(concTrig,HA.con_epi_time_cat);
[tbloiTrig,ChioiTrig,poiTrig] = crosstab(othinjTrig,HA.con_epi_time_cat);
[tbliTrig,ChiiTrig,piTrig] = crosstab(infectTrig,HA.con_epi_time_cat);
[tblgiTrig,ChigiTrig,pgiTrig] = crosstab(GIsxTrig,HA.con_epi_time_cat);
[tbloilTrig,ChioilTrig,poilTrig] = crosstab(othIllTrig,HA.con_epi_time_cat);
[tblsTrig,ChisTrig,psTrig] = crosstab(stressTrig,HA.con_epi_time_cat);
[tblmTrig,ChimTrig,pmTrig] = crosstab(mensTrig,HA.con_epi_time_cat);
[tbloTrig,ChioTrig,poTrig] = crosstab(othTrig,HA.con_epi_time_cat);

%% compare missing data to non-missing data
missdata = missdata_evo;
missdata.missdata = ones(height(missdata),1);

excludedata = exclude_cont;
excludedata.missdata = zeros(height(excludedata),1);

HA.missdata = zeros(height(HA),1);

rebuild_data = [HA;missdata];

mdl_miss = fitglm(rebuild_data,'missdata ~ ageY + gender + race + ethnicity','Distribution','binomial');


%% compare no, rapid, and gradual evolution of headache to continuous (3 months continuous headache only)

noTrig3 = HA3mo.p_con_prec___none;
concTrig3 = HA3mo.p_con_prec___conc;
othinjTrig3 = HA3mo.p_con_prec___oth_inj;
GIsxTrig3 = HA3mo.p_con_prec___sxg;
infectTrig3 = HA3mo.p_con_prec___infect;
othIllTrig3 = HA3mo.p_con_prec___oth_ill;
mensTrig3 = HA3mo.p_con_prec___mens;
stressTrig3 = HA3mo.p_con_prec___stress;
othTrig3 = HA3mo.p_con_prec___oth;

[pAge3,tblAge3,statsAge3] = kruskalwallis(HA3mo.age,HA3mo.con_epi_time_cat);
[tblSex3,ChiSex3,pSex3] = crosstab(HA3mo.gender,HA3mo.con_epi_time_cat);
[pSev3,tblSev3,statsSev3] = kruskalwallis(HA3mo.p_sev_usual,HA3mo.con_epi_time_cat);
[pDis3,tblDis3,statsDis3] = kruskalwallis(HA3mo.p_pedmidas_score,HA3mo.con_epi_time_cat);
[tblICHD3,~,~] = crosstab(HA3mo.ichd3,HA3mo.con_epi_time_cat);
[tblDur3,~,~] = crosstab(removecats(HA3mo.p_con_pattern_duration),HA3mo.con_epi_time_cat);
[tblPat3,ChiPat3,pPat3] = crosstab(removecats(HA3mo.p_current_ha_pattern),HA3mo.con_epi_time_cat);
[tblEvo3,~,~] = crosstab(HA3mo.p_con_start_epi_time,HA3mo.con_epi_time_cat);


[tblnTrig3,ChinTrig3,pnTrig3] = crosstab(noTrig3,HA3mo.con_epi_time_cat);
[tblcTrig3,ChicTrig3,pcTrig3] = crosstab(concTrig3,HA3mo.con_epi_time_cat);
[tbloiTrig3,ChioiTrig3,poiTrig3] = crosstab(othinjTrig3,HA3mo.con_epi_time_cat);
[tbliTrig3,ChiiTrig3,piTrig3] = crosstab(infectTrig3,HA3mo.con_epi_time_cat);
[tblgiTrig3,ChigiTrig3,pgiTrig3] = crosstab(GIsxTrig3,HA3mo.con_epi_time_cat);
[tbloilTrig3,ChioilTrig3,poilTrig3] = crosstab(othIllTrig3,HA3mo.con_epi_time_cat);
[tblsTrig3,ChisTrig3,psTrig3] = crosstab(stressTrig3,HA3mo.con_epi_time_cat);
[tblmTrig3,ChimTrig3,pmTrig3] = crosstab(mensTrig3,HA3mo.con_epi_time_cat);
[tbloTrig3,ChioTrig3,poTrig3] = crosstab(othTrig3,HA3mo.con_epi_time_cat);

% % Get rid of entries with continuous headache for <3 months
% Dur_req = Cont_req(Cont_req.p_con_pattern_duration=='1to2y'|Cont_req.p_con_pattern_duration=='2to3y'|...
%     Cont_req.p_con_pattern_duration=='3to6mo'|Cont_req.p_con_pattern_duration=='3yrs'|...
%     Cont_req.p_con_pattern_duration=='6to12mo',:);
% 
% missdata_dur = Cont_req(Cont_req.p_con_pattern_duration~='1to2y' & Cont_req.p_con_pattern_duration~='2to3y' & Cont_req.p_con_pattern_duration~='3to6mo' &...
%     Cont_req.p_con_pattern_duration~='3yrs' & Cont_req.p_con_pattern_duration~='6to12mo' & Cont_req.p_con_pattern_duration~='2wks' & Cont_req.p_con_pattern_duration~='2to4wk' &...
%     Cont_req.p_con_pattern_duration~='4to8wk' & Cont_req.p_con_pattern_duration~='8to12wk',:);
% exclude_dur =  Cont_req(Cont_req.p_con_pattern_duration=='2wks' | Cont_req.p_con_pattern_duration=='2to4wk' |...
%     Cont_req.p_con_pattern_duration=='4to8wk' | Cont_req.p_con_pattern_duration=='8to12wk',:);