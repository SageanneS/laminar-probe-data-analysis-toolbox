%% compute_power_map.m
% Written by Dr. Sageanne Senneff
% Taillefumier Lab
% August 2nd, 2024

function power_map = compute_power_map(filedir, stimcontrast)
% compute_power_map.m requires the following inputs:
% filedir      = folder directory of the data file to be analyzed
% stimcontrast = stimulus contrast level to be analyzed
%                Know your dataset, but there are generally 2-4 levels of
%                stimulus contrast, indexed from lowest to highest
%                contrast, i.e. index "end" = highest contrast level
%
% compute_power_map.m has the following outputs:
% power_map    = matrix of normalized psd values required as an input to
%                the (v)FLIP algorithm (see run_laminar_identification.m)

%%
% load in the laminar probe data file
load(filedir);

% grab the lfp time series for the response period
lfp_ts    = data.lfp_stim;                                                 % lfp time series 
lfp_on    = data.stimOnset;                                                % time of stimulus onset/response onset
twindow   = 1.0;                                                           % duration of response period to analyze (sec)
fs        = 1000;                                                          % sampling frequency (msec)
lfp_off   = lfp_on + twindow*fs;                                           % time of response offset

% select a stimulus contrast level
lfp_contrast       = lfp_ts(stimcontrast, :);                              % end == high contrast stimulus
% grab lfp time series in response to each stimulus orientation
orientation        = data.orientation;                                     % stimulus orientation
lfp_struct         = cell(size(orientation));                              % data structure for storing the lfp
for ix = 1:length(orientation) 
    data_temp      = lfp_contrast{ix};
    lfp_struct{ix} = data_temp(:,:, lfp_on:lfp_off); 
end

% welch's power spectral density estimate
nfft     = fs;                                                             % frequency bin size (1 Hz)
f_max    = 150;                                                            % upper frequency bound for analysis
for ix = 1:length(orientation)
    num_trials = size(lfp_struct{ix}, 1);
    for jx = 1:num_trials % compute for each trial
       call_sample = lfp_struct{ix};
       call_sample = call_sample(jx, :, :);
       call_sample = squeeze(call_sample);                                 % grab lfp data for trial jx
        for wx=1:size(call_sample, 1)
           % notch filter the data at 60 Hz due to hardware noise
           d = designfilt('bandstopiir', 'FilterOrder', 2, ...             % notch filter design
               'HalfPowerFrequency1', 59, 'HalfPowerFrequency2', 61, ...
               'DesignMethod','butter','SampleRate',fs);
           y = filtfilt(d, call_sample(wx,:)');                            % applying the notch filter
           [pxx, f] = pwelch(y, [], [], fs, fs, 'twosided', 'power');      % compute the psd across all frequencies
           pxx_pow(wx, :) = pxx;
        end
        pow{jx}    = pxx_pow(:, 1:f_max);                                  % store the estimate at each trial for 0 to f_max Hz
    end
    % non-normalized power
    pow_all{ix} = pow;                                                     % store all trial estimates at each orientation
end

% average psd estimates across orientations
laminar_pow = cell(size(orientation));
for ix   = 1:length(orientation)
    
    temp = pow_all{ix};
    dim  = ndims(temp);                                                    % number of array dimensions
    M    = cat(dim+1,temp{:});                                             % convert to a (dim+1)-dimensional matrix
    
    meanArray       = mean(M,dim+1);                                       % get the mean across the matrix
    laminar_pow{ix} = meanArray;                                           % save the matrix power map for each orientation
end
dim         = ndims(laminar_pow);
M           = cat(dim+1, laminar_pow{:});          
meanArray   = mean(M,dim+1);
laminar_pow = meanArray;                                                   % average the matrix power maps

% normalize the power
max_pow = max(laminar_pow');                                               % max psd value at each laminar depth
[M,I]   = max(max_pow(:));
rel_pow = laminar_pow/M; 

% output normalized power map
power_map = rel_pow;

end

