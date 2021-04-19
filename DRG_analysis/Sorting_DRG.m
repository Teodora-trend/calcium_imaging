%% Import the excel data WT
data_path = 'DRGWTrefined.xlsx';
T = readtable(data_path);
T_mat = table2array(T);  
C_nt = T_mat(2:end,3:end); %Take all the cells and time points and store in a matrix Neurons X Time
l = size(C_nt); %find the number of cells N and number of time points T
disp(l)
MeanWT = mean(C_nt)
%% Import the excel data Hom
data_path = 'DRG_HOM_refined.xlsx';
Thom = readtable(data_path);
T_mathom = table2array(Thom);  
C_nt_hom = T_mathom(2:end,3:end); %Take all the cells and time points and store in a matrix Neurons X Time
l_hom = size(C_nt_hom); %find the number of cells N and number of time points T
disp(l_hom)
MeanHOM = mean(C_nt_hom)
%% Normalisation (might be unnecessary)
m = C_nt(:,1:60); %all values from 1 : 60 for each neuron
mean_subBaseline = nanmean(m,2) %mean of all values from 1 : 60 for each neuron
mean_Baseline = nanmean(mean_subBaseline)
Norm_C_nt = C_nt - mean_subBaseline;
Norm_C_tn = Norm_C_nt';
plot(Norm_C_tn);
%% Normalisation (might be unnecessary) Hom
m_hom = C_nt_hom(:,1:60); %all values from 1 : 60 for each neuron
mean_subBaseline_hom = nanmean(m_hom,2) %mean of all values from 1 : 60 for each neuron
mean_Baseline_hom = nanmean(mean_subBaseline_hom)
Norm_C_nt_hom = C_nt_hom - mean_subBaseline_hom;
Norm_C_tn_hom = Norm_C_nt_hom';
plot(Norm_C_tn_hom);
%% Plot means WT vs Hom
font_sz = 30;
lw = 4;
figure;
MeanWT = mean(C_nt);
plot(MeanWT);
title('Mean activity across Neurons')
xlabel('Time (s)');
ylabel('Ratio 340:380');

hold on 
MeanHOM = mean(C_nt_hom);
plot(MeanHOM);

legend('WT', 'Hom')

hold off

%% Plot normalised means WT vs Hom
font_sz = 30;
lw = 4;
figure;
Mean_norm_WT = mean(Norm_C_nt);
plot(Mean_norm_WT);
title('Mean activity across Neurons - normalised to 0')
xlabel('Time (s)');
ylabel('Ratio 340:380');

hold on 
Mean_norm_HOM = mean(Norm_C_nt_hom);
plot(Mean_norm_HOM);

legend('WT', 'Hom')

hold off
%% Indexing animals WT - returns two xlxs sheets with final one containing n=5 animals
data_path = 'DRGWTrefined.xlsx';
T = readtable(data_path);
T_mat = table2array(T);  

A4WTidx = T_mat(:,1) >= 1 & T_mat(:,1) <= 81; %% animal4
Anim4WT = T_mat(A4WTidx,:);

A8WTidx = T_mat(:,1) >= 82 & T_mat(:,1) <= 127; %% animal8
Anim8WT = T_mat(A8WTidx,:);

A9WTidx = T_mat(:,1) >= 128 & T_mat(:,1) <= 158; %% animal9
Anim9WT = T_mat(A9WTidx,:);

A42_1eWTidx = T_mat(:,1) >= 159 & T_mat(:,1) <= 191; %% animal42_1e
Anim42_1eWT = T_mat(A42_1eWTidx,:);

A45_1gWTidx = T_mat(:,1) >= 192 & T_mat(:,1) <= 216; %% animal45_1g
Anim45_1gWT = T_mat(A45_1gWTidx,:);

c = [Anim4WT;Anim8WT;Anim9WT;Anim42_1eWT;Anim45_1gWT]
filename = 'DRG_selection_WT.xlsx';
table_data = table(c);
writetable(table_data, filename); %%keeps animals based on quality, keeps all animals - they all have more than 20 cells
%% Indexing animals HOM - code returns and xlsx sheet with n=5 animals
data_path = 'DRGHOMrefined.xlsx';
Thom = readtable(data_path);
T_mathom = table2array(Thom);  

