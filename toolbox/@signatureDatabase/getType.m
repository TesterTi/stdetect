function [val, index] = getType(db, fundamentalfound)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   GETTYPE todo:description
%       VAK = GETTYPE(DB, FUNDAMENTALFOUND)
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Copyright 2008, 2010 Thomas Lampert
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


val = '';
for signatureIndex = 1:numel(db.database)
    if (fundamentalfound <= db.database{signatureIndex}.fundamental * (1 + (db.database{signatureIndex}.searchRange/100))) && (fundamentalfound >= db.database{signatureIndex}.fundamental * (1 - (db.database{signatureIndex}.searchRange/100)))
        val = [db.database{signatureIndex}.type ' @ ' num2str(fundamentalfound) ' Hz'];
        index = signatureIndex;
    end
end

if isempty(val)
    val = ['Unknown Type @ ' num2str(fundamentalfound, '%5.1f') ' Hz'];
    index = -1;
end