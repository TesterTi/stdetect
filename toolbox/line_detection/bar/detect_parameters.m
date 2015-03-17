function [theta_index, length_index, strength] = detect_parameters(response)

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

response_normalised = (1/std(reshape(response, numel(response), 1))) * (response - mean(mean(response)));

% To find the angle: the line will have a constant angle so will form a
% straight detection in the parameter space, summing along the theta axis
% and calculating the maximum (above a threshold) will detect the angle,
% theta.
[~, theta_index] = max(sum(response_normalised, 1)/size(response_normalised, 1));
length_vector = response_normalised(:, theta_index);

% to find the length of this detection we extract the column corresponding
% to the detected theta....
length_threshold = max(length_vector) - ((max(length_vector) - min(length_vector)) * (3/4));
indexes = find(length_vector <= length_threshold);

if numel(indexes) > 0
    length_index = indexes(1);
else
    length_index = size(response_normalised, 1);
end


strength = sum(response(1:length_index, theta_index))/length_index;
%strength = sum(length_vector(1:length_index))/length_index;