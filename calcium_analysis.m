clear all;
close all;

%% Define params
resp_window_start_s = [60; 150; 240];
resp_window_duration_s = 80;
resp_window_end_s = resp_window_start_s + resp_window_duration_s;
n_reps = length(resp_window_start_s);

%% Select figures to plot and define plotting params

neuronal_type = 'DRG'; %Which neuronal type to analyse
%DH - Dorsal Horn
%DRG - Dorsal Root Ganglion

analysis_type = 'WT'; %Which data to analyse. The options are:
% 'WT' - Wild type
% 'HOM' - Homozygous

plot_fig1 = 0;
plot_fig2 = 1;
plot_fig3 = 1;
plot_fig4 = 1;
plot_fig5 = 1;
font_sz = 40;
fig_format = 'png'; %What fromat the pictures are saved in

base_dir = [neuronal_type,'_analysis'];
save_dir = fullfile(base_dir,'SPNP_sorting',analysis_type);

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

%% Inport the excel data
base_name = 'Calcium_Response_';

data_path = [base_name,neuronal_type,'_',analysis_type,'.xlsx'];
T = readtable(fullfile(base_dir,data_path));
T_mat = table2array(T); 
t_s = T_mat(:,1); %Take all the time points
C_tn = T_mat(:,2:end); %Take all the cells and time points and store in a matrix
C_nt = C_tn'; %Transpose the data matrix so it is Neurons X Time points
[N,T] = size(C_nt); %find the number of cells N and number of time points T

%% Figure 1: Plot the mean activity with shaded error bar
if plot_fig1
    lw = 4;
    figure('units','normalized','outerposition',[0 0 1 1]);
    mean_act = mean(C_nt);
    std_act = std(C_nt);
    std_error = std_act/sqrt(N);
    shadedErrorBar(t_s, mean_act, std_error);
    xlabel('Time (s)');
    ylabel('Ratio 340:380');
    title(['Mean activity across Neurons - ',analysis_type]);
    set(gca,'FontSize',font_sz);
    set(gcf,'color','w');
    save_name = fullfile(save_dir,[analysis_type,'_Mean_activity.',fig_format]);
    saveas(gcf,save_name);
    close;
end

%% Figure 2: Plot all cells together as a matrix
if plot_fig2
    figure('units','normalized','outerposition',[0 0 1 1]);
    max_val_vec = max(C_nt,[],2);
    imagesc(C_nt./max_val_vec);
    resp_window_s = [resp_window_start_s, resp_window_end_s];
    for j = 1:numel(resp_window_s(:))
        xline(resp_window_s(j),'--');
    end
    xlabel('Time (s)');
    ylabel('Neuron #');
    title(['Normalized Activity of all neurons - ',analysis_type]);
    set(gca,'FontSize',font_sz);
    set(gcf,'color','w');
    colormap('viridis');
    colorbar;
    save_name = fullfile(save_dir,[analysis_type,'_Calcium_temporal_profile_all_cells.',fig_format]);
    saveas(gcf,save_name);
    close;
end


%% Calculate Signal-Power-to-Noise-Power ratio (bigger is better); SP = Signal Power; NP = Noise Power; tr = trial; t = time

for j = 1:N
    
    SPNP_data = [];
    
    for i = 1:n_reps
        
        ix_start = find(t_s==resp_window_start_s(i));
        ix_end = find(t_s==resp_window_end_s(i));
        SPNP_data(i,:) = C_nt(j,ix_start:ix_end);

    end
    
    SPNP_rez(j).data = SPNP_data;
    [SP, NP, TP, SP_std_error] = sahani_quick(SPNP_data);
    SPNP_rez(j).SP = SP;
    SPNP_rez(j).NP = NP;
    SPNP_rez(j).SPNP_ratio = SP/NP;
    
end

SPNP = [SPNP_rez.SPNP_ratio]';
SPNP_sort = SPNP;
SPNP_sort(isnan(SPNP_sort)) = -Inf;
[SPNP_sort, ix_sort_SPNP] = sort(SPNP_sort,1,'descend');
SPNP_sort(isinf(SPNP_sort)) = NaN;

