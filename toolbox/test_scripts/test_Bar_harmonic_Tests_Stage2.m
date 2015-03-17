function [tpr, fpr] = test_Bar_harmonic_Tests_Stage2(bars, lengths, THRESHOLD)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Called by main function test_Bar_multiscale_harmonic
%   
%   Loops through the training database testing the bar 
%   convolution detector performance with the specified threshold.
%
%   results are read from under the directory of the toolbox, i.e.
%   .\test_scripts\results\bar_multiscale_harmonic\
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

    [pathlist, filenamelist] = getTrainingList;
    
    save_path = ['.' filesep 'test_scripts' filesep 'results' filesep 'bar_multiscale_harmonic' filesep];
    
    trainingcount = 0;
    tpr = zeros(1, numel(THRESHOLD));
    fpr = zeros(1, numel(THRESHOLD));
    parfor i = 1:numel(filenamelist)
            
        fprintf('Load Spectrogram...%s ...', filenamelist{i});
        spectrogram = load_Spectrogram([pathlist{i}, filenamelist{i}], 1);
        fprintf('Done\n');

        [tpr_score, fpr_score] = test(spectrogram, bars, lengths, THRESHOLD, filenamelist{i}, save_path);

        tpr = tpr + tpr_score;
        fpr = fpr + fpr_score;

        trainingcount = trainingcount + 1;
        
    end
    
    tpr = tpr / trainingcount;
    fpr = fpr / trainingcount;
end



function [tpr_score, fpr_score] = test(spectrogram, bars, lengths, THRESHOLD, filename, save_path)
 
    detection = load([save_path, filename(1:end-4) ,'.mat']);
    
    detection.theta = detection.theta;
    detection.length = detection.length;
    detection.intensity = detection.intensity;
    detection.theta_index = detection.theta_index;
    detection.length_index = detection.length_index;
    
    fprintf('Testing thresholds...');
    tpr_score = zeros(1,numel(THRESHOLD));
    fpr_score = zeros(1,numel(THRESHOLD));
    
    [temp, spectrogram.template] = integrate_harmony_locations(spectrogram);
    spectrogram.template = spectrogram.template(max(lengths)+1:end, max(lengths)+1:end-max(lengths));
    
    for i = 1:numel(THRESHOLD)
        thresholded = reconstruct_Image(detection.theta, detection.length, detection.intensity, detection.theta_index, detection.length_index, bars, THRESHOLD(i), lengths);
        thresholded = thresholded(max(lengths)+1:end, max(lengths)+1:end-max(lengths));

        [tpr_score(i), fpr_score(i)] = roc_rate(thresholded, spectrogram.template);
    end
    
    fprintf('Done\n');
    fprintf('\n');
end