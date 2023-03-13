% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath 'PfizerHAdataJun17Feb22.mat'])

data = data(data.p_current_ha_pattern=='episodic'|data.p_current_ha_pattern=='cons_same'|data.p_current_ha_pattern=='cons_flare'|...
    data.c_current_ha_pattern=='episodic'|data.c_current_ha_pattern=='cons_same'|data.c_current_ha_pattern=='cons_flare',:);

data = data(data.visit_dt>'01-Jan-2017' & data.visit_dt<'01-Jan-2022',:);

% patient data, headache quality
data.pulsate = sum(table2array(data(:,[123 124 133])),2);
data.pulsate(data.pulsate>1) = 1;
data.pressure = sum(table2array(data(:,[126:128 131])),2);
data.pressure(data.pressure>1) = 1;
data.neuralgia = sum(table2array(data(:,[125 129 130 132])),2);
data.neuralgia(data.neuralgia>1) = 1;

% clinician data, headache quality
data.pulsate_c = sum(table2array(data(:,[744 745 754])),2);
data.pulsate_c(data.pulsate_c>1) = 1;
data.pressure_c = sum(table2array(data(:,[747:749 752])),2);
data.pressure_c(data.pressure_c>1) = 1;
data.neuralgia_c = sum(table2array(data(:,[746 750 751 753])),2);
data.neuralgia_c(data.neuralgia_c>1) = 1;

ICHD3 = ichd3_Dx_clinician(data);
data.ichd3 = ICHD3.dx;




temp = tbl.record_id(tbl.p_assoc_sx_vis___spot==1 & tbl.p_assoc_sx_vis___star==0 &...
    tbl.p_assoc_sx_vis___light==0  & tbl.p_assoc_sx_vis___zigzag==0 & tbl.p_assoc_sx_vis___heat==0 &...
    tbl.p_assoc_sx_vis___loss_vis==0 & (ICHD3.migraine==1 | ICHD3.probable_migraine==1));
