function mask = diskmask(x_size, y_size)

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

mask = zeros(y_size, x_size);

for y = -(size(mask, 1)-1)/2:(size(mask, 1)-1)/2
    for x = -(size(mask, 2)-1)/2:(size(mask, 2)-1)/2
        
        z = sqrt((y/(size(mask,1)/2))^2 + (x/(size(mask,2)/2))^2);
        
        if abs(z) < 0.9231
            u_z = 1;
        else
            u_z = 0;
        end
        
        mask(y+(size(mask, 1)-1)/2 + 1, x+(size(mask, 2)-1)/2 + 1) = u_z;
    end
end

%figure, imagesc(mask), colormap(gray)
%title('Window Mask');