function val = get(p,prop_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   GET Get snake_param property from the specified object
%      VAL = GET(P, PROP_NAME) Get snake_param property from the field
%      specified in PROP_NAME in object P and return the value VAL.
%      Property names are: ######################
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


switch prop_name
    case 'SnakeLength'
        val = p.slength;
    case 'Forward'
        val = p.forward;
    case 'WalkRate'
        val = p.walkrate;
    case 'Alpha'
        val = p.alpha;
    case 'Beta'
        val = p.beta;
    case 'Gamma'
        val = p.gamma;
    case 'PointDist'
        val = p.dm;
    case 'CorrWeight'
        val = p.correlationWeight;
    case 'Restricted'
        val = p.blocked;
    case 'WindowWidth'
        val = p.windowWidth;
    case 'Windowheight'
        val = p.windowHeight;
    case 'OutputPlot'
        val = p.outputPlot;
    case 'Range'
        val = p.range;
    case 'InternalEnergy'
        val = p.perrin;
    case 'WindowOffset'
        val = p.windowOffset;
    otherwise
        error([prop_name ,'Is not a valid snake_param property'])
end