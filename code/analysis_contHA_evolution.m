% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath 'PfizerHAdataJun23.mat'])
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'
addpath '/Users/pattersonc/Documents/MATLAB/headacheDx'

data.p_con_pattern_duration = categorical(data.p_con_pattern_duration);
data.p_con_pattern_duration = reordercats(data.p_con_pattern_duration,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});
data.p_con_start_epi_time = categorical(data.p_con_start_epi_time);
data.p_con_start_epi_time = reordercats(data.p_con_start_epi_time,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});

data.con_epi_time_cat = NaN*ones(height(data),1);
data.con_epi_time_cat(data.p_pattern_to_con=='none'|data.p_pattern_to_con=='rare') = 2;
data.con_epi_time_cat(data.p_con_start_epi_time == '2wks' | data.p_con_start_epi_time=='2to4wk' | data.p_con_start_epi_time=='4to8wk' | data.p_con_start_epi_time=='8to12wk') = 1;
data.con_epi_time_cat(data.p_con_start_epi_time == '3to6mo' | data.p_con_start_epi_time=='6to12mo' | data.p_con_start_epi_time=='1to2y' | ...
    data.p_con_start_epi_time=='2to3y' | data.p_con_start_epi_time=='3yrs') = 0;

data.con_epi_time_cat2 = data.con_epi_time_cat;
data.con_epi_time_cat = categorical(data.con_epi_time_cat,[2 1 0],{'sudden onset','rapid evolution','gradual evolution'});


ICHD3 = ichd3_Dx(data);
ICHD3.dx = reordercats(ICHD3.dx,{'migraine','prob_migraine','chronic_migraine','tth','chronic_tth','tac','other_primary','new_onset','ndph','pth','undefined'});
ICHD3.dx = mergecats(ICHD3.dx,{'migraine','prob_migraine','chronic_migraine'});
ICHD3.dx = mergecats(ICHD3.dx,{'tth','chronic_tth'});
data.ichd3 = ICHD3.dx;
data.pulsate = ICHD3.pulsate;
data.pressure = ICHD3.pressure;
data.neuralgia = ICHD3.neuralgia;
data.ICHD_data = sum(table2array(ICHD3(:,2:40)),2);

% Reorder race categories to make white (largest group) the reference group
data.race_full = data.race;
data.race = reordercats(data.race,{'white','black','asian','am_indian','pacific_island','no_answer','unk'});
data.race = mergecats(data.race,{'am_indian','pacific_island','no_answer','unk'},'other');
data.race(data.race=='other') = '<undefined>';
data.race = removecats(data.race);

% Reorder ethnicity categories to make non-hispanic (largest group) the
% reference group
data.ethnicity = reordercats(data.ethnicity,{'no_hisp','hisp','no_answer','unk'});
data.ethnicity = removecats(data.ethnicity);

data.pattern_dur_wk = zeros(height(data),1);
data.pattern_dur_wk(data.p_con_pattern_duration=='2wks') = 1;
data.pattern_dur_wk(data.p_con_pattern_duration=='2to4wk') = 3;
data.pattern_dur_wk(data.p_con_pattern_duration=='4to8wk') = 6;
data.pattern_dur_wk(data.p_con_pattern_duration=='8to12wk') = 10;
data.pattern_dur_wk(data.p_con_pattern_duration=='3to6mo') = 18;
data.pattern_dur_wk(data.p_con_pattern_duration=='6to12mo') = 36;
data.pattern_dur_wk(data.p_con_pattern_duration=='1to2y') = 72;
data.pattern_dur_wk(data.p_con_pattern_duration=='2to3y') = 120;
data.pattern_dur_wk(data.p_con_pattern_duration=='3yrs') = 144;

