function [data2, gt2] = evenClasses(data, gt, number)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   EVENCLASSES Evens the number of classes in a data set
%       [DATA2, GT2] = EVENCLASSES(DATA, GT, NUMBER) returns a data set 
%       with ground truths which is built up of an even number of samples 
%       from each class in DATA and GT. The number of samples is specified 
%       in NUMBER.
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


data2 = [];
gt2 = [];
for i = 1:size(gt, 2)
    pos = find(gt(:,i) == 1);
    if numel(pos) ~= 0
    data2 = [data2; data(pos(1:number),:)];
    gt2 = [gt2; gt(pos(1:number), :)];
    end
end

%pos1 = find(gt(:,1) == 1);
%pos2 = find(gt(:,2) == 1);
%data = [data(pos1(1:number),:); data(pos2(1:number),:)];
%gt = [gt(pos1(1:number),:); gt(pos2(1:number), :)];