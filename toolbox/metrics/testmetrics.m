function [results, line_location] = testmetrics(detection, template)

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


allowedDistance = 5;

line_location = line_location_accuracy(detection, template);

detected = 0;
diff = 0;
falsepositive = 0;
cumulative_sum_gt = 0;
for time = 1:size(detection, 1)
    [sind] = find(detection(time,:) > 0);
    [tind] = find(template(time,:) > 0);

    cumulative_sum_gt = cumulative_sum_gt + numel(tind);
    
    if ~isempty(sind)
        
        s_index = false(1, numel(sind)); % keeps record of which detections are true and within the allowed distance (for calculating the mean distance from detection)
        t_index = true(1, numel(tind));  % keeps record of which parts of the template have been detected
        
        for t = 1:numel(sind)
            if ~isempty(tind(t_index)) && min(abs(tind - sind(t))) <= allowedDistance
                detected = detected + 1;
                
                [dist, ind] = min(abs(tind - sind(t)));
                diff = diff + dist;
                
                t_index(ind) = 0;
                
                s_index(t) = 1;
            end
        end
        
        sind = sind(~s_index);
        
        falsepositive = falsepositive + numel(sind);
    end
end
if diff ~= 0
    diff = diff / detected;
else
    diff  = 0;
end
detected = detected / cumulative_sum_gt;

falsepositive = falsepositive/size(detection, 1);

results = [detected, diff, falsepositive];