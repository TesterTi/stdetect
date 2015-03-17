function detection = run_bardetection(spectrogram, length, threshold)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   RUN_BARDETECTION todo:description
%       DETECTION = RUN_BARDETECTION(SPECTROGRAM, LENGTH, THRESHOLD)
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


if all(spectrogram.size(1) < length) || all(spectrogram.size(2) < length)
    error('Image size must match bar length');
end

width = 1;

for i = 1:numel(length)
	bars{i} = create_Bar_Masks(length(i), width, 0:-0.05:-(pi/2));
end

[theta, lengths, intensity, theta_index, length_index] = bardetect(spectrogram, length);

detection = reconstruct_Image(theta, lengths, intensity, theta_index, length_index, bars, threshold, length);
