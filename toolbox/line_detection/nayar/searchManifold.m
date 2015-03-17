function [detected, closest_ind, dist] = searchManifold(vector, projected_windowset, dist_threshold)


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


searchwindowsize = (max(projected_windowset{end}, [], 1) - min(projected_windowset{end}, [], 1)) / 2;

range = [min(projected_windowset{1}(:,1)), max(projected_windowset{1}(:,1)),...
         min(projected_windowset{1}(:,2)), max(projected_windowset{1}(:,2)),...
         min(projected_windowset{1}(:,3)), max(projected_windowset{1}(:,3))];

%dist_threshold = 2;

for i = 1:numel(projected_windowset)
    
    whole_dist = zeros(size(projected_windowset{i}, 1), 1);
    
    subset = projected_windowset{i}(:,1) >= range(1) & projected_windowset{i}(:,1) <= range(2) &...
             projected_windowset{i}(:,2) >= range(3) & projected_windowset{i}(:,2) <= range(4) &...
             projected_windowset{i}(:,3) >= range(5) & projected_windowset{i}(:,3) <= range(6);
         
%    subset_dist = sqrt(sum((projected_windowset{i}(subset, :) - repmat(vector, sum(subset), 1)).^2, 2));

    subset_dist = sqrt(sum((projected_windowset{i}(subset, :) - vector(ones(sum(subset), 1), :)).^2, 2)); 
    
    if isempty(subset_dist)
        error(['Search window empty at level ' num2str(i)]);
    end
    
    whole_dist(subset) = subset_dist;
    whole_dist(~subset) = max(subset_dist)+1;
    
    [temp, closest_ind] = min(whole_dist);
    
    %if min(subset_dist) >= dist_threshold
    %    i = 5;
    %    closest_ind = -1;
    %    dist = min(subset_dist);
    %else
        range = [projected_windowset{i}(closest_ind,1) - searchwindowsize(1), projected_windowset{i}(closest_ind,1) + searchwindowsize(1),...
                 projected_windowset{i}(closest_ind,2) - searchwindowsize(2), projected_windowset{i}(closest_ind,2) + searchwindowsize(2),...
                 projected_windowset{i}(closest_ind,3) - searchwindowsize(3), projected_windowset{i}(closest_ind,3) + searchwindowsize(3)];
        
        searchwindowsize = searchwindowsize / 2;
        
        if sum(searchwindowsize < min(subset_dist)) > 0
            searchwindowsize(searchwindowsize < min(subset_dist)) = min(subset_dist);
        end
    %end
    
    %figure, plot3(projected_windowset{i}(~subset,1), projected_windowset{i}(~subset,2), projected_windowset{i}(~subset,3), '.r');
    %hold on;
    %plot3(projected_windowset{i}(subset,1), projected_windowset{i}(subset,2), projected_windowset{i}(subset,3), '.g');
    %plot3(vector(1), vector(2), vector(3), '.b');
    %plot3(projected_windowset{i}(closest_ind,1), projected_windowset{i}(closest_ind,2), projected_windowset{i}(closest_ind,3), '.k');
    %hold off;
end

if closest_ind ~= -1
    detected = projected_windowset{end}(subset(closest_ind), :);
    dist = min(subset_dist);
else
    detected = -1;
end