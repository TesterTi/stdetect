function [loss, results] = evaluate_performance(args, alpha, external)

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


%%%%%%%%%%%%%%%%%%%%%%
% SET VARIABLES
%%%%%%%%%%%%%%%%%%%%%%

dimensionality   = 3;

testing_settings = 0; % Generates evaluation performance using one spectrogram for rapid genetic algorithm testing

%%%%%%%%%%%%%%%%%%%%%%


fprintf('External: %.4f, Beta %.4f, Walk: %.4f, Width: %d, Height: %d, Spectrogram: ', args(1), args(2), args(3), args(4), args(5));

p = snake_param();
p = set(p, 'Gamma', args(1));
p = set(p, 'Beta', args(2));
p = set(p, 'WalkRate', args(3));
p = set(p, 'WindowWidth', args(4));
p = set(p, 'WindowHeight', args(5));

if exist('alpha', 'var') && ~isempty(alpha)
    p = set(p, 'InternalEnergy', 'original');
    p = set(p, 'Alpha', alpha);
end

filters  = train_PCA_filters(p, dimensionality);
gaussian = train_Gauss(filters, p);
nets = train_Classifiers(p, dimensionality);

[pathlist, filenamelist] = getTrainingList;

out_of_range = [ceil(p.windowHeight/2)+(p.snakeLength/2), floor(p.windowHeight/2)+ceil(p.snakeLength/2)];
    
if ~testing_settings
    
    ind = [1:105, 211:305, 391:475, 561:645];
    
    pathlist     = {pathlist{ind}};
    filenamelist = {filenamelist{ind}};
    
    results = zeros(numel(filenamelist), 3);
    line_location_results = zeros(numel(filenamelist), 1);
    
    for j = 1:numel(filenamelist)
        
        fprintf('%3d of %3d', j, numel(filenamelist));
        
        spectrogram = load_Spectrogram([pathlist{j} filenamelist{j}], 1);
        
        detection   = analyse_Spectrogram(spectrogram, external, [], p, nets, filters, gaussian);

        [spectrogram.template, detection]        = extract_fundamental(spectrogram.template, detection);

        [results(j,:), line_location_results(j)] = testmetrics(detection(out_of_range(1):spectrogram.size(1)-out_of_range(2),:), spectrogram.template(out_of_range(1):spectrogram.size(1)-out_of_range(2),:));
        
        fprintf('\b\b\b\b\b\b\b\b\b\b');
    end
else
    
    ind = randperm(numel(pathlist));
    
    spectrogram = load_Spectrogram([pathlist{ind(1)} filenamelist{ind(1)}], 1);
    
    detection = analyse_Spectrogram(spectrogram, external, [], p, nets, filters, gaussian);
    
    [spectrogram.template, detection] = extract_fundamental(spectrogram.template, detection);
    
    [results,line_location_results] = testmetrics(detection(out_of_range(1):spectrogram.size(1)-out_of_range(2),:), spectrogram.template(out_of_range(1):spectrogram.size(1)-out_of_range(2),:));
    
end

results = mean(results, 1);
loss = 1-mean(line_location_results);