function F = line_location_accuracy(d, t)

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


% J-C. Di Martino, S. Tabbone - An Approach to Detect Lofar Lines

% d = detected features
% t = template

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alpha = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[x,y] = find(t > 0);
A_points = [x,y];
I_a = numel(x);

[x,y] = find(d > 0);
I_points = [x,y];
I_i = numel(x);

s = 0;
for i = 1:size(I_points, 1)
    
    if I_a > 0
        d = sqrt(sum((A_points - I_points(i*ones(size(A_points,1), 1), :)).^2, 2));
        s = s + (1/(1 + (alpha * min(d)^2)));
    end
end

if max(I_a, I_i) > 0
    F = (1/max(I_a, I_i)) * s;
else
    if (I_a == 0) && (I_i == 0)
        F = 1;
    end
end