% Pedmidas severity grade
data.pedmidas_grade = NaN*ones(height(data),1);
data.pedmidas_grade(data.p_pedmidas_score<=10) = 0;
data.pedmidas_grade(data.p_pedmidas_score>10 & data.p_pedmidas_score<=30) = 1;
data.pedmidas_grade(data.p_pedmidas_score>30 & data.p_pedmidas_score<=50) = 2;
data.pedmidas_grade(data.p_pedmidas_score>50) = 3;

%% Collapse triggers data

data.nTriggers = sum([data.p_con_prec___conc data.p_con_prec___sxg...
    data.p_con_prec___infect data.p_con_prec___mens data.p_con_prec___stress data.p_con_prec___oth],2);

% removed 'other injury' since only those who also had concussion reported
% other injury
data.triggers = -1*ones(height(data),1);
data.triggers(data.p_con_prec___none==1) = 0;
data.triggers(data.p_con_prec___conc==1) = 1;
data.triggers(data.p_con_prec___sxg==1) = 2;
data.triggers(data.p_con_prec___infect==1|data.p_con_prec___oth_ill==1) = 3;
data.triggers(data.p_con_prec___mens==1) = 4;
data.triggers(data.p_con_prec___stress==1) = 5;
data.triggers(data.p_con_prec___oth==1|data.p_con_prec___oth_ill==1) = 6;
data.triggers(data.nTriggers>1) = 7;

data.triggers = categorical(data.triggers,0:1:7,{'none','concussion','GI symptoms',...
    'illness','menses','stress','other','multiple'});

data.triggers = mergecats(data.triggers,{'illness','GI symptoms'});

data.trigger_binary = NaN*ones(height(data),1);
data.trigger_binary(data.triggers=='none') = 0;
data.trigger_binary(data.triggers~='none') = 1;


%% Apply inclusion criteria
% Find participants, 6 to 17 years old with continuous headache, without
% PTH or NDPH

data_recent = data(data.visit_dt>datetime(2022,11,01),:);

data_start = data_recent(data_recent.p_current_ha_pattern == 'cons_flare' | data_recent.p_current_ha_pattern == 'cons_same' | data_recent.p_current_ha_pattern == 'episodic',:);

Age_req = data_start(data_start.age>=6 & data_start.age<18,:);

% Convert age to years
Age_req.ageY = floor(Age_req.age);

% Identify those with continuous headache
Cont_req = Age_req((Age_req.p_current_ha_pattern == 'cons_flare' | Age_req.p_current_ha_pattern == 'cons_same'),:);
exclude_cont =  Age_req(Age_req.p_current_ha_pattern=='episodic',:);

Evo_req = Cont_req(~isnan(Cont_req.con_epi_time_cat2),:);
missdata_evo = Cont_req(isnan(Cont_req.con_epi_time_cat2),:);

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

%% compare no, rapid, and gradual evolution of headache to continuous
HA.ethnicity = removecats(HA.ethnicity);
HA.race = removecats(HA.race);
HA.ichd3 = removecats(HA.ichd3);
HA.p_current_ha_pattern = removecats(HA.p_current_ha_pattern);

[pAge,tblAge,statsAge] = kruskalwallis(HA.age,HA.con_epi_time_cat);
[tblSex,ChiSex,pSex] = crosstab(HA.gender,HA.con_epi_time_cat);
[tblRace,ChiRace,pRace] = crosstab(HA.race,HA.con_epi_time_cat);
[tblEth,ChiEth,pEth] = crosstab(HA.ethnicity,HA.con_epi_time_cat);
[pSev,tblSev,statsSev] = kruskalwallis(HA.p_sev_usual,HA.con_epi_time_cat);
[pDis,tblDis,statsDis] = kruskalwallis(HA.p_pedmidas_score,HA.con_epi_time_cat);
[tblICHD,~,~] = crosstab(HA.ichd3,HA.con_epi_time_cat);
[pDurD,tblDurD,statsDurD] = kruskalwallis(HA.pattern_dur_wk,HA.con_epi_time_cat);
[tblPat,ChiPat,pPat] = crosstab(HA.p_current_ha_pattern,HA.con_epi_time_cat);
[tblEvo,~,~] = crosstab(HA.p_con_start_epi_time,HA.con_epi_time_cat);
[tblTrig,ChiTrig,pTrig] = crosstab(HA.triggers,HA.con_epi_time_cat);
[tblTrigBi,ChiTrigBi,pTrigBi] = crosstab(HA.trigger_binary,HA.con_epi_time_cat);

