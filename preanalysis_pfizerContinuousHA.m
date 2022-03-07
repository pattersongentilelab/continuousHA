% Pre-analysis of continuous headache subjects from Pfizer headache
% registry, for case-control study comparing PPTH, NDPH, and Migraine

load PfizerHAdata

% calculate age at the time of filling out the form in days
data.ageDays = datenum(data.visit_dt)-datenum(data.dob);

% create a variable for the number of prescription preventive medications
% tried
data.num_prescr_prevent = sum(table2array(data(:,[318:321 323:332 335:343])),2);

% Find participants, 6 to 17 years old - current dataset does not have current age - with continuous headache for 3
% months to 1 year from onset, and have tried 2 or less preventive medications
contHA = data(data.p_current_ha_pattern == 'cons_flare' & ...
    (data.p_con_pattern_duration == '3to6mo' | data.p_con_pattern_duration == '6to12mo')...
    & data.num_prescr_prevent<3 & data.ageDays>=2160 & data.ageDays<6480,:);

clear data

% Separate out NDPH, Migraine, and PPTH

migraine = contHA(contHA.p_dx_overall_cat == 1 & contHA.p_dx_overall_pheno<4 & (contHA.p_con_start_epi_time =='4to8wk' | ...
    contHA.p_con_start_epi_time =='3to6mo' | contHA.p_con_start_epi_time =='6to12mo' | contHA.p_con_start_epi_time =='1to2y' | ...
    contHA.p_con_start_epi_time =='2to3y' | contHA.p_con_start_epi_time =='3yrs'),:);
ndph = contHA(contHA.p_dx_overall_cat == 3,:);
ppth = contHA(contHA.p_dx_overall_cat == 6 & contHA.p_con_prec___conc == 1 & contHA.p_con_start_epi_time ~='3yrs' ...
    & contHA.p_con_start_epi_time ~='1to2y' & contHA.p_con_start_epi_time ~='2to3y' & contHA.p_con_start_epi_time ~='3to6mo' ...
    & contHA.p_con_start_epi_time ~='6to12mo',:);

% gender and age
figure
subplot(1,2,1)
histogram(contHA.age)

subplot(1,2,2)
histogram(contHA.gender,'Normalization','probability')

%randomly order ppth subjects
ppth_randperm = ppth(randperm(height(ppth)),:);

% order males first to maximize the number of males included
ppth_randperm = sortrows(ppth_randperm,1122,'descend');


% Select case control subjects, with ppth as the comparator group since it
% has the fewest number of subjects, stopping once there are 50 subjects
% per group

ppth_pool = ppth;
migraine_pool = migraine;
ndph_pool = ndph;

counter = 0;
x = 1;
while x<51
    counter = counter+1;
    sP = ppth_randperm(counter,:);
%     sprintf('biological sex = %1.1f, age (days) = %4.1f ', [sP.gender sP.ageDays])
    
    tempM = migraine_pool(migraine_pool.gender == sP.gender,:);
    age_diffM = abs(diff([tempM.ageDays sP.ageDays*ones(height(tempM),1)],1,2));
    sM = tempM(find(age_diffM==min(age_diffM)),:);
%     sprintf('biological sex = %1.1f, age (days) = %4.1f ', [sM(1,:).gender sM(1,:).ageDays])
    
    tempN = ndph_pool(ndph_pool.gender == sP.gender,:);
    age_diffN = abs(diff([tempN.ageDays sP.ageDays*ones(height(tempN),1)],1,2));
    sN = tempN(find(age_diffN==min(age_diffN) & isnan(tempN.p_sev_usual)==0),:);
%     sprintf('biological sex = %1.1f, age (days) = %4.1f ', [sN(1,:).gender sN(1,:).ageDays])
   
    
    if min(age_diffN)>120 || min(age_diffM)>120 || isnan(sP(1,:).p_sev_usual) || isnan(sN(1,:).p_sev_usual) || isnan(sM(1,:).p_sev_usual)
        disp('no match')
       continue
    end
    
        % compile case-control subjects
        ppth_case(x,:) = sP;
        ndph_case(x,:) = sN(1,:);
        migraine_case(x,:) = sM(1,:);
        
        % remove case-control subjects from pools
        ppth_pool = ppth_pool(ppth_pool.record_id ~= sP.record_id,:);
        migraine_pool = migraine_pool(migraine_pool.record_id ~= sM(1,:).record_id,:);
        ndph_pool = ndph_pool(ndph_pool.record_id ~= sN(1,:).record_id,:);
    
    clear age_diffN age_diffM sN sP sM temp*
    
    x = x+1;
        
    if counter==height(ppth)-1
        break
    end
end

save continuousHAcasecontrol_clean ppth_case ndph_case migraine_case
save continuousHApool_clean ppth_pool ndph_pool migraine_pool