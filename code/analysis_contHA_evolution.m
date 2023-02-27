% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath 'Pfizer_DATA_20230220.mat'])

%% clean raw data

data = data_raw(data_raw.redcap_repeat_instrument~='visit_diagnoses' & ...
    data_raw.redcap_repeat_instrument~='imaging',:); % removes imaging and follow up visits

data.p_con_pattern_duration = categorical(data.p_con_pattern_duration);
data.p_con_pattern_duration = reordercats(data.p_con_pattern_duration,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});
data.p_con_start_epi_time = categorical(data.p_con_start_epi_time);
data.p_con_start_epi_time = mergecats(data.p_con_start_epi_time,{'1to2y','2to3y','3yrs'},'>1yr');
data.p_con_start_epi_time = reordercats(data.p_con_start_epi_time,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','>1yr'});

data.con_epi_time_binary = zeros(height(data),1);
data.con_epi_time_binary(data.p_con_start_epi_time == '3to6mo' | data.p_con_start_epi_time=='6to12mo' | data.p_con_start_epi_time=='>1yr') = 1;

% categorize pain quality types
data.pulsate = sum(table2array(data(:,[85 86 95])),2);
data.pulsate(data.pulsate>1) = 1;
data.pressure = sum(table2array(data(:,[88:90 93])),2);
data.pressure(data.pressure>1) = 1;
data.neuralgia = sum(table2array(data(:,[87 91 92 94])),2);
data.neuralgia(data.neuralgia>1) = 1;

ICHD3 = ichd3_Dx(data);
ICHD3.dx = reordercats(ICHD3.dx,{'migraine','prob_migraine','tth','cluster','hc','primary_stabbing','occipital_neuralgia','ndph','new_onset','pth','other'});
data.ichd3 = ICHD3.dx;
data.ICHD_data = sum(table2array(ICHD3(:,2:40)),2);

%% Apply inclusion criteria
% Find participants, 6 to 17 years old with continuous headache, without
% PTH or NDPH

Age_req = data(data.age>=6 & data.age<18,:);

% Convert age to years
Age_req.ageY = floor(Age_req.age);

% Reorder race categories to make white (largest group) the reference group
Age_req.race = reordercats(Age_req.race,{'white','black','asian','am_indian','pacific_island','no_answer','unk'});

% Reorder ethnicity categories to make non-hispanic (largest group) the
% reference group
Age_req.ethnicity = reordercats(Age_req.ethnicity,{'no_hisp','hisp','no_answer','unk'});


% Identify those with continuous headache
Cont_req = Age_req((Age_req.p_current_ha_pattern == 'cons_flare' | Age_req.p_current_ha_pattern == 'cons_same'),:);
missdata_cont = Age_req(Age_req.p_current_ha_pattern ~= 'cons_flare' & Age_req.p_current_ha_pattern ~= 'cons_same' & Age_req.p_current_ha_pattern ~= 'episodic',:);
exclude_cont = Age_req(Age_req.p_current_ha_pattern == 'episodic',:); % not included in missing since did not start questionnaire

% Get rid of entries with continuous headache for <3 months
Dur_req = Cont_req(Cont_req.p_con_pattern_duration=='1to2y'|Cont_req.p_con_pattern_duration=='2to3y'|...
    Cont_req.p_con_pattern_duration=='3to6mo'|Cont_req.p_con_pattern_duration=='3yrs'|...
    Cont_req.p_con_pattern_duration=='6to12mo',:);

missdata_dur = Cont_req(Cont_req.p_con_pattern_duration~='1to2y' & Cont_req.p_con_pattern_duration~='2to3y' & Cont_req.p_con_pattern_duration~='3to6mo' &...
    Cont_req.p_con_pattern_duration~='3yrs' & Cont_req.p_con_pattern_duration~='6to12mo' & Cont_req.p_con_pattern_duration~='2wks' & Cont_req.p_con_pattern_duration~='2to4wk' &...
    Cont_req.p_con_pattern_duration~='4to8wk' & Cont_req.p_con_pattern_duration~='8to12wk',:);
exclude_dur =  Cont_req(Cont_req.p_con_pattern_duration=='2wks' | Cont_req.p_con_pattern_duration=='2to4wk' |...
    Cont_req.p_con_pattern_duration=='4to8wk' | Cont_req.p_con_pattern_duration=='8to12wk',:);

% only include migraine and probable migraine
ICHD_req = Dur_req(Dur_req.ichd3=='migraine' | Dur_req.ichd3=='prob_migraine',:);

missdata_ichd = Dur_req(Dur_req.ICHD_data==0,:);
exclude_ichd = Dur_req(Dur_req.ICHD_data~=0 & Dur_req.ichd3~='migraine' & Dur_req.ichd3~='prob_migraine',:);

% Keep only data that includes transition to continuous
Evo_req = ICHD_req((ICHD_req.p_con_start_epi_time=='>1yr' | ICHD_req.p_con_start_epi_time=='2to4wk' |...
    ICHD_req.p_con_start_epi_time=='2wks' | ICHD_req.p_con_start_epi_time=='3to6mo' |...
    ICHD_req.p_con_start_epi_time=='4to8wk' | ICHD_req.p_con_start_epi_time=='6to12mo' | ICHD_req.p_con_start_epi_time=='8to12wk'),:);

missdata_evo = ICHD_req(ICHD_req.p_con_start_epi_time~='>1yr' & ICHD_req.p_con_start_epi_time~='2to4wk' &...
    ICHD_req.p_con_start_epi_time~='2wks' & ICHD_req.p_con_start_epi_time~='3to6mo' &...
    ICHD_req.p_con_start_epi_time~='4to8wk' & ICHD_req.p_con_start_epi_time~='6to12mo' & ICHD_req.p_con_start_epi_time~='8to12wk',:);

HA = Evo_req;


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
mdl = fitglm(HA,'con_epi_time_binary ~ ageY + gender + race + ethnicity + p_pedmidas_score + p_sev_usual + ichd3','Distribution','binomial');



%% compare missing data to non-missing data
missdata = [missdata_dur;missdata_ichd;missdata_evo];
missdata.missdata = ones(height(missdata),1);

excludedata = [exclude_cont;exclude_dur;exclude_ichd];
excludedata.missdata = zeros(height(excludedata),1);

HA.missdata = zeros(height(HA),1);

rebuild_data = [HA;excludedata;missdata];

mdl_miss = fitglm(rebuild_data,'missdata ~ ageY + gender + race + ethnicity','Distribution','binomial');