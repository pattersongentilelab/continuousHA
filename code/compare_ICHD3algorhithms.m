% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath 'PfizerHAdataJun17Feb22.mat'])

data = data(data.p_current_ha_pattern=='episodic'|data.p_current_ha_pattern=='cons_same'|data.p_current_ha_pattern=='cons_flare'|...
    data.c_current_ha_pattern=='episodic'|data.c_current_ha_pattern=='cons_same'|data.c_current_ha_pattern=='cons_flare',:);

data = data(data.visit_dt>'01-Jan-2017' & data.visit_dt<'01-Jan-2022',:);


ICHD3 = ichd3_Dx(data);
% ICHD3c = ichd3_Dx_clinician(data);

