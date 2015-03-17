function net = create_Bar_Masks(barLength, barWidth, theta)

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


net.barLength = barLength;
net.barWidth  = barWidth;

% Theta is reflected at the end of this function
%net.theta = 0:-0.05:-(pi/2);
net.theta     = theta;


% Create Masks
templates = zeros(net.barLength, (net.barLength*2)-1, (numel(net.theta)*2)-1);
pixelCount = zeros(numel(net.theta), 1);
for j = 1:numel(net.theta)
    
    templates(:,:,j) = create_bar(net.theta(j), net.barLength, net.barWidth);
    
    pixelCount(j) = numel(find(templates(:,:,j) == 1));
end

count = 1;
for j = numel(net.theta)-1:-1:1
    templates(:,:,numel(net.theta)+count) = reverse(templates(:,:,j));
    
    pixelCount(numel(net.theta)+count) = numel(find(templates(:,:,numel(net.theta)+count) == 1));
    
    count = count + 1;
end

%net.theta = -(pi/2):0.05:(pi/2);
net.theta = [net.theta(end:-1:2), net.theta];
net.templates = templates;
net.pixelCount = pixelCount;