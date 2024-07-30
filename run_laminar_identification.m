%% run_laminar_identification.m
% Written by Dr. Sageanne Senneff
% Taillefumier Lab
% August 2nd, 2024

function [startinglowfreq, endinglowfreq, startinghighfreq, ...
    endinghighfreq, goodnessvalue, superficialchannel, deepchannel, ...
    highfreqmaxchannel, lowfreqmaxchannel, crossoverchannel...
    ] = run_laminar_identification(power_map, id_type, lowfreqrange, ...
        highfreqrange, contactdist, maxfreq, freqbin)
% run_laminar_identification.m requires the following inputs:
% power_map     = matrix of power values across electrode contacts
%                 probe_data is the output from get_power_map.m
% id_type       = identification algorithm type 
%                 1: FLIP
%                 0: vFLIP
% lowfreqrange  = alpha/beta range of frequency values
% highfreqrange = gamma range of frequency values
% contactdist   = distance between probe electrode contacts(microns)
% maxfreq       = maximum frequency allowed for identification
% freqbin       = frequency bin size (typically 1 Hz)
%
% run_laminar_identification.m has the following outputs:
% (from DOI 10.1038/s41593-023-01554-7; see below)
% startinglowfreq    = lower bound of alpha/beta frequency range
% endinglowfreq      = upper bound of alpha/beta frequency range
% startinghighfreq   = lower bound of gamma frequency range
% endinghighfreq     = upper bound of gamma frequency range
% goodnessvalue      = goodness-of-fit value from (v)FLIP
% superficialchannel = electrode contact closest to surface
% deepchannel        = deepest elecrode contact
% highfreqmaxchannel = channel wherein gamma LFP power peaks
% lowfreqmaxchannel  = channel wherein alpha/beta LFP power peaks
% crossoverchannel   = switch from superficial to deep layer contacts
% !!!For more information on FLIP/vFLIP, see the paper!!! 
%  https://doi.org/10.1038/s41593-023-01554-7
%  "A ubiquitous spectrolaminar motif of local field potential power across
%  the primate cortex" Nature Neuroscience, 2024

%%

% set-up algorithm options
lamsize     = size(power_map, 1);                                          % size of the laminar probe (contact number)
laminaraxis = 0:contactdist:contactdist*(lamsize-1);                       % laminar axis spacing      (distance between contacts)
freqaxis    = 1:freqbin:maxfreq;                                           % frequency axis spacing    (fidelity of FLIP)

% run frequency-based layer identification protocol (FLIP)
% or the optimized version (vFLIP)
% with FLIPAnalysis.m 
%  https://doi.org/10.1038/s41593-023-01554-7
%  "A ubiquitous spectrolaminar motif of local field potential power across
%  the primate cortex" Nature Neuroscience, 2024
[startinglowfreq,endinglowfreq,startinghighfreq,endinghighfreq, ...
    goodnessvalue,superficialchannel,deepchannel,highfreqmaxchannel, ...
    lowfreqmaxchannel,crossoverchannel] = FLIPAnalysis(...
                                            power_map,laminaraxis,freqaxis,id_type,lowfreqrange,highfreqrange);

end