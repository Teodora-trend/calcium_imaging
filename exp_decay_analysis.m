clear all;
close all;

%% Import the excel data 
%If there are NaN values use nanmean() and nanstd() instead of mean() and
%std()

neuronal_type = 'DRG'; %Which neuronal type to analyse
%DH - Dorsal Horn
%DRG - Dorsal Root Ganglion

analysis_type = 'HOM'; %Which data to analyse. The options are:
% 'WT' - Wild type
% 'HOM' - Homozygous

fig_format = 'png'; %What fromat the pictures are saved in

base_dir = [neuronal_type,'_analysis'];
data_path = [neuronal_type,'_Selection_', analysis_type, '.xlsx'];
T = readtable(fullfile(base_dir,data_path));

T_mat = table2array(T); 


save_dir = fullfile(base_dir,'Exp_decay',analysis_type);

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

%% Define params
resp_window_start_s = [90; 180; 270];
resp_window_duration_s = 60;
resp_window_end_s = resp_window_start_s + resp_window_duration_s;
n_reps = length(resp_window_start_s);

plot_raw = 0;
plot_norm = 0;
plot_WT_vs_Hom_raw = 0;
plot_WT_vs_Hom_norm = 0;
plot_fig1 = 1;
plot_fig2 = 1;
plot_fig3 = 1;

font_sz = 40;
%% Assign key variables
cell_ids = T_mat(:,1);
SPNPs = T_mat(:,2);
C_nt = T_mat(:,3:end);
[N,T] = size(C_nt); %find the number of cells N and number of time points T
t_s = [1:T]; %Make all the time points

%% Figure 1: Plot the mean activity with shaded error bar
if plot_fig1
    
    font_sz = 40;
    lw = 4;
    figure('units','normalized','outerposition',[0 0 1 1]);
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
    save_name = fullfile(save_dir,[analysis_type,'_Mean_activity.',fig_format]);
    saveas(gcf,save_name);
    close;
end

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


%% Figure 2: Plot single cell exp fit

if plot_fig2
    c = 100; %Choose the cell [1-529]
    p = 3; %Choose the peak [1-3]
    
    A_curr = A(c, p);
    tau_curr = tau(c, p);
    t_curr = time_plot{c}.(['rep', num2str(p)]);
    data_curr = data_plot{c}.(['rep', num2str(p)]);
    fit_curve = A_curr*exp(-t_curr/tau_curr);
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    plot(t_curr, data_curr,'.', 'MarkerSize', 80);
    hold on;
    plot(t_curr, fit_curve,'r', 'LineWidth',10);
    ylabel('Ratio 380:340');
    xlabel('Time (s)');
    title(['Tau fit to cell no', num2str(c),' peak ', num2str(p), ' tau=',num2str(tau_curr),'s']);
    set(gca,'FontSize',font_sz);
    set(gcf,'color','w');
    save_name = fullfile(save_dir,[analysis_type,'_Exp_decay_profile_Cell_',num2str(c),'_Peak_',num2str(p),'.',fig_format]);
    saveas(gcf,save_name);
    close;
end

%% Figure 3: Plot subploys with all the cells

if plot_fig3
    
    font_sz = 15;
    cells_per_plot = 10;
    n_peaks = 3;
    
    n_groups = ceil(N/cells_per_plot);
    last_cells_per_plot = N - cells_per_plot*(n_groups-1);
    
    
    row = 3;
    col = cells_per_plot;
    per = 0.005;
    edgel = 0.04; edger = per; edgeh = 0.04; edgeb = 0.05; space_h = 0.035; space_v = 0.065;
    [pos]=subplot_pos(row,col,edgel,edger,edgeh,edgeb,space_h,space_v);
    [last_pos]=subplot_pos(row,last_cells_per_plot,edgel,edger,edgeh,edgeb,space_h,space_v);
    
    for g = 1:n_groups
        
        figure('units','normalized','outerposition',[0 0 1 1]);
        counter = (g-1)*cells_per_plot;
        
        if g == n_groups
            pos = last_pos;
            cells_per_plot = last_cells_per_plot;
        end
        
        for k = 1:cells_per_plot
            
            c = counter + k;
            
            for p = 1:n_peaks
                
                A_curr = A(c, p);
                tau_curr = tau(c, p);
                t_curr = time_plot{c}.(['rep', num2str(p)]);
                data_curr = data_plot{c}.(['rep', num2str(p)]);
                fit_curve = A_curr*exp(-t_curr/tau_curr);
                
                
                ii = (p-1)*cells_per_plot + k;
                subplot('position',pos{ii});
                
                plot(t_curr, data_curr,'.', 'MarkerSize', 15);
                hold on;
                plot(t_curr, fit_curve,'r', 'LineWidth',5);
                
                if p == 1
                    title(['cell #', num2str(c), ' \tau = ',num2str(tau_curr,'%.1f'),'s']);
                else
                    title(['\tau = ',num2str(tau_curr,'%.1f'),'s']);
                end
                
                set(gca,'FontSize',font_sz);
                set(gcf,'color','w');
                
                if p == 3
                    xlabel('Time (s)');
                end
                
                xlim([0 60]);
                
                if ismember(ii,[1,cells_per_plot+1,2*cells_per_plot+1])
                    ylabel(['peak=',num2str(p),' Ratio 380:340']);
                end
            end
        end
        
        save_name = fullfile(save_dir,['Exp_decay_cells_group_',num2str(g),'.',fig_format]);
        saveas(gcf,save_name);
        close all;
    end
    
end

%% Normalisation - write an excel sheet containing Norm data, SEM for each time window
% time_window1_norm = time_window1 - min(time_window1);
% time_window2_norm = time_window2 - min(time_window2);
% time_window3_norm = time_window3 - min(time_window3);
% 
% norm_data_TW1=C_nt(:, 90:150)-min(C_nt(:, 90:150),[],2 );
% Mean_norm_data_TW1=mean(norm_data_TW1);
% sem_Mean_norm_data_TW1= std(norm_data_TW1)/sqrt(N);
% 
% norm_data_TW2=C_nt(:, 180:240)-min(C_nt(:, 180:240),[],2 );
% Mean_norm_data_TW2=mean(norm_data_TW2);
% sem_Mean_norm_data_TW2= std(norm_data_TW2)/sqrt(N);
% 
% norm_data_TW3=C_nt(:, 270:330)-min(C_nt(:, 270:330),[],2 );
% Mean_norm_data_TW3=mean(norm_data_TW3);
% sem_Mean_norm_data_TW3=std(norm_data_TW3)/sqrt(N);
% 
% filename = ['Norm_dat_SEM_', analysis_type, '_DH.xlsx'];
% C = vertcat(Mean_norm_data_TW1,sem_Mean_norm_data_TW1,Mean_norm_data_TW2,sem_Mean_norm_data_TW2, Mean_norm_data_TW3,sem_Mean_norm_data_TW3);
% D = transpose(C);
% Z = array2table(D);
% writetable(Z, filename);

%% Make an excel sheet with individual tau values for WT

filename = fullfile(save_dir, ['Tau_values_', analysis_type,'.xlsx']);
table_data = table(tau);
writetable(table_data, filename);