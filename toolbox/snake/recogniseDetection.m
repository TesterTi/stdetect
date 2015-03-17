function [fstr, detectionTypeCounts] = recogniseDetection(f, fundamentals, detectionTypeCounts, gt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	RECOGNISEDETECTION identifies the type of target 
%       [FSTR, DETECTCONFMATRIX] = RECOGNISEDETECTION(DB, FUNDAMENTALS, ...
%               DETECTCONFMATRIX, GT) returns the id strings and the count 
%       of each detection type specified in the database DB. The 
%       fundamental frequencies found are specified in the vector 
%       FUNDAMENTALS. The current detection confusion matrix to be updated 
%       is passed in DETECTCONFMATRIX which is updated if the optional 
%       argument ground truth data GT is passed.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2007, 2010 Thomas Lampert
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


fstr = cell(1, numel(fundamentals));
for i = 1:numel(fundamentals)
    [fstr{i}, index] = getType(f, fundamentals(i));
    
    if index ~= -1
        detectionTypeCounts(gt,index) = detectionTypeCounts(gt,index)+1;
    else
        detectionTypeCounts(gt, end-1) = detectionTypeCounts(gt, end-1)+1;
    end
end