% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath '/PfizerHAdataJun17Feb22.mat'])


% Find participants, 6 to 17 years old with continuous headache, without
% PTH or NDPH
HA = data((data.p_current_ha_pattern == 'cons_flare' | data.p_current_ha_pattern == 'cons_same') & ...
    data.age>=6 & data.age<18 & data.p_dx_overall_cat~=2 & data.p_dx_overall_cat~=3 & data.p_dx_overall_cat~=6,:);

HA.miss_data = zeros(height(HA),1);

% Identify missing data
HA.miss_data((HA.p_con_start_epi_time~='1to2y' & HA.p_con_start_epi_time~='2to3y' & HA.p_con_start_epi_time~='2to4wk' &...
    HA.p_con_start_epi_time~='2wks' & HA.p_con_start_epi_time~='3to6mo' & HA.p_con_start_epi_time~='3yrs' &...
    HA.p_con_start_epi_time~='4to8wk' & HA.p_con_start_epi_time~='6to12mo') | (HA.p_con_pattern_duration~='1to2y' &...
    HA.p_con_pattern_duration~='2to3y' & HA.p_con_pattern_duration~='3to6mo' & HA.p_con_pattern_duration~='3yrs' & ...
    HA.p_con_pattern_duration~='6to12mo' & HA.p_con_pattern_duration~='2wks' & HA.p_con_pattern_duration~='2to4wk' & HA.p_con_pattern_duration~='4to8wk'),:) = 1;

contHA = HA;

% keep only complete data
HA = HA(HA.miss_data==0,:);

% Get rid of entries with continuous headache for <3 months
HA = HA(HA.p_con_pattern_duration=='1to2y'|HA.p_con_pattern_duration=='2to3y'|...
    HA.p_con_pattern_duration=='3to6mo'|HA.p_con_pattern_duration=='3yrs'|...
    HA.p_con_pattern_duration=='6to12mo',:);


HA.allodynia = sum(table2array(HA(:,191:194)),2);
HA.allodynia(HA.allodynia>0) = 1;

HA.pulsate = sum(table2array(HA(:,[123 124 133])),2);
HA.pulsate(HA.pulsate>1) = 1;
HA.pressure = sum(table2array(HA(:,[126:128 131])),2);
HA.pressure(HA.pressure>1) = 1;
HA.neuralgia = sum(table2array(HA(:,[125 129 130 132])),2);
HA.neuralgia(HA.neuralgia>1) = 1;

[HA_severity] = prctile(HA.p_sev_usual,[25 50 75]);
[pedmidas] = prctile(HA.p_pedmidas_score,[25 50 75]);



%% evolution of headache to continuous

figure
A = HA.p_con_start_epi_time;
B = reordercats(A,{'2wks','2to4wk','4to8wk','3to6mo','6to12mo','1to2y','2to3y','3yrs'});
histogram(B,'Normalization','probability')
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

% ICHD diagnosis
migr = HA(HA.p_migraine_ichd==1 & HA.p_dx_overall_cat==1 & HA.p_dx_overall_pheno<4,:);
pmigr = HA(HA.p_migraine_ichd==0 & HA.p_dx_overall_cat==1 & HA.p_dx_overall_pheno<4,:);
tth = HA(HA.p_dx_overall_cat==1 & (HA.p_dx_overall_pheno==5|HA.p_dx_overall_pheno==6),:);
tac = HA(HA.p_dx_overall_cat==1 & HA.p_dx_overall_pheno==4,:);

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
[tblSex_m,chi2Sex_m,pSex_m] = crosstab(contHA.miss_data,contHA.gender);
[tblEth_m,chi2Eth_m,pEth_m] = crosstab(contHA.miss_data,removecats(contHA.ethnicity));
[tblRace_m,chi2Race_m,pRace_m] = crosstab(contHA.miss_data,removecats(contHA.race));
[pAge_m,tblAge_m,statsAge_m] = kruskalwallis(contHA.age,contHA.miss_data);