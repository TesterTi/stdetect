function [theta, length, intensity, theta_index, length_index] = bardetect(spectrogram, lengths)

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


theta = zeros(spectrogram.size(1), spectrogram.size(2));
length = zeros(spectrogram.size(1), spectrogram.size(2));
intensity = zeros(spectrogram.size(1), spectrogram.size(2));
length_index = zeros(spectrogram.size(1), spectrogram.size(2));
theta_index = zeros(spectrogram.size(1), spectrogram.size(2));

bars = cell(1, numel(lengths));
for l = 1:numel(lengths)
    bars{l} = create_Bar_Masks(lengths(l), 1, 0:-0.05:-(pi/2));
end

for g = max(lengths)+1:spectrogram.size(1)
    for h = max(lengths)+1:spectrogram.size(2)-max(lengths)
        
        pixel_response = zeros(numel(lengths), numel(bars{1}.theta));
        
        for l = 1:numel(lengths)
            if g > lengths(l) && h > lengths(l) && h <= spectrogram.size(2)-lengths(l)
                b = bars{l};
                
                % Loop through each angle
                for tindex = 1:numel(b.theta)
                    
                    % Average pixels encompassed by the bar
                    pixel_response(l, tindex) = sum(sum(spectrogram.z_spec(g-b.barLength+1:g, h-b.barLength+1:h+b.barLength-1) .* b.templates(:, :, tindex))) / b.pixelCount(tindex);
                end
            end
        end
        
        [theta_ind, length_ind, strength] = detect_parameters(pixel_response);
        
        theta(g, h) = b.theta(theta_ind);
        length(g, h) = lengths(length_ind);
        intensity(g, h) = strength;
        
        theta_index(g, h) = theta_ind;
        length_index(g, h) = length_ind;
    end
end