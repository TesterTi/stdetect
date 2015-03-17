function [filters,  trdata, trgt] = train_PCA_filters(p, dimensionality)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   TRAIN_PCA_FILTERS Trains PCA filters
%       FILTERS = TRAIN_PCA_FILTERS(P) Trains the PCA filters for using the
%       parameters set in P and returns them as a structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2007, 2010 Thomas Lampert
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

output_plots                = 0;

number_of_vectors           = dimensionality;

live_data                   = 1;

number_of_training_samples  = 2000; % The number of samples used to train the classifiers, this is the total of both classes

snr                         = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if number_of_vectors > p.windowWidth*p.windowHeight
    fprintf(2, 'Warning: Number of PCA dimensions is greater than the dimensionality \n\t     of the original space. Reverting to original space dimensionality.\n');
    number_of_vectors = p.windowWidth*p.windowHeight;
end

if p.windowWidth ~= 3 || p.windowHeight ~= 21
    live_data = 1;
end
    
if live_data
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
    %spectrograms{4} =
    %load_Spectrogram(['./examples/training_data/ip_test_data_P1_V_2_'
    %num2str(snr) '_2.dat'], 1);
    
    count = count - 1;
    
    if count == 0
        filters = [];
        fprintf(2, 'Error: could not load training data\n');
        return;
    end
    if count < 3
        fprintf(2, 'Warning: could not load all the training data. \nContinuing with a reduced amount of training data, accuracy may be compromised.\n')
    end
    
    spectrograms = spectrograms(randperm(count));
    
    trdata  = [];
    trgt    = [];
    
    while size(trdata, 1) < number_of_training_samples
        for i = 1:numel(spectrograms)
            [trdata2, trgt2] = label_Spectrogram(spectrograms{i}.z_spec(200:end,:), spectrograms{i}.template(200:end,:), p.windowWidth, p.windowHeight);
            %[trdata2, trgt2] = label_Spectrogram(spectrograms{i}.z_spec, spectrograms{i}.template, p.windowWidth, p.windowHeight);
            trdata           = [trdata; trdata2];
            trgt             = [trgt; trgt2];
        end
    end
    clear 'trdata2' 'trgt2'
    
    data_index = randperm(size(trdata, 1));
    trdata = trdata(data_index, :);
    trgt = trgt(data_index, :);
else
    load 'trdata-3x21-120';
    trdata = trdata([1:1000, 1905:2905], :);
    trgt = trgt([1:1000, 1905:2905], :);
end


%[trdata, I] = scale(trdata, 1, I);
[trdata, trgt] = evenClasses(trdata, trgt, floor(number_of_training_samples/2));

% Subtract the minimum value in the window to create a relative feature
if p.relativeWindow
    trdata = trdata - repmat(min(trdata, [], 2), 1, size(trdata, 2));
end

%fprintf('Training PCA Window feature classifier...\n');
% Train classifier for window analysis
[pccoeff, pcvec] = pca(trdata);

%data.X = trdata';
%data.y = zeros(1, size(trdata, 1));
%data.y(trgt(:,1)==1) = 1;
%data.y(trgt(:,2)==1) = 2;
%[model] = lda(data);
%pccoeff = model.eigval;

pcvec = pcvec(:, 1:number_of_vectors);

%plot(cumsum(pccoeff)/max(cumsum(pccoeff)), '.-r');

filters.templates = zeros(p.windowHeight, p.windowWidth, number_of_vectors);

for i = 1:size(pcvec, 2)
    filters.templates(:,:,i) = reshape(pcvec(:,i), p.windowHeight, p.windowWidth);
end

filters.window_Width = p.windowWidth;
filters.window_Height = p.windowHeight;


%if output_plots
%     figure, subplot(2,2,1), surf(reshape(pcvec(:,1), p.windowHeight, p.windowWidth))
%     title('1st Principal Component');
%     axis([1 p.windowWidth 1 p.windowHeight min([min(pcvec(:,1)), min(pcvec(:,2)), min(pcvec(:,1)+pcvec(:,2))]) max([max(pcvec(:,1)+pcvec(:,2)), max(pcvec(:,1)), max(pcvec(:,2))])]);
%     subplot(2,2,2), surf(reshape(pcvec(:,2),p.windowHeight,p.windowWidth))
%     title('2nd Principal Component');
%     axis([1 p.windowWidth 1 p.windowHeight min([min(pcvec(:,1)), min(pcvec(:,2)), min(pcvec(:,1)+pcvec(:,2))]) max([max(pcvec(:,1)+pcvec(:,2)), max(pcvec(:,1)), max(pcvec(:,2))])]);
%     figure, subplot(2,2,1), surf(reshape(pcvec(:,3),p.windowHeight,p.windowWidth))
%     title('3rd Principal Component');
%     axis([1 p.windowWidth 1 p.windowHeight min([min(pcvec(:,1)), min(pcvec(:,2)), min(pcvec(:,1)+pcvec(:,2))]) max([max(pcvec(:,1)+pcvec(:,2)), max(pcvec(:,1)), max(pcvec(:,2))])]);
    %subplot(2,2,3), surf(reshape(pcvec(:,2),p.windowHeight,p.windowWidth) + reshape(pcvec(:,1), p.windowHeight, p.windowWidth))
    %title('1st+2nd Principal Component');
    %axis([1 p.windowWidth 1 p.windowHeight min([min(pcvec(:,1)), min(pcvec(:,2)), min(pcvec(:,1)+pcvec(:,2))]) max([max(pcvec(:,1)+pcvec(:,2)), max(pcvec(:,1)), max(pcvec(:,2))])]);

    %figure, subplot(2,1,1), plot(pccoeff/sum(pccoeff), '.-r');
    %axis([1 numel(pccoeff) 0 1]);
    %title('PCA Coefficients');
    %figure, subplot(2,1,1), plot([cumsum(pccoeff)./sum(pccoeff)]', '.-b');
    %axis([1 numel(pccoeff) 0 1]);
    %title('Cumulative PCA Coefficients');
    %axis([1 p.windowHeight*p.windowWidth 0 1]);
%end

end