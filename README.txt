## Project Title

Laminar Probe Data Analysis Toolbox

## Introduction

This project contains a set of MATLAB scripts for analyzing laminar probe data, particularly focusing on local field potential (LFP) and membrane potential (Vm) responses to various stimuli. The toolbox includes functionalities for computing power maps, running laminar identification protocols, and quantifying synchrony across electrode contacts.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Dependencies](#dependencies)
- [Configuration](#configuration)
- [Documentation](#documentation)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributors](#contributors)
- [License](#license)

## Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   ```
2. **Navigate to the project directory:**
   ```bash
   cd <project_directory>
   ```
3. **Open MATLAB and add the project directory to your path:**
   ```matlab
   addpath(genpath('<project_directory>'))
   ```

## Usage

### Compute Power Map

To compute the power map, use the `compute_power_map.m` script:

```matlab
power_map = compute_power_map(filedir, stimcontrast);
```

### Run Laminar Identification

To run the laminar identification, use the `run_laminar_identification.m` script:

```matlab
[startinglowfreq, endinglowfreq, startinghighfreq, endinghighfreq, goodnessvalue, superficialchannel, deepchannel, highfreqmaxchannel, lowfreqmaxchannel, crossoverchannel] = run_laminar_identification(power_map, id_type, lowfreqrange, highfreqrange, contactdist, maxfreq, freqbin);
```

### Quantify Synchrony

To quantify synchrony, use the `quantify_synchrony.m` script:

```matlab
[rho_all, lags_all, cxy_all, frqs_all] = quantify_synchrony(filedir, stimcontrast, stimON, contact_num, response_dur);
```

## Features

- **Power Map Computation:** Computes normalized power spectral density (PSD) values across electrode contacts.
- **Laminar Identification:** Identifies laminar layers based on frequency ranges using the (v)FLIP algorithm.
- **Synchrony Quantification:** Quantifies correlation and coherence between LFP and Vm signals across electrode contacts.

## Dependencies

- MATLAB R2020b or later
- Signal Processing Toolbox

## Configuration

Ensure that the data files are organized in the specified directory structure and that the `filedir` parameter correctly points to the data files.

## Documentation

### `compute_power_map.m`

**Inputs:**
- `filedir` (string): Directory of the data file to be analyzed.
- `stimcontrast` (int): Stimulus contrast level to be analyzed.

**Outputs:**
- `power_map` (matrix): Normalized PSD values.

### `run_laminar_identification.m`

**Inputs:**
- `power_map` (matrix): Matrix of power values across electrode contacts.
- `id_type` (int): Identification algorithm type (1: FLIP, 0: vFLIP).
- `lowfreqrange` (vector): Alpha/beta range of frequency values.
- `highfreqrange` (vector): Gamma range of frequency values.
- `contactdist` (double): Distance between probe electrode contacts (microns).
- `maxfreq` (double): Maximum frequency allowed for identification.
- `freqbin` (double): Frequency bin size (typically 1 Hz).

**Outputs:**
- `startinglowfreq` (double): Lower bound of alpha/beta frequency range.
- `endinglowfreq` (double): Upper bound of alpha/beta frequency range.
- `startinghighfreq` (double): Lower bound of gamma frequency range.
- `endinghighfreq` (double): Upper bound of gamma frequency range.
- `goodnessvalue` (double): Goodness-of-fit value from (v)FLIP.
- `superficialchannel` (int): Electrode contact closest to surface.
- `deepchannel` (int): Deepest electrode contact.
- `highfreqmaxchannel` (int): Channel wherein gamma LFP power peaks.
- `lowfreqmaxchannel` (int): Channel wherein alpha/beta LFP power peaks.
- `crossoverchannel` (int): Switch from superficial to deep layer contacts.

### `quantify_synchrony.m`

**Inputs:**
- `filedir` (string): Directory of the data file to be analyzed.
- `stimcontrast` (int): Stimulus contrast level to be analyzed.
- `stimON` (int): User option to analyze evoked (1) or spontaneous (0) trials.
- `contact_num` (int): Number of electrode contacts on laminar probe.
- `response_dur` (double): Trial response period following stimulus.

**Outputs:**
- `rho_all` (cell array): Correlation coefficients over time at each electrode contact.
- `lags_all` (cell array): Lag distances for correlation coefficients.
- `cxy_all` (cell array): Coherence over time at each electrode contact.
- `frqs_all` (cell array): Frequencies for coherence estimation.

## Examples

### Example: Compute Power Map

```matlab
filedir = 'path/to/data';
stimcontrast = 2;
power_map = compute_power_map(filedir, stimcontrast);
```

### Example: Run Laminar Identification

```matlab
id_type = 1;
lowfreqrange = [10, 30];
highfreqrange = [75, 150];
contactdist = 0.1;
maxfreq = 150;
freqbin = 1;
[startinglowfreq, endinglowfreq, startinghighfreq, endinghighfreq, goodnessvalue, superficialchannel, deepchannel, highfreqmaxchannel, lowfreqmaxchannel, crossoverchannel] = run_laminar_identification(power_map, id_type, lowfreqrange, highfreqrange, contactdist, maxfreq, freqbin);
```

### Example: Quantify Synchrony

```matlab
filedir = 'path/to/data';
stimcontrast = 2;
stimON = 1;
contact_num = 32;
response_dur = 1.0;
[rho_all, lags_all, cxy_all, frqs_all] = quantify_synchrony(filedir, stimcontrast, stimON, contact_num, response_dur);
```

## Troubleshooting

If you encounter issues, ensure that:
- MATLAB and the required toolboxes are correctly installed.
- The data files are correctly formatted and located in the specified directory.
- All input parameters are correctly set according to the dataset and analysis requirements.

## Contributors

- Dr. Sageanne Senneff, Taillefumier Lab

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.