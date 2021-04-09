%% Import the excel data WT
data_path = 'Decay_SUN_refined.xlsx';
T = readtable(data_path);
T_mat = table2array(T);  
t_s = T_mat(:,2); %Take all the time points
C_nt = T_mat(2:end,3:end); %Take all the cells and time points and store in a matrix Neurons X Time
l = size(C_nt); %find the number of cells N and number of time points T
disp(l)
MeanWT = mean(C_nt)
%% Import the excel data Hom
data_path = 'DECAY_HOM_refined.xlsx';
Thom = readtable(data_path);
T_mathom = table2array(Thom);  
t_s_hom = T_mathom(:,2); %Take all the time points
C_nt_hom = T_mathom(2:end,3:end); %Take all the cells and time points and store in a matrix Neurons X Time
l_hom = size(C_nt_hom); %find the number of cells N and number of time points T
disp(l_hom)
MeanHOM = mean(C_nt_hom)
%% Normalisation (might be unnecessary)
m = C_nt(:,1:60); %all values from 1 : 60 for each neuron
mean_subBaseline = mean(m,2) %mean of all values from 1 : 60 for each neuron
mean_Baseline = mean(mean_subBaseline)
Norm_C_nt = C_nt - mean_subBaseline;
Norm_C_tn = Norm_C_nt';
plot(Norm_C_tn);
%% Normalisation (might be unnecessary) Hom
m_hom = C_nt_hom(:,1:60); %all values from 1 : 60 for each neuron
mean_subBaseline_hom = mean(m_hom,2) %mean of all values from 1 : 60 for each neuron
mean_Baseline_hom = mean(mean_subBaseline_hom)
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
hold off
%% Indexing animals WT - returns two xlxs sheets with final one containing n=5 animals
data_path = 'Decay_SUN_refined.xlsx';
T = readtable(data_path);
T_mat = table2array(T);  

A1WTidx = T_mat(:,1) >= 1 & T_mat(:,1) <= 6; %% animal1
Anim1WT = T_mat(A1WTidx,:);

A2WTidx = T_mat(:,1) >= 7 & T_mat(:,1) <= 130; %% animal2
Anim2WT = T_mat(A2WTidx,:);

A3WTidx = T_mat(:,1) >= 131 & T_mat(:,1) <= 323; %% animal3
Anim3WT = T_mat(A3WTidx,:);

A4WTidx = T_mat(:,1) >= 324 & T_mat(:,1) <= 468; %% animal4
Anim4WT = T_mat(A4WTidx,:);

A5WTidx = T_mat(:,1) >= 469 & T_mat(:,1) <= 660; %% animal5
Anim5WT = T_mat(A5WTidx,:);

A11WTidx = T_mat(:,1) >= 661 & T_mat(:,1) <= 675; %% animal11
Anim11WT = T_mat(A11WTidx,:);

A13WTidx = T_mat(:,1) >= 676 & T_mat(:,1) <= 719; %% animal13
Anim13WT = T_mat(A13WTidx,:);

A14WTidx = T_mat(:,1) >= 720 & T_mat(:,1) <= 741; %% animal14
Anim14WT = T_mat(A14WTidx,:);

c = [Anim1WT;Anim2WT;Anim3WT;Anim4WT;Anim5WT;Anim11WT;Anim13WT;Anim14WT]
filename = 'First_selection_WT.xlsx';
table_data = table(c);
writetable(table_data, filename); %% keeps 7 out of 8 animals based on quality, animal 14 fully excluded

d = [Anim2WT;Anim3WT;Anim4WT;Anim5WT;;Anim13WT;Anim14WT]
filename = 'Final_selection_WT.xlsx';
table_data_fin = table(d);
writetable(table_data_fin, filename); %% keeps 5 out of 8 animals based on number of cells, excludes anim1WT and anim11WT due to fewer than 30 cells

%% Indexing animals HOM - code returns and xlsx sheet with n=5 animals
data_path = 'DECAY_HOM_refined.xlsx';
Thom = readtable(data_path);
T_mathom = table2array(Thom);  

A10HOMidx = T_mathom(:,1) >= 1 & T_mathom(:,1) <= 50; %% animal10hom
Anim10HOM = T_mathom(A10HOMidx,:);

A6HOMidx = T_mathom(:,1) >= 51 & T_mathom(:,1) <=228; %% animal6hom
Anim6HOM = T_mathom(A6HOMidx,:);

A7HOMidx = T_mathom(:,1) >= 229 & T_mathom(:,1) <= 310; %% animal7hom
Anim7HOM = T_mathom(A7HOMidx,:);

A8HOMidx = T_mathom(:,1) >= 311 & T_mathom(:,1) <= 505; %% animal8hom
Anim8HOM = T_mathom(A8HOMidx,:);

A9HOMidx = T_mathom(:,1) >= 506 & T_mathom(:,1) <= 784; %% animal9hom
Anim9HOM = T_mathom(A9HOMidx,:);


e = [Anim10HOM;Anim6HOM;Anim7HOM;Anim8HOM;Anim9HOM]
filename = 'First_selection_HOM.xlsx';
table_data = table(e);
writetable(table_data, filename); %% keeps animals based on quality, all animals included and all animals more than 30 cells

%% Plotting means of WT separately and then as a full average between all means

a2 = mean(Anim2WT(:,3:end));
a3 = mean(Anim3WT(:,3:end));
a4 = mean(Anim4WT(:,3:end));
a5 = mean(Anim5WT(:,3:end));
a13 = mean(Anim13WT(:,3:end));

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

legend('Animal 2', 'Animal 3', 'Animal 4', 'Animal 5', 'Animal 13')

hold off

%% Plot full average between all means

meanMatrixWT = (a2 + a3 + a4 + a5 + a13)/5;
plot(meanMatrixWT);

%% Plotting means of HOM separately and then as a full average between all means

b10 = mean(Anim10HOM(:,3:end));
b6 = mean(Anim6HOM(:,3:end));
b7 = mean(Anim7HOM(:,3:end));
b8 = mean(Anim8HOM(:,3:end));
b9 = mean(Anim9HOM(:,3:end));

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

legend('Animal 10', 'Animal 6', 'Animal 7', 'Animal 8', 'Animal 9')

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
hold off




