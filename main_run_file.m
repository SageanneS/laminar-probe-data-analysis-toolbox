%% main_run_file.m
% Written by Dr. Sageanne Senneff
% Taillefumier Lab
% August 2nd, 2024

clear 
close all

filedir             = 'valid_recordings/data_LFP_M23D20200611R0TS.mat';    % laminar probe data - LFP and Vm
load(filedir);

high_contrast_level = length(data.contrast);                               % highest contrast stimulus data index
stimcontrast        = high_contrast_level;                                 % set contrast to be used for laminar id

id_type             = 0;                                                   % 0 = auto FLIP (vFLIP), 1 = FLIP
lowfreqrange        = [10 30];                                             % alpha/beta frequency range
highfreqrange       = [75 150];                                            % gamma frequency range

contactdist         = 0.1;                                                 % distance between electrode contacts (microns)
maxfreq             = 150;                                                 % maximum frequency to be analyzed
freqbin             = 1.0;                                                 % frequency sampling (1 Hz)

stimON              = 1;                                                   % analyze evoked (1) or spontaneous data (0)
contact_num         = 32;                                                  % number of electrode contacts
response_dur        = 1.0;                                                 % duration of post-stimulus response period (sec)

%% Run Functions
% Power Map
[power_map]  = compute_power_map(filedir, stimcontrast);
% Laminar Identification
[startinglowfreq, endinglowfreq, startinghighfreq, endinghighfreq, ...
    goodnessvalue, superficialchannel, deepchannel,  ...
    highfreqmaxchannel, lowfreqmaxchannel, crossoverchannel] = ...
    run_laminar_identification(power_map, id_type, ...
    lowfreqrange, highfreqrange, contactdist, maxfreq, freqbin);
% Synchrony Computation (Correlation, Magnitude-Squared Coherence)
[rho_all, lags_all, cxy_all, frqs_all] = quantify_synchrony(...
    filedir, stimcontrast, stimON, contact_num, response_dur);

%% Plot Data
% Vm-LFP Correlation & Vm-LFP Coherence
% average across trials
clear avg_rho
clear lag_values
clear avg_cxy
clear frq_values
for ix = 1:32
    % average correlation coefficients
    rho_trials     = rho_all{ix};                                          % grab all rho values for every trial
    rho_trials     = [rho_trials{:}];
    convert_data   = cell2mat(rho_trials');                                % convert from a cell to a matrix
    avg_rho{ix}    = mean(convert_data);                                   % average across the matrix
    % access lag values
    lag_values{ix} = lags_all{ix}{1};                                      % they are all identical for every trial; choose any one of them
    % average magnitude-squared coherence estimates
    cxy_trials     = cxy_all{ix};                                          % grab all coherence estimates for every trial
    cxy_trials     = [cxy_trials{:}];
    convert_data   = cell2mat(cxy_trials);                                 % convert from a cell to a matrix
    avg_cxy{ix}    = mean(convert_data');                                  % average across the matrix
    % access frequency values
    frq_values{ix} = frqs_all{ix}{1};                                      % they are all identical for every trial; choose any one of them
end

% convert data format for plotting
close all
avg_rho  = cell2mat(avg_rho'); % plot rho values
for ix = 1:32
    figure(1)
    hold on
    % subtract off mean to normalize the rho data
    plot(lag_values{ix}{1}, avg_rho(ix,:)-mean(avg_rho(ix,:)))
    ylim([-1 1])
    set(gcf, 'color', 'w');
    xlabel('Lag (sec)')
    ylabel('Correlation Coefficient (\rho)')
    ax.FontSize = 13;
end
title('Vm-LFP Correlation')
avg_cxy  = cell2mat(avg_cxy'); % plot cxy values
for ix = 1:32
    figure(2)
    hold on
    % subtract off mean to normalize the cxy data
    plot(frq_values{ix}{1}, avg_cxy(ix,:)-mean(avg_cxy(ix,:)))
    ylim([0 1])
    set(gcf, 'color', 'w');
    xlabel('Frq (Hz)')
    ylabel('Coherence Estimate')
    ax.FontSize = 13;
end
title('Vm-LFP Coherence (1-150 Hz)')