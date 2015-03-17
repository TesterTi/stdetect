function gaussian = train_Gauss(filters, p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   CREATE_GAUSSIAN todo:description
%       GAUSSIAN = CREATE_GAUSSIAN(FILTERS)
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2009, 2010 Thomas Lampert
%
%
%   This file is part of STDetect.
%
%   STDetect is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   STDetect is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with STDetect. If not, see <http://www.gnu.org/licenses/>.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

number_of_training_samples  = 2000; % The number of samples used to train the classifiers, this is the total of both classes

snr                         = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%path = getDataPath();
    
count = 1;
temp_spec = load_Spectrogram(['./examples/training_data/ip_test_data_P1_V_1_' num2str(snr) '_1.dat'], 1);
if ~isempty(temp_spec.z_spec) && ~isempty(temp_spec.template)
    spectrograms{count} = temp_spec;
    count = count + 1;
end
temp_spec = load_Spectrogram(['./examples/training_data/ip_test_data_P1_V_1_' num2str(snr) '_2.dat'], 1);
if ~isempty(temp_spec.z_spec) && ~isempty(temp_spec.template)
    spectrograms{count} = temp_spec;
    count = count + 1;
end
temp_spec = load_Spectrogram(['./examples/training_data/ip_test_data_P1_V_2_' num2str(snr) '_1.dat'], 1);
if ~isempty(temp_spec.z_spec) && ~isempty(temp_spec.template)
    spectrograms{count} = temp_spec;
    count = count + 1;
end
temp_spec = load_Spectrogram(['./examples/training_data/ip_test_data_P1_V_2_' num2str(snr) '_2.dat'], 1);
if ~isempty(temp_spec.z_spec) && ~isempty(temp_spec.template)
    spectrograms{count} = temp_spec;
    count = count + 1;
end
count = count - 1;

if count == 0
    gaussian = [];
    fprintf(2, 'Error: could not load training data\n');
    return;
end
if count < 4
    fprintf(2, 'Warning: could not load all the training data. \nContinuing with a reduced amount of training data, accuracy may be compromised.\n')
end

spectrograms = spectrograms(randperm(count));

trdata  = [];
trgt    = [];
    
while size(trdata, 1) < number_of_training_samples
    for i = 1:numel(spectrograms)
        [trdata2, trgt2] = label_Spectrogram(spectrograms{i}.z_spec(200:end,:), spectrograms{i}.template(200:end,:), p.windowWidth, p.windowHeight);
        trdata           = [trdata; trdata2];
        trgt             = [trgt; trgt2];
    end
end
clear 'trdata2' 'trgt2'
    
data_index = randperm(size(trdata, 1));
trdata = trdata(data_index, :);
trgt = trgt(data_index, :);
    
[trdata, trgt] = evenClasses(trdata, trgt, floor(number_of_training_samples/2));


% Subtract the minimum value in the window to create a relative feature
if p.relativeWindow
    trdata = trdata - repmat(min(trdata, [], 2), 1, size(trdata, 2));
end


for i = 1:size(filters.templates, 3)
    pcvec(:,i) = reshape(filters.templates(:,:,i), 1, filters.window_Width*filters.window_Height);
end


%trdata = trdata - repmat(mean(trdata, 1), size(trdata, 1), 1);

trd = trdata*pcvec;

noisetrdata = findClass(trd, trgt, 2);
noisetrdata_original = findClass(trdata, trgt, 2);

gaussian.Mu = mean(noisetrdata);
%gaussian.Mu = mean(noisetrdata_original);

gaussian.Covar = 2*diag(std(noisetrdata));
