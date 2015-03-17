function window = parametricline(vector, x_size, y_size)

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEATURE VECTOR CONSTRUCTION
% vector = [A, B, Th, p, w, s]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A+B = intensity of line (noise + signal)
% w = line width
% p (rho) = distance from centre of window
% s (sigma) = blurring of Gaussian smoothing (could probably remove)
% Th (theta) = perpendicular angle from vertical axis (in radians)
% F = feature vector, comprising of A, B, Th, p, w, s

% u(t) = 1 if t >= 0
%        0 if t <  0 

% therefore  step can be written to be A+B . u(t)

% z = orthogonal distance of arbitrary point from edge
% z = y . cos(Th) - x . sin(Th) - p

% now edge can be written as A+B . u(z)

window = zeros(y_size, x_size);

%vector = [10, 20, pi/3, 2, 1, 1];

A = vector(1);
B = vector(2);
Th = vector(3);
p = vector(4);
w = vector(5);
s = vector(6);

for y = -(size(window, 1)-1)/2:(size(window, 1)-1)/2
    for x = -(size(window, 2)-1)/2:(size(window, 2)-1)/2
        
        z = (y * cos(Th)) - (x * sin(Th)) - p;
        z1 = z + w/2;
        z2 = z - w/2;
        
        if z1 >= 0
            u_z1 = 1;
        else
            u_z1 = 0;
        end
        
        if z2 >= 0
            u_z2 = 1;
        else
            u_z2 = 0;
        end
        
        %if (z <= w/2) && (z >= -w/2)
        %    u_z3 = 1;
        %else
        %    u_z3 = 0;
        %end
        
        window(y+(size(window, 1)-1)/2 + 1, x+(size(window, 2)-1)/2 + 1) = A + (B * u_z1) - (B * u_z2);
        %window(y+(size(window, 1)-1)/2 + 1, x+(size(window, 2)-1)/2 + 1) = A + (B * u_z3);
    end
end

% figure, image(window), colormap(gray);
% hold on;
% plot(ones(1, size(window,1))*(size(window,2)/2)+0.5, [1:size(window, 1)], '-r');
% plot([1:size(window, 2)], ones(1, size(window,2))*(size(window,1)/2), '-r');
% axis xy
% 
% figure, image(window2), colormap(gray);
% hold on;
% plot(ones(1, size(window2,1))*(size(window2,2)/2)+0.5, [1:size(window2, 1)], '-r');
% plot([1:size(window2, 2)], ones(1, size(window2,2))*(size(window2,1)/2), '-r');
% axis xy