function test_Bar_harmonic_Tests_Stage1(max_val, lengths)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Called by main function test_Bar_multiscale_harmonic
%   
%   Loops through the training database and determines detection
%   performance by loading the detections performed in
%   train_Bar_Tests_Stage1
%
%   stores results under the directory of the toolbox, i.e.
%   .\test_scripts\results\bar_multiscale_harmonic\
%   and will require approximately 2GB of available disk space, the files
%   contained within this folder can be deleted after completion.
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

    save_path = ['.' filesep 'test_scripts' filesep 'results' filesep 'bar_multiscale_harmonic' filesep];
    
    [pathlist, filenamelist] = getTrainingList;
    
    parfor i = 1:numel(filenamelist)
        
        fprintf('Load Spectrogram...%s ...', filenamelist{i});
        spectrogram = load_Spectrogram([pathlist{i}, filenamelist{i}], 1);
        fprintf('Done\n');
        
        fprintf('Transform Spectrogram....');
        spectrogram.z_spec = integrate_harmony_locations(spectrogram);
        spectrogram.size = size(spectrogram.z_spec);
        fprintf('Done\n');
        
        [theta, length, intensity, theta_index, length_index] = test(spectrogram, lengths, max_val);
        
        save_results([save_path filenamelist{i}(1:end-4) '.mat'], theta, length, intensity, theta_index, length_index);
        
        fprintf('Done\n');
        fprintf('\n');
    end
end


function [theta, length, intensity, theta_index, length_index] = test(spectrogram, lengths, max_val)
    fprintf('Running Detection...');
    spectrogram.z_spec = scale(spectrogram.z_spec, 255, max_val);
    [theta, length, intensity, theta_index, length_index] = bardetect(spectrogram, lengths);
    fprintf('Done\n');
end

function save_results(filename, theta, length, intensity, theta_index, length_index)
    save(filename, 'theta', 'length', 'intensity', 'theta_index', 'length_index');
end