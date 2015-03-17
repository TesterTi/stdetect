function [tpr fpr] = test_PCA()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Method used in Chapter 3, recreates the PCA detector's results 
%   presented in Figure 3.12
%
%   Loops through the training database testing the PCA filter
%   performance with the specified threshold.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2010 Thomas Lampert
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
    
    dimensionality = 6;
    
    THRESHOLDS     = [0:0.001:0.1, 0.101:0.01:1];
    
    p = snake_param();
    
    path1 = getDataPath;
    
    [pathlist, filenamelist] = getTrainingList;
    
    tpr = zeros(10, numel(THRESHOLDS));
    fpr = zeros(10, numel(THRESHOLDS));
    
    for j = 1:10   % averages out effects of stochastic training (random sets of training data)
        
        [filters]               = train_PCA_filters(p, dimensionality);
        gaussian                = train_Gauss(filters, p);

	fpr_temp = zeros(1, numel(THRESHOLDS));
	tpr_temp = zeros(1, numel(THRESHOLDS));
        
        parfor i = 1:numel(filenamelist)
            fprintf('Load Spectrogram...%s ...', filenamelist{i});
            spectrogram = load_Spectrogram([pathlist{i}, filenamelist{i}], 1);
            fprintf('Done\n');
            
            [tpr_score, fpr_score] = test(spectrogram, filters, gaussian, THRESHOLDS, path1, filenamelist{i});
            tpr_temp               = tpr_temp + tpr_score;
            fpr_temp               = fpr_temp + fpr_score;
            
            fprintf('Done\n');
            
            fprintf('\n');
        end
    
    	
        tpr(j,:) = tpr_temp / numel(filenamelist);
        fpr(j,:) = fpr_temp / numel(filenamelist);
    
    end
    
    tpr = mean(tpr, 1);
    fpr = mean(fpr, 1);

    save(['.' filesep 'test_scripts' filesep 'results' filesep 'pca_tpr_fpr'], 'tpr', 'fpr');

    % Plot Output
    %figure, plot(fpr, tpr, '-r');
    %axis([0 1 0 1]);
    %title('PCA ROC Curve');
    %xlabel('False Positive Rate');
    %ylabel('True Positive Rate');
end


function [tpr_score, fpr_score] = test(spectrogram, filters, gaussian, THRESHOLDS, path, filename)

    fprintf('Running Detection...');

    convolved_images = pca_convolution(spectrogram.z_spec, filters);

    result = pca_gaussian(convolved_images, gaussian, filters);

    result = result(ceil(filters.window_Height/2):end-floor(filters.window_Height/2), :);
    spectrogram.template = spectrogram.template(ceil(filters.window_Height/2):end-floor(filters.window_Height/2), :);
    spectrogram.size = [spectrogram.size(1)-filters.window_Height spectrogram.size(2)];

    fprintf('Done\n');

    fprintf('Testing thresholds...');
    tpr_score = zeros(1, numel(THRESHOLDS));
    fpr_score = zeros(1, numel(THRESHOLDS));
    for i = 1:numel(THRESHOLDS)

        detection = zeros(size(result));
        detection(result < THRESHOLDS(i)) = 1;
        
        [tpr_score(i), fpr_score(i)] = roc_rate(detection, spectrogram.template);
    end
    fprintf('Done\n');

    fprintf('\n');
end