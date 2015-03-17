function [convoluted_images] = pca_convolution_matlab(im, filters)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   PCA_GAUSSIAN_MATLAB Todo: description
%       [IMG1, IMG2] = PCA_GAUSSIAN_MATLAB(I, NET) 
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

convoluted_images = zeros(size(im, 1), size(im, 2), size(filters.templates, 3));

for i = (filters.window_Height-1)/2+1:size(im,1)-(filters.window_Height-1)/2
    for j = (filters.window_Width-1)/2+1:size(im,2)-(filters.window_Width-1)/2
        
        %window =
        %im(i-(filters.window_Width-1)/2:i+(filters.window_Width-1)/2,
        %j-(filters.window_Height-1)/2:j+(filters.window_Height-1)/2);
        window = im(i-floor(filters.window_Height/2):i+floor(filters.window_Height/2), j-floor(filters.window_Width/2):j+floor(filters.window_Width/2));
        
        for k = 1:size(convoluted_images, 3)
            convoluted_images(i,j,k) = sum(sum(window .* filters.templates(:,:,k)));
        end
    end
end