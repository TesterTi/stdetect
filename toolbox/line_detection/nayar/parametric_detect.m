function [distancemap, result, index] = parametric_detect(image, manifolds, pcvec, trainingwindowsets, mask)

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

x_size = size(mask, 1);
y_size = x_size;

num_mask_elements = numel(mask(mask > 0));

result = ones(size(image))*Inf;
distancemap = zeros(size(image));
index = zeros(size(image));

%fprintf('Performing detection within image - size: %d x %d...\n', size(image,2), size(image,1));
%fprintf('Current Location: ');

% use for Nayar model
%for i = ((y_size-1)/2)+1:size(image, 1)-((y_size-1)/2)
%    for j = ((x_size-1)/2)+1:size(image, 2)-((x_size-1)/2)

% use for bar model
for i = x_size+1:size(image, 2)-x_size
    for j = y_size+1:size(image, 1)
        
        
        %fprintf('x: %4d, y: %4d', j, i);
        
        % Extract window around current pixel location
        
        % use for Nayar model
        %window = image(i-((y_size-1)/2): i+((y_size-1)/2), j-((x_size-1)/2): j+((x_size-1)/2));

        % use for bar model
        window = image(j-y_size+1:j, i-x_size+1:i+x_size-1);
        
        % Normalise the window and projecting onto principal components
        [vector, mu, v] = normaliseVector(reshape(window(mask > 0), 1, num_mask_elements));
        
        vector = vector * pcvec;
        
        %if v > 
            % Search for closest feature in manifold
            %[detected, closest_index, dist] = searchManifold(vector, manifolds, dist_threshold);
            [~, closest_index, dist] = searchManifold(vector, manifolds);
        %else
        %    closest_index = -1;
        %end
        
        if closest_index ~= -1
            % Pick out closest detected vector from manifold
              detectedVector = trainingwindowsets{end}(closest_index, :);
            
            % Restore normalisation parameters
              %detectedVector = reverseNormalise(detectedVector, mu, v);
              detectedVector(detectedVector == min(detectedVector)) = 0;
              detectedVector(detectedVector == max(detectedVector)) = 1;
            
            % Convert vector to window shape
              detectedWindow = restoreWindowShape(detectedVector, mask);
            
            % Add feature to result image
              
              % use for Nayar model
              %result2(i-((y_size-1)/2): i+((y_size-1)/2), j-((x_size-1)/2): j+((x_size-1)/2)) = result2(i-((y_size-1)/2): i+((y_size-1)/2), j-((x_size-1)/2): j+((x_size-1)/2)) + detectedWindow;
              %existing = result2(i-((y_size-1)/2): i+((y_size-1)/2), j-((x_size-1)/2): j+((x_size-1)/2));
              
              % use for bar model
              existing = result(j-y_size+1:j, i-x_size+1:i+x_size-1);
              
              detectedWindow = detectedWindow * dist;
              detectedWindow(detectedWindow == 0) = Inf;
              
              %detectedWindow((existing ~= -1) & (existing < detectedWindow)) = existing((existing ~= -1) & (existing < detectedWindow));
              detectedWindow(existing < detectedWindow) = existing(existing < detectedWindow);
              
              result(j-y_size+1:j, i-x_size+1:i+x_size-1) = detectedWindow;
        end
        
        distancemap(j,i) = dist;
        index(j,i) = closest_index;
        %fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    end
end
%fprintf('finished\n');

%result(result > 0) = 1;

figure, imagesc(distancemap), colormap(gray);
title('Distance from Manifold');


%figure, imagesc(result), colormap(gray);
%title('Detected Features');