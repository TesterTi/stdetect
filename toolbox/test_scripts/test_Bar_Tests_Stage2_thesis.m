function [tpr, fpr] = test_Bar_Tests_Stage2_thesis(length, THRESHOLD)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Called by the main function test_Bar_fixedscale.m if the boolean 
%   'thesis' is set
%   
%   Loops through the training database testing the bar 
%   convolution detector performance with the specified threshold.
%    
%   reads results from under the directory of the toolbox, i.e.
%   .\test_scripts\results\bar_fixedscale\
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

    save_path = ['.' filesep 'test_scripts' filesep 'results' filesep 'bar_fixedscale' filesep];
    
    [pathlist, filenamelist] = getTrainingList;
    
    trainingcount = 0;
    tpr = zeros(1, numel(THRESHOLD));
    fpr = zeros(1, numel(THRESHOLD));
    for i = 1:numel(filenamelist)
        fprintf('Load Spectrogram...%s ...', filenamelist{i});
        spectrogram = load_Spectrogram([pathlist{i}, filenamelist{i}], 1);
        fprintf('Done\n');
        
        [tpr_score, fpr_score] = test(spectrogram, length, THRESHOLD, filenamelist{i}, save_path);
        tpr = tpr + tpr_score;
        fpr = fpr + fpr_score;
        
        trainingcount = trainingcount + 1;
        fprintf('Done\n');
        
        fprintf('\n');
    end
    
    tpr = tpr / trainingcount;
    fpr = fpr / trainingcount;
end



function [tpr_score, fpr_score] = test(spectrogram, length, THRESHOLD, filename, save_path)

    detection = load([save_path filename(1:end-4) ,'.mat']);
    
    fprintf('Testing thresholds...');
    tpr_score = zeros(1,numel(THRESHOLD));
    fpr_score = zeros(1,numel(THRESHOLD));
    
    spectrogram.template = spectrogram.template(length+1:end, length+1:end-length);
    
    for i = 1:numel(THRESHOLD)
        thresholded = detection.intensity > THRESHOLD(i);

        thresholded = thresholded(length+1:end, length+1:end-length);
        [tpr_score(i), fpr_score(i)] = roc_rate(thresholded, spectrogram.template);
    end
    
    %save([path, 'results', filesep, 'barfull', filesep, filename], 'tpr_score', 'fpr_score', 'THRESHOLD');
    fprintf('Done\n');
    fprintf('\n');
end