%% Figure 3: Plot all cells sorted by their reliability (SPNP ratio)
C_nt_sorted = C_nt(ix_sort_SPNP, :);
max_val_vec = max(C_nt_sorted,[],2);

if plot_fig3
    figure('units','normalized','outerposition',[0 0 1 1]);
    imagesc(C_nt_sorted./max_val_vec);
    resp_window_s = [resp_window_start_s, resp_window_end_s];
    for j = 1:numel(resp_window_s(:))
        xline(resp_window_s(j),'--');
    end
    xlabel('Time (s)');
    ylabel('Neuron #');
    title(['Normalized Activity of all neurons sorted by reliability (SPNP) - ',analysis_type]);
    set(gca,'FontSize',font_sz);
    set(gcf,'color','w');
    colormap('viridis');
    colorbar;
    save_name = fullfile(save_dir,[analysis_type,'_Calcium_temporal_profile_all_cells_SPNP_ordered.',fig_format]);
    saveas(gcf,save_name);
    close;
end

%% Figure 4: Plot all cells unsorted and sorted by their reliability (SPNP ratio) next to each other
row = 2;
col = 1;
per = 0.005;
edgel = 0.07; edger = 0.05; edgeh = 0.1; edgeb = 0.12; space_h = per; space_v = 0.1;
[pos]=subplot_pos(row,col,edgel,edger,edgeh,edgeb,space_h,space_v);

if plot_fig4
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot('position', pos{1});
    max_val_vec = max(C_nt,[],2);
    imagesc(C_nt./max_val_vec);
    for j = 1:numel(resp_window_s(:))
        xline(resp_window_s(j),'--');
    end
    set(gca,'XTickLabel',[]);
    ylabel('Neuron #');
    title('Normalized Activity of all neurons HOM');
    set(gca,'FontSize',font_sz);
    set(gcf,'color','w');
    colormap('viridis');
    colorbar;
    
    subplot('position', pos{2});
    max_val_vec = max(C_nt_sorted,[],2);
    imagesc(C_nt_sorted./max_val_vec);
    for j = 1:numel(resp_window_s(:))
        xline(resp_window_s(j),'--');
    end
    xlabel('Time (s)');
    ylabel('Neuron #');
    title(['Normalized Activity of all neurons sorted by reliability (SPNP) - ',analysis_type]);
    set(gca,'FontSize',font_sz);
    set(gcf,'color','w');
    colormap('viridis');
    colorbar;
    save_name = fullfile(save_dir,[analysis_type,'_Calcium_temporal_profile_all_cells_unsorted_sorted.',fig_format]);
    saveas(gcf,save_name);
    close;
end

%% Figure 5: Plot only the selected neurons 
SPSP_th = 1; %As much signal power as noise power
ix_keep = SPNP_sort>SPSP_th;
SPNP_sort_excel = SPNP_sort(ix_keep);
ix_save_excel = ix_sort_SPNP(ix_keep);
C_nt_select = C_nt_sorted(ix_keep,:);

if plot_fig5
    figure('units','normalized','outerposition',[0 0 1 1]);
    max_val_vec = max(C_nt_select,[],2);
    imagesc(C_nt_select./max_val_vec);
    for j = 1:numel(resp_window_s(:))
        xline(resp_window_s(j),'--');
    end
    set(gca,'XTickLabel',[]);
    ylabel('Neuron #');
    title(['Normalized Activity of all selected ', analysis_type,' neurons with SPNP Th>', num2str(SPSP_th)]);
    set(gca,'FontSize',font_sz);
    set(gcf,'color','w');
    colormap('viridis');
    colorbar;
    save_name = fullfile(save_dir,[analysis_type,'_Calcium_temporal_profile_SPNP_sorted_selected_Th_',num2str(SPSP_th),'.',fig_format]);
    saveas(gcf,save_name);
    close;
end

%% Write the results as excel file
C_nt_select = [ix_save_excel, SPNP_sort_excel, C_nt_select];
filename = fullfile(save_dir,[base_name,analysis_type,'_Refined.xlsx']);
table_data = table(C_nt_select);
writetable(table_data, filename);