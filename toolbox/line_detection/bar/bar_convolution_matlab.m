function response = bar_convolution_matlab(x, net)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   BAR_CONVOLUTION_MATLAB todo:description
%       RESPONSE = BAR_CONVOLUTION_MATLAB(X, NET)
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


if size(x,1) < net.barLength || size(x,2) < net.barLength
    error('Image size must match bar length');
end

response = zeros(size(x));

s = zeros(numel(net.theta), 1);
for g = net.barLength:size(x, 1)
    for h = net.barLength:size(x,2)-(net.barLength-1)
        % Loop through each angle
        for tindex = 1:numel(net.theta)
            
            % Average pixels encompassed by the bar
            s(tindex) = sum(sum(x(g-net.barLength+1:g, h-net.barLength+1:h+net.barLength-1) .* net.templates(:, :, tindex))) / net.pixelCount(tindex);
        end
        
        response(g,h) = max(s);
    end
end