%% Compare pedmidas
mdl_evo = fitlm(HA,'p_pedmidas_score ~ con_epi_time_cat','RobustOpts','on');
tbl_evo = lm_tbl_plot(mdl_evo);
mdl_age = fitlm(HA,'p_pedmidas_score ~ age','RobustOpts','on');
tbl_age = lm_tbl_plot(mdl_age);
mdl_sex = fitlm(HA,'p_pedmidas_score ~ gender','RobustOpts','on');
tbl_sex = lm_tbl_plot(mdl_sex);
mdl_race = fitlm(HA,'p_pedmidas_score ~ race','RobustOpts','on');
tbl_race = lm_tbl_plot(mdl_race);
mdl_eth = fitlm(HA,'p_pedmidas_score ~ ethnicity','RobustOpts','on');
tbl_eth = lm_tbl_plot(mdl_eth);
mdl_sev = fitlm(HA,'p_pedmidas_score ~ p_sev_usual','RobustOpts','on');
tbl_sev = lm_tbl_plot(mdl_sev);
mdl_dur = fitlm(HA,'p_pedmidas_score ~ pattern_dur_wk','RobustOpts','on');
tbl_dur = lm_tbl_plot(mdl_dur);
mdl_pat = fitlm(HA,'p_pedmidas_score ~ p_current_ha_pattern','RobustOpts','on');
tbl_pat = lm_tbl_plot(mdl_pat);
mdl_trig = fitlm(HA,'p_pedmidas_score ~ trigger_binary','RobustOpts','on');
tbl_trig = lm_tbl_plot(mdl_trig);

%% Regression analysis

mdl_evo_disability = fitlm(HA,'p_pedmidas_score ~ con_epi_time_cat + age + gender + race + pattern_dur_wk + p_sev_usual + trigger_binary','RobustOpts','on');
tbl_Full = lm_tbl_plot(mdl_evo_disability);

mdl_final = fitlm(HA,'p_pedmidas_score ~ con_epi_time_cat + age + race + trigger_binary','RobustOpts','on');
tbl_Final = lm_tbl_plot(mdl_final);

%% compare no, rapid, and gradual evolution of headache to continuous (3 months continuous headache only)

[pAge3,tblAge3,statsAge3] = kruskalwallis(HA3mo.age,HA3mo.con_epi_time_cat);
[tblSex3,ChiSex3,pSex3] = crosstab(HA3mo.gender,HA3mo.con_epi_time_cat);
[pSev3,tblSev3,statsSev3] = kruskalwallis(HA3mo.p_sev_usual,HA3mo.con_epi_time_cat);
[pDis3,tblDis3,statsDis3] = kruskalwallis(HA3mo.p_pedmidas_score,HA3mo.con_epi_time_cat);
[tblICHD3,~,~] = crosstab(HA3mo.ichd3,HA3mo.con_epi_time_cat);
[tblDur3,~,~] = crosstab(removecats(HA3mo.p_con_pattern_duration),HA3mo.con_epi_time_cat);
[tblPat3,ChiPat3,pPat3] = crosstab(removecats(HA3mo.p_current_ha_pattern),HA3mo.con_epi_time_cat);
[tblEvo3,~,~] = crosstab(HA3mo.p_con_start_epi_time,HA3mo.con_epi_time_cat);
[tblTrig3,ChiTrig3,pTrig3] = crosstab(HA3mo.triggers,HA3mo.con_epi_time_cat);

