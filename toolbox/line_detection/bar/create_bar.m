function temp = create_bar(theta, barLength, barWidth)

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


n = [cos(theta)', sin(theta)'];
t = [-sin(theta)', cos(theta)'];

% Set up window's pixel co-ordinate values
l = repmat([-barLength+1:0]', barLength, 1);
part2 = [];
for j = -barLength+1:0
    part2 = [part2; ones(barLength, 1)*j];
end
baseWindow = [l, part2];

nDistance = reshape(abs(dot(repmat(n, (barLength)^2, 1), baseWindow, 2)), barLength, barLength);

tDistance = reshape(abs(dot(repmat(t, (barLength)^2, 1), baseWindow, 2))', barLength, barLength);

% Threshold distances to line width and length
temp = zeros(barLength);
temp(intersect(find(nDistance <= (barWidth/2)), find(tDistance <= barLength))) = 1;
temp = [temp, zeros(size(temp,1), size(temp, 2)-1)];