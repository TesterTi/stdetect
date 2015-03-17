function [result, template, x_axis] = integrate_harmony_locations(spectrogram)

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

harmony_number = 5;

harmony_set = [1 2 3 4 5];
count = 1;
for i = 1:(1/harmony_number):spectrogram.size(2)/harmony_number
    
    harmony_locations = round(harmony_set * i);
    
    valid_index = harmony_locations < spectrogram.size(2);
    
    if sum(valid_index) > 0
        result(:, count) = sum(spectrogram.z_spec(:, harmony_locations(valid_index)), 2)/sum(valid_index);
        
        template(:, count) = sum(spectrogram.template(:, harmony_locations(valid_index)), 2)/sum(valid_index);
        
        x_axis(count)    = i;
        count = count + 1;
    end
end

limit = 0.7;

template(template < limit) = 0;
template(template >= limit) = 1;