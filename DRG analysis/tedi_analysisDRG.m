%% Define params
resp_window_start_s = [60; 150; 240];
resp_window_duration_s = 80;
resp_window_end_s = resp_window_start_s + resp_window_duration_s;
n_reps = length(resp_window_start_s);

%% Inport the excel data
data_path = 'DRG WT cells.xlsx';
T = readtable(data_path);
T_mat = table2array(T); 
t_s = T_mat(3:end,1); %Take all the time points
C_tn = T_mat(3:end,2:217); %Take all the cells and time points and store in a matrix
C_nt = C_tn'; %Transpose the data matrix so it is Neurons X Time points
[N,T] = size(C_nt); %find the number of cells N and number of time points T

%% Figure 1: Plot the mean activity with shaded error bar
font_sz = 30;
lw = 4;
figure;
mean_act = mean(C_nt);
std_act = std(C_nt);
std_error = std_act/sqrt(N);
xlabel('Time (s)');
ylabel('Ratio 340:380');
title('Mean activity across Neurons WT');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
legend('SEM','Mean');

%% Figure 2: Plot all cells together as a matrix
figure;
max_val_vec = max(C_nt,[],2);
imagesc(C_nt./max_val_vec);
resp_window_s = [resp_window_start_s, resp_window_end_s];
for j = 1:numel(resp_window_s(:))
    xline(resp_window_s(j),'--');
end
xlabel('Time (s)');
ylabel('Neuron #');
title('Normalized Activity of all neurons WT');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
colormap('viridis');
colorbar;

%% Figure 3: Plot the corr coef between all cells
CC_mat = corr(C_nt');
figure;
imagesc(CC_mat);
max_val = max(abs(CC_mat(:)));
caxis([-max_val max_val]);
xlabel('Neuron #');
ylabel('Neuron #');
title('Correlation coef between all pairs of neurons WT');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
colormap('redblue');
colorbar;

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

%% Figure 4: Plot all cells sorted by their reliability (SPNP ratio)

figure;
C_nt_sorted = C_nt(ix_sort_SPNP, :);
max_val_vec = max(C_nt_sorted,[],2);
imagesc(C_nt_sorted./max_val_vec);
resp_window_s = [resp_window_start_s, resp_window_end_s];
for j = 1:numel(resp_window_s(:))
    xline(resp_window_s(j),'--');
end
xlabel('Time (s)');
ylabel('Neuron #');
title('Normalized Activity of all neurons sorted by reliability (SPNP)WT ');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
colormap('viridis');
colorbar;

%% Figure 5: Plot all cells unsorted and sorted by their reliability (SPNP ratio) next to each other
row = 2;
col = 1;
per = 0.005;
edgel = 0.07; edger = 0.05; edgeh = 0.1; edgeb = 0.12; space_h = per; space_v = 0.1;
[pos]=subplot_pos(row,col,edgel,edger,edgeh,edgeb,space_h,space_v);
figure;

subplot('position', pos{1});
max_val_vec = max(C_nt,[],2);
imagesc(C_nt./max_val_vec);
for j = 1:numel(resp_window_s(:))
    xline(resp_window_s(j),'--');
end
set(gca,'XTickLabel',[]);
ylabel('Neuron #');
title('Normalized Activity of all neurons WT');
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
title('Normalized Activity of all neurons sorted by reliability (SPNP) WT');
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
colormap('viridis');
colorbar;

%% Figure 6: Plot only the selected neurons and keep them

SPSP_th = 1; %As much signal power as nosie power
ix_keep = SPNP_sort>SPSP_th;
SPNP_sort_excel = SPNP_sort(ix_keep);
ix_save_excel = ix_sort_SPNP(ix_keep);
C_nt_select = C_nt_sorted(ix_keep,:);
figure;
max_val_vec = max(C_nt_select,[],2);
imagesc(C_nt_select./max_val_vec);
for j = 1:numel(resp_window_s(:))
    xline(resp_window_s(j),'--');
end
set(gca,'XTickLabel',[]);
ylabel('Neuron #');
title(['Normalized Activity of all selected WT neurons with SPNP Th>', num2str(SPSP_th)]);
set(gca,'FontSize',font_sz);
set(gcf,'color','w');
colormap('viridis');
colorbar;

%% Write the results as excel file
C_nt_select = [ix_save_excel, SPNP_sort_excel, C_nt_select];
filename = 'DRG_WT_refined.xlsx';
table_data = table(C_nt_select);
writetable(table_data, filename);

%% Take only neurons which have certain activity level - Example of enuronal selection
mean_total_act = mean(C_nt(:));
th = 0.95;
th_act = mean_total_act*th;

C_mean_n = mean(C_nt,2);
ix_selected = C_mean_n>th_act;
C_nt_selected = C_nt(ix_selected, :);

