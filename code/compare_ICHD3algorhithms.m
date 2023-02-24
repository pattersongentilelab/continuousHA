% assess MCA across all continuous headache participants

Pfizer_dataBasePath = getpref('continuousHA','pfizerDataPath');

load([Pfizer_dataBasePath 'PfizerHAdataJun17Feb22.mat'])

% patient data, headache quality
data.pulsate = sum(table2array(data(:,[123 124 133])),2);
data.pulsate(data.pulsate>1) = 1;
data.pressure = sum(table2array(data(:,[126:128 131])),2);
data.pressure(data.pressure>1) = 1;
data.neuralgia = sum(table2array(data(:,[125 129 130 132])),2);
data.neuralgia(data.neuralgia>1) = 1;

ICHD3 = ichd3_Dx(data);
ICHD3.dx = reordercats(ICHD3.dx,{'migraine','prob_migraine','tth','cluster','hc','primary_stabbing','occipital_neuralgia','ndph','new_onset','pth','other'});
data.ichd3 = ICHD3.dx;


% clinician data
data.pulsate_c = sum(table2array(data(:,[744 745 754])),2);
data.pulsate_c(data.pulsate_c>1) = 1;
data.pressure_c = sum(table2array(data(:,[747:749 752])),2);
data.pressure_c(data.pressure_c>1) = 1;
data.neuralgia_c = sum(table2array(data(:,[746 750 751 753])),2);
data.neuralgia_c(data.neuralgia_c>1) = 1;