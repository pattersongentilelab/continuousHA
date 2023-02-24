% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath 'Pfizer_DATA_20230220.mat'])

%% clean raw data

data = data_raw(data_raw.redcap_repeat_instrument~='visit_diagnoses' & ...
    data_raw.redcap_repeat_instrument~='imaging',:); % removes imaging and follow up visits

data.p_con_pattern_duration = categorical(data.p_con_pattern_duration);
data.p_con_pattern_duration = reordercats(data.p_con_pattern_duration,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});
data.p_con_start_epi_time = categorical(data.p_con_start_epi_time);
data.p_con_start_epi_time = reordercats(data.p_con_start_epi_time,{'2wks','2to4wk','4to8wk','8to12wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});

% categorize pain quality types
data.pulsate = sum(table2array(data(:,[85 86 95])),2);
data.pulsate(data.pulsate>1) = 1;
data.pressure = sum(table2array(data(:,[88:90 93])),2);
data.pressure(data.pressure>1) = 1;
data.neuralgia = sum(table2array(data(:,[87 91 92 94])),2);
data.neuralgia(data.neuralgia>1) = 1;

ICHD3 = ichd3_Dx(data);
ICHD3.dx = reordercats(ICHD3.dx,{'migraine','prob_migraine','tth','tac','ndph_no','pth','other'});
data.ichd3 = ICHD3.dx;

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

% Creat placeholder to identify missing data
Age_req.missdata = zeros(height(Age_req),1);

% Identify those with continuous headache
Cont_req = Age_req((Age_req.p_current_ha_pattern == 'cons_flare' | Age_req.p_current_ha_pattern == 'cons_same'),:);

Age_req.missdata((Age_req.p_current_ha_pattern ~= 'cons_flare' & Age_req.p_current_ha_pattern ~= 'cons_same' & Age_req.p_current_ha_pattern ~= 'episodic'),:) = 1;

% Get rid of entries with continuous headache for <3 months
Dur_req = Cont_req(Cont_req.p_con_pattern_duration=='1to2y'|Cont_req.p_con_pattern_duration=='2to3y'|...
    Cont_req.p_con_pattern_duration=='3to6mo'|Cont_req.p_con_pattern_duration=='3yrs'|...
    Cont_req.p_con_pattern_duration=='6to12mo',:);

Age_req.missdata(Age_req.p_current_ha_pattern ~= 'episodic' & Age_req.p_con_pattern_duration~='1to2y' & Age_req.p_con_pattern_duration~='2to3y' & Age_req.p_con_pattern_duration~='3to6mo' &...
    Age_req.p_con_pattern_duration~='3yrs' & Age_req.p_con_pattern_duration~='6to12mo' & Age_req.p_con_pattern_duration~='2wks' & Age_req.p_con_pattern_duration~='2to4wk' &...
    Age_req.p_con_pattern_duration~='4to8wk' & Age_req.p_con_pattern_duration~='8to12wk') = 1;

% only include migraine and probable migraine
ICHD_req = Dur_req(Dur_req.ichd3=='migraine' | Dur_req.ichd3=='prob_migraine',:);

% Keep only data that includes transition to continuous
Evo_req = ICHD_req((ICHD_req.p_con_start_epi_time=='1to2y' | ICHD_req.p_con_start_epi_time=='2to3y' | ICHD_req.p_con_start_epi_time=='2to4wk' |...
    ICHD_req.p_con_start_epi_time=='2wks' | ICHD_req.p_con_start_epi_time=='3to6mo' | ICHD_req.p_con_start_epi_time=='3yrs' |...
    ICHD_req.p_con_start_epi_time=='4to8wk' | ICHD_req.p_con_start_epi_time=='6to12mo' | ICHD_req.p_con_start_epi_time=='8to12wk'),:);

Age_req.missdata((Age_req.p_current_ha_pattern ~= 'episodic' & Age_req.p_con_start_epi_time~='1to2y' & Age_req.p_con_start_epi_time~='2to3y' & Age_req.p_con_start_epi_time~='2to4wk' &...
    Age_req.p_con_start_epi_time~='2wks' & Age_req.p_con_start_epi_time~='3to6mo' & Age_req.p_con_start_epi_time~='3yrs' &...
    Age_req.p_con_start_epi_time~='4to8wk' & Age_req.p_con_start_epi_time~='6to12mo' & Age_req.p_con_start_epi_time~='8to12wk' &...
    Age_req.ichd3~='tac' & Age_req.ichd3~='tth' & Age_req.ichd3~='ndph_no' & Age_req.ichd3~='pth'),:) = 1;

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
X = [HA.gender HA.age HA.p_sev_usual HA.p_pedmidas_score HA.allodynia];
Y = ordinal(HA.p_con_start_epi_time,{'1','2','3','4','5','6','7','8'},{'2wks','2to4wk','4to8wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});

verbose = false;
y = double(Y);
[tblSex,chi2Sex,pSex] = crosstab(Y,HA.gender,Y);
[tblAld,chi2Ald,pAld] = crosstab(HA.allodynia,Y);
[tblSev,statsSev,pSev] = kruskalwallis(y,HA.p_sev_usual);
[pPM,tblPM,statsPM] = kruskalwallis(y,HA.p_pedmidas_score);
[pAge,tblAge,statsAge] = kruskalwallis(y,HA.age);

[B,dev,stats] = mnrfit(X,Y,'model','ordinal');


%% compare missing data to non-missing data
[tblSex_m,chi2Sex_m,pSex_m] = crosstab(Age_req.missdata,Age_req.gender);
[tblEth_m,chi2Eth_m,pEth_m] = crosstab(Age_req.missdata,removecats(Age_req.ethnicity));
[tblRace_m,chi2Race_m,pRace_m] = crosstab(Age_req.missdata,removecats(Age_req.race));
[pAge_m,tblAge_m,statsAge_m] = kruskalwallis(Age_req.age,Age_req.missdata);


mdl = fitglm(Age_req,'missdata ~ ageY + gender + race + ethnicity','Distribution','binomial');