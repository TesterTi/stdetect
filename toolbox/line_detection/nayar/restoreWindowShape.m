function window = restoreWindowShape(vector, mask)


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



num_mask_elements = numel(mask(mask > 0));
x_size = size(mask, 2);
y_size = size(mask, 1);

if numel(vector) == num_mask_elements
    window = zeros(y_size, x_size);
    count = 1;
    for j = 1:x_size
        pos = find(mask(:,j) > 0);
        
        if ~isempty(pos)
            window(pos(1):pos(numel(pos)),j) = vector(count:count+numel(pos)-1);
            count = count + numel(pos);
        end
    end
    
    %figure, imagesc(window), colormap(gray);
else
    %figure, imagesc(reshape(vector, y_size, x_size)), colormap(gray);
    window = reshape(vector, y_size, x_size);
end