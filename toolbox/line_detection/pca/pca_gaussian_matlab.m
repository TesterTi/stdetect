function result = pca_gaussian_matlab(convolved_images, gauss, filters)

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


for i = 1:size(convolved_images, 3)
    convolved_images(:,:,i) = convolved_images(:,:,i) - gauss.Mu(i);
end

window_Width = filters.window_Width;
window_Height = filters.window_Height;

inverted_covar = inv(gauss.Covar.^2);

result = ones(size(convolved_images, 1), size(convolved_images, 2));
for i = floor(window_Height/2)+1:size(convolved_images,1)-floor(window_Height/2)
    for j = floor(window_Width/2)+1:size(convolved_images,2)-floor(window_Width/2)
        
        x = squeeze(convolved_images(i,j,:))';
        
        r_sq = diag(x*inverted_covar*x');
        
        result(i,j) = exp((-1/2)*r_sq);
    end
end