A1HOMidx = T_mathom(:,1) >= 1 & T_mathom(:,1) <= 93; %% animal1hom
Anim1HOM = T_mathom(A1HOMidx,:);

A3HOMidx = T_mathom(:,1) >= 94 & T_mathom(:,1) <=110; %% animal3hom
Anim3HOM = T_mathom(A3HOMidx,:);

A6HOMidx = T_mathom(:,1) >= 111 & T_mathom(:,1) <= 148; %% animal6hom
Anim6HOM = T_mathom(A6HOMidx,:);

A7HOMidx = T_mathom(:,1) >= 149 & T_mathom(:,1) <= 200; %% animal7hom
Anim7HOM = T_mathom(A7HOMidx,:);

A45_1aHOMidx = T_mathom(:,1) >= 201 & T_mathom(:,1) <= 249; %% animal45_1ahom
Anim45_1aHOM = T_mathom(A45_1aHOMidx,:);

A45_1dHOMidx = T_mathom(:,1) >= 250 & T_mathom(:,1) <= 282; %% animal45_1dhom
Anim45_1dHOM = T_mathom(A45_1dHOMidx,:);


e = [Anim1HOM;Anim3HOM;Anim6HOM;Anim7HOM;Anim45_1aHOM;Anim45_1dHOM]
filename = 'DRG_selection_HOM.xlsx';
table_data = table(e);
writetable(table_data, filename); %% keeps animals based on quality, 6 animals included and 5 animals more than 20 cells

%% Final selection for hom

f = [Anim1HOM;Anim6HOM;Anim7HOM;Anim45_1aHOM;Anim45_1dHOM]
filename = 'DRG_finalselection_HOM.xlsx';
table_data = table(f);
writetable(table_data, filename); %% keeps 5 animals - more than 20 cells

%% Plotting means of WT separately and then as a full average between all means

a2 = mean(Anim4WT(:,3:end));
a3 = mean(Anim8WT(:,3:end));
a4 = mean(Anim9WT(:,3:end));
a5 = mean(Anim42_1eWT(:,3:end));
a13 = mean(Anim45_1gWT(:,3:end));

figure;
font_sz = 150;
ax.FontSize = 12
plot(a2);
title('Activity - individual animals WT')
xlabel('Time (s)');
ylabel('Ratio 340:380');

hold on

plot(a3)
plot(a4)
plot(a5)
plot(a13)

legend('Animal 4', 'Animal 8', 'Animal 9', 'Animal 42.1e', 'Animal 45.1g')

hold off

%% Plot full average between all means

meanMatrixWT = (a2 + a3 + a4 + a5 + a13)/5;
plot(meanMatrixWT);

%% Plotting means of HOM separately and then as a full average between all means

b10 = mean(Anim1HOM(:,3:end));
b6 = mean(Anim6HOM(:,3:end));
b7 = mean(Anim7HOM(:,3:end));
b8 = mean(Anim45_1aHOM(:,3:end));
b9 = mean(Anim45_1dHOM(:,3:end));

font_sz = 50;
lw = 4;
figure;
plot(b10);
title('Activity - individual animals HOM')
xlabel('Time (s)');
ylabel('Ratio 340:380');
hold on

plot(b6)
plot(b7)
plot(b8)
plot(b9)

legend('Animal 1', 'Animal 6', 'Animal 7', 'Animal 45.1a', 'Animal 45.1d')

hold off

%% Plot full average between all means

meanMatrixHOM = (b10 + b6 + b7 + b8 + b9)/5;
plot(meanMatrixHOM);

font_sz = 50;
lw = 4;
figure;
plot(meanMatrixWT);
title('Mean activity within animal groups')
xlabel('Time (s)');
ylabel('Ratio 340:380');

hold on 
plot(meanMatrixHOM);

legend('WT', 'Hom')

hold off




