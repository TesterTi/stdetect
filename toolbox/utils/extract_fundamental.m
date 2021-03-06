function [template, detection] = extract_fundamental(template, detection)


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



template(template == max(max(template))) = 1;

for i = 1:size(template, 1)
    I = find(template(i,:) == 1);
    I = sort(I, 'ascend');
    
    if ~isempty(I)
        template(i, :)  = [template(i, 1:I(1)+2), zeros(1, size(template, 2)-(I(1)+2))];
        %detection(i, :) = [detection(i, 1:I(1)+2), zeros(1, size(detection, 2)-(I(1)+2))];
    else
        template(i, :)  = template(i, :);
    end
end