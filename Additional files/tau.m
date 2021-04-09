%% Indexing tau values higher than 0.95
data_path = 'Book2_WTdecay.xlsx';
Thom = readtable(data_path);
T_mat_hom = table2array(Thom);  

Tau_values_idx = T_mat_hom(:,2) > 0.95
TauvaluesHOM = T_mat_hom(Tau_values_idx,:);

filename = 'Selected tau values_WT_peakI_097r.xlsx';
table_data = table(TauvaluesHOM);
writetable(table_data, filename);

%% Indexing tau values higher than 0.95
data_path = 'Book2_HOMdecay.xlsx';
Thom = readtable(data_path);
T_mat_hom = table2array(Thom);  

Tau_values_idx = T_mat_hom(:,2) > 0.95
TauvaluesHOM = T_mat_hom(Tau_values_idx,:);

filename = 'Selected tau values_HOM_peakI_097r.xlsx';
table_data = table(TauvaluesHOM);
writetable(table_data, filename);