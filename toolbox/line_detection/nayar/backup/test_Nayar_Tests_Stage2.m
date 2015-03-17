function [tpr, fpr] = test_Nayar_Tests_Stage2(THRESHOLDS, windowsize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    
%   Called by main function test_Nayar
%   
%   Loops through the responses calculated using train_Nayar_Tests_Stage1
%   calculaing the tpr and fpr using the thresholds specified.
%    
%   reads results from under the director specified by path.txt, i.e.
%   .\test_scripts\results\nayar\
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

    save_path = ['.' filesep 'test_scripts' filesep 'results' filesep 'nayar' filesep];
    
    [pathlist, filenamelist] = getTrainingList;
    
    tpr = zeros(1, numel(THRESHOLDS));
    fpr = zeros(1, numel(THRESHOLDS));
    
    trainingcount = 0;
    parfor i = 1:numel(filenamelist)
        fprintf('Load Spectrogram...%s ...', filenamelist{i});
        spectrogram = load_Spectrogram([pathlist{i}, filenamelist{i}], 1);
        fprintf('Done\n');
        
        [tpr_score, fpr_score] = test(spectrogram, THRESHOLDS, windowsize, save_path, [filenamelist{i}(1:end-4) '.mat']);
        tpr = tpr + tpr_score;
        fpr = fpr + fpr_score;
        
        trainingcount = trainingcount + 1;
        fprintf('Done\n');
        
        fprintf('\n');
    end
    
    tpr = tpr / trainingcount;
    fpr = fpr / trainingcount;
end


function [tpr_score, fpr_score] = test(spectrogram, THRESHOLDS, windowsize, save_path, filename)
    
    response = load([save_path, filename]);
    response = response.response;
    
    spectrogram.template = spectrogram.template(ceil(windowsize/2):end-floor(windowsize/2), ceil(windowsize/2):end-floor(windowsize/2));
    response = response(ceil(windowsize/2):end-floor(windowsize/2), ceil(windowsize/2):end-floor(windowsize/2));
    
    tpr_score = zeros(1,numel(THRESHOLDS));
    fpr_score = zeros(1,numel(THRESHOLDS));
    
    fprintf('Running Detection...');
    for i = 1:numel(THRESHOLDS)
        detection = zeros(size(response));
        detection(response < THRESHOLDS(i)) = 1;
        
        [tpr_score(i), fpr_score(i)] = roc_rate(detection, spectrogram.template);
    end
    fprintf('Done\n');
    
    fprintf('\n');
end