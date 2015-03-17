function [mx] = findMax()


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


% Value for provided dataset has been stored (it's quicker)
try 
    load maxSpectrogramVal;
catch e
    printf('Could not load stored maximum value.\n');
    printf('Proceeding to scan training data set for maximum... this could take a long time!\n');

    mx = -1000;

    mx_SNR = -1000;
    mn_SNR = 1000;

    [pathlist, filenamelist] = getTrainingList;

    for i = 1:numel(filenamelist)
       fprintf('Load Spectrogram...%s ...', filenamelist{i});
       spectrogram = load_Spectrogram([pathlist{i}, filenamelist{i}], 1);

       m = max(max(spectrogram.z_spec));

       if m > mx
           mx = m;
       end

       if spectrogram.snr > mx_SNR
           mx_SNR = spectrogram.snr;
       end

       if spectrogram.snr < mn_SNR
           mn_SNR = spectrogram.snr;
       end
    end
end