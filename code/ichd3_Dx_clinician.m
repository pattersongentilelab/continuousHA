% Determines ICHD3 diagnoses based on patient questionnaire
function [ICHD3] = ichd3_Dx_clinician(tbl)
        
%% Migraine features
        
        
        ICHD3 = tbl(:,1);
        
        ICHD3.focal = zeros(height(tbl),1);
        ICHD3.focal(tbl.c_location_side___right==1|tbl.c_location_side___left==1) = 1;
        ICHD3.focal(tbl.c_location_area___sides==1|tbl.c_location_area___front==1|...
            tbl.c_location_area___back==1|tbl.c_location_area___around==1|tbl.c_location_area___behind==1 ... 
            |tbl.c_location_area___top==1|tbl.c_location_area___oth==1) = 1;
        
        ICHD3.bilateral = zeros(height(tbl),1);
        ICHD3.bilateral(tbl.c_location_side___both==1) = 1;
        
        ICHD3.pulsate_c = tbl.pulsate_c;
        ICHD3.pressure_c = tbl.pressure_c;
        
        ICHD3.photophobia = zeros(height(tbl),1);
        ICHD3.photophobia(tbl.c_assoc_sx_oth_sx___light==1|tbl.c_trigger___light==1) = 1;
        
        ICHD3.phonophobia = zeros(height(tbl),1);
        ICHD3.phonophobia(tbl.c_assoc_sx_oth_sx___sound==1|tbl.c_trigger___noises==1) = 1;
        
        ICHD3.nausea_vomiting(tbl.c_assoc_sx_gi___naus==1|tbl.c_assoc_sx_gi___vomiting==1) = 1;
        
        ICHD3.mig_sev = zeros(height(tbl),1);
        ICHD3.mig_sev(tbl.c_sev_overall=='mod'|tbl.c_sev_overall=='sev'|tbl.c_sev_usual>3) = 1;
        
        
        ICHD3.activity = zeros(height(tbl),1);
        ICHD3.activity(tbl.c_trigger___exercise==1|tbl.c_activity=='feel_worse') = 1;
        
        ICHD3.mig_char = sum([ICHD3.focal ICHD3.mig_sev ICHD3.pulsate_c ICHD3.activity],2);
        
        ICHD3.mig_dur = zeros(height(tbl),1);
        ICHD3.mig_dur(tbl.c_sev_dur=='3days'|tbl.c_sev_dur=='1to3d'|tbl.c_sev_dur=='hrs') = 1;
        
        ICHD3.mig_num = zeros(height(tbl),1);
        ICHD3.mig_num(tbl.c_ha_in_lifetime=='many') = 1;
        
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


        ICHD3.aura_vis = zeros(height(tbl),1);
        ICHD3.aura_vis (tbl.c_assoc_sx_vis___spot==1|tbl.c_assoc_sx_vis___star==1|tbl.c_assoc_sx_vis___light==1|...
            tbl.c_assoc_sx_vis___zigzag==1|tbl.c_assoc_sx_vis___heat==1|tbl.c_assoc_sx_vis___loss_vis==1) = 1;
        
        ICHD3.aura_sens = zeros(height(tbl),1);
        ICHD3.aura_sens(tbl.c_assoc_sx_neur_uni___numb==1|tbl.c_assoc_sx_neur_uni___tingle==1) = 1;
        
        ICHD3.aura_speech = zeros(height(tbl),1);
        ICHD3.aura_speech(tbl.c_assoc_sx_oth_sx___talk==1) = 1;
        
        ICHD3.aura_weak = zeros(height(tbl),1);
        ICHD3.aura_weak(tbl.c_assoc_sx_neur_uni___weak==1) = 1;
        
        ICHD3.aura = zeros(height(tbl),1);
        ICHD3.aura(ICHD3.aura_sens==1|ICHD3.aura_vis==1|ICHD3.aura_speech==1|ICHD3.aura_weak==1) = 1;
 

        ICHD3.migraine = zeros(height(tbl),1);
        ICHD3.migraine(ICHD3.mig_score==4) = 1;
        
        ICHD3.probable_migraine = zeros(height(tbl),1);
        ICHD3.probable_migraine(ICHD3.mig_score==3) = 1;
        
        ICHD3.migraine_aura = zeros(height(tbl),1);
        ICHD3.migraine_aura(ICHD3.migraine==1 & ICHD3.aura==1) = 1;
        
        ICHD3.chronic_migraine = zeros(height(tbl),1);
        ICHD3.chronic_migraine((ICHD3.migraine==1) & (tbl.c_fre_bad=='2to3wk'|tbl.c_fre_bad=='3wk'|tbl.c_fre_bad=='daily'|tbl.c_fre_bad=='always')) = 1;
        
        ICHD3.chronic_probable_migraine = zeros(height(tbl),1);
        ICHD3.chronic_probable_migraine(ICHD3.probable_migraine==1 & (tbl.c_fre_bad=='2to3wk'|tbl.c_fre_bad=='3wk'|tbl.c_fre_bad=='daily'|tbl.c_fre_bad=='always')) = 1;
        
        ICHD3.probable_migraine_aura = zeros(height(tbl),1);
        ICHD3.probable_migraine_aura(ICHD3.probable_migraine==1 & ICHD3.aura==1) = 1;
 
        %% Tension type headache criteria
        
        ICHD3.tth_dur(tbl.c_sev_dur=='3days'|tbl.c_sev_dur=='1to3d'|tbl.c_sev_dur=='hrs'|tbl.c_sev_dur=='mins') = 1;
        
        ICHD3.tth_char = zeros(height(tbl),1);
        ICHD3.tth_char(tbl.c_location_side___both==1) = ICHD3.tth_char(tbl.c_location_side___both==1)+1;
        ICHD3.tth_char(ICHD3.pressure_c==1 & ICHD3.pulsate_c==0) = ICHD3.tth_char(ICHD3.pressure_c==1 & ICHD3.pulsate_c==0)+1;
        ICHD3.tth_char(tbl.c_sev_overall=='mild' | tbl.c_sev_overall=='mod' | tbl.c_sev_usual<7) = ICHD3.tth_char(tbl.c_sev_overall=='mild' | tbl.c_sev_overall=='mod' | tbl.c_sev_usual<7)+1;
        ICHD3.tth_char(tbl.c_activity=='feel_better' | tbl.c_activity=='no_change') = ICHD3.tth_char(tbl.c_activity=='feel_better' | tbl.c_activity=='no_change')+1;

        % determine if tension-type headache
        ICHD3.tth_score = zeros(height(tbl),1);
        ICHD3.tth_score(ICHD3.mig_num==1) = ICHD3.tth_score(ICHD3.mig_num==1)+1; % criteria A of tth ICHD3
        ICHD3.tth_score(ICHD3.tth_dur==1) = ICHD3.tth_score(ICHD3.tth_dur==1)+1; % criteria B of tth ICHD3 of headache lasting 30 min to days
        ICHD3.tth_score(ICHD3.tth_char>=2) = ICHD3.tth_score(ICHD3.tth_char>=2)+1; % criteria C of tth ICHD3
        ICHD3.tth_score(ICHD3.photophono<2 & ICHD3.nausea_vomiting==0) = ICHD3.tth_score(ICHD3.photophono<2 & ICHD3.nausea_vomiting==0)+1; % criteria D
        
        ICHD3.tth = zeros(height(tbl),1);
        ICHD3.tth(ICHD3.tth_score==4) = 1;
        
        %% TAC
        ICHD3.unilateral_sideLocked = zeros(height(tbl),1);        
        ICHD3.unilateral_sideLocked(tbl.c_location_side___right==0 & tbl.c_location_side___left==1) = 1; % can also have bilateral headache
        ICHD3.unilateral_sideLocked(tbl.c_location_side___right==1 & tbl.c_location_side___left==0) = 1;
        
        % unilateral autonomic features
        ICHD3.uni_autonomic_only((tbl.c_assoc_sx_neur_uni___red_eye==1 & tbl.c_assoc_sx_neur_bil___red_eye==0) | (tbl.c_assoc_sx_neur_uni___tear==1 & tbl.c_assoc_sx_neur_bil___tear==0) |...
            (tbl.c_assoc_sx_neur_uni___run_nose==1 & tbl.c_assoc_sx_neur_bil___run_nose==0) | (tbl.c_assoc_sx_neur_uni___puff_eye==1 & tbl.c_assoc_sx_neur_bil___puff_eye==0) |...
            (tbl.c_assoc_sx_neur_uni___sweat==1 & tbl.c_assoc_sx_neur_bil___sweat==0) | (tbl.c_assoc_sx_neur_uni___flush==1 & tbl.c_assoc_sx_neur_bil___flush==0) |...
            (tbl.c_assoc_sx_neur_uni___full_ear==1 & tbl.c_assoc_sx_neur_bil___full_ear==0) | (tbl.c_assoc_sx_neur_uni___ptosis==1 & tbl.c_assoc_sx_neur_bil___ptosis==0) |...
            tbl.c_assoc_sx_neur_uni___pupilbig==1) = 1;
        
        
        tbl.c_con_pattern_duration = categorical(tbl.c_con_pattern_duration);
        ICHD3.hc = zeros(height(tbl),1);
        ICHD3.hc(ICHD3.unilateral_sideLocked==1 & (ICHD3.uni_autonomic_only==1 | tbl.c_activity=='feel_worse' | tbl.c_activity=='move' | tbl.c_trigger___exercise==1 ) & tbl.c_ha_in_lifetime=='many' & ...
            (tbl.c_con_pattern_duration=='3to6mo' | tbl.c_con_pattern_duration=='6to12mo' | tbl.c_con_pattern_duration=='1to2y' | tbl.c_con_pattern_duration=='2to3y' | tbl.c_con_pattern_duration=='3yrs') &...
            ICHD3.mig_sev==1) = 1;
        
        ICHD3.cluster = zeros(height(tbl),1);
        ICHD3.cluster(ICHD3.unilateral_sideLocked==1 & tbl.c_ha_in_lifetime=='many' & (tbl.c_sev_overall=='sev' |...
            tbl.c_sev_usual>=7) & (tbl.c_sev_dur=='hrs' | tbl.c_sev_dur=='mins') & (tbl.c_epi_fre=='2to3wk' | tbl.c_epi_fre=='3wk' | tbl.c_epi_fre=='daily') & ...
            (ICHD3.uni_autonomic_only==1 | tbl.c_activity=='move')) = 1;

        %% Primary stabbing headache
        ICHD3.psh = zeros(height(tbl),1);
        ICHD3.psh(tbl.c_sev_dur=='secs' & ICHD3.uni_autonomic_only==0  & (tbl.c_ha_quality___stab==1 | tbl.c_ha_quality___sharp==1)) = 1;

        
        %% Occipital neuralgia_c
        ICHD3.on = zeros(height(tbl),1);
        ICHD3.on(tbl.c_location_area___back==1 & (tbl.c_sev_dur=='secs' | tbl.c_sev_dur=='mins') & (tbl.c_sev_overall=='sev' |...
            tbl.c_sev_usual>=7) & (tbl.c_ha_quality___stab==1 | tbl.c_ha_quality___sharp==1)) = 1;
        ICHD3.on(tbl.c_location_area___sides==1 | tbl.c_location_area___front==1 | tbl.c_location_area___around==1 |...
            tbl.c_location_area___behind==1 | tbl.c_location_area___allover==1) = 0;

        %% Criteria for PTH
        ICHD3.pth = zeros(height(tbl),1);
        ICHD3.pth(tbl.c_epi_prec___conc==1 | tbl.c_epi_inc_fre_prec___conc==1 | tbl.c_con_st_epi_prec_ep___conc==1 | tbl.c_con_prec___conc==1) = 1;
        
        %% Criteria for NDPH/new onset
        ICHD3.ndph = zeros(height(tbl),1);
        tbl.c_pattern_to_con = categorical(tbl.c_pattern_to_con);
        ICHD3.ndph((tbl.c_current_ha_pattern=='cons_same' | tbl.c_current_ha_pattern=='cons_flare') &...
            (tbl.c_pattern_to_con=='none' | tbl.c_pattern_to_con=='rare') & (~isnat(tbl.c_con_start_date) |...
            ~isnan(tbl.c_con_start_age)) & (tbl.c_con_pattern_duration=='3to6mo' | tbl.c_con_pattern_duration=='6to12mo' |...
            tbl.c_con_pattern_duration=="1to2y" | tbl.c_con_pattern_duration=='2to3y' | tbl.c_con_pattern_duration=='3yrs') &...
            tbl.c_con_prec___conc==0 & tbl.c_con_prec___oth_inj==0) = 1;

        ICHD3.new_onset = zeros(height(tbl),1);
        ICHD3.new_onset((tbl.c_current_ha_pattern=='cons_same' | tbl.c_current_ha_pattern=='cons_flare') &...
            (tbl.c_pattern_to_con=='none' | tbl.c_pattern_to_con=='rare') & (~isnat(tbl.c_con_start_date) |...
            ~isnan(tbl.c_con_start_age)) & (tbl.c_con_pattern_duration=='2wks' | tbl.c_con_pattern_duration=='2to4wk' |...
            tbl.c_con_pattern_duration=='4to8wk' | tbl.c_con_pattern_duration=='8to12wk') & tbl.c_con_prec___conc==0 & tbl.c_con_prec___oth_inj==0) = 1;
        
        
        %% phenotype
        
        ICHD3.pheno = zeros(height(tbl),1);
        ICHD3.pheno(ICHD3.probable_migraine==1) = 2;
        ICHD3.pheno(ICHD3.migraine==1) = 1;
        ICHD3.pheno(ICHD3.psh==1) = 4;
        ICHD3.pheno(ICHD3.cluster==1) = 5;
        ICHD3.pheno(ICHD3.hc==1) = 6; 
        ICHD3.pheno(ICHD3.on==1) = 7;
        ICHD3.pheno(ICHD3.tth==1) = 3;
        
        ICHD3.pheno = categorical(ICHD3.pheno,[0 1 2 3 4 5 6 7],{'other','migraine','prob_migraine','tth','primary_stabbing','cluster','hc','occipital_neuralgia_c'});
        %% final diagnosis
        
        ICHD3.dx = zeros(height(tbl),1);
        ICHD3.dx(ICHD3.on==1) = 7;
        ICHD3.dx(ICHD3.psh==1) = 4;
        ICHD3.dx(ICHD3.probable_migraine==1) = 2;
        ICHD3.dx(ICHD3.migraine==1) = 1;
        ICHD3.dx(ICHD3.cluster==1) = 5;
        ICHD3.dx(ICHD3.hc==1) = 6;
        ICHD3.dx(ICHD3.tth==1) = 3;
        ICHD3.dx(ICHD3.ndph==1) = 8;
        ICHD3.dx(ICHD3.new_onset==1) = 9;
        ICHD3.dx(ICHD3.pth==1) = 10;
        
        
        ICHD3.dx = categorical(ICHD3.dx,[0 1 2 3 4 5 6 7 8 9 10],{'other','migraine','prob_migraine','tth','primary_stabbing','cluster','hc','occipital_neuralgia_c','ndph','new_onset','pth'});
        
end
