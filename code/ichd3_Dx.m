% Determines ICHD3 diagnoses based on patient questionnaire
function [ICHD3] = ichd3_Dx(tbl)
        
%% Migraine features
        
        
        ICHD3 = tbl(:,1);
        
        ICHD3.focal = zeros(height(tbl),1);
        ICHD3.focal(tbl.p_location_side___right==1|tbl.p_location_side___left==1) = 1;
        ICHD3.focal(tbl.p_location_area___sides==1|tbl.p_location_area___front==1|...
            tbl.p_location_area___back==1|tbl.p_location_area___around==1|tbl.p_location_area___behind==1 ... 
            |tbl.p_location_area___top==1|tbl.p_location_area___oth==1) = 1;
        
        ICHD3.bilateral = zeros(height(tbl),1);
        ICHD3.bilateral(tbl.p_location_side___both==1) = 1;
        
        ICHD3.aura_vis = zeros(height(tbl),1);
        ICHD3.aura_vis (tbl.p_assoc_sx_vis___spot==1|tbl.p_assoc_sx_vis___star==1|tbl.p_assoc_sx_vis___light==1|...
            tbl.p_assoc_sx_vis___zigzag==1|tbl.p_assoc_sx_vis___heat==1|tbl.p_assoc_sx_vis___loss_vis==1) = 1;
        ICHD3.aura_sens = zeros(height(tbl),1);
        ICHD3.aura_sens(tbl.p_assoc_sx_neur_uni___numb==1|tbl.p_assoc_sx_neur_uni___tingle==1) = 1;
        ICHD3.aura_sens(tbl.p_assoc_sx_neur_bil___numb==1|tbl.p_assoc_sx_neur_bil___tingle==1) = 0;
        ICHD3.aura_speech = zeros(height(tbl),1);
        ICHD3.aura_speech(tbl.p_assoc_sx_oth_sx___talk==1) = 1;
        ICHD3.aura_weak = zeros(height(tbl),1);
        ICHD3.aura_weak(tbl.p_assoc_sx_neur_uni___weak==1 & tbl.p_assoc_sx_neur_bil___weak==0) = 1;
        ICHD3.aura_brainstem = sum([tbl.p_assoc_sx_oth_sx___talk tbl.p_assoc_sx_oth_sx___spinning tbl.p_assoc_sx_oth_sx___ringing tbl.p_assoc_sx_oth_sx___hear...
            tbl.p_assoc_sx_oth_sx___unrespons tbl.p_assoc_sx_oth_sx___balance tbl.p_assoc_sx_vis___double_vis],2);
        ICHD3.aura_brainstem(ICHD3.aura_brainstem==1) = 0;
        ICHD3.aura_brainstem(ICHD3.aura_brainstem>1) = 1;
        ICHD3.aura = zeros(height(tbl),1);
        ICHD3.aura(ICHD3.aura_sens==1|ICHD3.aura_vis==1|ICHD3.aura_speech==1|ICHD3.aura_weak==1|ICHD3.aura_brainstem==1) = 1;
        
        ICHD3.pulsate = tbl.pulsate;
        ICHD3.pressure = tbl.pressure;
        
        ICHD3.photophobia = zeros(height(tbl),1);
        ICHD3.photophobia(tbl.p_assoc_sx_oth_sx___light==1|tbl.p_trigger___light==1) = 1;
        
        ICHD3.phonophobia = zeros(height(tbl),1);
        ICHD3.phonophobia(tbl.p_assoc_sx_oth_sx___sound==1|tbl.p_trigger___noises==1) = 1;
        
        ICHD3.nausea_vomiting(tbl.p_assoc_sx_gi___naus==1|tbl.p_assoc_sx_gi___vomiting==1) = 1;
        
        ICHD3.mig_sev = zeros(height(tbl),1);
        ICHD3.mig_sev(tbl.p_sev_overall=='mod'|tbl.p_sev_overall=='sev'|tbl.p_sev_usual>3) = 1;
        
        
        ICHD3.activity = zeros(height(tbl),1);
        ICHD3.activity(tbl.p_trigger___exercise==1|tbl.p_activity=='feel_worse') = 1;
        
        ICHD3.mig_char = sum([ICHD3.focal ICHD3.mig_sev ICHD3.pulsate ICHD3.activity],2);
        
        ICHD3.mig_dur = zeros(height(tbl),1);
        ICHD3.mig_dur(tbl.p_sev_dur=='3days'|tbl.p_sev_dur=='1to3d'|tbl.p_sev_dur=='hrs') = 1;
        
        ICHD3.mig_num = zeros(height(tbl),1);
        ICHD3.mig_num(tbl.p_ha_in_lifetime=='many' | (tbl.p_ha_in_lifetime=='few' & ICHD3.aura==1)) = 1;
        
        ICHD3.photophono = sum([ICHD3.photophobia ICHD3.phonophobia],2);
        
        ICHD3.mig_assocSx = zeros(height(tbl),1);
        ICHD3.mig_assocSx(ICHD3.photophono==2) = 1;
        ICHD3.mig_assocSx(ICHD3.nausea_vomiting==1) = 1;
        
        % determine migraine score, 4 is migraine, 3 is probable migraine
        ICHD3.mig_score = zeros(height(tbl),1);
        ICHD3.mig_score(ICHD3.mig_num==1) = ICHD3.mig_score(ICHD3.mig_num==1)+1; % criteria A of migraine ICHD3
        ICHD3.mig_score(ICHD3.mig_dur==1) = ICHD3.mig_score(ICHD3.mig_dur==1)+1; % criteria B of migraine ICHD3
        ICHD3.mig_score(ICHD3.mig_char>=2) = ICHD3.mig_score(ICHD3.mig_char>=2)+1; % criteria C of migraine ICHD3
        ICHD3.mig_score(ICHD3.mig_assocSx==1) = ICHD3.mig_score(ICHD3.mig_assocSx==1)+1; % criteria D of migraine ICHD3
 

        ICHD3.migraine = zeros(height(tbl),1);
        ICHD3.migraine(ICHD3.mig_score==4) = 1;
        
        ICHD3.probable_migraine = zeros(height(tbl),1);
        ICHD3.probable_migraine(ICHD3.mig_score==3) = 1;
        
        ICHD3.migraine_aura = zeros(height(tbl),1);
        ICHD3.migraine_aura(ICHD3.migraine==1 & ICHD3.aura==1) = 1;
        
        % determine if chronic
        ICHD3.chronic = zeros(height(tbl),1);
        ICHD3.chronic((tbl.p_con_pattern_duration=='3yrs'|tbl.p_con_pattern_duration=='1to2yr'|tbl.p_con_pattern_duration=='6to12mo'|...
            tbl.p_con_pattern_duration=='3to6mo'|tbl.p_epi_fre_dur=='3mo') & (tbl.p_fre_bad=='2to3wk'|tbl.p_fre_bad=='3wk'|tbl.p_fre_bad=='daily'|...
            tbl.p_fre_bad=='always')) = 1;
        
 
        %% Tension type headache criteria
        
        ICHD3.tth_dur(tbl.p_sev_dur=='3days'|tbl.p_sev_dur=='1to3d'|tbl.p_sev_dur=='hrs'|tbl.p_sev_dur=='mins') = 1;
        
        ICHD3.tth_char = zeros(height(tbl),1);
        ICHD3.tth_char(tbl.p_location_side___both==1) = ICHD3.tth_char(tbl.p_location_side___both==1)+1;
        ICHD3.tth_char(ICHD3.pressure==1 & ICHD3.pulsate==0) = ICHD3.tth_char(ICHD3.pressure==1 & ICHD3.pulsate==0)+1;
        ICHD3.tth_char(tbl.p_sev_overall=='mild' | tbl.p_sev_overall=='mod' | tbl.p_sev_usual<7) = ICHD3.tth_char(tbl.p_sev_overall=='mild' | tbl.p_sev_overall=='mod' | tbl.p_sev_usual<7)+1;
        ICHD3.tth_char(tbl.p_activity=='feel_better' | tbl.p_activity=='no_change') = ICHD3.tth_char(tbl.p_activity=='feel_better' | tbl.p_activity=='no_change')+1;

        % determine if tension-type headache
        ICHD3.tth_score = zeros(height(tbl),1);
        ICHD3.tth_score(ICHD3.mig_num==1) = ICHD3.tth_score(ICHD3.mig_num==1)+1; % criteria A of tth ICHD3
        ICHD3.tth_score(ICHD3.tth_dur==1) = ICHD3.tth_score(ICHD3.tth_dur==1)+1; % criteria B of tth ICHD3 of headache lasting 30 min to days
        ICHD3.tth_score(ICHD3.tth_char>=2) = ICHD3.tth_score(ICHD3.tth_char>=2)+1; % criteria C of tth ICHD3
        ICHD3.tth_score(ICHD3.mig_assocSx==0) = ICHD3.tth_score(ICHD3.mig_assocSx==0)+1; % criteria D
        
        ICHD3.tth = zeros(height(tbl),1);
        ICHD3.tth(ICHD3.tth_score==4) = 1;
        
        %% TAC
        ICHD3.unilateral_sideLocked = zeros(height(tbl),1);        
        ICHD3.unilateral_sideLocked(tbl.p_location_side___right==0 & tbl.p_location_side___left==1) = 1; % can also have bilateral headache
        ICHD3.unilateral_sideLocked(tbl.p_location_side___right==1 & tbl.p_location_side___left==0) = 1;
        
        % unilateral autonomic features
        ICHD3.uni_autonomic_only((tbl.p_assoc_sx_neur_uni___red_eye==1 & tbl.p_assoc_sx_neur_bil___red_eye==0) | (tbl.p_assoc_sx_neur_uni___tear==1 & tbl.p_assoc_sx_neur_bil___tear==0) |...
            (tbl.p_assoc_sx_neur_uni___run_nose==1 & tbl.p_assoc_sx_neur_bil___run_nose==0) | (tbl.p_assoc_sx_neur_uni___puff_eye==1 & tbl.p_assoc_sx_neur_bil___puff_eye==0) |...
            (tbl.p_assoc_sx_neur_uni___sweat==1 & tbl.p_assoc_sx_neur_bil___sweat==0) | (tbl.p_assoc_sx_neur_uni___flush==1 & tbl.p_assoc_sx_neur_bil___flush==0) |...
            (tbl.p_assoc_sx_neur_uni___full_ear==1 & tbl.p_assoc_sx_neur_bil___full_ear==0) | (tbl.p_assoc_sx_neur_uni___ptosis==1 & tbl.p_assoc_sx_neur_bil___ptosis==0) |...
            tbl.p_assoc_sx_neur_uni___pupilbig==1) = 1;
        
        ICHD3.hc_dur = zeros(height(tbl),1);
        
        ICHD3.hc_dur(tbl.p_con_pattern_duration=='3to6mo' | tbl.p_con_pattern_duration=='6to12mo' | tbl.p_con_pattern_duration=='1to2y' | tbl.p_con_pattern_duration=='2to3y' |...
            tbl.p_con_pattern_duration=='3yrs' | tbl.p_epi_fre_dur=='3mo') = 1;
        
        % This HC code agrees with CLS 3/6/23
        ICHD3.hc = zeros(height(tbl),1);
        ICHD3.hc(ICHD3.unilateral_sideLocked==1 & (ICHD3.uni_autonomic_only==1 | tbl.p_activity=='feel_worse' | tbl.p_activity=='move' | tbl.p_trigger___exercise==1) & ...
            ICHD3.hc_dur==1 & ICHD3.mig_sev==1) = 1;
        
        ICHD3.cluster = zeros(height(tbl),1);
        ICHD3.cluster(ICHD3.unilateral_sideLocked==1 & (tbl.p_location_area___sides==1|tbl.p_location_area___front==1 |...
            tbl.p_location_area___around==1 | tbl.p_location_area___behind==1) & tbl.p_ha_in_lifetime=='many' & (tbl.p_sev_overall=='sev' |...
            tbl.p_sev_usual>=7) & (tbl.p_sev_dur=='hrs' | tbl.p_sev_dur=='mins') & (tbl.p_epi_fre=='2to3wk' | tbl.p_epi_fre=='3wk' | tbl.p_epi_fre=='daily') & ...
            (ICHD3.uni_autonomic_only==1 | tbl.p_activity=='move')) = 1;

        %% Primary stabbing headache
        ICHD3.psh = zeros(height(tbl),1);
        ICHD3.psh(tbl.p_sev_dur=='secs' & ICHD3.uni_autonomic_only==0  & (tbl.p_ha_quality___stab==1 | tbl.p_ha_quality___sharp==1)) = 1;

        
        %% Occipital neuralgia
        ICHD3.on = zeros(height(tbl),1);
        ICHD3.on(tbl.p_location_area___back==1 & (tbl.p_sev_dur=='secs' | tbl.p_sev_dur=='mins') & (tbl.p_sev_overall=='sev' |...
            tbl.p_sev_usual>=7) & (tbl.p_ha_quality___stab==1 | tbl.p_ha_quality___sharp==1)) = 1;
        ICHD3.on(tbl.p_location_area___sides==1 | tbl.p_location_area___front==1 | tbl.p_location_area___around==1 |...
            tbl.p_location_area___behind==1 | tbl.p_location_area___allover==1) = 0;

        %% Criteria for PTH
        ICHD3.pth = zeros(height(tbl),1);
        ICHD3.pth(tbl.p_epi_prec___conc==1 | tbl.p_epi_inc_fre_prec___conc==1 | tbl.p_con_st_epi_prec_ep___conc==1 | tbl.p_con_prec___conc==1) = 1;
        
        %% Criteria for NDPH/new onset
        ICHD3.ndph = zeros(height(tbl),1);
        ICHD3.ndph((tbl.p_current_ha_pattern=='cons_same' | tbl.p_current_ha_pattern=='cons_flare') &...
            (tbl.p_pattern_to_con=='none' | tbl.p_pattern_to_con=='rare') & (~isnat(tbl.p_con_start_date) |...
            ~isnan(tbl.p_con_start_age)) & (tbl.p_con_pattern_duration=='3to6mo' | tbl.p_con_pattern_duration=='6to12mo' |...
            tbl.p_con_pattern_duration=="1to2y" | tbl.p_con_pattern_duration=='2to3y' | tbl.p_con_pattern_duration=='3yrs') &...
            tbl.p_con_prec___conc==0 & tbl.p_con_prec___oth_inj==0) = 1;

        ICHD3.new_onset = zeros(height(tbl),1);
        ICHD3.new_onset((tbl.p_current_ha_pattern=='cons_same' | tbl.p_current_ha_pattern=='cons_flare') &...
            (tbl.p_pattern_to_con=='none' | tbl.p_pattern_to_con=='rare') & (~isnat(tbl.p_con_start_date) |...
            ~isnan(tbl.p_con_start_age)) & (tbl.p_con_pattern_duration=='2wks' | tbl.p_con_pattern_duration=='2to4wk' |...
            tbl.p_con_pattern_duration=='4to8wk' | tbl.p_con_pattern_duration=='8to12wk') & tbl.p_con_prec___conc==0 & tbl.p_con_prec___oth_inj==0) = 1;
        
        
        %% phenotype
        
        ICHD3.pheno = zeros(height(tbl),1);
        ICHD3.pheno(ICHD3.tth==1) = 4;
        ICHD3.pheno(ICHD3.psh==1) = 6;
        ICHD3.pheno(ICHD3.on==1) = 6;
        ICHD3.pheno(ICHD3.probable_migraine==1) = 2;
        ICHD3.pheno(ICHD3.migraine==1) = 1;
        ICHD3.pheno(ICHD3.aura==1 & ICHD3.mig_num==1) = 3;
        ICHD3.pheno(ICHD3.cluster==1) = 5;
        ICHD3.pheno(ICHD3.hc==1) = 5;
        
        ICHD3.pheno = categorical(ICHD3.pheno,[0 1 2 3 4 5 6],{'undefined','migraine','prob_migraine','migraine_aura','tth','tac','other_primary'});
        %% final diagnosis
        
        ICHD3.dx = zeros(height(tbl),1);
        ICHD3.dx(ICHD3.tth==1) = 4;
        ICHD3.dx(ICHD3.on==1) = 6;
        ICHD3.dx(ICHD3.psh==1) = 6;
        ICHD3.dx(ICHD3.probable_migraine==1) = 2;
        ICHD3.dx(ICHD3.migraine==1) = 1;
        ICHD3.dx(ICHD3.aura==1 & ICHD3.mig_num==1) = 3;
        ICHD3.dx(ICHD3.cluster==1) = 5;
        ICHD3.dx(ICHD3.hc==1) = 5;
        ICHD3.dx(ICHD3.new_onset==1) = 7;
        ICHD3.dx(ICHD3.ndph==1) = 8;
        ICHD3.dx(ICHD3.pth==1) = 9;
        
        
        ICHD3.dx = categorical(ICHD3.dx,[0 1 2 3 4 5 6 7 8 9],{'undefined','migraine','prob_migraine','migraine_aura','tth','tac','other_primary','new_onset','ndph','pth'});
        
end
