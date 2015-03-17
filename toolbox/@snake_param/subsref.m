function val = subsref(p,index)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   SUBSREF Defines field name indexing for snake_param objects
%       VAL = SUBSREF(P, INDEX)
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


switch index.type
    case '()'
        switch index.subs{:}
            case 1
                val = p.slength;
            case 2
                val = p.range;
            case 3
                val = p.forward;
            case 4
                val = p.walkrate;
            case 5
                val = p.alpha;
            case 6
                val = p.beta;
            case 7
                val = p.gamma;
            case 8
                val = p.pointdist;
            case 10
                val = p.corrWeight;
            case 11
                val = p.blocked;
            case 12
                val = p.windowWidth;
            case 13
                val = p.windowHeight;
            case 14
                val = p.outputPlot;
            otherwise
                error('Index out of range')
        end
    case '.'
        switch index.subs
            case 'snakeLength'
                val = p.slength;
            case 'range'
                val = p.range;
            case 'forward'
                val = p.forward;
            case 'walkRate'
                val = p.walkrate;
            case 'alpha'
                val = p.alpha;
            case 'beta'
                val = p.beta;
            case 'gamma'
                val = p.gamma;
            case 'econs'
                val = p.Econs;
            case 'corrWeight'
                val = p.correlationWeight;
            case 'blocked'
                val = p.blocked;
            case 'windowWidth'
                val = p.windowWidth;
            case 'windowHeight'
                val = p.windowHeight;
            case 'outputPlot'
                val = p.outputPlot;
            case 'zerodb'
                val = p.zerodb;
            case 'harmonyNumber'
                val = p.harmonyNumber;
            case 'harmonicSet'
                val = p.harmonicSet;
            case 'relativeWindow'
                val = p.relativeWindow;
            case 'movingMean'
                val = p.movingMean;
            case 'internalEnergy'
                val = p.perrin;
            case 'windowOffset'
                val = p.windowOffset;
            otherwise
                error('Invalid field name')
        end
    case '{}'
        error('Cell array indexing not supported by snake_param objects')
end