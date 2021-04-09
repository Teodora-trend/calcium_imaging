%% Import the excel data 
%If there are NaN values use nanmean() and nanstd() instead of mean() and
%std()

data_path = 'First_selection_HOM.xlsx';
T = readtable(data_path);
T_mat = table2array(T); 

%% Define params
resp_window_start_s = [90; 180; 270];
resp_window_duration_s = 60;
resp_window_end_s = resp_window_start_s + resp_window_duration_s;
n_reps = length(resp_window_start_s);

%% Assign key variables
cell_ids = T_mat(:,1);
SPNPs = T_mat(:,2);
C_nt = T_mat(:,3:end);
[N,T] = size(C_nt); %find the number of cells N and number of time points T
t_s = [1:T]; %Make all the time points

%% Plot time windows - to do: normalise to 0, plot with hom

mean_data = mean(C_nt)
time_window1 = mean_data(:, 90:150)
time_window2 = mean_data(:, 180:240)
time_window3 = mean_data(:, 270:330)
x1 = [90:150]
x2 = [180:240]
x3 = [270:330]

font_sz = 40;
lw = 4;
figure;
plot(x1,time_window1)
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Mean activity across Neurons during decay 1');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

figure;
plot(x2,time_window2)
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Mean activity across Neurons during decay 2');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

figure;
plot(x3,time_window3)
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Mean activity across Neurons during decay 3');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

%% Normalisation
time_window1_norm = time_window1 - min(time_window1);
time_window2_norm = time_window2 - min(time_window2);
time_window3_norm = time_window3 - min(time_window3);

font_sz = 40;
lw = 4;
figure;
plot(x1,time_window1_norm)
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Decay dynamics 1st peak - normalised to 0');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

figure;
plot(x2,time_window2_norm)
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Decay dynamics 2nd peak - normalised to 0');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

figure;
plot(x3,time_window3_norm)
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Decay dynamics 3rd peak - normalised to 0');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

%% Figure 1: Plot the mean activity with shaded error bar
font_sz = 40;
lw = 4;
figure;
mean_act = mean(C_nt);
std_act = std(C_nt);
std_error = std_act/sqrt(N);
shadedErrorBar(t_s, mean_act, std_error);
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Mean activity across Neurons');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

%% Calculate exp decay time const (tau) for every cell and each trial tr = trial; t = time

t_min_s = 40; %The minimum length in s that is necessary to fit the tau
tau = [];
A = [];
data_plot = cell(N,1);
time_plot = cell(N,1);

tic;
for j = 1:N
    
    fprintf('== Cell %0.f/%0.f ==\n', j, N);
    
    for i = 1:n_reps
        
        ix_start = find(t_s==resp_window_start_s(i));
        ix_end = find(t_s==resp_window_end_s(i));
        
        %Get the data for this cell and trial
        data_temp = C_nt(j,ix_start:ix_end);
        
        %Find the max resp in this time window
        [~, ix_max] = max(data_temp);
        
        %Get the data to fit from max to end of time window
        data_fit = data_temp(ix_max:end);
        data_fit = data_fit(:);
        
        %Normalize the minimum to zero
        data_fit_norm = data_fit - min(data_fit);
        
        data_plot{j}.(['rep',num2str(i)]) = data_fit_norm;
        
        %Make a time vector for the fitting
        t_fit_s = [0:length(data_fit_norm)-1];
        t_fit_s =t_fit_s(:);
        time_plot{j}.(['rep',num2str(i)]) = t_fit_s;
        
        %Fit a single exp decay using Matlab's built in funciton
        if length(data_fit_norm) >= t_min_s
            
            f = fit(t_fit_s, data_fit_norm, 'exp1');
            tau(j,i) = -1/f.b;
            A(j,i) = f.a;
            
        else
            
            tau(j,i) = NaN;
            A(j,i) = NaN;
            
        end
    end
    
end

fprintf('== Done! This took %0.fs ==\n', toc);
%% Plot the data
cell_choose = 77; %Choose the cell [1-529]
peak = 3; %Choose the peak [1-3]

A_curr = A(cell_choose, peak);
tau_curr = tau(cell_choose, peak);
t_curr = time_plot{cell_choose}.(['rep', num2str(peak)]); 
data_curr = data_plot{cell_choose}.(['rep', num2str(peak)]);
fit_curve = A_curr*exp(-t_curr/tau_curr);

figure;
plot(t_curr, data_curr,'.', 'MarkerSize', 80);
hold on;
plot(t_curr, fit_curve,'r', 'LineWidth',10);
ylabel('Ratio 380:340');
xlabel('Time (s)');
title(['Tau fit to cell no', num2str(cell_choose),' peak ', num2str(peak), ' tau=',num2str(tau_curr),'s']);
set(gca,'FontSize',font_sz);
set(gcf,'color','w');

%% Normalisation - write an excel sheet containing Norm data, SEM for each time window
time_window1_norm = time_window1 - min(time_window1);
time_window2_norm = time_window2 - min(time_window2);
time_window3_norm = time_window3 - min(time_window3);

norm_data_TW1=C_nt(:, 90:150)-min(C_nt(:, 90:150),[],2)
Mean_norm_data_TW1=mean(norm_data_TW1)
sem_Mean_norm_data_TW1= std(norm_data_TW1)/sqrt(N)

norm_data_TW2=C_nt(:, 180:240)-min(C_nt(:, 180:240),[],2)
Mean_norm_data_TW2=mean(norm_data_TW2)
sem_Mean_norm_data_TW2= std(norm_data_TW2)/sqrt(N)

norm_data_TW3=C_nt(:, 270:330)-min(C_nt(:, 270:330),[],2)
Mean_norm_data_TW3=mean(norm_data_TW3)
sem_Mean_norm_data_TW3=std(norm_data_TW3)/sqrt(N)

filename = 'Norm_dat_SEM_HOM_DH.xlsx';
C = vertcat(Mean_norm_data_TW1,sem_Mean_norm_data_TW1,Mean_norm_data_TW2,sem_Mean_norm_data_TW2, Mean_norm_data_TW3,sem_Mean_norm_data_TW3)
D = transpose(C)
Z = array2table(D)
writetable(Z, filename);

%% Make an excel sheet with individual tau values for HOM

filename = 'Tau_values_Hom_shortInterval.xlsx';
table_data = table(tau);
writetable(table_data, filename);
