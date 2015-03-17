function [result2] = reconstruct_Image_Parametric(distance_map, index, manifolds, pcvec, trainingwindowsets, dist_threshold)

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


x_size = 13;
y_size = x_size;

mask = diskmask(x_size, y_size);
num_mask_elements = numel(mask(mask > 0));

%result1 = zeros(size(image));
result2 = zeros(size(distance_map));

tic
%fprintf('Performing detection within image - size: %d x %d...\n', size(image,2), size(image,1));
%fprintf('Current Location: ');

% use for Nayar model
%for i = ((y_size-1)/2)+1:size(distance_map, 1)-((y_size-1)/2)
%    for j = ((x_size-1)/2)+1:size(distance_map, 2)-((x_size-1)/2)

% use for bar model
for i = x_size+1:size(distance_map, 2)-x_size
    for j = y_size+1:size(distance_map, 1)
        
        %fprintf('x: %4d, y: %4d', j, i);
        
        % Extract window around current pixel location
        
        % use for Nayar model
        %window = image(i-((y_size-1)/2): i+((y_size-1)/2), j-((x_size-1)/2): j+((x_size-1)/2));

        % use for bar model
        window = image(j-y_size+1:j, i-x_size+1:i+x_size-1);
        
        % Normalise the window and projecting onto principal components
        %[vector, mu, v] = normaliseVector(reshape(window(mask > 0), 1, num_mask_elements));
        
        %vector = vector * pcvec;
        
        %if v > 
            % Search for closest feature in manifold
            %[detected, closest_index, dist] = searchManifold(vector, manifolds, dist_threshold);
        %else
        %    closest_index = -1;
        %end
        closest_index = index(i,j); 
        
        if distance_map(i,j) < dist_threshold
            % Pick out closest detected vector from manifold
              detectedVector = trainingwindowsets{5}(closest_index, :);
            
            % Restore normalisation parameters
              %detectedVector = reverseNormalise(detectedVector, mu, v);
            
            % Convert vector to window shape
              detectedWindow = restoreWindowShape(detectedVector, mask);
            
            % Add feature to result image
              %result1(i,j) = result1(i,j) + detectedWindow(((y_size-1)/2), ((x_size-1)/2));
            %result1(i,j) = 1;
            detectedWindow(detectedWindow < max(max(detectedWindow))) = 0;
 
            % use for Nayar model
            %result2(i-((y_size-1)/2): i+((y_size-1)/2), j-((x_size-1)/2): j+((x_size-1)/2)) = result2(i-((y_size-1)/2): i+((y_size-1)/2), j-((x_size-1)/2): j+((x_size-1)/2)) + detectedWindow;
 
            % use for bar model
            result2(j-y_size+1:j, i-x_size+1:i+x_size-1) = detectedWindow;
        end
        
        %fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    end
end
%fprintf('finished\n');
toc

result2(result2 > 0) = 1;