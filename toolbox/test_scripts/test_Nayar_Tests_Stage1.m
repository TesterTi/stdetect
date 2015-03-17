function test_Nayar_Tests_Stage1(max_val, projected_windowset, pcvec, coarse_to_fine, mask)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    
%   Called by main function test_Nayar
%   
%   Loops through the training database testing the Parametric 
%   line detector performance with the specified threshold.
%
%   stores results under the directory of the toolbox, i.e.
%   .\test_scripts\results\nayar\
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

    save_path = ['.' filesep 'test_scripts' filesep 'results' filesep 'nayar' filesep];
    
    [pathlist, filenamelist] = getTrainingList;
    
    parfor i = 1:numel(filenamelist)
        fprintf('Load Spectrogram...%s ...', filenamelist{i});
        spectrogram = load_Spectrogram([pathlist{i}, filenamelist{i}], 1);
        fprintf('Done\n');
        
        response = test(spectrogram, projected_windowset, pcvec, coarse_to_fine, mask, max_val);
        
        save_results([save_path, filenamelist{i}(1:end-4) '.mat'], response);
        
        fprintf('Done\n');
        
        fprintf('\n');
    end
end


function [response] = test(spectrogram, projected_windowset, pcvec, coarse_to_fine, mask, max_val)
    
    fprintf('Running Detection...');
    response = parametric_detect(scale(spectrogram.z_spec, max_val, 255), projected_windowset, pcvec, coarse_to_fine, mask);
    fprintf('Done\n');
    
end

function save_results(filename, response)
    save(filename, 'response');
end