%% quantify_synchrony.m
% Written by Dr. Sageanne Senneff
% Taillefumier Lab
% August 2nd, 2024

function [rho_all, lags_all, cxy_all, frqs_all] = quantify_synchrony(...
    filedir, stimcontrast, stimON, contact_num, response_dur)
% quantifysynchrony.m requires the following inputs:
% filedir      = folder directory of the data file to be analyzed
% stimcontrast = stimulus contrast level to be analyzed
%                Know your dataset, but there are generally 2-4 levels of
%                stimulus contrast, indexed from lowest to highest
%                contrast, i.e. index "end" = highest contrast level
% stimON       =  user option to select whether to analyze either 
%                   evoked trials (stimulus presented - stimON:1) or 
%                   blank(spontaneous) trials (no stimulus - stimON:0). 
% contact_num  = number of electrode contacts on laminar probe 
% response_dur = trial response period following stimulus

% quantifysynchrony.m has the following outputs:
% rho_all  = correlation coefficients over time at each electrode contact
% lags_all = lag distances for correlation coefficients
% cxy_all  = coherence over time at each electrode contact
% frqs_all = frequencies for coherence estimation

%%
% load in the laminar probe data file
load(filedir);

% grab the lfp and Vm time series data
if stimON == 1
    lfp_ts             = data.lfp_stim;
    Vm_ts              = data.Vm_stim;
    % grab the data for a given contrast level at each stimulus orientation
    lfp_struct         = cell(size(data.orientation));
    Vm_struct          = cell(size(data.orientation));
    for ix = 1:length(data.orientation)
        lfp_struct{ix} = lfp_ts{stimcontrast*ix};                          % lfp data struct (contrast + orientation) -> ("evoked lfp")
        Vm_struct{ix}  = Vm_ts{stimcontrast*ix};                           % Vm data struct  (contrast + orientation) -> ("evoked Vm")
    end
end
if stimON == 0
    lfp_ts = data.lfp_blank;                                               % blank labeled lfp time series ("spontaneous lfp")
    Vm_ts  = data.Vm_blank;                                                % blank labeled Vm time series  ("spontaneous Vm")
end

% temporally align the Vm data to the lfp data
lfp_fs    = data.lfp_samplingrate;                                         % lfp time series sampling frequency
Vm_fs     = data.Vm_samplingrate;                                          % Vm time series sampling frequency
lfp_tstim = data.stimOnset;                                                % time of stimulus onset
Vm_tstim  =  (Vm_fs/lfp_fs)*lfp_tstim;                                     % normalize Vm_fs to lfp_fs aligned to stimulus onset
if stimON == 1
    lfp_response         = cell(size(data.orientation));
    Vm_response          = cell(size(data.orientation));
    for ix = 1:length(data.orientation)
        response_dur     = 1.0;                                            % trial response period following the stimulus
        lfp_response{ix} = lfp_struct{ix}(:, :, ...
            lfp_tstim:lfp_tstim+response_dur*lfp_fs);                      % indexing the lfp ts down to the response period  
        Vm_response{ix}  = Vm_struct{ix}(:,  ...
            Vm_tstim:Vm_tstim+response_dur*Vm_fs);                         % indexing the Vm ts down to the response period
    end
end
if stimON == 0
    lfp_response = lfp_ts(:, :, ...
        lfp_tstim:lfp_tstim+response_dur*lfp_fs);                          % indexing the lfp ts for the blank response period
    Vm_response  = Vm_ts(:,  ...
        Vm_tstim:Vm_tstim+response_dur*Vm_fs);                             % indexing the Vm ts for the blank response period
end

% iterate over all laminar probe contacts
% downsample Vm data to match the time dimension of the lfp data 
% at each contact, for each trial, compute Vm-LFP correlation
%                                  compute Vm-LFP coherence
for ix = 1:contact_num 

    % EVOKED RESPONSES
    if stimON == 1
        % iterate over all stimulus orientations
        for orx = 1:length(data.orientation)
            lfp_data  = lfp_response{orx};                                 % grab lfp response at each stimulus orientation
            lfp_data  = squeeze(lfp_data(:, ix, :));                       % reformat data to match Vm-dim
            Vm_data   = Vm_response{orx};                                  % grab Vm response at each stimulus orientation
            % compute at every trial (trx) at each stim orientation (orx)
            for trx = 1:size(lfp_data,1)
                % downsample the Vm data
                Vm_data_ds   = decimate(Vm_data(trx,:), Vm_fs/lfp_fs);     % downsample from Vm_fs to lfp_fs
                % compute the Vm-LFP correlation
                % rho  = cross-correlation value
                % lags = lags at which rho is computed
                [rho, lags]  = xcorr(lfp_data(trx,:), Vm_data_ds, ...
                    'coeff');                                              % returns a correlation coefficient with 'coeff' function input
                % compute the Vm-LFP coherence (magnitude-squared)
                % cxy  = magnitude-squared coherence estimate
                % frqs = vector of frequencies expressed in terms of fs
                [cxy, frqs]  = mscohere(lfp_data(trx,:), Vm_data_ds, ...
                    [], [], [], lfp_fs);                                   % coherence estimation with default function inputs sampled at lfp_fs
                % store function outputs at each trial
                trial_rho{trx}  = rho;                                     % trial struct of correlation coefficients
                trial_lags{trx} = lags;                                    % trial struct of lags
                trial_cxy{trx}  = cxy;                                     % trial struct of coherence estimations
                trial_frqs{trx} = frqs;                                    % trial struct of frequencies at which coherence estimated
            end
            % store function outputs at each trial, for each orienation
            store_rho{orx}  = trial_rho;                                   % orientation x trial struct
            store_lags{orx} = trial_lags;                                  % ""
            store_cxy{orx}  = trial_cxy;                                   % ""
            store_frqs{orx} = trial_frqs;                                  % ""
        end
        rho_all{ix}  = store_rho;                                          % contact x orientation x trial struct
        lags_all{ix} = store_lags;                                         % ""
        cxy_all{ix}  = store_cxy;                                          % ""
        frqs_all{ix} = store_frqs;                                         % ""
    end

    % SPONTANEOUS RESPONSES
    if stimON == 0
        % compute at every trial (trx)
        for trx=1:size(lfp_response, 1)
            % downsample the Vm data
            Vm_data_ds = decimate(Vm_response(trx,:), Vm_fs/lfp_fs);       % downsample from Vm_fs to lfp_fs
            lfp_data   = squeeze(lfp_response(trx, ix, :));                % reformat data to match Vm-dim
            [rho, lags]  = xcorr(lfp_data, Vm_data_ds, ...
                'coeff');                                                  % returns a correlation coefficient with 'coeff' function input
            [cxy, frqs]  = mscohere(lfp_data, Vm_data_ds, ...
                [], [], [], lfp_fs);                                       % coherence estimation with default function inputs sampled at lfp_fs
            trial_rho{trx}  = rho;                                         % trial struct of correlation coefficients
            trial_lags{trx} = lags;                                        % trial struct of lags
            trial_cxy{trx}  = cxy;                                         % trial struct of coherence estimations
            trial_frqs{trx} = frqs;                                        % trial struct of frequences at which coherence estimated
        end
        rho_all{ix}  = trial_rho;                                          % contact x trial struct
        lags_all{ix} = trial_lags;                                         % contact x trial struct
        cxy_all{ix}  = trial_cxy;                                          % contact x trial struct
        frqs_all{ix} = trial_frqs;                                         % contact x trial struct
    end

end

end

